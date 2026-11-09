# Vision produit - Application APC

Document de cadrage ajoute le 13 octobre 2026 à partir des informations transmises par le propriétaire. Il complète les références du projet sans les remplacer. Les choix marqués « à confirmer » ne sont pas des décisions techniques définitives.

## Vision générale

Construire une application de gestion intégrée pour Africa Print Communication, utilisable par le personnel et, à terme, par les clients. L'interface et les actions disponibles dépendent du profil. Le propriétaire souhaite une expérience visuelle soignée et spécifique au métier de l'imprimerie, pas un tableau de bord générique.

L'application doit couvrir plus que l'impression : les prestations APC, le traitement commercial, la production, l'administration, la comptabilité, les employés et les clients. Le code Flutter devrait être partagé entre desktop et mobile lorsque cela reste pertinent, avec des parcours adaptés à chaque écran et profil.

## Profils et usages souhaités

- Secrétariat / commercial : principalement desktop. Consulter les prestations et tarifs, gérer les clients, saisir les demandes reçues au guichet, par téléphone, WhatsApp ou email, suivre les devis et communiquer avec les clients.
- Direction et administration : principalement desktop. Paramétrer l'entreprise et les sites, administrer les profils et rôles, suivre les activités et consulter les informations de gestion autorisées.
- Comptabilité : principalement desktop. À terme, suivre factures, paiements, soldes et informations fiscales/comptables.
- Employé : mobile. Accéder à son profil, pointer, consulter ses missions et notes, demander une absence, suivre les informations de paie auxquelles il a droit, recevoir des notifications et interagir avec l'administration.
- Atelier / production : interface adaptée au poste et au matériel de l'atelier pour consulter les travaux, leur avancement et les incidents, une fois le module production disponible.
- Client externe : mobile ou web selon le parcours retenu. Créer un compte client, consulter les prestations, demander un devis, joindre ultérieurement un fichier et échanger avec le secrétariat. Ce portail est souhaité mais n'est pas encore implémenté.

## Pointage mobile inspiré de TimeStation

Le propriétaire souhaite un parcours de pointage rapide sur téléphone : l'employé ouvre l'application, démarre sa journée et peut retrouver son espace de travail, ses tâches ou missions et ses notes. L'administration doit pouvoir gérer et suivre les pointages.

La référence TimeStation communiquée est https://www.mytimestation.com/. Les fonctions relevées sur leur site incluent pointage rapide, portail employé, localisation au moment du pointage, fonctionnement hors ligne avec synchronisation, plusieurs sites, droits d'accès et rapports de gestion. Il s'agit d'une inspiration fonctionnelle, pas d'une demande de copier leur interface ou leur logiciel.

À concevoir avec le propriétaire avant mise en production : pointage d'entrée/sortie, corrections et approbations, règles de retard, sites autorisés, fonctionnement hors ligne, conservation des données GPS, visibilité des employés et responsables. Proposition à valider : demander la localisation uniquement à l'action explicite de pointage, avec information de l'employé et site autorisé, sans suivi continu en arrière-plan.

## Paramètres initiaux de l'entreprise

Prévoir un écran d'administration pour enregistrer les données stables nécessaires aux documents et à la comptabilité : nom légal et nom commercial, forme juridique, identifiants fiscaux/commerciaux applicables, adresses, téléphones, emails, contacts, logo, devise, fuseau horaire et sites opérationnels. Pour chaque site, prévoir adresse et coordonnées géographiques si elles sont utilisées pour valider un pointage.

Juridiction à confirmer avant de figer les champs fiscaux ou les calculs : les références existantes parlent de Douala / Cameroun, alors que certains éléments du backend utilisent XOF et des numéros +225. Ne pas présumer IFU, NIF, RCCM, TVA, devise ou formats comptables avant validation par le propriétaire.

## Parcours réalisables dès maintenant

Le backend expose actuellement l'authentification du personnel, le catalogue et le calcul de tarif, les clients et une première version des demandes/devis. Cela permet de commencer l'application Flutter sans attendre la fin de tous les modules : connexion du personnel, consultation du catalogue, répertoire client et suivi des demandes/devis.

Les pages de commande, production, paiements, RH/pointage, paie, fichiers et portail client doivent rester indiquées comme non disponibles ou comme prototype jusqu'à ce que leurs APIs soient prêtes. Le frontend ne doit jamais remplacer les contrôles de rôles et permissions du backend.

## Cibles techniques et limites connues

- Cibles demandées : desktop et mobile Android/iOS, avec une expérience adaptée au facteur de forme.
- Développement Windows : Flutter peut cibler Windows, Android et Web si leurs toolchains sont installées.
- iOS : le code Flutter peut être partagé, mais compiler, signer et publier nécessite macOS avec Xcode ou un runner macOS. Un iPhone connecté à Windows ne fournit pas Xcode.
- Les API backend sont versionnées sous `/api/v1` et l'authentification employé utilise un jeton Sanctum Bearer.
