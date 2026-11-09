<?php

namespace Database\Factories;

use App\Models\Department;
use App\Models\Order;
use App\Models\WorkOrder;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<WorkOrder>
 */
class WorkOrderFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'order_id' => Order::factory(),
            'department_id' => Department::factory(),
            'work_order_number' => 'OT-'.Str::upper(Str::random(10)),
            'description' => fake()->paragraph(),
            'status' => 'pending',
        ];
    }
}
