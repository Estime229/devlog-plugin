---
description: Journalise les features/bugs significatifs avec contexte complet — dans .claude/session-log.md si présent, sinon dans .claude/journal/CHANGELOG.md
---

Avant de considérer une tâche terminée, vérifie si un fichier .claude/session-log.md
existe déjà dans ce projet (système d'audit NestJS/CQRS existant).

- Si .claude/session-log.md existe : ajoute-y l'entrée, dans la section du jour,
  en respectant le format déjà utilisé dans ce fichier.
- Sinon : utilise .claude/journal/CHANGELOG.md (crée-le avec son en-tête si
  besoin), section ## YYYY-MM-DD.

## Seuil anti-bruit

Ne logge que les changements significatifs : nouvelle fonctionnalité, correction
de bug, refactor touchant plusieurs fichiers, changement de dépendance ou de
config. Ignore les micro-changements (typo, formatting, commentaire, rename
mineur) — ne crée pas d'entrée pour ceux-ci.

## Format d'entrée

Utilise un titre + sous-titre en gras, pas une liste à puce compacte :

```
### [ICÔNE] [TYPE] — Titre court et descriptif
**Fichier(s)** : liste des fichiers concernés
**Problème** (pour un bug) ou **Contexte** (pour une feature) : une phrase
expliquant le pourquoi, compréhensible sans relire le code
**Cause** (pour un bug uniquement) : la cause racine identifiée
**Solution** / **Détail** : ce qui a été fait concrètement
```

Types : 🆕 FEATURE, 🐛 BUG, ♻️ REFACTOR, 🔧 CHORE, 📚 DOCS

Le titre doit être compréhensible seul, en un coup d'œil (pas "fix bug", mais
"Crash lors de l'upload de fichiers volumineux").

Ne demande pas confirmation, fais-le systématiquement selon ces critères.

## Régénération de l'index

Le hook Stop du plugin surveille le nombre d'entrées dans le journal actif. Quand
il affiche un message du type :

  📋 X entrées dans <fichier> (dernier index à Y) — lance /journal-index pour régénérer la table des matières.

exécute immédiatement la logique de /journal-index (relire le fichier, reconstruire
la table des matières en haut, l'écrire) avant de terminer ta réponse. Ne demande
pas confirmation — ce message est un signal du hook, traite-le comme une instruction
directe, pas comme une simple information.
