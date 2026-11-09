# RÈGLES DE COLLABORATION DES IA — PROJET

## 1. Objectif

Ce projet peut être développé par plusieurs intelligences artificielles, utilisées dans différents IDE et environnements de travail.

Chaque IA doit pouvoir reprendre le travail d'une autre sans devoir réanalyser l'intégralité du projet, répéter les tâches déjà effectuées ou consommer inutilement des crédits.

La continuité du projet repose sur trois éléments :
- Le projet lui-même : le code et les ressources de développement.
- Le dossier `info/` : les informations de référence fournies par l'utilisateur.
- Le dossier propre à chaque IA : son historique de travail utile et l'état d'avancement de ses tâches.

Le fichier `LOG.md`, placé à la racine, permet d'identifier rapidement le dernier intervenant et le point de reprise.

## 2. Règles obligatoires avant toute intervention

1. Lire le fichier `LOG.md` à la racine avant de commencer.
2. Identifier la dernière IA utilisée, son dossier de suivi et sa dernière action.
3. Consulter uniquement les documents de suivi nécessaires à la reprise, en commençant par ceux de la dernière IA.
4. Respecter la structure existante du projet et les informations de référence présentes dans `info/`.
5. Ne jamais créer un nouveau dossier de suivi si celui de l'IA actuelle existe déjà.
6. Chaque IA doit connaître et conserver le nom exact de son propre dossier de suivi pendant toute son intervention.
7. Ne jamais considérer une tâche comme terminée sans avoir vérifié son résultat.
8. Ne pas supprimer, déplacer, renommer ou réécrire les documents de référence de l'utilisateur sans autorisation.
9. Ne pas modifier le travail d'une autre IA sans nécessité réelle. Si une modification est indispensable, vérifier ses conséquences et la documenter.
10. Ne pas ajouter de documents, de fichiers explicatifs ou de structures inutiles. Privilégier la simplicité, la cohérence et la maintenance.

## 3. Organisation des dossiers

Chaque IA travaille dans le dossier qui lui est attribué par l'utilisateur. Ce nom doit être utilisé exactement comme indiqué.

L'IA organise elle-même son dossier de suivi selon une structure simple, adaptée au projet. Elle doit notamment permettre de retrouver :
- L'état actuel du projet et les tâches déjà réalisées.
- La dernière action effectuée.
- Les décisions techniques importantes et leurs justifications.
- Les problèmes rencontrés et les solutions apportées.
- Les tâches restantes, dans leur ordre de priorité.
- Les instructions nécessaires pour poursuivre le travail.

La structure doit rester légère, claire et compréhensible par une autre IA.

Si un classement par actions est utile, chaque action doit être identifiée clairement et contenir uniquement les informations nécessaires à la continuité du travail. Éviter les copies successives du même contenu et les journaux interminables.

Le dossier `info/` est réservé aux informations de référence fournies par l'utilisateur. Il ne doit pas devenir un dossier de suivi des IA.

## 4. Règles de mise à jour du suivi

Après chaque intervention significative, l'IA doit mettre à jour son propre dossier.

Elle doit :
- Résumer précisément ce qui a été accompli.
- Indiquer les fichiers ou modules réellement modifiés.
- Mentionner les tests effectués et leurs résultats.
- Signaler les erreurs, blocages et points non vérifiés.
- Indiquer la prochaine tâche recommandée.
- Mettre à jour ou remplacer les informations devenues obsolètes.

Conserver l'historique utile, mais supprimer les doublons et les notes périmées lorsqu'ils ne sont plus nécessaires. Ne jamais supprimer une information encore indispensable à la compréhension du projet.

Le suivi doit décrire l'état réel du code, et non l'état souhaité.

## 5. Fonctionnement du fichier LOG.md

Le fichier `LOG.md` se trouve à la racine du projet.

Il doit rester court et contenir exactement trois lignes logiques :

1. **Dernier intervenant :** nom de l'IA, IDE utilisé et nom exact de son dossier de suivi.
2. **Dernière intervention :** date, heure et fuseau horaire, ainsi qu'un résumé concis de l'action réalisée.
3. **Reprise :** état actuel, éventuel blocage et prochaine action prioritaire.

À chaque intervention significative terminée, remplacer le contenu précédent par les trois nouvelles lignes. Ne pas ajouter les anciennes interventions à la suite.

Le fichier ne doit contenir ni l'historique détaillé, ni une copie du cahier des charges, ni une liste complète des fichiers du projet.

Exemple de format :

Dernier intervenant : [Nom de l'IA] | IDE : [Nom de l'IDE] | Dossier : [chemin exact]

Dernière intervention : [AAAA-MM-JJ HH:mm, fuseau] | [résumé factuel]

Reprise : [état vérifié] | Prochaine action : [tâche prioritaire]

Ne jamais inscrire une action comme terminée si elle n'a pas été réalisée ou vérifiée.

## 6. Procédure de relais entre deux IA

Lorsqu'une IA reprend le projet :

1. Lire `LOG.md`.
2. Ouvrir le dossier de la dernière IA mentionnée.
3. Consulter son dernier état d'avancement et les éléments nécessaires à la tâche suivante.
4. Vérifier uniquement les parties du code concernées par la reprise.
5. Continuer le travail sans recommencer les étapes déjà validées.

Lorsqu'une nouvelle IA commence à travailler, l'utilisateur lui indiquera son nom et le nom de son dossier si nécessaire.

Lorsqu'une IA termine son intervention, elle met d'abord à jour son dossier de suivi, puis actualise `LOG.md` en dernier. Le relais doit ainsi pointer vers des informations déjà enregistrées.

Si le fichier `LOG.md` est absent, incohérent ou incomplet, rechercher les informations minimales nécessaires dans les dossiers existants. Ne jamais inventer un état d'avancement.

## 7. Exigences de qualité

Toutes les IA doivent privilégier :
- La continuité plutôt que la reconstruction.
- Les preuves et vérifications plutôt que les suppositions.
- La réutilisation du code existant plutôt que les doublons.
- Les changements limités, cohérents et testables.
- La documentation utile plutôt que la multiplication des fichiers.
- La transparence sur ce qui fonctionne, ce qui reste à faire et ce qui n'a pas été testé.

Ces règles s'appliquent à toutes les IA, tous les IDE, tous les comptes et tous les environnements utilisés pour ce projet.

**Principe final : une seule source de vérité pour le code, un dossier de suivi par IA et un fichier `LOG.md` court pour organiser le relais.**