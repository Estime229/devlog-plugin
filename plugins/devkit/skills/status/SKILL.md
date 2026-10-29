---
description: Tableau de bord devkit du projet — bugs et failles ouverts, fraîcheur de PATTERNS.md, dernières entrées du journal, règles de routage, et les prochaines actions conseillées.
disable-model-invocation: true
model: haiku
---

Affiche l'état devkit du projet, sans rien modifier. Lis seulement les fichiers
ci-dessous, pas le code du projet.

1. `.devkit/PATTERNS.md` : la ligne `Commit étudié`, puis
   `git rev-list --count <hash>..HEAD` pour le nombre de commits depuis. Si
   cette commande échoue, le commit n'existe plus : écris « commit introuvable »
   et conseille `/devkit:study full`.
2. `.devkit/BUGS.md` : `grep '^### BUG-'`.
3. `.devkit/SECURITY.md` : `grep '^### SEC-'` et la ligne
   `Dernier audit complet`.
4. Le journal actif (`.claude/session-log.md` s'il existe, sinon
   `.devkit/journal/CHANGELOG.md`, sinon l'ancien
   `.claude/journal/CHANGELOG.md`) : les 5 dernières entrées `### `.
5. `.devkit/routing.md` : les règles actives, hors commentaires.

Affiche ce format directement en Markdown, sans bloc de code autour et sans
rien ajouter avant :

```
## État devkit

**Étude** : PATTERNS.md au commit <hash>, <N> commits depuis
**Bugs** : <X> ouverts · <Y> en cours · <Z> corrigés
| ID | Gravité | Titre |
**Sécurité** : <X> failles ouvertes · dernier audit complet <date ou « aucun »>
| ID | Gravité | Titre |
**Journal** : les 5 dernières entrées, une par ligne
**Routage** : « modèles par défaut » ou les règles de routing.md

**À faire**
1 à 3 actions, les plus urgentes d'abord, chacune avec sa commande.
```

Les deux tableaux ne contiennent que les lignes 🔴 et 🟡, de la plus grave à la
moins grave. Les bugs et failles 🟢 ou ⚪ ne comptent que dans les totaux. S'il
n'y a aucune ligne à afficher, remplace le tableau par « aucun ».

Exemples d'actions : une faille critique ouverte (`/devkit:security fix
SEC-001`), un bug critique ou haut (`/devkit:bug fix BUG-002`), une étude en
retard de plus de 30 commits (`/devkit:study`), aucun audit complet
(`/devkit:security full`).

Un fichier absent s'affiche « pas encore créé », avec la commande qui le crée.
Si `.devkit/` n'existe pas du tout, dis qu'il se crée à l'ouverture de
session, et propose `/devkit:init` pour le poser tout de suite.
