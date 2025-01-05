import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../utils/constants.dart';

class TransactionController {
  // Get semua transaksi
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactions}'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return (jsonData['data'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();
        }
      }
      throw Exception(AppConstants.serverError);
    } catch (e) {
      throw Exception('${AppConstants.networkError}: $e');
    }
  }

  // Get transaksi berdasarkan rentang tanggal
  Future<List<Transaction>> getTransactionsByDateRange(
      String startDate, String endDate) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactionsByDate}')
            .replace(queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
        }),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return (jsonData['data'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();
        }
      }
      throw Exception(AppConstants.serverError);
    } catch (e) {
      throw Exception('${AppConstants.networkError}: $e');
    }
  }

  // Get transaksi berdasarkan kategori
  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.transactionsByCategory}/$categoryId'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return (jsonData['data'] as List)
              .map((item) => Transaction.fromJson(item))
              .toList();
        }
      }
      throw Exception(AppConstants.serverError);
    } catch (e) {
      throw Exception('${AppConstants.networkError}: $e');
    }
  }

  // Tambah transaksi baru
  Future<Transaction> addTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactions}'),
        headers: ApiConstants.headers,
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return Transaction.fromJson(jsonData['data']);
        }
      }
      throw Exception(AppConstants.serverError);
    } catch (e) {
      throw Exception('${AppConstants.networkError}: $e');
    }
  }

  // Update transaksi
  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.transactions}/${transaction.id}'),
        headers: ApiConstants.headers,
        body: jsonEncode(transaction.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return Transaction.fromJson(jsonData['data']);
        }
      }
      throw Exception(AppConstants.serverError);
    } catch (e) {
      throw Exception('${AppConstants.networkError}: $e');
    }
  }

  // Hapus transaksi
  Future<void> deleteTransaction(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactions}/$id'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode != 200) {
        throw Exception(AppConstants.serverError);
      }
    } catch (e) {
      throw Exception('${AppConstants.networkError}: $e');
    }
  }
}
