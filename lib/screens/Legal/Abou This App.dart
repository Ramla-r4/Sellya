import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  final Color primaryColor = const Color.fromARGB(255, 71, 129, 82);
  final Color backgroundColor = Color(0xFFF4F4F4);
  final Color textColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/images/logo copy.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          'About Sellya',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sellya is a simple, fast, and modern platform to buy and sell both new and used items.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Whether you\'re cleaning out your closet or looking for great deals, Sellya makes it easy to list your products, connect with buyers, and manage your sales—all from one app.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'What You Can Do:',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...[
              'Create listings in seconds',
              'Chat directly with buyers or sellers',
              'Explore deals nearby or across the country',
              'Sell anything—from fashion to electronics',
            ].map(bulletPoint),
            const SizedBox(height: 32),
            Divider(color: Colors.grey[400], thickness: 1),
            const SizedBox(height: 24),
            Text(
              'Contact Us',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            contactInfo(Icons.email, 'spprtsellya@gmail.com'),
            contactInfo(Icons.language, 'www.sellya.com'),
            contactInfo(Icons.phone, '+252619850057'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.poppins(fontSize: 15.5)),
          ),
        ],
      ),
    );
  }

  Widget contactInfo(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
