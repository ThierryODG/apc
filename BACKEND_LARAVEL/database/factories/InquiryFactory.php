<?php

namespace Database\Factories;

use App\Models\Inquiry;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Inquiry>
 */
class InquiryFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'source' => fake()->randomElement(['whatsapp', 'phone', 'walk_in', 'email', 'referral', 'other']),
            'contact_name' => fake()->name(),
            'subject' => fake()->sentence(4),
            'description' => fake()->paragraph(),
            'status' => 'new',
        ];
    }
}
