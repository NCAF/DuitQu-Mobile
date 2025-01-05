<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Transaction;
use Illuminate\Support\Facades\Validator;

class TransactionController extends Controller
{
    /**
     * Display a listing of the transactions.
     */
    public function index()
    {
        try {
            $transactions = Transaction::with('category')->get();
            return response()->json([
                'status' => true,
                'data' => $transactions
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to fetch transactions'
            ], 500);
        }
    }

    /**
     * Store a newly created transaction.
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'category_id' => 'required|exists:categories,id',
                'amount' => 'required|numeric|min:0',
                'transaction_date' => 'required|date'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            $transaction = Transaction::create($request->all());
            $transaction->load('category');

            return response()->json([
                'status' => true,
                'message' => 'Transaction created successfully',
                'data' => $transaction
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to create transaction'
            ], 500);
        }
    }

    /**
     * Display the specified transaction.
     */
    public function show($id)
    {
        try {
            $transaction = Transaction::with('category')->findOrFail($id);
            return response()->json([
                'status' => true,
                'data' => $transaction
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Transaction not found'
            ], 404);
        }
    }

    /**
     * Update the specified transaction.
     */
    public function update(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'category_id' => 'required|exists:categories,id',
                'amount' => 'required|numeric|min:0',
                'transaction_date' => 'required|date'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            $transaction = Transaction::findOrFail($id);
            $transaction->update($request->all());
            $transaction->load('category');

            return response()->json([
                'status' => true,
                'message' => 'Transaction updated successfully',
                'data' => $transaction
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to update transaction'
            ], 500);
        }
    }

    /**
     * Remove the specified transaction.
     */
    public function destroy($id)
    {
        try {
            $transaction = Transaction::findOrFail($id);
            $transaction->delete();

            return response()->json([
                'status' => true,
                'message' => 'Transaction deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to delete transaction'
            ], 500);
        }
    }

    /**
     * Get transactions by date range
     */
    public function getByDateRange(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'start_date' => 'required|date',
                'end_date' => 'required|date|after_or_equal:start_date'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            $transactions = Transaction::with('category')
                ->whereBetween('transaction_date', [$request->start_date, $request->end_date])
                ->get();

            return response()->json([
                'status' => true,
                'data' => $transactions
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to fetch transactions'
            ], 500);
        }
    }

    /**
     * Get transactions by category
     */
    public function getByCategory($categoryId)
    {
        try {
            $transactions = Transaction::with('category')
                ->where('category_id', $categoryId)
                ->get();

            return response()->json([
                'status' => true,
                'data' => $transactions
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to fetch transactions'
            ], 500);
        }
    }
}