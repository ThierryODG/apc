<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\CompanySeeder;
use Database\Seeders\FiscalYearSeeder;
use Database\Seeders\UserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AccountingTest extends TestCase
{
    use RefreshDatabase;

    protected User $accountant;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(CompanySeeder::class);
        $this->seed(FiscalYearSeeder::class);
        $this->seed(UserSeeder::class);

        $this->accountant = User::where('role', 'accounting')->first();
    }

    public function test_accountant_can_view_dashboard(): void
    {
        $response = $this->actingAs($this->accountant)->getJson('/api/accounting/dashboard');

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('scope', 'accounting')
            ->assertJsonStructure([
                'treasury_summary' => [
                    'total_cash_in',
                    'total_cash_out',
                    'net_cash_balance',
                    'total_receivables',
                    'total_expenses',
                ],
                'expenses_by_category',
                'daily_trends',
            ]);
    }

    public function test_accountant_can_record_expense(): void
    {
        $response = $this->actingAs($this->accountant)->postJson('/api/accounting/expenses', [
            'category' => 'Papier & Consommables',
            'beneficiary' => 'Papeterie Moderne SARL',
            'amount' => 150000,
            'payment_method' => 'cash',
            'expense_date' => now()->toDateString(),
            'notes' => 'Achat de 10 cartons de papier 80g',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('expense.amount', '150000.00');

        $this->assertDatabaseHas('expenses', ['beneficiary' => 'Papeterie Moderne SARL']);
        $this->assertDatabaseHas('cash_flows', ['flow_type' => 'out', 'amount' => '150000.00']);
    }

    public function test_accountant_can_open_and_close_daily_register(): void
    {
        // 1. Ouverture de caisse du jour
        $openResponse = $this->actingAs($this->accountant)->postJson('/api/accounting/daily-register/open', [
            'opening_balance' => 25000,
        ]);

        $openResponse->assertStatus(201)
            ->assertJsonPath('success', true)
            ->assertJsonPath('register.opening_balance', '25000.00')
            ->assertJsonPath('register.status', 'open');

        // 2. Consultation de l'état de caisse en direct
        $currentResponse = $this->actingAs($this->accountant)->getJson('/api/accounting/daily-register/current');
        $currentResponse->assertStatus(200)
            ->assertJsonPath('is_open', true)
            ->assertJsonPath('live_calculation.opening_balance', 25000);

        // 3. Clôture de fin de journée (Z-Report)
        $closeResponse = $this->actingAs($this->accountant)->postJson('/api/accounting/daily-register/close', [
            'actual_closing_balance' => 25000,
            'notes' => 'Clôture normale sans écart.',
        ]);

        $closeResponse->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('z_report.status', 'closed')
            ->assertJsonPath('z_report.discrepancy', '0.00');
    }
}

