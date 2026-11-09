# 📋 Suivi d'avancement — Backend Laravel APC
> Africa Print Communication — Imprimerie Douala
> Mis à jour : 2026-10-13

---

## ✅ MODULE 1 — Socle & Authentification (TERMINÉ)

### Fichiers créés
| Fichier | Rôle |
|---|---|
| `database/migrations/…_create_personal_access_tokens_table.php` | Sanctum tokens |
| `database/migrations/…_create_permission_tables.php` | Spatie RBAC |
| `database/migrations/…_create_departments_table.php` | Départements APC |
| `database/migrations/…_add_department_and_profile_fields_to_users_table.php` | Champs utilisateur |
| `app/Models/User.php` | Modèle utilisateur avec HasRoles |
| `app/Models/Department.php` | Modèle département |
| `app/Http/Controllers/Api/V1/AuthController.php` | Login, Me, Logout |
| `app/Http/Requests/Api/V1/LoginRequest.php` | Validation login |
| `app/Support/ApiResponse.php` | Trait réponses JSON unifiées |
| `database/seeders/RoleAndPermissionSeeder.php` | Rôles, permissions, users démo |

### Routes API
- `POST   /api/v1/auth/login`
- `GET    /api/v1/auth/me`
- `POST   /api/v1/auth/logout`

---

## ✅ MODULE 2 — Catalogue des Prestations & Tarifs (TERMINÉ)

### Fichiers créés
| Fichier | Rôle |
|---|---|
| `database/migrations/…_create_service_categories_table.php` | Catégories |
| `database/migrations/…_create_units_table.php` | Unités de mesure |
| `database/migrations/…_create_print_services_table.php` | Prestations |
| `database/migrations/…_create_service_options_table.php` | Options/finitions |
| `database/migrations/…_create_price_histories_table.php` | Historique des prix |
| `app/Models/ServiceCategory.php` | Modèle catégorie |
| `app/Models/Unit.php` | Modèle unité |
| `app/Models/PrintService.php` | Modèle prestation |
| `app/Models/ServiceOption.php` | Modèle option |
| `app/Models/PriceHistory.php` | Modèle historique prix |
| `app/Domain/Catalog/Services/CatalogService.php` | Logique métier catalogue |
| `app/Domain/Catalog/DTO/PriceCalculationDTO.php` | DTO calcul de prix |
| `app/Http/Controllers/Api/V1/CatalogController.php` | Contrôleur catalogue |
| `app/Http/Controllers/Api/V1/UnitController.php` | Contrôleur unités |
| `app/Http/Requests/Api/V1/CalculatePriceRequest.php` | Validation calcul prix |
| `app/Http/Requests/Api/V1/UpdatePriceRequest.php` | Validation mise à jour tarif |
| `app/Http/Resources/Api/V1/ServiceCategoryResource.php` | Ressource catégorie |
| `app/Http/Resources/Api/V1/PrintServiceResource.php` | Ressource prestation |
| `app/Http/Resources/Api/V1/UnitResource.php` | Ressource unité |
| `database/seeders/CatalogSeeder.php` | Données initiales du catalogue |

### Routes API
- `GET  /api/v1/catalog/`
- `GET  /api/v1/catalog/units`
- `GET  /api/v1/catalog/services/{service}`
- `POST /api/v1/catalog/calculate-price`
- `PATCH /api/v1/catalog/services/{service}/price` *(auth:sanctum)*

---

## ✅ MODULE 3 — Clients & Contacts (TERMINÉ)

### Fichiers créés
| Fichier | Rôle |
|---|---|
| `database/migrations/…_create_customers_table.php` | Clients (particuliers + entreprises) |
| `database/migrations/…_create_customer_contacts_table.php` | Contacts additionnels |
| `database/migrations/…_create_customer_addresses_table.php` | Adresses livraison/facturation |
| `app/Models/Customer.php` | Modèle client avec softDeletes, scopes |
| `app/Models/CustomerContact.php` | Modèle contact |
| `app/Models/CustomerAddress.php` | Modèle adresse |
| `app/Domain/Customers/Services/CustomerService.php` | Logique métier clients |
| `app/Http/Controllers/Api/V1/CustomerController.php` | Contrôleur CRUD clients |
| `app/Http/Requests/Api/V1/StoreCustomerRequest.php` | Validation création client |
| `app/Http/Requests/Api/V1/UpdateCustomerRequest.php` | Validation mise à jour client |
| `app/Http/Resources/Api/V1/CustomerResource.php` | Ressource JSON client |
| `app/Http/Resources/Api/V1/CustomerContactResource.php` | Ressource contact |
| `app/Http/Resources/Api/V1/CustomerAddressResource.php` | Ressource adresse |
| `database/seeders/CustomerSeeder.php` | Import Aronium (818 clients) + démo |

### Routes API (toutes protégées par auth:sanctum)
- `GET    /api/v1/customers` — Liste paginée + filtres
- `POST   /api/v1/customers` — Créer un client
- `GET    /api/v1/customers/stats` — Statistiques
- `GET    /api/v1/customers/{id}` — Fiche détaillée
- `PATCH  /api/v1/customers/{id}` — Modifier
- `DELETE /api/v1/customers/{id}` — Archiver (soft delete)
- `PATCH  /api/v1/customers/{id}/toggle-status` — Activer/Désactiver
- `POST   /api/v1/customers/{id}/contacts` — Ajouter un contact
- `POST   /api/v1/customers/{id}/addresses` — Ajouter une adresse

### Fonctionnalités
- Segmentation VIP/Regular/Occasional/New
- Gestion des crédits et délais de paiement
- Import depuis base Aronium (818 clients existants)
- Recherche plein texte (nom, email, téléphone)
- Géolocalisation optionnelle des adresses

---

## 🔜 MODULE 4 — Demandes Entrantes (Inquiries/Devis)

**Prochaine étape :**
- Table `inquiries` (demandes WhatsApp + accueil)
- Table `inquiry_files` (fichiers joints)
- Workflow : Nouveau → Qualifié → Devis envoyé → Converti en commande / Refusé
- Service `InquiryService`
- Routes : `POST /api/v1/inquiries`, `GET`, `PATCH /{id}/qualify`, `PATCH /{id}/convert`

---

## 🔜 MODULE 5 — Commandes & Ordres de Travail
## 🔜 MODULE 6 — Gestion des Fichiers (upload sécurisé + analyse)
## 🔜 MODULE 7 — Production & Ateliers
## 🔜 MODULE 8 — Finances & Paiements
## 🔜 MODULE 9 — Stock & Consommables
## 🔜 MODULE 10 — RH & Présences
## 🔜 MODULE 11 — Tableau de bord & Rapports

---

## 🛠️ Stack technique
- **Laravel** 12.x + PHP 8.3
- **PostgreSQL** 17 (local)
- **Sanctum** (auth par token)
- **Spatie/Permission** (RBAC granulaire)
- **Architecture** : Domain-Driven (Domain/Services/Actions/DTO)
- **Réponses API** : trait `ApiResponse` unifié

## 🗄️ Base Aronium (ancien logiciel)
- Fichier : `INFO/aronium-database-2026-08-02-12-00.db` (SQLite, 1.6 Mo)
- Contenu : 49 tables, **818 clients**, **125 produits**, **4 648 ventes**
- Migration : `CustomerSeeder` lit et importe automatiquement les clients Aronium
