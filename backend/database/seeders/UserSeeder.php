<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Profil Administrateur
        User::updateOrCreate(
            ['email' => 'admin@africaprint.com'],
            [
                'name' => 'Directeur Général (Admin)',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'phone' => '+225 07 10 20 30 40',
                'is_active' => true,
            ]
        );

        // 2. Profil Secrétariat / Caisse (POS Aronium)
        User::updateOrCreate(
            ['email' => 'secretaire@africaprint.com'],
            [
                'name' => 'Secrétaire Commerciale (Guichet)',
                'password' => Hash::make('secretariat123'),
                'role' => 'secretary',
                'phone' => '+225 07 11 22 33 44',
                'is_active' => true,
            ]
        );

        // 3. Profil Comptabilité
        User::updateOrCreate(
            ['email' => 'comptable@africaprint.com'],
            [
                'name' => 'Responsable Comptable & Financier',
                'password' => Hash::make('compta123'),
                'role' => 'accounting',
                'phone' => '+225 07 55 66 77 88',
                'is_active' => true,
            ]
        );
    }
}

