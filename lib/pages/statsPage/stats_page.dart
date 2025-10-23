import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../homePage/home_page.dart';
import '../cardsPage/cards_page.dart';
import '../profilePage/profile_page.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87, // Updated to black for visibility
          ),
        ),
        backgroundColor: Colors.transparent, // Removed background color
        elevation: 0, // Removed shadow
        automaticallyImplyLeading: false, // Removed back button
      ),
      body: Center(
        child: Text(
          'Stats Page Content Goes Here',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1, // Set to Stats tab
        onTap: (index) {
          if (index != 1) {
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
    );
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return const HomePage();
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
}
