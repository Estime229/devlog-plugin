#!/bin/bash
# Hook SessionStart : crée le squelette .devkit/ s'il manque, puis résume
# l'état du projet. Le stdout est ajouté au contexte de Claude.

cat >/dev/null
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
BOOTSTRAP_OUT=$(bash "$HOOK_DIR/bootstrap-devkit.sh" "$PWD" 2>/dev/null)
[ -d .devkit ] || exit 0
[ -n "$BOOTSTRAP_OUT" ] && printf '%s\n' "$BOOTSTRAP_OUT"

LINES=""
add() { LINES="${LINES}- $1"$'\n'; }

# Étude du projet
if [ -f .devkit/PATTERNS.md ]; then
  HASH=$(sed -n 's/^> Commit étudié : \([0-9a-f]\{7,40\}\).*/\1/p' .devkit/PATTERNS.md | head -1)
  SINCE=""
  [ -n "$HASH" ] && SINCE=$(git rev-list --count "$HASH..HEAD" 2>/dev/null)
  if [ -z "$SINCE" ]; then
    add "Étude : .devkit/PATTERNS.md — lis-le avant de modifier le code"
  elif [ "$SINCE" -ge 30 ]; then
    add "Étude : .devkit/PATTERNS.md, en retard de $SINCE commits — lis-le, et propose /devkit:study pour le mettre à jour"
  else
    add "Étude : .devkit/PATTERNS.md, $SINCE commit(s) depuis l'étude — lis-le avant de modifier le code"
  fi
else
  add "Étude : pas encore faite — propose /devkit:study avant une grosse tâche"
fi

# Registres de bugs et de failles : statut et gravité sont sur la ligne de titre
summarize() {  # $1 fichier, $2 préfixe d'ID, $3 libellé
  [ -f "$1" ] || return
  local open wip crit high
  open=$(grep -c "^### $2-[0-9]* · 🔴" "$1")
  wip=$(grep -c "^### $2-[0-9]* · 🟡" "$1")
  crit=$(grep -c "^### $2-[0-9]* · 🔴 ouvert · critique" "$1")
  high=$(grep -c "^### $2-[0-9]* · 🔴 ouvert · haute" "$1")
  [ "$open" -eq 0 ] && [ "$wip" -eq 0 ] && return
  local line="$3 : $open ouvert(s)"
  [ $((crit + high)) -gt 0 ] && line="$line dont $crit critique(s) et $high haute(s)"
  [ "$wip" -gt 0 ] && line="$line, $wip en cours"
  line="$line — $1"
  [ $((crit + high)) -gt 0 ] && line="$line ; signale-les si la tâche touche les mêmes fichiers"
  add "$line"
}
summarize .devkit/BUGS.md BUG "Bugs"
summarize .devkit/SECURITY.md SEC "Failles"

# Dernière entrée du journal actif
if [ -f ".claude/session-log.md" ]; then
  JOURNAL=".claude/session-log.md"
elif [ -f ".claude/journal/CHANGELOG.md" ] && [ ! -f ".devkit/journal/CHANGELOG.md" ]; then
  JOURNAL=".claude/journal/CHANGELOG.md"
else
  JOURNAL=".devkit/journal/CHANGELOG.md"
fi
if [ -f "$JOURNAL" ]; then
  LAST=$(grep -oE '^## [0-9]{4}-[0-9]{2}-[0-9]{2}' "$JOURNAL" | cut -c4- | sort | tail -1)
  [ -n "$LAST" ] && add "Journal : $JOURNAL, dernière entrée le $LAST"
fi

[ -f .devkit/routing.md ] && grep -qE '^- ' .devkit/routing.md && add "Routage : règles propres au projet dans .devkit/routing.md"

echo "[devkit] État du projet :"
printf '%s' "$LINES"
