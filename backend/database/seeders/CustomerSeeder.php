<?php

namespace Database\Seeders;

use App\Models\Customer;
use Illuminate\Database\Seeder;

class CustomerSeeder extends Seeder
{
    public function run(): void
    {
        Customer::updateOrCreate(
            ['code' => 'CLT-00001'],
            [
                'name' => 'Cabinet d\'Avocats Juris-Consult',
                'phone' => '+225 07 20 20 20 20',
                'email' => 'contact@jurisconsult.ci',
                'address' => 'Plateau, Immeuble Trade Center',
                'city' => 'Abidjan',
                'ifu_number' => '0201998877665',
                'notes' => 'Client régulier pour dossiers et mémoires.',
                'is_active' => true,
            ]
        );

        Customer::updateOrCreate(
            ['code' => 'CLT-00002'],
            [
                'name' => 'Agence Événementielle Prestige Event',
                'phone' => '+225 05 33 44 55 66',
                'email' => 'info@prestigeevent.ci',
                'address' => 'Cocody Angré 7e Tranche',
                'city' => 'Abidjan',
                'ifu_number' => '0304556677889',
                'notes' => 'Commandes de bâches et roll-ups.',
                'is_active' => true,
            ]
        );
    }
}
