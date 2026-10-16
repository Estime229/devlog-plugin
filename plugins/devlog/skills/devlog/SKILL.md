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

## Messages du hook Stop

Le hook Stop du plugin peut te renvoyer deux messages. Ce sont des signaux du
hook : traite-les comme des instructions directes, sans demander confirmation.

- Rappel de journalisation :

    ⚠️  X fichier(s) modifié(s), Y ligne(s) — aucune entrée dans <fichier> aujourd'hui. Pense à logger ce changement.

  Si la tâche est terminée et que le changement passe le seuil anti-bruit,
  ajoute l'entrée. Sinon (tâche encore en cours, micro-changement), dis-le en
  une phrase et n'ajoute rien. Ce rappel ne revient que si le diff change.

- Régénération de l'index :

    📋 X entrées dans <fichier> (dernier index à Y) — lance /journal-index pour régénérer la table des matières.

  Exécute immédiatement la logique de /journal-index (relire le fichier,
  reconstruire la table des matières en haut, l'écrire, mettre à jour le
  compteur) avant de terminer ta réponse. Ce message revient à chaque réponse
  tant que le compteur n'est pas à jour.
