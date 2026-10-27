<?php

namespace Tests\Feature\Api\V1;

use App\Models\Customer;
use App\Models\Inquiry;
use App\Models\User;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InquiryTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);
    }

    public function test_inquiry_routes_require_authentication(): void
    {
        $this->getJson('/api/v1/inquiries')
            ->assertUnauthorized()
            ->assertJsonPath('message', 'Non authentifié. Veuillez vous connecter.');
    }

    public function test_user_without_inquiry_permission_is_forbidden(): void
    {
        $user = User::factory()->create();
        $user->assignRole('Machiniste');

        $this->withToken($user->createToken('inquiry-test')->plainTextToken)
            ->getJson('/api/v1/inquiries')
            ->assertForbidden()
            ->assertJsonPath('message', 'Action non autorisée. Permissions insuffisantes.');
    }

    public function test_machiniste_cannot_create_an_inquiry(): void
    {
        $user = User::factory()->create();
        $user->assignRole('Machiniste');

        $this->withToken($user->createToken('inquiry-test')->plainTextToken)
            ->postJson('/api/v1/inquiries', [
                'source' => 'walk_in',
                'contact_name' => 'Client test',
                'subject' => 'Impression test',
                'description' => 'Une demande de test.',
            ])->assertForbidden();
    }

    public function test_inquiry_creation_returns_422_for_an_unsupported_source(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();

        $this->withToken($admin->createToken('inquiry-test')->plainTextToken)
            ->postJson('/api/v1/inquiries', [
                'source' => 'unknown_channel',
                'contact_name' => 'Client test',
                'subject' => 'Impression test',
                'description' => 'Une demande de test.',
            ])->assertUnprocessable()
            ->assertJsonValidationErrors(['source']);
    }

    public function test_authorized_user_can_create_and_list_an_inquiry(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $customer = Customer::create([
            'type' => 'company',
            'name' => 'Client demandeur',
            'created_by' => $admin->id,
        ]);
        $this->withToken($admin->createToken('inquiry-test')->plainTextToken);

        $this->postJson('/api/v1/inquiries', [
            'customer_id' => $customer->id,
            'source' => 'whatsapp',
            'contact_name' => 'Awa Kouassi',
            'contact_phone' => '+2250102030405',
            'subject' => 'Impression bâches',
            'description' => 'Besoin de deux bâches grand format.',
        ])->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'new')
            ->assertJsonPath('data.source', 'whatsapp')
            ->assertJsonPath('data.customer.id', $customer->id);

        $this->assertDatabaseHas('inquiries', [
            'customer_id' => $customer->id,
            'created_by' => $admin->id,
            'status' => 'new',
        ]);

        $this->getJson('/api/v1/inquiries?status=new')
            ->assertOk()
            ->assertJsonPath('data.data.0.subject', 'Impression bâches');
    }

    public function test_inquiry_workflow_requires_qualification_before_quote(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $this->withToken($admin->createToken('inquiry-test')->plainTextToken);
        $inquiry = $this->createInquiry($admin);

        $this->patchJson("/api/v1/inquiries/{$inquiry->id}/quote", [
            'quote_amount' => 29000,
        ])->assertUnprocessable();

        $this->patchJson("/api/v1/inquiries/{$inquiry->id}/qualify")
            ->assertOk()
            ->assertJsonPath('data.status', 'qualified');

        $this->patchJson("/api/v1/inquiries/{$inquiry->id}/quote", [
            'quote_amount' => 29000,
        ])->assertOk()
            ->assertJsonPath('data.status', 'quote_sent')
            ->assertJsonPath('data.quote_amount', 29000);
    }

    public function test_inquiry_can_be_refused_from_an_open_workflow_state(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $this->withToken($admin->createToken('inquiry-test')->plainTextToken);
        $inquiry = $this->createInquiry($admin);

        $this->patchJson("/api/v1/inquiries/{$inquiry->id}/refuse", [
            'reason' => 'Le client a annulé sa demande.',
        ])->assertOk()
            ->assertJsonPath('data.status', 'refused')
            ->assertJsonPath('data.refusal_reason', 'Le client a annulé sa demande.');
    }

    public function test_refused_inquiry_returns_422_when_qualified_again(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $this->withToken($admin->createToken('inquiry-test')->plainTextToken);
        $inquiry = $this->createInquiry($admin);

        $this->patchJson("/api/v1/inquiries/{$inquiry->id}/refuse", [
            'reason' => 'Le client a annulé sa demande.',
        ])->assertOk();

        $this->patchJson("/api/v1/inquiries/{$inquiry->id}/qualify")
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Seule une demande nouvelle peut être qualifiée.');

        $this->assertDatabaseHas('inquiries', [
            'id' => $inquiry->id,
            'status' => 'refused',
        ]);
    }

    public function test_authorized_user_can_view_and_update_an_open_inquiry(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $this->withToken($admin->createToken('inquiry-test')->plainTextToken);
        $inquiry = $this->createInquiry($admin);

        $this->patchJson("/api/v1/inquiries/{$inquiry->id}", [
            'subject' => 'Sujet corrigé',
        ])->assertOk()
            ->assertJsonPath('data.subject', 'Sujet corrigé');

        $this->getJson("/api/v1/inquiries/{$inquiry->id}")
            ->assertOk()
            ->assertJsonPath('data.subject', 'Sujet corrigé');

        $this->assertDatabaseHas('inquiries', [
            'id' => $inquiry->id,
            'subject' => 'Sujet corrigé',
        ]);
    }

    private function createInquiry(User $creator): Inquiry
    {
        return Inquiry::create([
            'source' => 'walk_in',
            'contact_name' => 'Client sans fiche',
            'subject' => 'Impression test',
            'description' => 'Demande de test',
            'status' => 'new',
            'created_by' => $creator->id,
        ]);
    }
}
