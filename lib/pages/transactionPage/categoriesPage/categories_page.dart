import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/colors.dart';
import '../transaction_page.dart';

class CategoriesPage extends StatefulWidget {
  final String currentCategory;
  final Map<String, String> categoryEmojis;
  final TxTypeForm transactionType;

  const CategoriesPage({
    super.key,
    required this.currentCategory,
    required this.categoryEmojis,
    required this.transactionType,
  });

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentCategory;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categoryEmojis.keys.toList();
    final primaryColor = widget.transactionType == TxTypeForm.expense
        ? expenseColor
        : incomeColor;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! < -10) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
                body: CategoriesPage(
                  currentCategory: widget.currentCategory,
                  categoryEmojis: widget.categoryEmojis,
                  transactionType: widget.transactionType,
                ),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        }
      },
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 6,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header hint
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Choose a category for your ${widget.transactionType == TxTypeForm.expense ? 'expense' : 'income'}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

          // Category grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final iconPath =
                    'assets/icons/categories/${category.toLowerCase().replaceAll(' ', '-')}.svg';
                final isSelected = category == _selectedCategory;

                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutBack,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: InkWell(
                    onTap: () async {
                      setState(() => _selectedCategory = category);
                      // Add a small scale pulse animation on tap
                      await Future.delayed(const Duration(milliseconds: 150));
                      if (!context.mounted) return;
                      Navigator.of(context).pop(category);
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: primaryColor.withValues(alpha: 0.2),
                    highlightColor: primaryColor.withValues(alpha: 0.1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.white, // White card
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : const Color(0xFFD9DBF1).withAlpha(
                                  (0.5 * 255).toInt(),
                                ), // Lavender border
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? primaryColor.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: isSelected ? 12 : 4,
                            offset: Offset(0, isSelected ? 4 : 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : const Color(
                                      0xFFF0EFF4,
                                    ), // Ghost White background
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                iconPath,
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.check_circle,
                                size: 16,
                                color: primaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
