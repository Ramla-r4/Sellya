import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ownsell/models/product_model.dart';
import 'package:ownsell/screens/Legal/Abou%20This%20App.dart';
import 'package:ownsell/screens/login_screen.dart';
import 'package:ownsell/screens/MessagesScreen.dart';
import 'package:ownsell/screens/my_items_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the screen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundGray = const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: backgroundGray,
        elevation: 0.5,
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        children: [
          const SizedBox(height: 16),

          _buildSectionTitle('General'),
          _buildSettingTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.business,
            title: 'My Item',
            onTap: () {
              // Example: pass user's own items
              final currentUserId = FirebaseAuth.instance.currentUser!.uid;

              FirebaseFirestore.instance
                  .collection('products')
                  .where('ownerId', isEqualTo: currentUserId)
                  .get()
                  .then((querySnapshot) {
                    final products =
                        querySnapshot.docs.map((doc) {
                          return ProductModel.fromMap(doc.data(), doc.id);
                        }).toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyItemsScreen(myProducts: products),
                      ),
                    );
                  });
            },
          ),
          _buildSettingTile(
            icon: Icons.chat_bubble_outline,
            title: 'Chats',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatListScreen(
                        currentUserId: FirebaseAuth.instance.currentUser!.uid,
                      ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          _buildSectionTitle('Support'),
          _buildSettingTile(
            icon: Icons.contact_support_outlined,
            title: 'Contact Us',
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'supportsellya@gmail.com',
                query: Uri.encodeFull(
                  'subject=Support Request&body=Hi Sellya Support,',
                ),
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not open email app")),
                );
              }
            },
          ),
          _buildSettingTile(
            icon: Icons.star_border,
            title: 'Rate the App',
            onTap: () {},
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Legal'),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () async {
              final url = Uri.parse(
                'https://www.freeprivacypolicy.com/live/aa294d90-5cee-410c-b3e9-9d379d3590a7',
              );
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open Privacy Policy'),
                  ),
                );
              }
            },
          ),

          _buildSettingTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () async {
              final url = Uri.parse(
                'https://app.websitepolicies.com/policies/view/immil509',
              );
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open Privacy Policy'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('About'),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About This App',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.logout_outlined,
            title: 'Log Out',
            onTap: () async {
              final confirmed = await showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );

              if (confirmed == true) {
                await FirebaseAuth.instance.signOut();

                // Navigate to login page (replace with your actual login screen route)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: const Color.fromARGB(255, 71, 129, 82)),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
