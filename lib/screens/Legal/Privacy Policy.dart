// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewScreen extends StatelessWidget {
//   final String title;
//   final String url;

//   const WebViewScreen({super.key, required this.title, required this.url});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: WebViewWidget(
//         controller: WebViewController()..loadRequest(Uri.parse(url)),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalScreen extends StatelessWidget {
  final Color backgroundColor = const Color(0xFFF5F5F5); // Light gray
  final Color textColor = Colors.black87;

  const LegalScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Legal & Info'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              _openUrl(
                'https://app.termly.io/dashboard/website/403d9756-940b-45a9-aef1-0f7cd3ba1453/privacy-policy',
              );
            },
          ),
          ListTile(
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Replace with your actual Termly terms link
              _openUrl(
                'https://app.termly.io/document/terms-of-use/your-link-here',
              );
            },
          ),
          ListTile(
            title: const Text('About This App'),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Your App Name',
                applicationVersion: '1.0.0',
                children: const [
                  Text(
                    'This app allows users to buy/sell products, chat, and more.',
                  ),
                  Text('Built with ❤️ using Flutter & Firebase.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
