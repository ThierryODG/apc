# Suivi VS Code — APC

Dernière mise à jour : 2026-10-13 23:32 +00:00.

## État vérifié à la reprise

- Le dossier de suivi de l’agent précédent consulté est `ANTYGAVITY/ACTION 01/DOCS_ET_SUIVI/` : guide de relais, journal d’avancement et découpage des modules.
- Les documents Anti-Gravity ne sont pas parfaitement à jour entre eux : le guide annonce le Module 2 comme prochaine étape, tandis que le journal annonce le Module 3. Les routes et contrôleurs présents montrent que le catalogue (Module 2) et une partie clients (Module 3) sont déjà implémentés. Se référer au code actuel plutôt qu’à ces statuts contradictoires.
- Module 1 : l’authentification Sanctum et les rôles/permissions sont déclarés comme terminés dans le journal Anti-Gravity. La suite de tests exécutée ici valide les tests d’authentification, avec des avertissements de dépréciation.
- Module 2 : routes catalogue, unités, calcul de prix et modification protégée du tarif présentes ; contrôleurs et `CatalogTest` présents.
- Module 3 : CRUD clients, statistiques, changement de statut, contacts et adresses présents. Une suite `CustomerTest` a été ajoutée : 5 scénarios, 28 assertions.
- Module 4 (Demandes entrantes, selon `INFO/AVANCEMENT_PROJET.md`) : création, liste filtrée/paginée, détail, mise à jour avant devis, qualification, enregistrement d’envoi de devis et refus. Sources prises en charge : WhatsApp, téléphone, guichet, email, recommandation, réseaux sociaux et autre.
- La table `inquiry_files` est préparée avec métadonnées, empreinte SHA-256 et stockage local privé ; aucun endpoint d’upload/téléchargement n’est encore exposé. Le traitement sécurisé des fichiers reste à compléter dans le module Fichiers.
- Pas de conversion Inquiry→commande pour l’instant : le modèle de commande n’existe pas. Ne pas marquer une demande « convertie » sans créer et lier une vraie commande.
- Les endpoints enregistrés sont 24 au total sous `/api/v1`, dont 7 routes Inquiry.

## Vérifications réalisées

- `php artisan test` : aucune assertion en échec, 179 assertions ; 28 tests Feature sont signalés en dépréciation liée à `PDO::MYSQL_ATTR_SSL_CA` sous PHP 8.5, même si `phpunit.xml` configure SQLite en mémoire.
- `InquiryTest` : 9 scénarios / 35 assertions, couvrant auth, permission, validation, création/liste, détail/modification et transitions. La suite complète finale totalise 179 assertions.
- `php artisan route:list --path=api --except-vendor` : 24 routes affichées.
- `php artisan migrate:status` : les deux migrations Inquiry étaient en attente sur PostgreSQL local ; `php artisan migrate --force` les a appliquées. Les appels navigateur login, catalogue, clients, stats et inquiries ont tous répondu HTTP 200.
- Flutter : `flutter analyze` sans erreur, `flutter test` réussi (3 tests dont un login avec API simulée), `flutter build web` réussi.
- Flutter Web local actif sur `http://127.0.0.1:5173`, backend sur `http://127.0.0.1:8000`.
- La tentative de hot reload Web via le terminal a expiré avec une erreur DWDS ; le serveur a été relancé proprement et la page web sert la version courante.
- `vendor/bin/pint --dirty --format agent` : réussi. `php -l` sur contrôleur Inquiry et son test : aucune erreur de syntaxe.
- `get_errors` a une fois affiché un import `User` inutilisé alors qu’il n’existe déjà plus dans le contrôleur après Pint ; PHP lint et tests passent. À recontrôler après rafraîchissement de l’analyse VS Code.
- `composer audit` : 4 avis sur `laravel/framework` 11.57.0 (low, medium, high et doublon lié à CRLF). Les versions corrigées mentionnées sont sur Laravel 12 ; aucune montée majeure n’a été faite dans cette tâche. À planifier séparément comme migration Laravel 12.
- Laravel Boost 2.10 est installé en dépendance de développement conformément à `BACKEND_LARAVEL/AGENTS.md`, configuré pour GitHub Copilot, sans intégration cloud. Il a généré les consignes/skills sous `BACKEND_LARAVEL/.github/` et `boost.json`.

## Cadrage produit transmis par le propriétaire (2026-10-13)

Ces points viennent de la conversation et ne sont pas encore des exigences techniques validées dans `INFO/`. Ne pas modifier les documents de référence utilisateur sans demande.

