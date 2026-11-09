<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\CompanySeeder;
use Database\Seeders\FiscalYearSeeder;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RolePermissionsTest extends TestCase
{
    use RefreshDatabase;

    protected User $admin;
    protected User $secretary;
    protected User $accountant;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(CompanySeeder::class);
        $this->seed(FiscalYearSeeder::class);
        $this->seed(UserSeeder::class);

        $this->admin = User::where('role', 'admin')->first();
        $this->secretary = User::where('role', 'secretary')->first();
        $this->accountant = User::where('role', 'accounting')->first();
    }

    public function test_secretary_cannot_access_accounting_dashboard(): void
    {
        $response = $this->actingAs($this->secretary)->getJson('/api/accounting/dashboard');
        $response->assertStatus(403)
            ->assertJsonPath('success', false);
    }

    public function test_accountant_cannot_access_secretary_orders(): void
    {
        $response = $this->actingAs($this->accountant)->getJson('/api/secretary/orders');
        $response->assertStatus(403)
            ->assertJsonPath('success', false);
    }

    public function test_secretary_cannot_access_admin_company_settings(): void
    {
        $response = $this->actingAs($this->secretary)->getJson('/api/admin/company');
        $response->assertStatus(403);
    }

    public function test_admin_has_full_access(): void
    {
        $this->actingAs($this->admin)->getJson('/api/admin/dashboard')->assertStatus(200);
        $this->actingAs($this->admin)->getJson('/api/secretary/dashboard')->assertStatus(200);
        $this->actingAs($this->admin)->getJson('/api/accounting/dashboard')->assertStatus(200);
    }
}
