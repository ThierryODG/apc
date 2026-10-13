<?php

namespace Database\Seeders;

use App\Models\Department;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RoleAndPermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Réinitialiser le cache des permissions Spatie
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        // 1. Départements / Services de l'imprimerie
        $departments = [
            [
                'name' => 'Direction Générale',
                'code' => 'DIRECTION',
                'description' => 'Supervision stratégique, validation générale et pilotage global.'
            ],
            [
                'name' => 'Secrétariat & Commercial',
                'code' => 'SECRETARIAT',
                'description' => 'Accueil des clients, réception des demandes (WhatsApp, guichet), commandes.'
            ],
            [
                'name' => 'PAO & Graphisme',
                'code' => 'PAO',
                'description' => 'Vérification, préparation et mise aux normes des fichiers clients.'
            ],
            [
                'name' => 'Atelier Numérique & Grand Format',
                'code' => 'NUMERIQUE',
                'description' => 'Impression bâche, vinyle, affiches et supports grands formats.'
            ],
            [
                'name' => 'Atelier Sérigraphie & Textiles',
                'code' => 'SERIGRAPHIE',
                'description' => 'Marquage textile, tee-shirts, casquettes et objets publicitaires.'
            ],
            [
                'name' => 'Façonnage & Finition',
                'code' => 'FINITION',
                'description' => 'Découpe, laminage, pose d\'œillets, collage et emballage.'
            ],
            [
                'name' => 'Comptabilité & Caisse',
                'code' => 'COMPTABILITE',
                'description' => 'Encaissements, facturation, suivi des soldes et gestion financière.'
            ],
        ];

        $deptModels = [];
        foreach ($departments as $dept) {
            $deptModels[$dept['code']] = Department::updateOrCreate(
                ['code' => $dept['code']],
                $dept
            );
        }

        // 2. Permissions granulaires côté serveur
        $permissions = [
            // Clients
            'customers.view',
            'customers.create',
            'customers.edit',
            'customers.delete',
            'customers.view_notes',

            // Demandes entrantes (WhatsApp, accueil)
            'inquiries.view',
            'inquiries.create',
            'inquiries.edit',
            'inquiries.convert',

            // Prestations & Tarifs
            'catalog.view',
            'catalog.edit',

            // Commandes & Ordres de travail
            'orders.view',
            'orders.create',
            'orders.edit',
            'orders.validate',
            'orders.cancel',
            'orders.close',

            // Fichiers
            'files.view',
            'files.upload',
            'files.download',
            'files.validate_prep',
            'files.delete',

            // Production & Ateliers
            'production.view_queue',
            'production.update_status',
            'production.record_waste',
            'production.declare_incident',
            'production.quality_check',

            // Finances & Paiements
            'finance.view',
            'finance.record_payment',
            'finance.cancel_payment',
            'finance.export',

            // Stock & Consommables
            'inventory.view',
            'inventory.record_movement',
            'inventory.adjust',
            'inventory.manage_items',

            // RH & Présences
            'hr.view_employees',
            'hr.manage_employees',
            'hr.record_attendance',
            'hr.manage_leaves',

            // Paie & Rémunération (Strictement isolé)
            'payroll.view',
            'payroll.edit',
            'payroll.validate',

            // Équipements & Maintenance
            'maintenance.view',
            'maintenance.record',

            // Paramètres & Administration
            'settings.manage',
            'users.manage',
            'audit.view',
        ];

        foreach ($permissions as $permissionName) {
            Permission::findOrCreate($permissionName, 'web');
        }

        // 3. Rôles et affectation des permissions
        // Rôle Super Administrateur (Toutes permissions)
        $superAdminRole = Role::findOrCreate('SuperAdmin', 'web');
        $superAdminRole->syncPermissions(Permission::all());

        // Rôle Direction Générale
        $dirRole = Role::findOrCreate('DirecteurGeneral', 'web');
        $dirRole->syncPermissions(Permission::all());

        // Rôle Secrétariat
        $secRole = Role::findOrCreate('Secretaire', 'web');
        $secRole->syncPermissions([
            'customers.view', 'customers.create', 'customers.edit',
            'inquiries.view', 'inquiries.create', 'inquiries.edit', 'inquiries.convert',
            'catalog.view',
            'orders.view', 'orders.create', 'orders.edit',
            'files.view', 'files.upload', 'files.download',
            'production.view_queue',
            'finance.view', 'finance.record_payment',
            'inventory.view',
            'hr.record_attendance',
        ]);

        // Rôle Graphiste / PAO
        $graphRole = Role::findOrCreate('Graphiste', 'web');
        $graphRole->syncPermissions([
            'orders.view',
            'files.view', 'files.upload', 'files.download', 'files.validate_prep',
            'production.view_queue', 'production.update_status',
            'hr.record_attendance',
        ]);

        // Rôle Machiniste / Opérateur Atelier
        $machRole = Role::findOrCreate('Machiniste', 'web');
        $machRole->syncPermissions([
            'orders.view',
            'files.view', 'files.download',
            'production.view_queue', 'production.update_status', 'production.record_waste', 'production.declare_incident',
            'inventory.view', 'inventory.record_movement',
            'hr.record_attendance',
        ]);

        // Rôle Comptabilité
        $comptaRole = Role::findOrCreate('Comptable', 'web');
        $comptaRole->syncPermissions([
            'customers.view',
            'orders.view',
            'finance.view', 'finance.record_payment', 'finance.cancel_payment', 'finance.export',
            'inventory.view',
            'payroll.view', 'payroll.edit', 'payroll.validate',
            'hr.view_employees', 'hr.record_attendance',
        ]);

        // 4. Utilisateur administrateur par défaut
        $admin = User::updateOrCreate(
            ['email' => 'admin@africaprint.com'],
            [
                'name' => 'Administrateur APC',
                'password' => Hash::make('Admin@APC2026!'),
                'department_id' => $deptModels['DIRECTION']->id,
                'phone' => '+225 0102030405',
                'is_active' => true,
                'email_verified_at' => now(),
            ]
        );

        $admin->syncRoles([$superAdminRole]);
    }
}
