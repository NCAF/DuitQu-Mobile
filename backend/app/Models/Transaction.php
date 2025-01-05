<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transaction extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'category_id',
        'amount',
        'transaction_date'
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'amount' => 'decimal:2',
        'transaction_date' => 'date',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the category that owns the transaction.
     */
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Scope a query to only include expenses
     */
    public function scopeExpenses($query)
    {
        return $query->whereHas('category', function ($q) {
            $q->where('type', 'expense');
        });
    }

    /**
     * Scope a query to only include income
     */
    public function scopeIncome($query)
    {
        return $query->whereHas('category', function ($q) {
            $q->where('type', 'income');
        });
    }

    /**
     * Scope a query to filter by date range
     */
    public function scopeDateBetween($query, $startDate, $endDate)
    {
        return $query->whereBetween('transaction_date', [$startDate, $endDate]);
    }

    /**
     * Get transaction type through category
     */
    public function getTypeAttribute()
    {
        return $this->category->type;
    }

    /**
     * Format amount with currency
     */
    public function getFormattedAmountAttribute()
    {
        return 'Rp ' . number_format($this->amount, 2, ',', '.');
    }
}