---
description: Analyse le git diff en cours et ajoute une entrée au journal actif (session-log.md ou CHANGELOG.md)
---

Détecte le fichier journal actif du projet, dans cet ordre :
`.claude/session-log.md` s'il existe ; sinon `.claude/journal/CHANGELOG.md`
s'il existe et que `.devkit/journal/CHANGELOG.md` n'existe pas (ancien
emplacement) ; sinon `.devkit/journal/CHANGELOG.md`, à créer avec son en-tête
si besoin.

Analyse `git diff` (fichiers modifiés, ajoutés, supprimés) et propose un résumé
au format suivant, avant de l'ajouter :

```
### [ICÔNE] [TYPE] — Titre court et descriptif
**Fichier(s)** : liste des fichiers concernés
**Problème** (pour un bug) ou **Contexte** (pour une feature) : une phrase
expliquant le pourquoi
**Cause** (pour un bug uniquement) : la cause racine identifiée
**Solution** / **Détail** : ce qui a été fait concrètement
**Décision technique** (si un choix d'implémentation méritait explication) :
l'option retenue, l'alternative envisagée et pourquoi elle a été écartée
**Blocage** (si un obstacle a été rencontré) : la difficulté, son impact, et
comment elle a été résolue (ou son état si elle ne l'est pas encore)
**Reste à faire** (si des points restent ouverts après ce changement) :
- [ ] un point en attente par case à cocher
```

Types : 🆕 FEATURE, 🐛 BUG, 🔒 SECURITY, ♻️ REFACTOR, 🔧 CHORE, 📚 DOCS

Si l'entrée corrige un bug de `.devkit/BUGS.md` ou une faille de
`.devkit/SECURITY.md`, ajoute sous le titre la ligne `**Bug** : BUG-xxx` ou
`**Faille** : SEC-xxx`, et clôture-le après l'écriture (skills `devkit:bug`
et `devkit:security`).

N'ajoute **Décision technique**, **Blocage** et **Reste à faire** que quand ils
apportent une information réelle pour ce changement précis — ne les inclus pas
vides ou par automatisme, dans le même esprit que le seuil anti-bruit du plugin.

Affiche le résumé proposé à l'utilisateur avant de l'écrire dans le fichier.
Ajoute l'entrée sous la section de la date du jour (crée-la si elle n'existe pas).
