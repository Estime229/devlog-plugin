# devkit

Plugin Claude Code interne 41Devs pour gérer les agents et les skills d'un
projet :

- des agents spécialisés, chacun sur le modèle adapté (opus, sonnet, haiku) ;
- une étude du projet qu'ils lisent avant de travailler ;
- une liste des bugs et un audit de sécurité tenus à jour ;
- un journal automatique des features, bugs et refactors ;
- un blocage des secrets avant chaque commit.

Anciennement `devlog`. Le dépôt garde son nom `41devs/devlog-plugin`.

## Installation dans un projet

```bash
/plugin marketplace add 41devs/devlog-plugin
/plugin install devkit@devtools-41devs
```

Puis, dans le projet : `/devkit:init`, qui crée `.devkit/` et propose de
lancer la première étude.

## Activation automatique pour toute l'équipe

Ajoute dans `.claude/settings.json` du projet :

```json
{
  "extraKnownMarketplaces": {
    "devtools-41devs": {
      "source": { "source": "github", "repo": "41devs/devlog-plugin" }
    }
  },
  "enabledPlugins": {
    "devkit@devtools-41devs": true
  }
}
```

## Migration depuis devlog

Le champ `renames` de `marketplace.json` réécrit automatiquement
`devlog@devtools-41devs` en `devkit@devtools-41devs` dans les settings des
projets. Chaque utilisateur doit seulement lancer une fois, après la mise à
jour de la marketplace :

```bash
/plugin install devkit@devtools-41devs
```

Les commandes s'appellent maintenant `/devkit:log` et `/devkit:journal-index`.

Les fichiers de devkit vivent dans `.devkit/` à la racine du projet, et non
plus dans `.claude/`. Claude Code protège `.claude/` : chaque écriture y
demande une approbation manuelle, et elle est refusée en mode non interactif
(`claude -p`), même avec une règle de permission. Un journal existant dans
`.claude/journal/CHANGELOG.md` reste utilisé tant qu'il n'est pas déplacé ;
`/devkit:init` propose de le migrer :

```bash
mkdir -p .devkit && git mv .claude/journal .devkit/journal
```

## Agents

| Agent | Modèle | Rôle | Accès |
|---|---|---|---|
| `devkit:feature-dev` | opus | Nouvelles fonctionnalités, refactors sur plusieurs fichiers | complet |
| `devkit:debugger` | opus | Reproduit un bug, trouve sa cause, le corrige si c'est local et sûr | complet |
| `devkit:security-auditor` | opus | Audit de sécurité justifié par le code | lecture seule |
| `devkit:test-writer` | sonnet | Écrit et lance les tests ; signale les bugs sans toucher au code | complet |
| `devkit:reviewer` | sonnet | Relit les changements en les comparant aux conventions du projet | lecture seule |
| `devkit:explorer` | haiku | Recherche rapide dans le code | lecture seule |
| `devkit:scribe` | haiku | Met en forme le journal, son index, les bugs et les failles | fichiers `.devkit/` |

Chaque agent termine par un rapport au même format (`## Rapport — <agent>`),
que la session principale lit pour enchaîner l'étape suivante. La session
principale garde la main : les agents ne s'appellent pas entre eux, sauf pour
déléguer une recherche à `explorer`.

### Changer les modèles pour un projet

Écris tes règles dans `.devkit/routing.md` (créé par `/devkit:init`), par
exemple « devkit:test-writer → opus » pour un projet critique. Le skill
`orchestrate` le lit et passe le modèle demandé à chaque appel.

## Skills

