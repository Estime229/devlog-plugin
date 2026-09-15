---
description: Génère/actualise une table des matières compacte en haut du journal (CHANGELOG.md ou session-log.md)
---

Détecte le fichier journal actif du projet (`.claude/session-log.md` si présent,
sinon `.claude/journal/CHANGELOG.md`).

Parcours toutes les entrées du fichier (format `### [ICÔNE] [TYPE] — Titre`) et
génère une table des matières compacte au format :

```
## Index
- 2026-09-15 · 🐛 BUG · [Crash lors de l'upload de fichiers volumineux](#crash-lors-de-lupload-de-fichiers-volumineux)
- 2026-09-15 · 🆕 FEATURE · [Filtre par statut sur la liste des tâches](#filtre-par-statut-sur-la-liste-des-tâches)
```

Place cette table juste après l'en-tête du fichier (titre + description), avant
la première entrée datée. Si un index existe déjà, remplace-le entièrement
plutôt que d'en ajouter un second (ne duplique jamais l'index).

Les ancres suivent la conversion standard Markdown (titre en minuscules, espaces
remplacés par des tirets, accents et ponctuation conservés tels que rendus par
GitHub/GitLab).

Trie l'index du plus récent au plus ancien.

Après régénération, mets à jour `.claude/.journal-index-count` avec le nombre
total d'entrées actuel.
