<?php

namespace Database\Factories;

use App\Models\Transaction;
use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

class TransactionFactory extends Factory
{
    protected $model = Transaction::class;

    public function definition(): array
    {
        return [
            'category_id' => Category::factory(),
            'amount' => $this->faker->randomFloat(2, 10, 10000),
            'transaction_date' => $this->faker->dateTimeBetween('-1 month', 'now'),
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }
}