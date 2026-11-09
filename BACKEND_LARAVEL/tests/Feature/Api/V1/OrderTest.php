<?php

namespace Tests\Feature\Api\V1;

use App\Models\Customer;
use App\Models\Department;
use App\Models\Inquiry;
use App\Models\Order;
use App\Models\User;
use App\Models\WorkOrder;
use Database\Seeders\RoleAndPermissionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrderTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {

        parent::setUp();
        $this->seed(RoleAndPermissionSeeder::class);
    }

    public function test_machiniste_cannot_convert_a_quoted_inquiry(): void
    {
        $department = $this->productionDepartment('NUMERIQUE');
        $machinist = User::factory()->create(['department_id' => $department->id]);
        $machinist->assignRole('Machiniste');
        $inquiry = $this->quotedInquiry();

        $this->withToken($machinist->createToken('orders-test')->plainTextToken)
            ->postJson("/api/v1/inquiries/{$inquiry->id}/convert", [
                'department_id' => $department->id,
            ])
            ->assertForbidden();

        $this->assertDatabaseCount('orders', 0);
        $this->assertDatabaseHas('inquiries', ['id' => $inquiry->id, 'status' => 'quote_sent']);
    }

    public function test_authorized_user_converts_a_quote_into_an_order_and_work_order(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $department = $this->productionDepartment('NUMERIQUE');
        $customer = Customer::factory()->create();
        $inquiry = $this->quotedInquiry($customer);

        $this->withToken($admin->createToken('orders-test')->plainTextToken)
            ->postJson("/api/v1/inquiries/{$inquiry->id}/convert", [
                'department_id' => $department->id,
            ])
            ->assertCreated()
            ->assertJsonPath('data.status', 'received')
            ->assertJsonPath('data.customer.id', $customer->id)
            ->assertJsonPath('data.work_orders.0.department.code', 'NUMERIQUE')
            ->assertJsonPath('data.work_orders.0.status', 'pending');

        $this->assertDatabaseHas('inquiries', ['id' => $inquiry->id, 'status' => 'converted']);
        $this->assertDatabaseHas('orders', [
            'inquiry_id' => $inquiry->id,
            'customer_id' => $customer->id,
            'quoted_total' => 29000,
            'status' => 'received',
        ]);
        $this->assertDatabaseHas('work_orders', [
            'department_id' => $department->id,
            'status' => 'pending',
        ]);
    }

    public function test_a_quoted_inquiry_cannot_be_converted_twice(): void
    {
        $admin = User::where('email', 'admin@africaprint.com')->firstOrFail();
        $department = $this->productionDepartment('PAO');
        $inquiry = $this->quotedInquiry();
        $this->withToken($admin->createToken('orders-test')->plainTextToken);

        $this->postJson("/api/v1/inquiries/{$inquiry->id}/convert", [
            'department_id' => $department->id,
        ])->assertCreated();

        $this->postJson("/api/v1/inquiries/{$inquiry->id}/convert", [
            'department_id' => $department->id,
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['inquiry']);

        $this->assertDatabaseCount('orders', 1);
        $this->assertDatabaseCount('work_orders', 1);
    }

    public function test_machiniste_sees_only_work_orders_in_their_department(): void
    {
        $numerique = $this->productionDepartment('NUMERIQUE');
        $pao = $this->productionDepartment('PAO');
        $machinist = User::factory()->create(['department_id' => $numerique->id]);
        $machinist->assignRole('Machiniste');
        $visibleWorkOrder = $this->workOrder($numerique);
        $this->workOrder($pao);

        $this->withToken($machinist->createToken('orders-test')->plainTextToken)
            ->getJson('/api/v1/work-orders')
            ->assertOk()
            ->assertJsonCount(1, 'data.data')
            ->assertJsonPath('data.data.0.id', $visibleWorkOrder->id);
    }

    public function test_machiniste_advances_a_work_order_and_updates_order_status(): void
    {
        $department = $this->productionDepartment('NUMERIQUE');
        $machinist = User::factory()->create(['department_id' => $department->id]);
        $machinist->assignRole('Machiniste');
        $workOrder = $this->workOrder($department);

        $this->withToken($machinist->createToken('orders-test')->plainTextToken)
            ->patchJson("/api/v1/work-orders/{$workOrder->id}/status", [
                'status' => 'in_progress',
            ])
            ->assertOk()
            ->assertJsonPath('data.status', 'in_progress');

        $this->assertDatabaseHas('work_orders', [
            'id' => $workOrder->id,
            'status' => 'in_progress',
            'status_updated_by' => $machinist->id,
        ]);
        $this->assertDatabaseHas('orders', [
            'id' => $workOrder->order_id,
            'status' => 'in_production',
        ]);
    }

    private function productionDepartment(string $code): Department
    {
        return Department::query()->firstOrCreate(
            ['code' => $code],
            ['name' => $code, 'is_active' => true],
        );
    }

    private function quotedInquiry(?Customer $customer = null): Inquiry
    {
        return Inquiry::factory()->create([
            'customer_id' => $customer?->id,
            'status' => 'quote_sent',
            'quote_amount' => 29000,
            'quote_sent_at' => now(),
        ]);
    }

    private function workOrder(Department $department): WorkOrder
    {
        $inquiry = $this->quotedInquiry();
        $order = Order::factory()->create([
            'inquiry_id' => $inquiry->id,
            'customer_id' => $inquiry->customer_id,
            'status' => 'received',
        ]);

        return WorkOrder::factory()->create([
            'order_id' => $order->id,
            'department_id' => $department->id,
        ]);
    }
}
