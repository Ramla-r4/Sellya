import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:ownsell/models/product_model.dart';
import 'package:ownsell/screens/add_product_screen.dart';
import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  final Color primaryColor = const Color.fromARGB(255, 59, 86, 63);

  final List<Widget> _pages = const [
    HomeScreen(),
    WishlistScreen(),
    // MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        backgroundColor: Colors.white,
        activeColor: primaryColor,
        color: Colors.grey,
        elevation: 2,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.favorite_border, title: 'Wishlist'),
          // TabItem(icon: Icons.chat_bubble_outline, title: 'Chats'), // ✅ NEW
          TabItem(icon: Icons.person_outline, title: 'Profile'),
        ],
        initialActiveIndex: selectedIndex,
        onTap: (int i) {
          setState(() {
            selectedIndex = i;
          });
        },
      ),
    );
  }
}