| Commande | Rôle | Déclenchement |
|---|---|---|
| `orchestrate` | Décide quand déléguer et à quel agent ; enchaîne explorer → feature-dev → test-writer → reviewer → audit si zone sensible | automatique |
| `/devkit:init` | Crée `.devkit/`, migre l'ancien journal, propose de relier `CLAUDE.md` et de lancer l'étude | manuel |
| `/devkit:study [full]` | Étudie le projet et écrit `.devkit/PATTERNS.md` ; opus, contexte séparé ; relancé, il ne lit que les nouveaux commits | manuel ou proposé |
| `/devkit:bug …` | Liste des bugs : enregistrer, `list`, `fix BUG-xxx` (debugger puis test-writer), `close BUG-xxx` | manuel et automatique |
| `/devkit:security …` | Audit `diff`, `full` ou d'un chemin ; `list`, `fix SEC-xxx`, `close SEC-xxx` | manuel, ou après une zone sensible |
| `/devkit:review [chemin]` | Relecture des changements par le reviewer, puis corrections si tu acceptes | manuel ou automatique |
| `/devkit:status` | Tableau de bord : étude, bugs, failles, journal, routage, prochaines actions ; tourne sur haiku | manuel |
| `devlog` | Journalise les changements significatifs | automatique |
| `/devkit:log` | Force une entrée de journal à partir du `git diff` | manuel |
| `/devkit:journal-index` | Régénère la table des matières du journal ; agent scribe (haiku), contexte séparé | manuel, ou sur signal du hook |

Une correction journalisée en 🐛 BUG ou 🔒 SECURITY clôture le bug ou la faille
correspondante, avec un lien vers l'entrée du journal.

## Hooks

- **Démarrage de session** : ajoute au contexte de Claude un résumé de l'état
  du projet (étude à jour ou en retard, bugs et failles ouverts, dernière
  entrée du journal). Silencieux si le projet n'a pas de `.devkit/`.
- **Anti-secrets** (avant chaque `git commit` lancé par Claude) : bloque le
  commit si les lignes ajoutées contiennent une clé privée ou un token au
  format connu (AWS, GitHub, GitLab, Slack, Stripe, Google, Anthropic, OpenAI,
  Mailgun), ou si un fichier `.env` est ajouté ou modifié (`.env.example` et
  ses variantes sont permis). Le message cite le fichier et le type de secret,
  jamais sa valeur. Les mots de passe en clair sans format reconnaissable ne
  sont pas détectés : c'est le rôle de `/devkit:security`. En cas de faux
  positif, l'utilisateur committe depuis son terminal, où le hook ne
  s'applique pas.
- **Fin de réponse** : rappelle à Claude de journaliser un changement
  significatif (au moins 15 lignes ou 2 fichiers, nouveaux fichiers compris)
  s'il n'y a aucune entrée du jour, et de régénérer l'index toutes les 5
  entrées.

## Fichiers créés dans les projets

| Fichier | Rôle | À commiter ? |
|---|---|---|
| `.devkit/PATTERNS.md` | Étude du projet | Oui, partagé avec l'équipe |
| `.devkit/BUGS.md` | Liste des bugs constatés | Oui |
| `.devkit/SECURITY.md` | Failles de sécurité et date du dernier audit complet | Oui (sans aucune valeur de secret) |
| `.devkit/journal/CHANGELOG.md` | Journal | Oui |
| `.devkit/routing.md` | Modèles propres au projet | Oui |
| `.devkit/.gitignore` | Ignore les deux compteurs ci-dessous | Oui |
| `.devkit/.journal-index-count`, `.devkit/.journal-reminded` | Compteurs internes du hook | Non (ignorés) |

## Coûts

- `/devkit:study` complet : 4,93 $ mesurés sur une API NestJS de 219 fichiers
  avant les optimisations (écriture en une passe, vérifications plafonnées,
  contexte séparé), environ la moitié attendue après ; les relances suivantes
  ne lisent que les nouveaux commits.
- `/devkit:journal-index` : 0,09 $ mesurés (haiku).
- `/devkit:status` tourne sur haiku. `/devkit:security full` est l'opération
  la plus chère : le skill la propose sans la lancer de lui-même.

## Mise à jour

Après modification, incrémente `version` dans
`plugins/devkit/.claude-plugin/plugin.json`, puis :

```bash
git add -A && git commit -m "vX.Y.Z: description du changement"
git push
```

## Validation avant publication

```bash
claude plugin validate .
```
