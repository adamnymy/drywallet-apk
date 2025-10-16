import 'package:flutter/material.dart';
import 'categoriesPage/categories_page.dart';

enum TxTypeForm { income, expense }

/// Returns a Map with keys: title (String), amount (double), type (String), category (String)
class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TxTypeForm _type = TxTypeForm.expense;
  String _selectedCategory = 'Food';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Category to emoji mapping
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
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    );
    // Delay animation start slightly to let Hero animation settle
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid title and amount'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'title': title,
      'amount': amount,
      'type': _type == TxTypeForm.expense ? 'expense' : 'income',
      'category': _selectedCategory,
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedEmoji = _categoryEmojis[_selectedCategory] ?? '📌';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Transaction',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero animated emoji circle - tappable to open category selector
              Hero(
                tag: 'add_tx_fab',
                flightShuttleBuilder:
                    (
                      flightContext,
                      animation,
                      flightDirection,
                      fromHeroContext,
                      toHeroContext,
                    ) {
                      final isForward =
                          flightDirection == HeroFlightDirection.push;
                      final Hero toHero = toHeroContext.widget as Hero;

                      return ScaleTransition(
                        scale:
                            Tween<double>(
                              begin: isForward ? 0.8 : 1.0,
                              end: isForward ? 1.0 : 0.8,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOutCubic,
                              ),
                            ),
                        child: FadeTransition(
                          opacity: animation,
                          child: toHero.child,
                        ),
                      );
                    },
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: InkWell(
                        onTap: () async {
                          final result = await showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return DraggableScrollableSheet(
                                initialChildSize:
                                    0.7, // Start at 70% of the screen height
                                minChildSize:
                                    0.3, // Allow shrinking to 30% of the screen height
                                maxChildSize:
                                    1.0, // Allow expanding to fullscreen
                                builder: (context, scrollController) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, -4),
                                        ),
                                      ],
                                    ),
                                    child: CategoriesPage(
                                      currentCategory: _selectedCategory,
                                      categoryEmojis: _categoryEmojis,
                                      transactionType: _type,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                          if (result != null) {
                            setState(() {
                              _selectedCategory = result;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _type == TxTypeForm.expense
                                  ? [Colors.red.shade400, Colors.red.shade600]
                                  : [
                                      Colors.green.shade400,
                                      Colors.green.shade600,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_type == TxTypeForm.expense
                                            ? Colors.red
                                            : Colors.green)
                                        .withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  selectedEmoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: _type == TxTypeForm.expense
                                        ? Colors.red.shade600
                                        : Colors.green.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Category label
              Center(
                child: Text(
                  _selectedCategory,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Type selector chips with staggered animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTypeChip(
                      'Expense',
                      TxTypeForm.expense,
                      Icons.arrow_downward,
                      Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _buildTypeChip(
                      'Income',
                      TxTypeForm.income,
                      Icons.arrow_upward,
                      Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount input card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextField(
                        controller: _amountController,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[300]),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title input card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'e.g., Coffee with friends',
                      prefixIcon: const Icon(Icons.edit_note),
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _type == TxTypeForm.expense
                        ? Colors.red.shade600
                        : Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _type == TxTypeForm.expense ? 'Add Expense' : 'Add Income',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    String label,
    TxTypeForm type,
    IconData icon,
    Color color,
  ) {
    final isSelected = _type == type;
    return InkWell(
      onTap: () => setState(() => _type = type),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? color : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
