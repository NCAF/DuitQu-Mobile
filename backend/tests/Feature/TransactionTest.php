<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Category;
use App\Models\Transaction;
use Illuminate\Foundation\Testing\RefreshDatabase;

class TransactionTest extends TestCase
{
    use RefreshDatabase;

    private $category;

    protected function setUp(): void
    {
        parent::setUp();
        $this->category = Category::factory()->create(['type' => 'expense']);
    }

    /**
     * Test get all transactions.
     */
    public function test_can_get_all_transactions(): void
    {
        Transaction::factory()->count(3)->create([
            'category_id' => $this->category->id
        ]);

        $response = $this->getJson('/api/transactions');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'data' => [
                    '*' => [
                        'id',
                        'category_id',
                        'amount',
                        'transaction_date',
                        'created_at',
                        'updated_at',
                        'category' => [
                            'id',
                            'name',
                            'type'
                        ]
                    ]
                ]
            ]);
    }

    /**
     * Test create transaction.
     */
    public function test_can_create_transaction(): void
    {
        $transactionData = [
            'category_id' => $this->category->id,
            'amount' => 1000.00,
            'transaction_date' => now()->format('Y-m-d H:i:s')
        ];

        $response = $this->postJson('/api/transactions', $transactionData);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    'id',
                    'category_id',
                    'amount',
                    'transaction_date',
                    'created_at',
                    'updated_at',
                    'category'
                ]
            ]);

        $this->assertDatabaseHas('transactions', $transactionData);
    }

    /**
     * Test validation for creating transaction.
     */
    public function test_cannot_create_transaction_with_invalid_data(): void
    {
        $response = $this->postJson('/api/transactions', [
            'category_id' => 999,
            'amount' => 'invalid_amount',
            'transaction_date' => 'invalid_date'
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['category_id', 'amount', 'transaction_date']);
    }

    /**
     * Test get single transaction.
     */
    public function test_can_get_single_transaction(): void
    {
        $transaction = Transaction::factory()->create([
            'category_id' => $this->category->id
        ]);

        $response = $this->getJson("/api/transactions/{$transaction->id}");

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'id' => $transaction->id,
                    'category_id' => $this->category->id,
                    'amount' => $transaction->amount
                ]
            ]);
    }

    /**
     * Test update transaction.
     */
    public function test_can_update_transaction(): void
    {
        $transaction = Transaction::factory()->create([
            'category_id' => $this->category->id
        ]);

        $updateData = [
            'category_id' => $this->category->id,
            'amount' => 2000.00,
            'transaction_date' => now()->format('Y-m-d H:i:s')
        ];

        $response = $this->putJson("/api/transactions/{$transaction->id}", $updateData);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'message' => 'Transaction updated successfully'
            ]);

        $this->assertDatabaseHas('transactions', $updateData);
    }

    /**
     * Test delete transaction.
     */
    public function test_can_delete_transaction(): void
    {
        $transaction = Transaction::factory()->create([
            'category_id' => $this->category->id
        ]);

        $response = $this->deleteJson("/api/transactions/{$transaction->id}");

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'message' => 'Transaction deleted successfully'
            ]);

        $this->assertDatabaseMissing('transactions', ['id' => $transaction->id]);
    }

    /**
     * Test get transactions by date range.
     */
    public function test_can_get_transactions_by_date_range(): void
    {
        // Create transactions with different dates
        Transaction::factory()->create([
            'category_id' => $this->category->id,
            'transaction_date' => now()->subDays(5)
        ]);
        Transaction::factory()->create([
            'category_id' => $this->category->id,
            'transaction_date' => now()->subDays(2)
        ]);
        Transaction::factory()->create([
            'category_id' => $this->category->id,
            'transaction_date' => now()->addDays(2)
        ]);

        $response = $this->getJson('/api/transactions/date-range?' . http_build_query([
            'start_date' => now()->subDays(6)->toDateString(),
            'end_date' => now()->toDateString()
        ]));

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }

    /**
     * Test get transactions by category.
     */
    public function test_can_get_transactions_by_category(): void
    {
        $anotherCategory = Category::factory()->create();

        Transaction::factory()->count(2)->create([
            'category_id' => $this->category->id
        ]);
        Transaction::factory()->create([
            'category_id' => $anotherCategory->id
        ]);

        $response = $this->getJson("/api/transactions/category/{$this->category->id}");

        $response->assertStatus(200)
            ->assertJsonCount(2, 'data');
    }
}