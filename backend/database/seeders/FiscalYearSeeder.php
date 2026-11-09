<?php

namespace Database\Seeders;

use App\Models\FiscalYear;
use Illuminate\Database\Seeder;

class FiscalYearSeeder extends Seeder
{
    public function run(): void
    {
        FiscalYear::updateOrCreate(
            ['code' => '2025-2026'],
            [
                'name' => 'Exercice 2025-2026',
                'start_date' => '2025-01-01',
                'end_date' => '2026-12-31',
                'is_active' => true,
                'status' => 'open',
                'notes' => 'Exercice d\'activité principal Africa Print Communication.',
            ]
        );
    }
}

