<?php

use App\Http\Controllers\Api\SummaryController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\TransactionController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Category Routes
Route::get('categories/type/income', [CategoryController::class, 'income']);
Route::get('categories/type/expense', [CategoryController::class, 'expense']);
Route::apiResource('categories', CategoryController::class);

// Transaction Routes - Specific routes first
Route::get('transactions/date-range', [TransactionController::class, 'getByDateRange']);
Route::get('transactions/category/{categoryId}', [TransactionController::class, 'getByCategory']);
Route::apiResource('transactions', TransactionController::class);

Route::prefix('summary')->group(function () {
    Route::get('summary', [SummaryController::class, 'summary']);
    Route::get('monthly-stats', [SummaryController::class, 'monthlyStats']);
    Route::get('expense-breakdown', [SummaryController::class, 'expenseBreakdown']);
    Route::get('cash-flow', [SummaryController::class, 'cashFlowTrend']);
});