<?php

namespace Tests\Feature\Api\V1;

use App\Models\PrintService;
use App\Models\ServiceOption;
use App\Models\User;
use Database\Seeders\CatalogSeeder;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CatalogTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->seed(RoleAndPermissionSeeder::class);
        $this->seed(CatalogSeeder::class);
    }

    public function test_can_list_active_catalog(): void
    {
        $response = $this->getJson('/api/v1/catalog');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'code',
                        'services' => [
                            '*' => [
                                'id',
                                'name',
                                'code',
                                'pricing_type',
                                'unit_price',
                                'unit',
                            ],
                        ],
                    ],
                ],
            ])
            ->assertJson([
                'success' => true,
            ]);
    }

    public function test_can_list_units(): void
    {
        $response = $this->getJson('/api/v1/catalog/units');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonFragment(['code' => 'M2'])
            ->assertJsonFragment(['code' => 'PIECE']);
    }

    public function test_can_show_service_detail(): void
    {
        $service = PrintService::where('code', 'IMP-BACHE-440')->first();

        $response = $this->getJson("/api/v1/catalog/services/{$service->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $service->id,
                    'code' => 'IMP-BACHE-440',
                    'pricing_type' => 'surface',
                    'unit_price' => 2000.0,
                ],
            ]);
    }

    public function test_can_calculate_surface_printing_price_correctly(): void
    {
        $bache = PrintService::where('code', 'IMP-BACHE-440')->first();
        $oeillet = ServiceOption::where('code', 'OEILLETS')->first();

        // 2 bâches de 200cm x 300cm (2m x 3m = 6m² par bâche, soit 12m² au total)
        // Prix de base = 12m² * 2000 FCFA = 24 000 FCFA
        // Périmètre par bâche = 2 * (2 + 3) = 10m. Pour 2 bâches = 20m.
        // Coût œillets = 20m * 250 FCFA = 5 000 FCFA
        // Total attendu = 24 000 + 5 000 = 29 000 FCFA
        $response = $this->postJson('/api/v1/catalog/calculate-price', [
            'service_id' => $bache->id,
            'quantity' => 2,
            'width_cm' => 200,
            'height_cm' => 300,
            'option_ids' => [$oeillet->id],
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'quantity' => 2.0,
                    'base_price' => 24000.0,
                    'options_total' => 5000.0,
                    'total_price' => 29000.0,
                    'currency' => 'XOF',
                    'dimensions' => [
                        'width_cm' => 200.0,
                        'height_cm' => 300.0,
                        'total_surface_sqm' => 12.0,
                        'perimeter_meters' => 10.0,
                    ],
                ],
            ]);
    }

    public function test_calculate_price_enforces_dimensions_for_surface_service(): void
    {
        $bache = PrintService::where('code', 'IMP-BACHE-440')->first();

        // Tentative de calcul sans dimensions pour une bâche
        $response = $this->postJson('/api/v1/catalog/calculate-price', [
            'service_id' => $bache->id,
            'quantity' => 1,
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
            ]);
    }

    public function test_can_calculate_fixed_unit_price(): void
    {
        $dtf = PrintService::where('code', 'DTF-A3')->first();

        // 5 transferts DTF A3 à 1 000 FCFA l'unité = 5 000 FCFA
        $response = $this->postJson('/api/v1/catalog/calculate-price', [
            'service_id' => $dtf->id,
            'quantity' => 5,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'quantity' => 5.0,
                    'base_price' => 5000.0,
                    'total_price' => 5000.0,
                ],
            ]);
    }

    public function test_authorized_user_can_update_price_and_audit_history_is_created(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->first();
        $token = $admin->createToken('test-token')->plainTextToken;
        $service = PrintService::where('code', 'IMP-BACHE-440')->first();

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->patchJson("/api/v1/catalog/services/{$service->id}/price", [
                'unit_price' => 2200.0,
                'reason' => 'Augmentation du coût de la matière première',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'unit_price' => 2200.0,
                ],
            ]);

        // Vérification en base de données du prix mis à jour
        $this->assertDatabaseHas('print_services', [
            'id' => $service->id,
            'unit_price' => 2200.0,
        ]);

        // Vérification de la création de la ligne d'audit
        $this->assertDatabaseHas('price_histories', [
            'print_service_id' => $service->id,
            'user_id' => $admin->id,
            'old_price' => 2000.0,
            'new_price' => 2200.0,
            'reason' => 'Augmentation du coût de la matière première',
        ]);
    }

    public function test_unauthorized_user_cannot_update_price(): void
    {
        // Création d'un utilisateur machiniste sans la permission catalog.edit
        $machiniste = User::factory()->create([
            'email' => 'machiniste@africaprint.com',
            'is_active' => true,
        ]);
        $machiniste->assignRole('Machiniste');
        $token = $machiniste->createToken('test-token')->plainTextToken;

        $service = PrintService::where('code', 'IMP-BACHE-440')->first();

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->patchJson("/api/v1/catalog/services/{$service->id}/price", [
                'unit_price' => 3000.0,
                'reason' => 'Tentative non autorisée',
            ]);

        $response->assertStatus(403)
            ->assertJson([
                'success' => false,
                'message' => 'Action non autorisée. Permissions insuffisantes.',
            ]);

        // Le prix ne doit pas avoir changé
        $this->assertDatabaseHas('print_services', [
            'id' => $service->id,
            'unit_price' => 2000.0,
        ]);
    }
}
