<?php

namespace Tests\Feature\Api\V1;

use App\Models\Department;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Exécuter les seeders pour disposer des départements et rôles
        $this->seed(\Database\Seeders\RoleAndPermissionSeeder::class);
    }

    public function test_login_requires_email_and_password(): void
    {
        $response = $this->postJson('/api/v1/auth/login', []);

        $response->assertStatus(422)
            ->assertJsonStructure([
                'success',
                'message',
                'errors' => ['email', 'password'],
            ])
            ->assertJson([
                'success' => false,
            ]);
    }

    public function test_login_fails_with_invalid_credentials(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'admin@africaprint.com',
            'password' => 'WrongPassword!',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'success' => false,
                'message' => 'Identifiants incorrects. Veuillez vérifier votre email et mot de passe.',
            ]);
    }

    public function test_login_succeeds_with_valid_credentials(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'admin@africaprint.com',
            'password' => 'Admin@APC2026!',
            'device_name' => 'desktop-test',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'token',
                    'token_type',
                    'user' => [
                        'id',
                        'name',
                        'email',
                        'department' => ['id', 'name', 'code'],
                        'roles',
                        'permissions',
                    ],
                ],
            ])
            ->assertJson([
                'success' => true,
                'data' => [
                    'token_type' => 'Bearer',
                    'user' => [
                        'email' => 'admin@africaprint.com',
                        'department' => [
                            'code' => 'DIRECTION',
                        ],
                    ],
                ],
            ]);
    }

    public function test_me_endpoint_requires_authentication(): void
    {
        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(401)
            ->assertJson([
                'success' => false,
                'message' => 'Non authentifié. Veuillez vous connecter.',
            ]);
    }

    public function test_authenticated_user_can_access_me_and_logout(): void
    {
        $user = User::where('email', 'admin@africaprint.com')->first();
        $token = $user->createToken('test-token')->plainTextToken;

        // Test /me
        $meResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/v1/auth/me');

        $meResponse->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'user' => [
                        'email' => 'admin@africaprint.com',
                    ],
                ],
            ]);

        // Test /logout
        $logoutResponse = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/v1/auth/logout');

        $logoutResponse->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        // Le token a été supprimé
        $this->assertDatabaseMissing('personal_access_tokens', [
            'tokenable_id' => $user->id,
            'name' => 'test-token',
        ]);
    }
}
