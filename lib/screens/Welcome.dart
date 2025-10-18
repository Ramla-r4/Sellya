// import 'package:flutter/material.dart';

// void main() {
//   runApp(const SellyaApp());
// }

// class SellyaApp extends StatelessWidget {
//   const SellyaApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sellya',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'Gabarito',
//         scaffoldBackgroundColor: const Color(0xFFF5F5F5),
//       ),
//       home: const WelcomeScreen(),
//     );
//   }
// }

// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.asset('assets/images/Welcom.png', height: 320),
//             const SizedBox(height: 16),
//             const Text(
//               'Sellya',
//               style: TextStyle(
//                 fontFamily: 'Gabarito',
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF2F4F2F),
//               ),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               'Your ultimate shopping destination',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontFamily: 'Gabarito',
//                 fontSize: 16,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 80),
//             SizedBox(
//               width: 348,
//               height: 55,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Navigate or perform action
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2F4F2F), // Dark green
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: const Text(
//                   'Shop Now',
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8), // soft white-green tint

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/Welcom.png', height: 320),
            const SizedBox(height: 16),
            const Text(
              'Sellya',
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F4F2F),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your ultimate shopping destination',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: 348,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool("first_launch", false);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F4F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Shop Now',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
