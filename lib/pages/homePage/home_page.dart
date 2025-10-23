import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../transactionPage/transaction_page.dart';
import '../statsPage/stats_page.dart';
import '../cardsPage/cards_page.dart';
import '../profilePage/profile_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../theme/colors.dart';

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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Start with no transactions — user will add real data via the TransactionPage
  final List<TransactionItem> _transactions = [];
  final int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Category to emoji mapping (matching TransactionPage)
  final Map<String, String> _categoryEmojis = {
    'Food': '🍔',
    'Salary': '💰',
    'Transport': '🚗',
    'Cafe': '☕',
    'Bills': '📄',
    'Shopping': '🛍️',
    'Entertainment': '🎬',
    'Health': '💊',
    'Education': '📚',
    'Other': '📌',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 1:
        return const StatsPage();
      case 2:
        return const CardsPage();
      case 3:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final summary = _sevenDaySummary; // not used in this layout
    // use totals for header delta
    final monthDelta = _totalIncome - _totalExpense;
    return Scaffold(
      backgroundColor: backgroundColor, // Updated to use light theme background
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    _getPageForIndex(index),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        },
      ),
      body: Column(
        children: [
          // Gradient header with fade-in animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      coolGray, // Cool Gray
                      vistaBlue, // Vista Blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: coolGray.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Total Balance',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    tween: Tween(begin: 0, end: _balance),
                                    builder: (context, value, child) {
                                      return Text(
                                        NumberFormat.simpleCurrency().format(
                                          value,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -1.5,
                                          height: 1.2,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: monthDelta >= 0
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : Colors.red.shade400.withValues(
                                              alpha: 0.3,
                                            ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          monthDelta >= 0
                                              ? Icons.trending_up_rounded
                                              : Icons.trending_down_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${NumberFormat.simpleCurrency().format(monthDelta.abs())} this month',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Income and Expense Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.arrow_downward_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Income',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        NumberFormat.simpleCurrency().format(
                                          _totalIncome,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.arrow_upward_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Expense',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        NumberFormat.simpleCurrency().format(
                                          _totalExpense,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Weekly spending graph removed
          const SizedBox(height: 16),

          // quick-action card removed

          // Recent Transactions header / empty state with animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _transactions.isNotEmpty
                ? Column(
                    key: const ValueKey('transactions'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),
                      // Transactions list (card style)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: _transactions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tx = entry.value;
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 400 + (index * 100),
                              ),
                              curve: Curves.easeOutCubic,
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Dismissible(
                                key: ValueKey(tx.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) => _removeTransaction(tx.id),
                                child: Card(
                                  elevation: 0,
                                  color: Colors.white, // White card
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: const Color(0xFFD9DBF1).withAlpha(
                                        (0.5 * 255).toInt(),
                                      ), // Lavender border
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: tx.type == TxType.expense
                                            ? Colors.red.withValues(alpha: 0.08)
                                            : Colors.green.withValues(
                                                alpha: 0.08,
                                              ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _categoryEmojis[tx.category] ?? '📌',
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      tx.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      tx.category,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    trailing: Text(
                                      NumberFormat.simpleCurrency().format(
                                        tx.amount,
                                      ),
                                      style: TextStyle(
                                        color: tx.type == TxType.expense
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    key: const ValueKey('empty'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wallet_outlined,
                              size: 56,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first transaction',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // budgets card removed
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton(
          // Use the built-in FAB heroTag to avoid nesting Hero widgets
          heroTag: 'add_tx_fab',
          elevation: 6,
          // Hero tag 'add_tx_fab' for FAB-to-page transition
          onPressed: () async {
            final result = await Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const TransactionPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      var scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
                          .chain(CurveTween(curve: Curves.easeOutBack))
                          .animate(animation);

                      var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                          .chain(CurveTween(curve: Curves.easeIn))
                          .animate(animation);

                      return ScaleTransition(
                        scale: scaleAnimation,
                        child: FadeTransition(
                          opacity: fadeAnimation,
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 500),
                reverseTransitionDuration: const Duration(milliseconds: 400),
              ),
            );
            if (result is Map<String, dynamic>) {
              final title = result['title'] as String?;
              final amount = result['amount'] as double?;
              final typeStr = result['type'] as String?;
              final category = result['category'] as String?;
              if (title != null &&
                  amount != null &&
                  typeStr != null &&
                  category != null) {
                final type = typeStr == 'income'
                    ? TxType.income
                    : TxType.expense;
                _addTransaction(title, amount, type, category);
              }
            }
          },
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  // quick-action helper removed
}
