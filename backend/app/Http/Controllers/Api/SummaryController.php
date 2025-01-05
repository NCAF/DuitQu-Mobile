<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class SummaryController extends Controller
{
    /**
     * Get dashboard summary data
     */
    public function summary()
    {
        try {
            // Get current month data
            $currentMonth = now()->format('Y-m');
            $monthTransactions = Transaction::with('category')
                ->whereYear('transaction_date', now()->year)
                ->whereMonth('transaction_date', now()->month)
                ->get();

            // Calculate current month totals
            $monthlyIncome = $monthTransactions->filter(function ($transaction) {
                return $transaction->category->type === 'income';
            })->sum('amount');

            $monthlyExpense = $monthTransactions->filter(function ($transaction) {
                return $transaction->category->type === 'expense';
            })->sum('amount');

            $monthlyBalance = $monthlyIncome - $monthlyExpense;

            // Get all time totals
            $allTransactions = Transaction::with('category')->get();
            $totalIncome = $allTransactions->filter(function ($transaction) {
                return $transaction->category->type === 'income';
            })->sum('amount');

            $totalExpense = $allTransactions->filter(function ($transaction) {
                return $transaction->category->type === 'expense';
            })->sum('amount');

            $totalBalance = $totalIncome - $totalExpense;

            // Get recent transactions (last 5)
            $recentTransactions = Transaction::with('category')
                ->orderBy('transaction_date', 'desc')
                ->limit(5)
                ->get();

            // Get top 5 expense categories this month
            $topExpenses = Transaction::with('category')
                ->whereHas('category', function ($query) {
                    $query->where('type', 'expense');
                })
                ->whereYear('transaction_date', now()->year)
                ->whereMonth('transaction_date', now()->month)
                ->select('category_id', DB::raw('SUM(amount) as total'))
                ->groupBy('category_id')
                ->orderBy('total', 'desc')
                ->limit(5)
                ->get();

            return response()->json([
                'status' => true,
                'data' => [
                    'current_month' => [
                        'income' => $monthlyIncome,
                        'expense' => $monthlyExpense,
                        'balance' => $monthlyBalance,
                    ],
                    'total' => [
                        'income' => $totalIncome,
                        'expense' => $totalExpense,
                        'balance' => $totalBalance,
                    ],
                    'recent_transactions' => $recentTransactions,
                    'top_expenses' => $topExpenses,
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to fetch dashboard data'
            ], 500);
        }
    }

    /**
     * Get monthly statistics for current year
     */
    public function monthlyStats()
    {
        try {
            $currentYear = now()->year;

            // Initialize monthly data array
            $monthlyData = [];
            for ($month = 1; $month <= 12; $month++) {
                $monthlyData[$month] = [
                    'month' => Carbon::create($currentYear, $month, 1)->format('M'),
                    'income' => 0,
                    'expense' => 0,
                    'balance' => 0
                ];
            }

            // Get all transactions for current year
            $transactions = Transaction::with('category')
                ->whereYear('transaction_date', $currentYear)
                ->get();

            // Calculate monthly totals
            foreach ($transactions as $transaction) {
                $month = date('n', strtotime($transaction->transaction_date));

                if ($transaction->category->type === 'income') {
                    $monthlyData[$month]['income'] += $transaction->amount;
                } else {
                    $monthlyData[$month]['expense'] += $transaction->amount;
                }

                $monthlyData[$month]['balance'] =
                    $monthlyData[$month]['income'] - $monthlyData[$month]['expense'];
            }

            return response()->json([
                'status' => true,
                'data' => array_values($monthlyData)
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to fetch monthly statistics'
            ], 500);
        }
    }

    /**
     * Get expense breakdown by category for current month
     */
    public function expenseBreakdown()
    {
        try {
            $currentMonth = now()->format('Y-m');

            $expenses = Transaction::with('category')
                ->whereHas('category', function ($query) {
                    $query->where('type', 'expense');
                })
                ->whereYear('transaction_date', now()->year)
                ->whereMonth('transaction_date', now()->month)
                ->select('category_id', DB::raw('SUM(amount) as total'))
                ->groupBy('category_id')
                ->get()
                ->map(function ($item) {
                    return [
                        'category' => $item->category->name,
                        'amount' => $item->total,
                    ];
                });

            $totalExpense = $expenses->sum('amount');

            // Calculate percentage for each category
            $expenses = $expenses->map(function ($item) use ($totalExpense) {
                $item['percentage'] = $totalExpense > 0
                    ? round(($item['amount'] / $totalExpense) * 100, 2)
                    : 0;
                return $item;
            });

            return response()->json([
                'status' => true,
                'data' => [
                    'total' => $totalExpense,
                    'breakdown' => $expenses
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to fetch expense breakdown'
            ], 500);
        }
    }

    /**
     * Get cash flow trend (daily) for current month
     */
    public function cashFlowTrend()
    {
        try {
            $startDate = now()->startOfMonth();
            $endDate = now()->endOfMonth();

            // Get all transactions for current month
            $transactions = Transaction::with('category')
                ->whereBetween('transaction_date', [$startDate, $endDate])
                ->get();

            $dailyData = [];
            $currentDate = $startDate->copy();

            // Initialize daily data
            while ($currentDate <= $endDate) {
                $dateStr = $currentDate->format('Y-m-d');
                $dailyData[$dateStr] = [
                    'date' => $dateStr,
                    'income' => 0,
                    'expense' => 0,
                    'balance' => 0
                ];
                $currentDate->addDay();
            }

            // Calculate daily totals
            foreach ($transactions as $transaction) {
                $date = $transaction->transaction_date;
                if ($transaction->category->type === 'income') {
                    $dailyData[$date]['income'] += $transaction->amount;
                } else {
                    $dailyData[$date]['expense'] += $transaction->amount;
                }
                $dailyData[$date]['balance'] =
                    $dailyData[$date]['income'] - $dailyData[$date]['expense'];
            }

            return response()->json([
                'status' => true,
                'data' => array_values($dailyData)
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to fetch cash flow trend'
            ], 500);
        }
    }
}