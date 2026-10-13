# 🤝 GUIDE DE RELAIS POUR N'IMPORTE QUEL AGENT OU DÉVELOPPEUR (HANDOFF)

> **Important pour l'Agent IA qui reprend ce projet :**
> Ce fichier est conçu pour que vous puissiez reprendre immédiatement le travail sans poser de questions redondantes à l'utilisateur et sans casser l'organisation établie. Lisez attentivement les règles et le contexte ci-dessous.

---

## 1. Contexte du Projet

- **Entreprise cliente** : **Africa Print Communication (APC)** — Imprimerie professionnelle (Grands formats, bâches, vinyles, textiles, carterie, objets personnalisés, etc.).
- **Objectif** : Application intégrée de gestion (ERP d'imprimerie) centralisant :
  - La réception des demandes clients (venant principalement de WhatsApp et guichet),
  - Le traitement intelligent et automatisé des fichiers d'impression (vérification dimensions, formats, aperçus légers, détection d'erreurs),
  - La gestion de production par atelier (Ordres de travail / fiches suiveuses),
  - Le suivi commercial, les devis, facturation, encaissements et soldes,
  - Les stocks de consommables (rouleaux, encres, œillets) et inventaires,
  - Les ressources humaines (présences, pointage, paie sécurisée),
  - Les tableaux de bord de pilotage.
- **Remplacement / Migration** : L'entreprise utilisait auparavant **Aronium Lite** pour les tickets au secrétariat. Une sauvegarde SQLite réelle (`INFO/aronium-database-2026-08-02-12-00.db`) est fournie dans `INFO/` et contient 125 produits, 818 clients et 4 648 documents de vente.

---

## 2. Règle d'or absolue : Organisation des dossiers (Anti-pollution)

Le projet est rigoureusement séparé en 4 espaces :
1. `BACKEND_LARAVEL/` : **Uniquement** le code source du backend Laravel. Aucun fichier temporaire, doc personnelle ou script scratch ne doit y être déposé.
2. `FRONTEND_FLUTTER/` : **Uniquement** le code source des applications Flutter Desktop et Mobile.
3. `INFO/` : Dossier de l'utilisateur contenant la documentation client, le cahier des charges officiel, le logo et la base Aronium source. **Ne jamais modifier ni supprimer ces fichiers.**
4. `DOCS_ET_SUIVI/` : **Notre dossier de suivi, documentation de relais et scripts utilitaires**. C'est un dossier isolé : s'il est supprimé, le projet fonctionne toujours à 100%. Tout ce qui aide à la compréhension et au relais doit être placé ici.

---

## 3. Contraintes Techniques Non Négociables

1. **Zéro service ou API payante** : Pas d'API WhatsApp payante, pas de services Cloud payants (AWS S3, OCR payant, etc.). Tout est **100% open source, gratuit et auto-hébergeable**.
2. **Backend** : Laravel avec API REST sous `/api/v1`.
3. **Base de données** : PostgreSQL 17 (actif localement).
   - Base : `apc_db`
   - Utilisateur : `Thierry`
   - Mot de passe : `Admin`
   - Port : `5432`
4. **Authentification** : Laravel Sanctum (tokens d'API pour Flutter).
5. **Permissions** : RBAC granulaire vérifié côté serveur (Policies).
6. **Fichiers** : Originaux **immuables** stockés hors de la racine web publique avec contrôle SHA-256. Traitement asynchrone pour les métadonnées et aperçus.

---

## 4. État d'avancement actuel

Consultez le fichier [AVANCEMENT_ET_JOURNAL.md](file:///y:/PROJET/APP/AFRICA%20PRINT%20COMMUNICATION/APC/DOCS_ET_SUIVI/AVANCEMENT_ET_JOURNAL.md) pour le détail exact.

- **Étape 0 (Cadrage et vérification environnement)** : ✅ TERMINÉ.
  - PostgreSQL 17 validé et testé (connexion `Thierry` / `Admin` sur `apc_db` réussie).
  - Base Aronium analysée et intègre.
  - PHP 8.2.12 + Composer + Flutter 3.47.7 opérationnels.
  - Dossier de suivi et de découpage mis en place.
- **Étape 1 (Socle Backend Laravel & Sécurité RBAC)** : ✅ TERMINÉ.
  - Squelette Laravel configuré avec PostgreSQL 17 (`apc_db`) et encodage UTF-8.
  - Authentification Sanctum opérationnelle (`/api/v1/auth/login`, `/api/v1/auth/me`, `/api/v1/auth/logout`).
  - Système de permissions Spatie avec 7 départements métiers et rôles opérationnels.
  - Formatage standardisé des réponses JSON (`ApiResponse`) et gestion d'erreurs (401, 403, 404, 422).
  - 100% des tests automatisés au vert (7 tests, 35 assertions).
- **Étape 2 (Prochaine étape)** : ⏳ À FAIRE.
  - Module Catalogue des Services & Tarifs paramétrables (bâches, vinyles, etc.).
  - Module Clients & Demandes commerciales (suivi entrées WhatsApp/guichet).
