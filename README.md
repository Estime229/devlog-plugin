# devlog-plugin

Plugin Claude Code interne 41Devs : journalisation automatique des features,
bugs, refactors et chores dans un journal Markdown, avec seuil anti-bruit,
table des matières auto-régénérée, génération de rapport journalier et suivi
des items en attente.

## Installation dans un projet

```bash
/plugin marketplace add Estime229/devlog-plugin
/plugin install devlog@devtools-41devs
```

## Activation automatique pour toute l'équipe

Ajoute dans `.claude/settings.json` du projet :

```json
{
  "extraKnownMarketplaces": {
    "devtools-41devs": {
      "source": { "source": "github", "repo": "Estime229/devlog-plugin" }
    }
  },
  "enabledPlugins": {
    "devlog@devtools-41devs": true
  }
}
```

## Ce que fait le plugin

- **Skill `devlog`** : journalise automatiquement les changements
  significatifs (feature, bug, refactor) dans `.claude/session-log.md` (si
  présent) ou `.claude/journal/CHANGELOG.md`, sans qu'on ait à le demander.
- **Hook `Stop`** : après chaque tâche, vérifie si un changement significatif
  a été fait sans être loggé, et rappelle à Claude de régénérer l'index tous
  les 5 entrées.
- **Commande `/log`** : force manuellement une entrée à partir du `git diff`
  en cours.
- **Commande `/journal-index`** : régénère la table des matières en haut du
  journal.
- **Commande `/rapport`** : génère le rapport journalier complet (en-tête
  Développeur/Projet/Branche, tâches, décisions techniques, blocages,
  fichiers modifiés, reste à faire) à partir des entrées du jour — prêt à
  copier/envoyer, sans reconstruction manuelle.
- **Commande `/todo`** : parcourt tout le journal et liste les items « Reste
  à faire » encore non cochés, groupés par date et reliés à leur entrée
  d'origine, pour ne rien perdre entre deux sessions.

## Format d'une entrée

```
### [ICÔNE] [TYPE] — Titre court et descriptif
**Fichier(s)** : liste des fichiers concernés
**Problème** (pour un bug) ou **Contexte** (pour une feature) : le pourquoi
**Cause** (pour un bug uniquement) : la cause racine identifiée
**Solution** / **Détail** : ce qui a été fait concrètement
**Décision technique** (si applicable) : option retenue, alternative écartée
**Blocage** (si applicable) : difficulté, impact, résolution (ou état actuel)
**Reste à faire** (si applicable) : liste à puce des points en attente
```

Types : 🆕 FEATURE, 🐛 BUG, ♻️ REFACTOR, 🔧 CHORE, 📚 DOCS

Les trois derniers champs sont **conditionnels** — ils n'apparaissent que
quand ils apportent une information réelle sur ce changement précis, dans le
même esprit que le seuil anti-bruit du hook `Stop`. C'est ce qui permet à
`/rapport` et `/todo` de rester fiables : ils lisent ces champs tels quels,
sans avoir à deviner ce qui est significatif.

## Flux d'utilisation typique

1. Pendant la journée : le skill `devlog` journalise seul les changements
   significatifs (ou `/log` pour forcer une entrée précise).
2. À tout moment : `/todo` pour vérifier ce qui reste ouvert avant de passer
   à autre chose.
3. En fin de journée : `/rapport` pour générer le rapport à envoyer, et
   `/journal-index` si le hook `Stop` a signalé qu'il est temps de
   régénérer la table des matières.

## Mise à jour

Après modification, incrémente `version` dans
`plugins/devlog/.claude-plugin/plugin.json`, puis :

```bash
git add -A && git commit -m "vX.Y.Z: description du changement"
git push
```

## Validation avant publication

```bash
claude plugin validate .
```
