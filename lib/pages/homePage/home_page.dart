import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../transactionPage/transaction_page.dart';
import '../../widgets/bottom_nav_bar.dart';

enum TxType { income, expense }

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TxType type;
  final String category;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Start with no transactions — user will add real data via the TransactionPage
  final List<TransactionItem> _transactions = [];
  int _selectedIndex = 0;

  double get _balance {
    return _transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get _totalIncome {
    return _transactions
        .where((t) => t.type == TxType.income)
        .fold(0.0, (s, t) => s + t.amount.abs());
  }

  double get _totalExpense {
    return _transactions
        .where((t) => t.type == TxType.expense)
        .fold(0.0, (s, t) => s + t.amount.abs());
  }

  void _addTransaction(String title, double amount, TxType type, String cat) {
    final tx = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: type == TxType.expense ? -amount : amount,
      date: DateTime.now(),
      type: type,
      category: cat,
    );

    setState(() {
      _transactions.insert(0, tx);
    });
  }

  void _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });
  }

  // Add-transaction sheet removed; navigation to TransactionPage will be used.

  // (Removed) 7-day summary calculation — not used in the current layout.

  @override
  Widget build(BuildContext context) {
    // final summary = _sevenDaySummary; // not used in this layout
    // use totals for header delta
    final monthDelta = _totalIncome - _totalExpense;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('DryWallet'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 76, 188, 121),
                    Color.fromARGB(255, 156, 154, 221),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 28),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat.simpleCurrency().format(_balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${monthDelta >= 0 ? '+' : '-'}${NumberFormat.simpleCurrency().format(monthDelta.abs())} this month',
                    style: TextStyle(
                      color: monthDelta >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            // quick-action card removed

            // Recent Transactions header / empty state
            if (_transactions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(onPressed: () {}, child: const Text('See All')),
                  ],
                ),
              ),

              // Transactions list (card style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: _transactions.map((tx) {
                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _removeTransaction(tx.id),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tx.type == TxType.expense
                                  ? Color.fromRGBO(244, 67, 54, 0.08)
                                  : Color.fromRGBO(76, 175, 80, 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              tx.type == TxType.expense
                                  ? Icons.fastfood
                                  : Icons.attach_money,
                              color: tx.type == TxType.expense
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          title: Text(
                            tx.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            tx.category,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            NumberFormat.simpleCurrency().format(tx.amount),
                            style: TextStyle(
                              color: tx.type == TxType.expense
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ] else ...[
              const SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first transaction.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // budgets card removed
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Use the built-in FAB heroTag to avoid nesting Hero widgets
        heroTag: 'add_tx_fab',
        // Hero tag 'add_tx_fab' for FAB-to-page transition
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TransactionPage()));
          if (result is Map<String, dynamic>) {
            final title = result['title'] as String?;
            final amount = result['amount'] as double?;
            final typeStr = result['type'] as String?;
            final category = result['category'] as String?;
            if (title != null &&
                amount != null &&
                typeStr != null &&
                category != null) {
              final type = typeStr == 'income' ? TxType.income : TxType.expense;
              _addTransaction(title, amount, type, category);
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // quick-action helper removed
}
