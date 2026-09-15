---
description: Liste tous les items "Reste à faire" non cochés du journal actif, groupés par date, avec leur entrée d'origine
---

Détecte le fichier journal actif du projet (`.claude/session-log.md` si
présent, sinon `.claude/journal/CHANGELOG.md`). S'il n'existe pas, préviens
l'utilisateur qu'il n'y a pas encore de journal — n'invente rien.

Parcours toutes les entrées (`### [ICÔNE] [TYPE] — Titre`) de tout le
fichier, du début à la fin, et pour chacune qui a un champ **Reste à faire**,
extrait chaque ligne `- [ ]` non cochée (ignore les lignes déjà `- [x]`).

## Format de sortie

Regroupe les items par section de date (`## YYYY-MM-DD`) d'origine, du plus
récent au plus ancien :

```
## Reste à faire — <N> item(s) ouvert(s)

### 2026-07-10
- [ ] Confirmer côté équipe backend le bug de persistance professionId — *Correction contrat spécial*
- [ ] Validation responsive/mobile de SingleFileField — *Correction contrat spécial*

### 2026-07-08
- [ ] ...
```

Chaque item référence en italique, après un tiret, le titre de l'entrée dont
il provient (sans son icône/type), pour retrouver le contexte facilement dans
le journal.

Si aucun item ouvert n'est trouvé, dis-le simplement — ne génère pas de
section vide.

## Marquer un item comme fait

Si l'utilisateur demande de cocher un ou plusieurs items de cette liste,
retrouve la ligne exacte dans le journal (par date + entrée d'origine
affichées) et remplace `- [ ]` par `- [x]` à cet endroit précis, sans modifier
le reste du fichier. Confirme quels items ont été cochés.
