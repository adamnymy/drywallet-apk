import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'categoriesPage/categories_page.dart';
import '../../widgets/custom_keyboard.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

enum TxTypeForm { income, expense }

/// Returns a Map with keys: title (String), amount (double), type (String), category (String), date (DateTime), notes (String)
class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  TxTypeForm _type = TxTypeForm.expense;
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _amountDisplay = '0';
  bool _showKeyboard = false;

  late AnimationController _animationController;
  late AnimationController _keyboardAnimationController;
  late Animation<Offset> _keyboardSlideAnimation;

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

    // Keyboard slide animation
    _keyboardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _keyboardSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _keyboardAnimationController,
            curve: Curves.easeOut,
          ),
        );

    // Delay animation start slightly to let Hero animation settle
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  void _handleKeyTap(String value) {
    setState(() {
      if (_amountDisplay == '0' && value != '.') {
        _amountDisplay = value;
      } else if (value == '.' && _amountDisplay.contains('.')) {
        // Don't add another decimal point
        return;
      } else {
        _amountDisplay += value;
      }
      _amountController.text = _amountDisplay;
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_amountDisplay.length > 1) {
        _amountDisplay = _amountDisplay.substring(0, _amountDisplay.length - 1);
      } else {
        _amountDisplay = '0';
      }
      _amountController.text = _amountDisplay;
    });
  }

  void _handleClear() {
    setState(() {
      _amountDisplay = '0';
      _amountController.text = '';
    });
  }

  void _showCustomKeyboard() {
    setState(() {
      _showKeyboard = true;
    });
    _keyboardAnimationController.forward();
  }

  void _hideCustomKeyboard() {
    _keyboardAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showKeyboard = false;
        });
      }
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _type == TxTypeForm.expense
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _type == TxTypeForm.expense
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    final notes = _notesController.text.trim();

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid title and amount'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Combine date and time
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    Navigator.of(context).pop({
      'title': title,
      'amount': amount,
      'type': _type == TxTypeForm.expense ? 'expense' : 'income',
      'category': _selectedCategory,
      'date': dateTime,
      'notes': notes.isEmpty ? null : notes,
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _keyboardAnimationController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor, // Updated to use Ghost White theme color
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'New Transaction',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // Amount and Type Selector
                  _buildAmountSection(),
                  const SizedBox(height: 32),

                  // Form Fields
                  _buildFormFields(),
                  const SizedBox(height: 24),

                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Custom Keyboard
          if (_showKeyboard)
            SlideTransition(
              position: _keyboardSlideAnimation,
              child: CustomKeyboard(
                onKeyTap: _handleKeyTap,
                onBackspace: _handleBackspace,
                onClear: _handleClear,
                primaryColor: _type == TxTypeForm.expense
                    ? expenseColor
                    : incomeColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      children: [
        // Category Selector
        GestureDetector(
          onTap: _showCategoryPicker,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondaryColor.withOpacity(0.5),
                ),
                child: Center(
                  child: Text(
                    _categoryEmojis[_selectedCategory] ?? '📌',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedCategory,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Amount Display
        GestureDetector(
          onTap: _showCustomKeyboard,
          child: Text(
            '${_type == TxTypeForm.expense ? '-' : '+'} \$${_amountDisplay == '0' ? '0.00' : _amountDisplay}',
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _type == TxTypeForm.expense ? expenseColor : incomeColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Type Chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTypeChip(
              'Expense',
              TxTypeForm.expense,
              Icons.arrow_downward,
              expenseColor,
            ),
            const SizedBox(width: 12),
            _buildTypeChip(
              'Income',
              TxTypeForm.income,
              Icons.arrow_upward,
              incomeColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            onTap: _hideCustomKeyboard,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'e.g., Lunch at restaurant',
              prefixIcon: const Icon(Icons.title_rounded),
              border: InputBorder.none,
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            ),
          ),
          const Divider(height: 1),
          // Date & Time
          _buildDateTimeRow(),
          const Divider(height: 1),
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onTap: _hideCustomKeyboard,
            decoration: InputDecoration(
              labelText: 'Notes (Optional)',
              hintText: 'Add any additional details...',
              prefixIcon: const Icon(Icons.notes_rounded),
              border: InputBorder.none,
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _selectDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      dateFormat.format(_selectedDate),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: _selectTime,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime.format(context),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _type == TxTypeForm.expense
              ? expenseColor
              : incomeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline),
            const SizedBox(width: 8),
            Text(
              _type == TxTypeForm.expense ? 'Add Expense' : 'Add Income',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
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
  }

  Widget _buildTypeChip(
    String label,
    TxTypeForm type,
    IconData icon,
    Color color,
  ) {
    final isSelected = _type == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _type = type);
        }
      },
      avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : color),
      labelStyle: GoogleFonts.poppins(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? Colors.white : color,
      ),
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
