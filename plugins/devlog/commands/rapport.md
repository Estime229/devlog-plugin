---
description: Génère le rapport journalier complet (format 41Devs) à partir des entrées du jour dans le journal actif
---

Détecte le fichier journal actif du projet (`.claude/session-log.md` si présent,
sinon `.claude/journal/CHANGELOG.md`).

Repère la section du jour (`## YYYY-MM-DD`) et récupère toutes les entrées
qu'elle contient (format `### [ICÔNE] [TYPE] — Titre`, avec leurs champs
**Fichier(s)**, **Contexte/Problème**, **Cause**, **Solution/Détail**,
**Décision technique**, **Blocage**, **Reste à faire**). S'il n'y a aucune
entrée aujourd'hui, préviens l'utilisateur et propose de lancer `/log` d'abord
plutôt que de générer un rapport vide.

## En-tête du rapport

Détermine :
- **Developpeur** : `git config user.name`, sinon demande à l'utilisateur
- **Projet** : champ `name` d'un `package.json`/`composer.json` à la racine si
  présent, sinon le nom du dossier courant, sinon demande
- **Branche** : `git branch --show-current`

## Construction

Génère un document au format suivant :

```
# Rapport Journalier — 41DEVS
> RAPPORT COURT — Projet Client

Developpeur : <développeur>
Date : <YYYY-MM-DD>
Projet : <projet>
Branche : <branche>
Soumission : fin de journée

---

## Taches realisees aujourd'hui

| # | Tache | Statut |
|---|-------|--------|
| 1 | <titre de l'entrée 1, sans l'icône/type> | <statut, voir ci-dessous> |

---

## Décisions techniques

### <titre court de la décision, dérivé du titre de l'entrée>
<contenu du champ **Décision technique** de l'entrée correspondante>

(une sous-section par entrée qui a un champ **Décision technique** ; omets
entièrement cette section « Décisions techniques » si aucune entrée du jour
n'en a)

---

## Blocages & Obstacles

| Blocage | Impact | Resolution |
|---------|--------|------------|
| <déduit du champ **Blocage**> | <déduit> | <déduit> |

(omets entièrement cette section si aucune entrée du jour n'a de champ
**Blocage**)

---

## Fichiers modifies

- <liste dédupliquée de tous les fichiers listés dans **Fichier(s)** des
  entrées du jour, un par ligne>

---

## Reste a faire

- [ ] <chaque item du champ **Reste à faire**, toutes entrées du jour
  confondues>
```

(omets entièrement la section « Reste a faire » si aucune entrée du jour n'en
a)

## Statut des tâches

Déduis le statut de chaque ligne du tableau à partir de son entrée d'origine :
- « Terminé » si l'entrée n'a ni **Blocage** non résolu ni **Reste à faire**
- « Terminé — remonté hors scope » (ou formulation équivalente) si le
  **Blocage** identifié n'est pas résolvable dans ce scope (ex. bug backend)
- « En cours » si des **Reste à faire** substantiels subsistent pour cette
  entrée

## Sortie

Affiche le rapport généré à l'utilisateur pour relecture avant toute autre
action. Ne l'écris dans un fichier que si l'utilisateur le demande
explicitement (par exemple dans `.claude/rapports/` avec un nom
`YYYY-MM-DD_<developpeur>_<projet>.md`, sur le modèle des rapports existants).
