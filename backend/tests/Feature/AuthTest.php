<?php

namespace Tests\Feature;

use App\Models\FiscalYear;
use App\Models\User;
use Database\Seeders\CompanySeeder;
use Database\Seeders\FiscalYearSeeder;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(CompanySeeder::class);
        $this->seed(FiscalYearSeeder::class);
        $this->seed(UserSeeder::class);
    }

    public function test_user_can_login_with_valid_credentials(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'secretaire@africaprint.com',
            'password' => 'secretariat123',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('user.role', 'secretary')
            ->assertJsonStructure([
                'token',
                'user' => ['id', 'name', 'email', 'role'],
                'active_fiscal_year' => ['id', 'name', 'code'],
                'company' => ['name', 'ifu_number'],
            ]);
    }

    public function test_login_fails_with_invalid_password(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'secretaire@africaprint.com',
            'password' => 'wrong_password',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    public function test_authenticated_user_can_retrieve_profile(): void
    {
        $user = User::where('email', 'admin@africaprint.com')->first();

        $response = $this->actingAs($user)->getJson('/api/auth/me');

        $response->assertStatus(200)
            ->assertJsonPath('user.role', 'admin')
            ->assertJsonPath('company.name', 'Africa Print Communication');
    }
}

