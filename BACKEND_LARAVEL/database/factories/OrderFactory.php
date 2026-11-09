<?php

namespace Database\Factories;

use App\Models\Customer;
use App\Models\Inquiry;
use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<Order>
 */
class OrderFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'inquiry_id' => Inquiry::factory(),
            'customer_id' => Customer::factory(),
            'created_by' => User::factory(),
            'order_number' => 'CMD-'.now()->format('Y').'-'.Str::upper(Str::random(8)),
            'source' => 'walk_in',
            'contact_name' => fake()->name(),
            'subject' => fake()->sentence(4),
            'description' => fake()->paragraph(),
            'quoted_total' => fake()->randomFloat(2, 1000, 1000000),
            'status' => 'received',
            'ordered_at' => now(),
        ];
    }
}
