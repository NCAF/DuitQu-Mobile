import '../models/category.dart';

class Transaction {
  int? id;
  int categoryId;
  double amount;
  String transactionDate;

  Category? category;

  Transaction({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.transactionDate,
    this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      categoryId: json['category_id'],
      amount: double.parse(json['amount'].toString()),
      transactionDate: json['transaction_date'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'amount': amount,
      'transaction_date': transactionDate
    };
  }
}
