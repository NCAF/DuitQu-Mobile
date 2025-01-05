<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Category;
use Illuminate\Foundation\Testing\RefreshDatabase;

class CategoryTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test get all categories.
     */
    public function test_can_get_all_categories(): void
    {
        Category::factory()->count(3)->create();

        $response = $this->getJson('/api/categories');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'status',
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'type',
                        'created_at',
                        'updated_at'
                    ]
                ]
            ]);
    }

    /**
     * Test create category.
     */
    public function test_can_create_category(): void
    {
        $categoryData = [
            'name' => 'Test Category',
            'type' => 'income'
        ];

        $response = $this->postJson('/api/categories', $categoryData);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'status',
                'message',
                'data' => [
                    'id',
                    'name',
                    'type',
                    'created_at',
                    'updated_at'
                ]
            ]);

        $this->assertDatabaseHas('categories', $categoryData);
    }

    /**
     * Test validation for creating category.
     */
    public function test_cannot_create_category_with_invalid_data(): void
    {
        $response = $this->postJson('/api/categories', [
            'name' => '',
            'type' => 'invalid_type'
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['name', 'type']);
    }

    /**
     * Test get single category.
     */
    public function test_can_get_single_category(): void
    {
        $category = Category::factory()->create();

        $response = $this->getJson("/api/categories/{$category->id}");

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'data' => [
                    'id' => $category->id,
                    'name' => $category->name,
                    'type' => $category->type
                ]
            ]);
    }

    /**
     * Test update category.
     */
    public function test_can_update_category(): void
    {
        $category = Category::factory()->create();
        $updateData = [
            'name' => 'Updated Category',
            'type' => 'expense'
        ];

        $response = $this->putJson("/api/categories/{$category->id}", $updateData);

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'message' => 'Category updated successfully'
            ]);

        $this->assertDatabaseHas('categories', $updateData);
    }

    /**
     * Test delete category.
     */
    public function test_can_delete_category(): void
    {
        $category = Category::factory()->create();

        $response = $this->deleteJson("/api/categories/{$category->id}");

        $response->assertStatus(200)
            ->assertJson([
                'status' => true,
                'message' => 'Category deleted successfully'
            ]);

        $this->assertDatabaseMissing('categories', ['id' => $category->id]);
    }

    /**
     * Test get categories by type.
     */
    public function test_can_get_categories_by_type(): void
    {
        Category::factory()->count(2)->create(['type' => 'income']);
        Category::factory()->count(3)->create(['type' => 'expense']);

        // Test income categories
        $responseIncome = $this->getJson('/api/categories/type/income');
        $responseIncome->assertStatus(200)
            ->assertJsonCount(2, 'data');

        // Test expense categories
        $responseExpense = $this->getJson('/api/categories/type/expense');
        $responseExpense->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }
}