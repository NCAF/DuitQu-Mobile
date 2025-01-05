// lib/controllers/summary_controller.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class SummaryController {
  // Singleton pattern
  static final SummaryController _instance = SummaryController._internal();
  factory SummaryController() => _instance;
  SummaryController._internal();

  final _currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<Map<String, dynamic>> getSummaryData() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/summary/summary'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return {
            'status': true,
            'data': data['data'],
          };
        }
      }

      return {
        'status': false,
        'message': AppConstants.serverError,
      };
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return _currencyFormatter.format(0);

    // Handle different types of amount
    double numericAmount;
    if (amount is String) {
      numericAmount = double.tryParse(amount) ?? 0;
    } else if (amount is int) {
      numericAmount = amount.toDouble();
    } else if (amount is double) {
      numericAmount = amount;
    } else {
      numericAmount = 0;
    }

    return _currencyFormatter.format(numericAmount);
  }

  String formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }
}
