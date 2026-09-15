---
description: Analyse le git diff en cours et ajoute une entrée au journal actif (session-log.md ou CHANGELOG.md)
---

Détecte le fichier journal actif du projet (`.claude/session-log.md` si présent,
sinon `.claude/journal/CHANGELOG.md`, à créer avec son en-tête si besoin).

Analyse `git diff` (fichiers modifiés, ajoutés, supprimés) et propose un résumé
au format suivant, avant de l'ajouter :

```
### [ICÔNE] [TYPE] — Titre court et descriptif
**Fichier(s)** : liste des fichiers concernés
**Problème** (pour un bug) ou **Contexte** (pour une feature) : une phrase
expliquant le pourquoi
**Cause** (pour un bug uniquement) : la cause racine identifiée
**Solution** / **Détail** : ce qui a été fait concrètement
```

Types : 🆕 FEATURE, 🐛 BUG, ♻️ REFACTOR, 🔧 CHORE, 📚 DOCS

Affiche le résumé proposé à l'utilisateur avant de l'écrire dans le fichier.
Ajoute l'entrée sous la section de la date du jour (crée-la si elle n'existe pas).
