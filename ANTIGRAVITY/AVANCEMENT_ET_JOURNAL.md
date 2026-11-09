# SUIVI DU PROJET APC — ANTIGRAVITY

## 1. Contexte et Décisions d'Architecture
- Reprise complète sur base saine sur la branche `v2-main`. L'ancienne version est intégralement conservée sur `archive/v1` et dans le dossier local `v1/` (ignoré par Git).
- **Backend Unique (`backend/`)** : Laravel 11 MVC pur API.
  - Cloisonnement strict des responsabilités par rôle utilisateur (`Admin`, `Secretary`, `Accounting`, `Auth`).
  - Middlewares dédiés : `EnsureUserRole` et `EnsureActiveFiscalYear`.
  - Routes séparées : `routes/admin.php`, `routes/secretary.php`, `routes/accounting.php`, `routes/auth.php`.
  - Gestion de l'exercice fiscal (`2025-2026`) : toutes les opérations sont rattachées à l'exercice actif.
  - Module Entreprise : Nom, N° IFU, RCCM, contacts, logo, pied de page ticket.
  - Caisse / POS style Aronium : création rapide client, ajout d'articles, calcul sous-total/remise/TVA, encaissement (espèces, MoMo, virement, chèque), calcul du rendu de monnaie, génération de reçu avec IFU et pied de page.
  - Comptabilité : Journal des flux de trésorerie (in/out), dépenses d'exploitation avec sortie de caisse automatique, suivi des créances, clôture de caisse quotidienne Z-Report.
  - **Tests automatisés validés** : 13 tests Feature, 100 assertions, 100% de réussite.
- **Frontend Desktop (`frontend_desktop/`)** : Projet Flutter autonome dédié au Desktop & Web, reprenant rigoureusement l'interface Aronium définie dans `docs/v.html`.
  - Charte graphique : Bleu `#0B3C6E`, Orange `#F5821F`, Fond `#EEF2F7`.
  - Authentification avec sélecteur direct de profil (Secrétaire, Comptable, Directeur).
  - Navigation dynamique et étanche par rôle (`AppSidebar` & `AppShell`).
  - Module Secrétariat : POS complet (catalogue filtrable par catégorie, ticket live avec calculs temps réel, popup d'encaissement, sélection client), gestion des commandes, liste clients avec code et N° IFU, devis/demandes.
  - Module Comptabilité : Tableau de bord KPIs financiers (recettes, dépenses, solde, créances), journal des flux de trésorerie, suivi des dépenses d'exploitation, créances clients, ouverture/clôture de caisse quotidienne Z-Report.
  - Module Administration : Tableau de bord global, paramétrage de l'entreprise (nom, IFU, RCCM, pied de page de reçu), gestion et activation des exercices fiscaux, gestion des utilisateurs (création et activation/désactivation).
  - Tests Flutter : compilation et tests widgets validés (`All tests passed!`, 0 erreur statique).
- **Frontend Mobile** : Sera un projet séparé distinct ultérieurement.

## 2. État d'avancement
- [x] Archivage propre de la v1 sur la branche `archive/v1`
- [x] Initialisation de la branche `v2-main`
- [x] Backend Laravel 11 complet et modulaire (API REST pure)
- [x] Migrations et seeders créés et appliqués
- [x] 13 tests PHPUnit validés (Auth, Vente POS, Reçus, Comptabilité, Permissions)
- [x] Création du dossier de suivi `ANTIGRAVITY/` et respect de `REGLES_IA.md`
- [x] Initialisation et structuration propre du projet Flutter Desktop `frontend_desktop/`
- [x] Implémentation du thème visuel Africa Print (Bleu #0B3C6E, Orange #F5821F)
- [x] Implémentation de l'écran POS Aronium (Catalogue produits, Ticket live, Encaissement, Impression reçu)
- [x] Implémentation de tous les écrans Secrétariat, Comptabilité et Administration
- [x] Tests Flutter compilés et validés

## 3. Prochaine Action
Commit Git des développements réalisés (Frontend Flutter Desktop + mise à jour du journal) et démonstration de lancement à l'utilisateur.
