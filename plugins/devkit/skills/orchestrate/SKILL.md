---
description: Règles de délégation aux agents devkit (feature-dev sur opus, test-writer sur sonnet, explorer sur haiku) et enchaînement entre eux. À appliquer avant toute tâche de développement non triviale — nouvelle fonctionnalité, refactor sur plusieurs fichiers, écriture de tests, recherche large dans le code.
---

Tu es le chef d'orchestre. Tu gardes la vue d'ensemble et le lien avec
l'utilisateur ; les agents font le travail lourd et te rendent un rapport.

## Qui fait quoi

| Tâche | Agent | Modèle par défaut |
|---|---|---|
| Nouvelle fonctionnalité, refactor sur plusieurs fichiers | `devkit:feature-dev` | opus |
| Écrire ou compléter des tests | `devkit:test-writer` | sonnet |
| Recherche large, cartographie, « où est géré X ? » | `devkit:explorer` | haiku |

Fais toi-même, sans déléguer : les questions, les petites corrections dans un
ou deux fichiers, les changements dont tu connais déjà l'emplacement exact.
Un agent repart de zéro, donc déléguer a un coût : ça vaut le coup quand la
tâche est longue, ou quand elle remplirait ton contexte de fichiers lus.

## Modèles propres au projet

Si `.devkit/routing.md` existe, lis-le : ses règles priment sur le tableau
ci-dessus. Pour changer le modèle d'un agent sur un appel, passe le paramètre
`model` à l'outil Agent (par exemple `opus` pour test-writer sur un projet
critique).

## Avant de déléguer

Vérifie que `.devkit/PATTERNS.md` existe. S'il manque et que la tâche
est grosse, propose à l'utilisateur de lancer d'abord `/devkit:study` : les
agents travaillent nettement mieux avec. S'il préfère s'en passer, continue.

Un agent ne voit pas cette conversation. Son prompt doit contenir tout ce dont
il a besoin :

- l'objectif et le critère de réussite (« l'endpoint renvoie 404 si… »)
- les fichiers ou zones concernés, si tu les connais
- les décisions déjà prises avec l'utilisateur
- ce qu'il ne doit pas toucher

## Enchaînement pour une fonctionnalité

1. `devkit:explorer` si tu ne sais pas encore où intervenir. Lances-en
   plusieurs en parallèle si les questions sont indépendantes.
2. `devkit:feature-dev` avec l'objectif et ce que l'exploration a trouvé.
3. `devkit:test-writer` avec les sections **Fichiers** et **À tester** du
   rapport de feature-dev.
4. Si test-writer signale des bugs dans le code, renvoie son rapport à
   feature-dev, puis relance test-writer. Après deux allers-retours sans
   succès, arrête-toi et explique la situation à l'utilisateur.
5. Résume à l'utilisateur : ce qui a été fait, le résultat des tests, les bugs
   hors périmètre signalés par les agents, et ce qui reste. Puis journalise
   selon le skill devlog.

## Lire les rapports

Chaque agent devkit termine par un rapport `## Rapport — <agent>`. Lis-le
avant de passer à l'étape suivante :

- Vérifie qu'il répond à la demande. S'il manque ou s'il est incomplet,
  demande à l'agent de le compléter plutôt que de deviner.
- Ne transmets pas à l'utilisateur ce que le rapport ne justifie pas : des
  tests annoncés comme passés sans commande lancée ne sont pas des tests
  passés.
