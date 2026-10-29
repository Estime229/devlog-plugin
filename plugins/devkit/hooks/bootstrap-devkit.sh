#!/bin/bash
# Crée le squelette .devkit/ s'il manque. N'écrase aucun fichier.
# Usage : bootstrap-devkit.sh [racine]
# stdout : une ligne par fichier créé, rien si déjà en place.

ROOT="${1:-${CLAUDE_PROJECT_DIR:-.}}"
cd "$ROOT" 2>/dev/null || exit 0

mkdir -p .devkit/journal 2>/dev/null || exit 0

if [ ! -f .devkit/.gitignore ]; then
  printf '.journal-index-count\n.journal-reminded\n' > .devkit/.gitignore
  echo "[devkit] créé .devkit/.gitignore"
fi

if [ ! -f .devkit/routing.md ]; then
  cat > .devkit/routing.md << 'EOF'
# Routage des agents devkit

Règles propres à ce projet. Elles priment sur les modèles par défaut des
agents ; sans règle ici, les défauts s'appliquent (voir le README devkit).

## Modèles

<!-- Exemple : - devkit:test-writer → opus (code de paiement critique) -->

## Règles

<!-- Exemple : - Toute modification de src/payment/ est suivie de /devkit:security diff -->
EOF
  echo "[devkit] créé .devkit/routing.md"
fi

# Un journal déjà ailleurs reste le journal actif : on n'en crée pas un second.
if [ -f .claude/session-log.md ]; then
  :
elif [ -f .claude/journal/CHANGELOG.md ]; then
  :
elif [ ! -f .devkit/journal/CHANGELOG.md ]; then
  cat > .devkit/journal/CHANGELOG.md << 'EOF'
# Journal

Changements significatifs du projet (features, bugs, refactors, sécurité),
par date. Tenu par devkit : /devkit:log, /devkit:journal-index.
EOF
  echo "[devkit] créé .devkit/journal/CHANGELOG.md"
fi