- Vision : un système APC intégré avec vues différentes selon les profils (clients, secrétariat/commercial, direction, comptabilité, RH, employés et ateliers). Le propriétaire souhaite une expérience desktop pour les équipes administratives et mobile pour les employés/clients, avec partage autant que possible d’une base de code Flutter.
- Espace client souhaité : création de compte, consultation du catalogue, demandes/devis, dépôt ultérieur de fichiers et échanges avec le secrétariat. À construire après les parcours internes de base ; les API de compte client, commandes, fichiers et messagerie n’existent pas encore.
- Espace employé souhaité : profil, pointage, demandes d’absence, suivi des informations de paie et notifications ; missions/notes et communication interne sont aussi envisagées. La présence, les congés, la paie et les notifications ne sont pas encore implémentés.
- Référence TimeStation consultée : pointage rapide, portail employé, localisation associée au pointage, fonctionnement hors ligne avec synchronisation, gestion des droits et rapports manager.
- Proposition de cadrage pour la localisation : la collecter seulement lors d’un pointage explicite (entrée/sortie), avec information/consentement, heure serveur, précision GPS et site autorisé/geofence ; pas de suivi continu en arrière-plan. Prévoir une file hors ligne et une synchronisation idempotente. C’est une proposition à valider, pas une décision déjà implémentée.
- Informations de l’entreprise à saisir dans un futur écran de configuration : identité légale et commerciale, identifiants fiscaux/RCCM selon juridiction, coordonnées, adresses/sites, fuseau horaire, devise, contacts et coordonnées GPS des sites. Le pays/juridiction doit être clarifié avant de fixer IFU/NIF, taxes et format comptable : les notes mentionnent Douala/Cameroun tandis que des éléments applicatifs utilisent XOF et +225.
- Le frontend Flutter contient maintenant un premier portail responsive du secrétariat : login Sanctum, vue d’ensemble, demandes (création/qualification/devis/refus), clients (liste/création) et catalogue. Logo APC intégré en asset.
- PostgreSQL local : les migrations `inquiries` et `inquiry_files` étaient en attente et ont été appliquées après contrôle. Login et endpoints locaux catalogue, clients, statistiques clients et demandes répondent HTTP 200 avec le compte administrateur de développement.
- Le cadrage produit du propriétaire a été enregistré dans `INFO/VISION_PRODUIT_APPLICATION_APC.md`; les documents INFO déjà fournis n’ont pas été réécrits.

## Stratégie de livraison recommandée

Il n’est pas nécessaire d’achever tout le backend avant le frontend. Construire par tranches verticales et utiliser les API déjà disponibles :

1. Le shell et les vues initiales sont démarrés. Faire tester le portail desktop/mobile au propriétaire, puis améliorer les fiches client, filtres/détails de demandes et états de chargement avec ses retours.
2. Afficher les fonctions non prêtes comme non disponibles ou utiliser des données de démonstration strictement identifiées ; ne pas faire croire qu’elles sont connectées au backend.
3. Ajouter ensuite Commandes et tester ensemble la conversion de demande, puis Fichiers et dépôt sécurisé.
4. Pour la présence mobile, implémenter d’abord le backend employé/sites/pointage/règles GPS et offline-sync, puis l’écran mobile correspondant.
5. Ajouter en étapes suivantes congés, missions/notes, notifications et paie. La paie requiert des permissions et protections renforcées.
6. Prévoir une application à interfaces selon rôle, mais ne pas fusionner les droits dans le frontend : le backend demeure l’autorité. La création libre d’un compte client et la création d’un compte employé doivent suivre des parcours distincts.

## Plateformes

- Depuis ce Windows, Flutter Web fonctionne. `flutter doctor` montre la cible Windows desktop désactivée et les licences Android non acceptées ; activer les prérequis avant les builds correspondants.
- Le code iOS peut être partagé, mais la compilation, signature et publication iOS requièrent macOS et Xcode. L’iPhone 15 Pro Max seul, connecté à un PC Windows, ne remplace pas cet environnement. Prévoir ponctuellement un Mac local ou un runner macOS pour valider/distribuer iOS.

## Reprise recommandée

1. Créer le Module Commandes avant d’implémenter la conversion réelle des demandes qualifiées en commandes.
2. Ajouter ensuite upload/téléchargement privé et analyse asynchrone des fichiers joints, en respectant l’immutabilité et SHA-256.
3. Préparer séparément la migration de Laravel 11 vers la version majeure corrigée ; retester le backend et corriger l’avertissement PDO de PHPUnit.
4. Continuer le prototype Flutter déjà livré, après essai propriétaire. Avant les modules fiscaux/RH, valider le pays légal de l’entreprise et les règles de pointage/GPS.

Dernier point de fiabilité : après les modifications signalées dans le contexte de reprise, `php artisan test --compact` a été relancé et passe avec 179 assertions. 28 tests Feature gardent des avertissements de dépréciation PDO MySQL sous PHP 8.5.

## État du dépôt

Les changements comprennent le correctif 403, les tests clients, le module Inquiry, Laravel Boost, le portail Flutter initial, `INFO/VISION_PRODUIT_APPLICATION_APC.md` et l’application des deux migrations Inquiry à la base PostgreSQL locale. Les suppressions préexistantes de `DOCS_ET_SUIVI/` et autres changements Git déjà présents n’ont pas été restaurés ni modifiés. Un fichier Word temporaire non suivi est apparu sous `INFO`; il est laissé intact.
