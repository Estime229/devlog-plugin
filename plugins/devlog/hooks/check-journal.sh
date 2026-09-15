#!/bin/bash
# Seuil anti-bruit + régénération automatique de l'index

CHANGED_FILES=$(git diff --stat HEAD 2>/dev/null | tail -1)
LINES_CHANGED=$(git diff --shortstat HEAD 2>/dev/null | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | grep -oE '[0-9]+' | awk '{sum+=$1} END {print sum+0}')
FILES_COUNT=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')

# Seuil : au moins 15 lignes modifiées OU 2 fichiers touchés
if [ "$LINES_CHANGED" -lt 15 ] && [ "$FILES_COUNT" -lt 2 ]; then
  exit 0
fi

# Détecte quel journal utiliser
if [ -f ".claude/session-log.md" ]; then
  JOURNAL=".claude/session-log.md"
else
  JOURNAL=".claude/journal/CHANGELOG.md"
fi

TODAY=$(date +%Y-%m-%d)

# Rappel si aucune entrée aujourd'hui
if [ -f "$JOURNAL" ] && ! grep -q "$TODAY" "$JOURNAL"; then
  echo "⚠️  $FILES_COUNT fichier(s) modifié(s), $LINES_CHANGED ligne(s) — aucune entrée dans $JOURNAL aujourd'hui. Pense à logger ce changement."
  exit 0
fi

# Régénération de l'index tous les 5 entrées
if [ -f "$JOURNAL" ]; then
  ENTRY_COUNT=$(grep -c "^### " "$JOURNAL")
  LAST_INDEX_COUNT_FILE=".claude/.journal-index-count"
  LAST_COUNT=0
  [ -f "$LAST_INDEX_COUNT_FILE" ] && LAST_COUNT=$(cat "$LAST_INDEX_COUNT_FILE")

  DIFF=$((ENTRY_COUNT - LAST_COUNT))
  if [ "$DIFF" -ge 5 ]; then
    echo "📋 $ENTRY_COUNT entrées dans $JOURNAL (dernier index à $LAST_COUNT) — lance /journal-index pour régénérer la table des matières."
    echo "$ENTRY_COUNT" > "$LAST_INDEX_COUNT_FILE"
  fi
fi
