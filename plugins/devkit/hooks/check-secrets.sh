#!/bin/bash
# Bloque les `git commit` lancés par Claude quand les changements contiennent
# un secret probable (format de clé connu) ou un fichier .env.
#
# Hook PreToolUse sur Bash : le code de sortie 2 bloque la commande et transmet
# stderr à Claude. Le message cite le fichier et le type de secret, jamais la
# valeur. Les commits faits par l'utilisateur dans son terminal ne passent pas
# par ce hook.

INPUT=$(cat)

# Seulement les commandes qui contiennent un git commit (git -c x=y commit, etc.)
echo "$INPUT" | grep -qE 'git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+commit([^-a-zA-Z]|$)' || exit 0

CWD=$(echo "$INPUT" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
cd "${CWD:-${CLAUDE_PROJECT_DIR:-.}}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# `git add … && git commit` ou `commit -a` : l'index n'est pas encore à jour au
# moment du hook, donc on regarde aussi les changements non indexés et les
# nouveaux fichiers. Sinon, seulement ce qui est indexé.
if echo "$INPUT" | grep -qE 'git[[:space:]]+add|commit[^"]*[[:space:]](-[a-zA-Z]*a[a-zA-Z]*|--all)([[:space:]]|\\|"|$)'; then
  DIFF_ARGS="HEAD"
  NEW_FILES=$(git ls-files --others --exclude-standard)
else
  DIFF_ARGS="--cached"
  NEW_FILES=""
fi
git rev-parse --verify HEAD >/dev/null 2>&1 || DIFF_ARGS="--cached"

# Lignes ajoutées, préfixées par leur fichier : "fichier<TAB>ligne"
ADDED=$(
  git diff $DIFF_ARGS -U0 --no-color 2>/dev/null \
    | awk '/^\+\+\+ /{f=substr($0,7); next} /^\+/{print f "\t" substr($0,2)}'
  if [ -n "$NEW_FILES" ]; then
    echo "$NEW_FILES" | tr '\n' '\0' | xargs -0 awk '{print FILENAME "\t" $0}' 2>/dev/null
  fi
)

FINDINGS=""
add_finding() { FINDINGS="${FINDINGS}  - $1 : $2"$'\n'; }

while IFS='|' read -r LABEL REGEX; do
  [ -z "$LABEL" ] && continue
  for F in $(echo "$ADDED" | grep -E -e "$REGEX" | cut -f1 | sort -u); do
    add_finding "$F" "$LABEL"
  done
done <<'PATTERNS'
clé privée|-----BEGIN ([A-Z]+ )*PRIVATE KEY-----
clé d'accès AWS|AKIA[0-9A-Z]{16}
token GitHub|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{22,}
token GitLab|glpat-[A-Za-z0-9_-]{20,}
token Slack|xox[abprs]-[A-Za-z0-9-]{10,}
clé Stripe live|(sk|rk)_live_[0-9A-Za-z]{20,}
clé API Google|AIza[0-9A-Za-z_-]{35}
clé Anthropic|sk-ant-[A-Za-z0-9_-]{20,}
clé OpenAI|sk-(proj-)?[A-Za-z0-9]{40,}
clé Mailgun|key-[0-9a-f]{32}
PATTERNS

# Fichiers .env ajoutés ou modifiés (les modèles .env.example & co sont permis)
CHANGED=$( (git diff $DIFF_ARGS --name-only --diff-filter=AM 2>/dev/null; echo "$NEW_FILES") | sort -u)
for F in $(echo "$CHANGED" | grep -E '(^|/)\.env(\.[^/]+)?$' | grep -vE '\.(example|sample|template|dist)$'); do
  add_finding "$F" "fichier d'environnement"
done

[ -z "$FINDINGS" ] && exit 0

cat >&2 <<EOF
🔒 devkit : commit bloqué — secret probable dans les changements :
${FINDINGS}
Ne committe pas ces valeurs : déplace-les dans une variable d'environnement non
commitée, retire les fichiers .env de l'index (git rm --cached <fichier>) et
ajoute-les au .gitignore. Un secret déjà poussé reste dans l'historique : il
faut aussi le révoquer.

Si c'est un faux positif (clé de test factice, par exemple), explique-le à
l'utilisateur : il peut committer lui-même depuis son terminal, ce contrôle ne
s'applique qu'aux commandes lancées par Claude. N'essaie pas de le contourner.
EOF
exit 2
