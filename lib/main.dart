import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/homePage/home_page.dart';

// Define the color palette
const Color primaryColor = Color(0xFF7D84B2); // Blue-grey
const Color primaryDarkColor = Color(0xFF8E9DCC); // Periwinkle
const Color secondaryColor = Color(0xFFD9DBF1); // Lavender
const Color backgroundColor = Color(0xFFFFFFF0); // Ivory
const Color accentColor = Color(0xFFDBF4A7); // Light lime
const Color incomeColor = Color(0xFFDBF4A7); // Light lime for income
const Color expenseColor = Color(0xFFEF4444);
const Color warningColor = Color(0xFFF59E0B);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DryWallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: incomeColor,
          error: expenseColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryDarkColor,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
        ),
        // Apply Poppins font globally
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
