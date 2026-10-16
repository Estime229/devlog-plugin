#!/bin/bash
# Seuil anti-bruit + régénération automatique de l'index
#
# Hook Stop : le stdout n'est pas transmis à Claude. Les messages passent par
# stderr avec le code de sortie 2, qui empêche l'arrêt et fait continuer Claude.

INPUT=$(cat)

# Claude continue déjà à cause de ce hook : on le laisse s'arrêter (anti-boucle)
if echo "$INPUT" | grep -qE '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

# Le cwd de la session peut avoir changé (cd dans un sous-dossier)
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# Détecte quel journal utiliser
if [ -f ".claude/session-log.md" ]; then
  JOURNAL=".claude/session-log.md"
else
  JOURNAL=".claude/journal/CHANGELOG.md"
fi

[ -f "$JOURNAL" ] || exit 0

MESSAGES=""

# Changements non commités, hors .claude/ (le journal lui-même ne compte pas)
LINES_CHANGED=$(git diff --shortstat HEAD -- ':!.claude' 2>/dev/null | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | grep -oE '[0-9]+' | awk '{sum+=$1} END {print sum+0}')
FILES_COUNT=$(git diff --name-only HEAD -- ':!.claude' 2>/dev/null | wc -l | tr -d ' ')

# Nouveaux fichiers : git diff HEAD ne les voit pas
UNTRACKED_COUNT=$(git ls-files --others --exclude-standard -- ':!.claude' 2>/dev/null | wc -l | tr -d ' ')
if [ "$UNTRACKED_COUNT" -gt 0 ]; then
  UNTRACKED_LINES=$(git ls-files -z --others --exclude-standard -- ':!.claude' | xargs -0 cat 2>/dev/null | wc -l | tr -d ' ')
  LINES_CHANGED=$((LINES_CHANGED + UNTRACKED_LINES))
  FILES_COUNT=$((FILES_COUNT + UNTRACKED_COUNT))
fi

TODAY=$(date +%Y-%m-%d)

# Rappel si changement significatif (15 lignes OU 2 fichiers) sans entrée aujourd'hui.
# Une seule fois par état du diff, pour ne pas relancer Claude à chaque réponse.
if { [ "$LINES_CHANGED" -ge 15 ] || [ "$FILES_COUNT" -ge 2 ]; } && ! grep -q "$TODAY" "$JOURNAL"; then
  REMINDED_FILE=".claude/.journal-reminded"
  SIGNATURE="$TODAY $FILES_COUNT $LINES_CHANGED"
  if [ "$(cat "$REMINDED_FILE" 2>/dev/null)" != "$SIGNATURE" ]; then
    echo "$SIGNATURE" > "$REMINDED_FILE"
    MESSAGES="⚠️  $FILES_COUNT fichier(s) modifié(s), $LINES_CHANGED ligne(s) — aucune entrée dans $JOURNAL aujourd'hui. Pense à logger ce changement."
  fi
fi

# Régénération de l'index toutes les 5 entrées. Indépendant du diff : après un
# commit le diff est vide, mais l'index peut être en retard. Le compteur est mis
# à jour par /journal-index, une fois l'index réellement régénéré.
ENTRY_COUNT=$(grep -c "^### " "$JOURNAL")
LAST_INDEX_COUNT_FILE=".claude/.journal-index-count"
LAST_COUNT=0
[ -f "$LAST_INDEX_COUNT_FILE" ] && LAST_COUNT=$(tr -dc '0-9' < "$LAST_INDEX_COUNT_FILE")
LAST_COUNT=${LAST_COUNT:-0}

if [ $((ENTRY_COUNT - LAST_COUNT)) -ge 5 ]; then
  [ -n "$MESSAGES" ] && MESSAGES="$MESSAGES"$'\n'
  MESSAGES="${MESSAGES}📋 $ENTRY_COUNT entrées dans $JOURNAL (dernier index à $LAST_COUNT) — lance /journal-index pour régénérer la table des matières."
fi

if [ -n "$MESSAGES" ]; then
  echo "$MESSAGES" >&2
  exit 2
fi
