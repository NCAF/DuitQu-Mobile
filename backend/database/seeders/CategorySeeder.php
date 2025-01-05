<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            // Kategori Pemasukan
            [
                'name' => 'Gaji',
                'type' => 'income',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Bonus',
                'type' => 'income',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Investasi',
                'type' => 'income',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Kategori Pengeluaran
            [
                'name' => 'Makanan',
                'type' => 'expense',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Transport',
                'type' => 'expense',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Belanja',
                'type' => 'expense',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('categories')->insert($categories);
    }
}