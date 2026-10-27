<?php

namespace Tests\Feature\Api\V1;

use App\Models\Customer;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CustomerTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed(RoleAndPermissionSeeder::class);
    }

    public function test_customer_routes_require_authentication(): void
    {
        $this->getJson('/api/v1/customers')
            ->assertUnauthorized()
            ->assertJson([
                'success' => false,
                'message' => 'Non authentifié. Veuillez vous connecter.',
            ]);
    }

    public function test_user_without_customer_permission_is_forbidden(): void
    {
        $user = User::factory()->create();
        $user->assignRole('Machiniste');

        $this->withToken($user->createToken('customer-test')->plainTextToken)
            ->getJson('/api/v1/customers')
            ->assertForbidden()
            ->assertJson([
                'success' => false,
                'message' => 'Action non autorisée. Permissions insuffisantes.',
            ]);
    }

    public function test_authorized_user_can_create_customer_with_contact_and_address(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $this->withToken($admin->createToken('customer-test')->plainTextToken);

        $this->postJson('/api/v1/customers', [
            'type' => 'company',
            'name' => 'Imprimerie Exemple',
            'trade_name' => 'Exemple Print',
            'email' => 'contact@exemple.test',
            'segment' => 'regular',
            'acquisition_channel' => 'whatsapp',
            'contact' => [
                'first_name' => 'Amina',
                'last_name' => 'Diallo',
                'phone' => '+2250102030405',
                'receives_quotes' => true,
            ],
            'address' => [
                'address_line_1' => 'Rue du Commerce',
                'city' => 'Abidjan',
            ],
        ])->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.name', 'Imprimerie Exemple')
            ->assertJsonPath('data.contacts.0.first_name', 'Amina')
            ->assertJsonPath('data.addresses.0.address_line_1', 'Rue du Commerce');

        $this->assertDatabaseHas('customers', [
            'name' => 'Imprimerie Exemple',
            'created_by' => $admin->id,
        ]);
        $this->assertDatabaseHas('customer_contacts', [
            'first_name' => 'Amina',
            'is_primary' => true,
        ]);
        $this->assertDatabaseHas('customer_addresses', [
            'address_line_1' => 'Rue du Commerce',
            'type' => 'both',
            'is_default' => true,
        ]);
    }

    public function test_authorized_user_can_list_show_update_toggle_and_archive_customer(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $this->withToken($admin->createToken('customer-test')->plainTextToken);
        $customer = Customer::create([
            'type' => 'individual',
            'name' => 'Client Initial',
            'email' => 'initial@exemple.test',
            'created_by' => $admin->id,
        ]);

        $this->getJson('/api/v1/customers')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.data.0.name', 'Client Initial');

        $this->getJson("/api/v1/customers/{$customer->id}")
            ->assertOk()
            ->assertJsonPath('data.name', 'Client Initial');

        $this->patchJson("/api/v1/customers/{$customer->id}", [
            'name' => 'Client Modifié',
        ])->assertOk()
            ->assertJsonPath('data.name', 'Client Modifié');

        $this->patchJson("/api/v1/customers/{$customer->id}/toggle-status")
            ->assertOk()
            ->assertJsonPath('data.is_active', false);

        $this->deleteJson("/api/v1/customers/{$customer->id}")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertSoftDeleted('customers', ['id' => $customer->id]);
    }

    public function test_authorized_user_can_add_customer_contact_and_address(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $this->withToken($admin->createToken('customer-test')->plainTextToken);
        $customer = Customer::create([
            'type' => 'company',
            'name' => 'Société Exemple',
            'created_by' => $admin->id,
        ]);

        $this->postJson("/api/v1/customers/{$customer->id}/contacts", [
            'first_name' => 'Koffi',
            'last_name' => 'Yao',
            'is_primary' => true,
        ])->assertCreated()
            ->assertJsonPath('data.contacts.0.first_name', 'Koffi');

        $this->postJson("/api/v1/customers/{$customer->id}/addresses", [
            'type' => 'delivery',
            'address_line_1' => 'Avenue des Arts',
            'city' => 'Abidjan',
            'is_default' => true,
        ])->assertCreated()
            ->assertJsonPath('data.addresses.0.address_line_1', 'Avenue des Arts');
    }
}
