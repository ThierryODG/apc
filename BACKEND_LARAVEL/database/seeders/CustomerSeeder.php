<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CustomerSeeder extends Seeder
{
    /**
     * Importe les 818 clients existants depuis la base Aronium (SQLite).
     * En développement, crée quelques clients de démonstration.
     */
    public function run(): void
    {
        // Évite les doublons en cas de re-seeding
        if (Customer::count() > 0) {
            $this->command->warn('Des clients existent déjà. Seeder ignoré.');
            return;
        }

        $aroniumPath = base_path('../../INFO/aronium-database-2026-08-02-12-00.db');

        if (file_exists($aroniumPath)) {
            $this->importFromAronium($aroniumPath);
        } else {
            $this->command->info('Base Aronium non trouvée. Création de clients de démonstration.');
            $this->createDemoCustomers();
        }
    }

    /**
     * Importe depuis la base Aronium SQLite.
     */
    private function importFromAronium(string $dbPath): void
    {
        $pdo     = new \PDO("sqlite:{$dbPath}");
        $stmt    = $pdo->query('SELECT * FROM Customer ORDER BY Id');
        $rows    = $stmt->fetchAll(\PDO::FETCH_ASSOC);
        $total   = count($rows);
        $chunk   = [];
        $now     = now()->toDateTimeString();

        $this->command->info("Importation de {$total} clients Aronium...");
        $bar = $this->command->getOutput()->createProgressBar($total);

        foreach ($rows as $row) {
            // Détermination du type client
            $type = 'individual';
            if (! empty($row['Company'])) {
                $type = 'company';
            }

            $chunk[] = [
                'type'                => $type,
                'name'                => trim($row['Name'] ?? $row['Company'] ?? 'Client inconnu'),
                'trade_name'          => ($type === 'company') ? trim($row['Name'] ?? '') : null,
                'email'               => $this->cleanEmail($row['Email'] ?? null),
                'phone'               => $this->cleanPhone($row['Mobile'] ?? $row['Phone'] ?? null),
                'phone_2'             => ($row['Mobile'] && $row['Phone']) ? $this->cleanPhone($row['Phone']) : null,
                'segment'             => 'regular',
                'acquisition_channel' => 'walk_in',
                'aronium_id'          => (string) $row['Id'],
                'is_active'           => true,
                'created_at'          => $now,
                'updated_at'          => $now,
            ];

            $bar->advance();

            // Insertion par lot de 100
            if (count($chunk) >= 100) {
                Customer::insert($chunk);
                $chunk = [];
            }
        }

        // Dernier lot
        if (! empty($chunk)) {
            Customer::insert($chunk);
        }

        $bar->finish();
        $this->command->newLine();
        $this->command->info("✅ {$total} clients importés avec succès depuis Aronium.");
    }

    /**
     * Crée quelques clients de démonstration si Aronium n'est pas disponible.
     */
    private function createDemoCustomers(): void
    {
        $customers = [
            [
                'type'                => 'company',
                'name'                => 'Entreprise CIMER SA',
                'trade_name'          => 'CIMER',
                'email'               => 'contact@cimer.cm',
                'phone'               => '+237 222 000 001',
                'rccm'                => 'RC/DLA/2010/B/1234',
                'industry'            => 'Construction',
                'segment'             => 'vip',
                'credit_limit'        => 500000,
                'payment_days'        => 30,
                'acquisition_channel' => 'referral',
            ],
            [
                'type'                => 'company',
                'name'                => 'TOTAL Energies Cameroun',
                'email'               => 'daf@total.cm',
                'phone'               => '+237 233 500 200',
                'industry'            => 'Énergie',
                'segment'             => 'vip',
                'credit_limit'        => 1000000,
                'payment_days'        => 30,
                'acquisition_channel' => 'referral',
            ],
            [
                'type'                => 'individual',
                'name'                => 'Marie ESSOMBA',
                'email'               => 'marie.essomba@gmail.com',
                'phone'               => '+237 690 123 456',
                'segment'             => 'regular',
                'acquisition_channel' => 'whatsapp',
            ],
            [
                'type'                => 'individual',
                'name'                => 'Jean-Pierre MBARGA',
                'phone'               => '+237 677 000 789',
                'segment'             => 'occasional',
                'acquisition_channel' => 'walk_in',
            ],
            [
                'type'                => 'company',
                'name'                => 'Université de Douala',
                'email'               => 'achats@univ-douala.cm',
                'phone'               => '+237 233 400 600',
                'industry'            => 'Éducation',
                'segment'             => 'vip',
                'credit_limit'        => 2000000,
                'payment_days'        => 45,
                'acquisition_channel' => 'walk_in',
            ],
        ];

        foreach ($customers as $data) {
            Customer::create(array_merge($data, ['is_active' => true]));
        }

        $this->command->info('✅ 5 clients de démonstration créés.');
    }

    private function cleanEmail(?string $email): ?string
    {
        if (! $email) return null;
        $email = trim($email);
        return filter_var($email, FILTER_VALIDATE_EMAIL) ? strtolower($email) : null;
    }

    private function cleanPhone(?string $phone): ?string
    {
        if (! $phone) return null;
        $phone = trim($phone);
        return strlen($phone) >= 6 ? $phone : null;
    }
}
