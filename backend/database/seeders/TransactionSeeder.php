<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TransactionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $transactions = [
            [
                'category_id' => 1, // Gaji
                'amount' => 5000000,
                'transaction_date' => now()->subDays(5),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'category_id' => 2, // Bonus
                'amount' => 1000000,
                'transaction_date' => now()->subDays(3),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'category_id' => 4, // Makanan
                'amount' => 50000,
                'transaction_date' => now()->subDays(2),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'category_id' => 5, // Transport
                'amount' => 25000,
                'transaction_date' => now()->subDay(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('transactions')->insert($transactions);
    }
}