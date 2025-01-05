import 'package:flutter/material.dart';
import '../controllers/summary_controller.dart';
import '../utils/app_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _summaryController = SummaryController();
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic> _summaryData = {};

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await _summaryController.getSummaryData();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (result['status']) {
          _summaryData = result['data'];
          _error = '';
        } else {
          _error = result['message'];
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadSummaryData();
  }

  Widget _buildMainContent() {
    final currentMonth = _summaryData['current_month'] ?? {};
    final total = _summaryData['total'] ?? {};

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: AppStyles.textStyleSubheading.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        'John Doe',
                        style: AppStyles.textStyleHeading,
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppStyles.primaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      color: AppStyles.primaryColor,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppStyles.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _summaryController.formatCurrency(total['balance']),
                          style: AppStyles.textStyleAmount,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBalanceInfo(
                              'Income',
                              _summaryController
                                  .formatCurrency(currentMonth['income']),
                              Icons.arrow_upward_rounded,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white30,
                            ),
                            _buildBalanceInfo(
                              'Expense',
                              _summaryController
                                  .formatCurrency(currentMonth['expense']),
                              Icons.arrow_downward_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Recent Transactions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: AppStyles.textStyleSubheading,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Recent Transactions List
                  _buildRecentTransactionsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(String title, String amount, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsList() {
    final recentTransactions = _summaryData['recent_transactions'] ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentTransactions.length,
      itemBuilder: (context, index) {
        final transaction = recentTransactions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction['category']['type'] == 'income'
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(
              transaction['category']['type'] == 'income'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: transaction['category']['type'] == 'income'
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          title: Text(transaction['category']['name']),
          subtitle: Text(transaction['transaction_date']),
          trailing: Text(
            _summaryController.formatCurrency(transaction['amount']),
            style: TextStyle(
              color: transaction['category']['type'] == 'income'
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSummaryData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: _buildMainContent(),
      ),
    );
  }
}
