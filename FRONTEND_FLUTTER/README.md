# APC Flutter

Prototype multiplateforme du bureau APC, connecté au backend Laravel.

## Démarrage local

Terminal 1, backend :

```powershell
cd BACKEND_LARAVEL
php artisan serve --host=0.0.0.0 --port=8000
```

Sur une nouvelle base locale, appliquer d’abord les migrations et seeders prévus par le projet. Les deux migrations Inquiry ajoutées en octobre 2026 doivent être exécutées avant d’ouvrir la vue Demandes.

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
- Navigation adaptative : barre latérale desktop, navigation basse sur petit écran.

Les commandes, fichiers, production, pointage, congés, paie, notifications et portail client complet ne sont pas encore implémentés. La vue demandes ne marque pas une commande comme convertie, car le module Commandes n’existe pas encore.

## Plateformes

Flutter Web fonctionne sur le poste de développement actuel. Windows Desktop doit être activé dans le SDK local avant compilation. Android est installé mais les licences Android doivent être acceptées. La compilation, la signature et la publication iOS nécessitent macOS et Xcode, localement ou via un runner macOS.

## Vérifications

```powershell
flutter analyze
flutter test
flutter build web
```