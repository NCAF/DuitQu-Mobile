import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/category_controller.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/transaction_list_item.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TransactionController _transactionController = TransactionController();
  final CategoryController _categoryController = CategoryController();
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadCategories();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await _transactionController.getAllTransactions();
      setState(() => _transactions = transactions);
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryController.getAllCategories();
      setState(() => _categories = categories);
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showAddEditDialog([Transaction? transaction]) async {
    Category? selectedCategory = transaction?.category ??
        _categories.firstWhere(
          (c) => c.type == 'expense',
          orElse: () => _categories.first,
        );
    final amountController = TextEditingController(
      text: transaction?.amount.toString() ?? '',
    );
    DateTime selectedDate = transaction != null
        ? DateTime.parse(transaction.transactionDate)
        : DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction == null
                        ? 'Add Transaction'
                        : 'Edit Transaction',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Category>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              category.type == 'expense'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: category.type == 'expense'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            const SizedBox(width: 10),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Category? value) {
                      setState(() => selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedCategory == null ||
                              amountController.text.isEmpty) {
                            _showMessage(
                              'Please fill all fields',
                              isError: true,
                            );
                            return;
                          }

                          try {
                            final amount = double.parse(amountController.text);
                            final newTransaction = Transaction(
                              id: transaction?.id,
                              categoryId: selectedCategory!.id!,
                              amount: amount,
                              transactionDate:
                                  DateFormat('yyyy-MM-dd').format(selectedDate),
                              category: selectedCategory,
                            );

                            if (transaction == null) {
                              await _transactionController
                                  .addTransaction(newTransaction);
                              _showMessage('Transaction added successfully');
                            } else {
                              await _transactionController
                                  .updateTransaction(newTransaction);
                              _showMessage('Transaction updated successfully');
                            }
                            Navigator.pop(context, true);
                          } catch (e) {
                            _showMessage(e.toString(), isError: true);
                          }
                        },
                        child: Text(transaction == null ? 'Add' : 'Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (result == true) {
      _loadTransactions();
    }
  }

  Future<void> _showDeleteConfirmation(Transaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _transactionController.deleteTransaction(transaction.id!);
        _showMessage('Transaction deleted successfully');
        _loadTransactions();
      } catch (e) {
        _showMessage(e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implementasi filter nanti
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadTransactions();
                await _loadCategories();
              },
              child: _transactions.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _showAddEditDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Transaction'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD14D72),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return TransactionListItem(
                          title: transaction.category?.name ?? 'Unknown',
                          amount: NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(transaction.amount),
                          date: DateFormat('dd MMM yyyy').format(
                              DateTime.parse(transaction.transactionDate)),
                          isExpense: transaction.category?.type == 'expense',
                          onTap: () => _showAddEditDialog(transaction),
                          onDelete: () => _showDeleteConfirmation(transaction),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEditDialog,
        backgroundColor: const Color(0xFFD14D72),
        child: const Icon(Icons.add),
      ),
    );
  }
}
