<?php

namespace Database\Seeders;

use App\Models\Company;
use Illuminate\Database\Seeder;

class CompanySeeder extends Seeder
{
    public function run(): void
    {
        Company::updateOrCreate(
            ['id' => 1],
            [
                'name' => 'Africa Print Communication',
                'legal_form' => 'SARL',
                'ifu_number' => '0202011234567',
                'rccm_number' => 'CI-ABJ-2024-B-12345',
                'phone_primary' => '+225 07 00 00 00 01',
                'phone_secondary' => '+225 05 00 00 00 02',
                'email' => 'contact@africaprint.com',
                'address' => 'Boulevard Principal, Face Pharmacie Centrale',
                'city' => 'Abidjan',
                'currency' => 'FCFA',
                'logo_path' => null,
                'receipt_header' => 'IMPRIMERIE - SÉRIGRAPHIE - GADGETS & COMMUNICATION VISUELLE',
                'receipt_footer' => 'Merci de votre confiance ! Les travaux imprimés vérifiés et livrés ne sont ni repris ni échangés.',
            ]
        );
    }
}

