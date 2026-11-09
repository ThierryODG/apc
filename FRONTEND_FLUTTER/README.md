# APC Flutter

Application Flutter multiplateforme pour les espaces internes APC, connectée au backend Laravel. Le code métier et les dépôts sont partagés; les présentations sont séparées par fonctionnalité et peuvent varier entre desktop et mobile.

## Démarrage local

Terminal 1, backend :

```powershell
cd BACKEND_LARAVEL
php artisan serve --host=0.0.0.0 --port=8000
```

Sur une nouvelle base locale, appliquer d’abord les migrations et seeders prévus par le projet. Les migrations Inquiry, commandes et ordres de travail doivent être exécutées avant d’utiliser leurs parcours.

Terminal 2, Flutter Web :

```powershell
cd FRONTEND_FLUTTER
flutter pub get
flutter run -d chrome --dart-define=APC_API_BASE_URL=http://127.0.0.1:8000
```

Le compte local initial du `RoleAndPermissionSeeder` est `admin@africaprint.com`; son mot de passe de développement est déclaré dans ce seeder. Le remplacer avant tout environnement partagé ou de production.

Pour un émulateur Android, l’URL par défaut utilise `10.0.2.2:8000`. Depuis un téléphone physique, utiliser l’adresse LAN du PC et la passer à `APC_API_BASE_URL`; le pare-feu Windows doit laisser passer le port choisi.

## Parcours disponibles

- Connexion interne avec Sanctum Bearer Token.
- Vue d’ensemble avec comptes provenant de l’API.
- Consultation du catalogue.
- Liste et création de clients.
- Liste, création, qualification, suivi du devis et refus des demandes entrantes.
- Espace de production machiniste : file filtrée par l’API, évolution de statut, table desktop et cartes tactiles mobile.
- Navigation par rôle et permission; les espaces direction, comptabilité et PAO sont séparés mais explicitement en préparation.

La conversion de devis en commande est disponible dans l’API; le bouton de conversion reste à ajouter à l’interface secrétariat. Les fichiers, le contrôle qualité, les stocks, le pointage, les congés, la paie, les notifications et le portail client ne sont pas encore disponibles.

## Organisation du code

- `lib/app/` : composition globale et session.
- `lib/core/` : thème, rôles et utilitaires partagés.
- `lib/features/<domaine>/` : code par fonctionnalité et couches `application`, `data`, `domain`, `presentation` selon besoin.
- `lib/features/production/presentation/` : vues production desktop et mobile distinctes.
- `lib/shared/` : composants de présentation réutilisables.
- `lib/data/` : transport HTTP commun; les dépôts propres à chaque fonctionnalité l’utilisent.

## Plateformes

Flutter Web fonctionne sur le poste de développement actuel. Windows Desktop doit être activé dans le SDK local avant compilation. Android est installé mais les licences Android doivent être acceptées. La compilation, la signature et la publication iOS nécessitent macOS et Xcode, localement ou via un runner macOS.

## Vérifications

```powershell
flutter analyze
flutter test
flutter build web
```

Vérification courte des espaces de connexion et de production :

```powershell
flutter test test/widget_test.dart
```