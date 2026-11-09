<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Database\Seeders\CompanySeeder;
use Database\Seeders\FiscalYearSeeder;
use Database\Seeders\ProductCatalogSeeder;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SecretaryPosTest extends TestCase
{
    use RefreshDatabase;

    protected User $secretary;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(CompanySeeder::class);
        $this->seed(FiscalYearSeeder::class);
        $this->seed(UserSeeder::class);
        $this->seed(ProductCatalogSeeder::class);

        $this->secretary = User::where('role', 'secretary')->first();
    }

    public function test_secretary_can_view_dashboard(): void
    {
        $response = $this->actingAs($this->secretary)->getJson('/api/secretary/dashboard');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('scope', 'secretary')
            ->assertJsonStructure([
                'summary' => [
                    'today_sales_total',
                    'today_tickets_count',
                    'today_collected',
                    'orders_in_progress',
                ],
            ]);
    }

    public function test_secretary_can_create_customer(): void
    {
        $response = $this->actingAs($this->secretary)->postJson('/api/secretary/customers', [
            'name' => 'M. Konan Jean',
            'phone' => '+225 07 44 55 66 77',
            'email' => 'konan@gmail.com',
            'ifu_number' => '0101998877665',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('customer.name', 'M. Konan Jean');

        $this->assertDatabaseHas('customers', ['name' => 'M. Konan Jean']);
    }

    public function test_secretary_can_create_pos_order_and_get_receipt(): void
    {
        $product = Product::first();
        $customer = Customer::create([
            'code' => 'CLT-TEST-01',
            'name' => 'Client Test Guichet',
            'phone' => '+225 01 02 03 04 05',
        ]);

        // Création commande / ticket avec règlement espèces style Aronium
        $response = $this->actingAs($this->secretary)->postJson('/api/secretary/orders', [
            'customer_id' => $customer->id,
            'items' => [
                [
                    'product_id' => $product->id,
                    'designation' => $product->name,
                    'unit' => $product->unit,
                    'quantity' => 2,
                    'unit_price' => 5000,
                    'tax_rate' => 0,
                    'discount_amount' => 500, // Total attendu : (2*5000) - 500 = 9500
                ],
            ],
            'payment' => [
                'method' => 'cash',
                'amount' => 9500,
                'amount_received' => 10000, // Le client a donné 10 000 FCFA
            ],
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('order.total_amount', '9500.00')
            ->assertJsonPath('order.paid_amount', '9500.00')
            ->assertJsonPath('order.payment_status', 'paid');

        $orderId = $response->json('order.id');

        // Test de l'endpoint de génération de ticket / reçu
        $receiptResponse = $this->actingAs($this->secretary)->getJson("/api/secretary/orders/{$orderId}/receipt");

        $receiptResponse->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('receipt.header.company_name', 'Africa Print Communication')
            ->assertJsonPath('receipt.header.ifu_number', '0202011234567')
            ->assertJsonPath('receipt.totals.total_amount', 9500)
            ->assertJsonPath('receipt.payments.0.amount_received', 10000)
            ->assertJsonPath('receipt.payments.0.change_returned', 500) // Rendu 500 FCFA
            ->assertJsonStructure([
                'receipt' => [
                    'header' => ['company_name', 'ifu_number', 'phones'],
                    'ticket' => ['order_number', 'date', 'cashier'],
                    'customer' => ['name'],
                    'items',
                    'totals' => ['total_amount', 'paid_amount', 'currency'],
                    'payments',
                    'footer' => ['message'],
                ],
            ]);
    }

    public function test_admin_can_manage_catalog_with_dimensions(): void
    {
        $admin = User::where('role', 'admin')->first();

        $createCategory = $this->actingAs($admin)->postJson('/api/admin/catalog/categories', [
            'code' => 'CAT-SIGN',
            'name' => 'Signalétique / Vinyle',
            'description' => 'Bâches, affiches, vinyles',
            'is_active' => true,
        ]);

        $createCategory->assertStatus(201)
            ->assertJsonPath('success', true);

        $categoryId = $createCategory->json('category.id');

        $createProduct = $this->actingAs($admin)->postJson('/api/admin/catalog/products', [
            'category_id' => $categoryId,
            'code' => 'VINYLE-STD',
            'name' => 'Vinyle adhésif standard',
            'description' => 'Impression sur vinyle adhésif',
            'unit' => 'm²',
            'unit_price' => 7500,
            'tax_rate' => 0,
            'allow_dimensions' => true,
            'length_field' => true,
            'width_field' => true,
            'length_label' => 'Longueur (m)',
            'width_label' => 'Largeur (m)',
            'default_length' => 1,
            'default_width' => 1,
        ]);

        $createProduct->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('product.allow_dimensions', true)
            ->assertJsonPath('product.length_field', true)
            ->assertJsonPath('product.width_field', true);

        $productId = $createProduct->json('product.id');

        $getCatalog = $this->actingAs($admin)->getJson('/api/admin/catalog');
        $getCatalog->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonFragment([
                'code' => 'VINYLE-STD',
                'allow_dimensions' => true,
                'length_field' => true,
                'width_field' => true,
            ]);

        $update = $this->actingAs($admin)->putJson("/api/admin/catalog/products/{$productId}", [
            'name' => 'Vinyle adhésif premium',
            'unit_price' => 9000,
            'allow_dimensions' => true,
            'length_field' => true,
            'width_field' => true,
            'default_length' => 2,
            'default_width' => 1.5,
        ]);

        $update->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('product.name', 'Vinyle adhésif premium')
            ->assertJsonPath('product.default_length', '2.00')
            ->assertJsonPath('product.default_width', '1.50');

        $delete = $this->actingAs($admin)->deleteJson("/api/admin/catalog/products/{$productId}");
        $delete->assertStatus(200)
            ->assertJsonPath('success', true);
    }
}

