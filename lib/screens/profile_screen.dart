// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   File? _image;
//   final _usernameController = TextEditingController(text: 'Username');
//   final _bioController = TextEditingController(text: 'This is my bio.');
//   final picker = ImagePicker();

//   final Color primaryColor = const Color.fromARGB(255, 71, 129, 82);
//   final Color backgroundGray = const Color(0xFFF2F2F2);
//   final Color textColor = const Color(0xFF212121);

//   Future<void> _pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _image = File(pickedFile.path));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundGray,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         centerTitle: true,
//         title: const Text(
//           'Profile',
//           style: TextStyle(color: Color(0xFF212121)),
//         ),
//         iconTheme: const IconThemeData(color: Color(0xFF212121)),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//         child: Column(
//           children: [
//             // Profile Picture
//             GestureDetector(
//               onTap: _pickImage,
//               child: Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.white,
//                     backgroundImage:
//                         _image != null
//                             ? FileImage(_image!)
//                             : const AssetImage('assets/images/user.png')
//                                 as ImageProvider,
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: primaryColor,
//                         shape: BoxShape.circle,
//                       ),
//                       padding: const EdgeInsets.all(6),
//                       child: const Icon(
//                         Icons.edit,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),

//             // Username Field
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: TextFormField(
//                 controller: _usernameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Username',
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Bio Field
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: TextFormField(
//                 controller: _bioController,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Bio',
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // Save Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // save/update logic here
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 child: const Text(
//                   'Save',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(255, 255, 255, 255),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/cloudinary_service.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _usernameController = TextEditingController();
//   final _bioController = TextEditingController();

//   String? _profileImageUrl;
//   File? _newImageFile;
//   bool _isSaving = false;

//   final currentUser = FirebaseAuth.instance.currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final doc =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser!.uid)
//             .get();

//     if (doc.exists) {
//       final data = doc.data()!;
//       _usernameController.text = data['name'] ?? '';
//       _bioController.text = data['bio'] ?? '';
//       setState(() {
//         _profileImageUrl = data['photoUrl'];
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         _newImageFile = File(picked.path);
//       });
//     }
//   }

//   Future<void> _saveProfile() async {
//     setState(() => _isSaving = true);

//     String? uploadedUrl = _profileImageUrl;

//     if (_newImageFile != null) {
//       final url = await CloudinaryService.uploadFile(_newImageFile!);
//       if (url != null) uploadedUrl = url;
//     }

//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(currentUser!.uid)
//         .set({
//           'name': _usernameController.text.trim(),
//           'bio': _bioController.text.trim(),
//           'photoUrl': uploadedUrl ?? '',
//         }, SetOptions(merge: true));

//     setState(() {
//       _isSaving = false;
//       _profileImageUrl = uploadedUrl;
//       _newImageFile = null;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Profile updated successfully")),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final backgroundGray = const Color(0xFFF2F2F2);
//     final primaryColor = const Color(0xFF7e57c2);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text('My Profile', style: TextStyle(color: Colors.black)),
//         iconTheme: const IconThemeData(color: Colors.black),
//         elevation: 0.5,
//       ),
//       backgroundColor: backgroundGray,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: _pickImage,
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundImage:
//                     _newImageFile != null
//                         ? FileImage(_newImageFile!)
//                         : (_profileImageUrl != null &&
//                             _profileImageUrl!.isNotEmpty)
//                         ? NetworkImage(_profileImageUrl!)
//                         : const AssetImage('assets/images/user.png')
//                             as ImageProvider,
//                 child: Align(
//                   alignment: Alignment.bottomRight,
//                   child: Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.edit, size: 20),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(
//                 labelText: 'Username',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _bioController,
//               maxLines: 3,
//               decoration: const InputDecoration(
//                 labelText: 'Bio',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: _isSaving ? null : _saveProfile,
//                 icon: const Icon(Icons.save),
//                 label:
//                     _isSaving
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text("Save"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// // Only import dart:io if not on Web
// import 'dart:io' as io show File;
// import 'package:image_picker/image_picker.dart';

// // Only import dart:html on Web
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;

// import '../services/cloudinary_service.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final user = FirebaseAuth.instance.currentUser!;
//   final _formKey = GlobalKey<FormState>();

//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _bioController = TextEditingController();
//   dynamic _newImageFile;
//   String? _imageUrl;

//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     final doc =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//     final data = doc.data();
//     if (data != null) {
//       _nameController.text = data['name'] ?? '';
//       _bioController.text = data['bio'] ?? '';
//       _imageUrl = data['photoUrl'];
//       setState(() {});
//     }
//   }

//   Future<void> _pickImage() async {
//     try {
//       if (kIsWeb) {
//         final input = html.FileUploadInputElement()..accept = 'image/*';
//         input.click();
//         await input.onChange.first;
//         if (input.files!.isNotEmpty) {
//           _newImageFile = input.files!.first;
//           setState(() {});
//         }
//       } else {
//         final picked = await ImagePicker().pickImage(
//           source: ImageSource.gallery,
//         );
//         if (picked != null) {
//           _newImageFile = io.File(picked.path);
//           setState(() {});
//         }
//       }
//     } catch (e) {
//       print("Error picking image: $e");
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isSaving = true);

//     try {
//       String? photoUrl = _imageUrl;
//       if (_newImageFile != null) {
//         photoUrl = await CloudinaryService.uploadFile(_newImageFile);
//       }

//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'name': _nameController.text.trim(),
//         'bio': _bioController.text.trim(),
//         'photoUrl': photoUrl,
//       }, SetOptions(merge: true));

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully')),
//       );
//     } catch (e) {
//       print("Save failed: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
//     } finally {
//       setState(() => _isSaving = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final avatarSize = 100.0;
//     final backgroundColor = const Color(0xFFF2F2F2);
//     final purpleColor = const Color(0xFF7e57c2);

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         title: const Text('Profile', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: avatarSize / 2,
//                       backgroundImage:
//                           _newImageFile != null
//                               ? (kIsWeb
//                                   ? NetworkImage(
//                                     html.Url.createObjectUrl(_newImageFile),
//                                   )
//                                   : FileImage(_newImageFile) as ImageProvider)
//                               : (_imageUrl != null
//                                   ? NetworkImage(_imageUrl!)
//                                   : const AssetImage('assets/images/user.png')),
//                       backgroundColor: Colors.grey[300],
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: CircleAvatar(
//                         radius: 14,
//                         backgroundColor: purpleColor,
//                         child: const Icon(
//                           Icons.edit,
//                           size: 16,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Username'),
//                 validator: (value) => value!.isEmpty ? 'Enter your name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _bioController,
//                 decoration: const InputDecoration(labelText: 'Bio'),
//                 maxLines: 2,
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isSaving ? null : _saveProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: purpleColor,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   child:
//                       _isSaving
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text('Save', style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// this work but only for web not phone
// Updated profile_screen.dart (Web & Mobile with working Cloudinary upload and Firestore update)

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:ownsell/services/cloudinary_service.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io' as io; // keep this for File

// // For web
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;

// // For mobile
// import 'dart:io' as io;

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _nameController = TextEditingController();
//   final _bioController = TextEditingController();
//   String? _imageUrl;
//   dynamic _newImageFile; // Either html.File or io.File
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final doc =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     final data = doc.data();

//     if (data != null) {
//       _nameController.text = data['name'] ?? '';
//       _bioController.text = data['bio'] ?? '';
//       setState(() => _imageUrl = data['imageUrl']);
//     }
//   }

//   Future<void> _pickImage() async {
//     if (kIsWeb) {
//       final input = html.FileUploadInputElement()..accept = 'image/*';
//       input.click();
//       input.onChange.listen((e) {
//         final file = input.files?.first;
//         if (file != null) {
//           setState(() => _newImageFile = file);
//         }
//       });
//     } else {
//       final result = await FilePicker.platform.pickFiles(type: FileType.image);
//       if (result != null && result.files.single.path != null) {
//         setState(() => _newImageFile = io.File(result.files.single.path!));
//       }
//     }
//   }

//   Future<void> _saveProfile() async {
//     setState(() => _isLoading = true);
//     final uid = FirebaseAuth.instance.currentUser!.uid;

//     try {
//       String? photoUrl;

//       if (_newImageFile != null) {
//         print('Uploading image...');
//         photoUrl = await CloudinaryService.uploadFile(_newImageFile);
//         print('Upload complete: $photoUrl');
//       }

//       await FirebaseFirestore.instance.collection('users').doc(uid).update({
//         'name': _nameController.text.trim(),
//         'bio': _bioController.text.trim(),
//         if (photoUrl != null) 'imageUrl': photoUrl,
//       });

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Profile updated!')));
//     } catch (e) {
//       print('Save failed: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final backgroundColor = const Color(0xFFF2F2F2);
//     final purpleColor = const Color(0xFF7e57c2);

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         title: const Text('My Profile'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: _pickImage,
//                       child: CircleAvatar(
//                         radius: 50,
//                         backgroundImage:
//                             _newImageFile != null
//                                 ? kIsWeb
//                                     ? NetworkImage(
//                                       html.Url.createObjectUrl(_newImageFile),
//                                     )
//                                     : FileImage(_newImageFile) as ImageProvider
//                                 : (_imageUrl != null && _imageUrl!.isNotEmpty)
//                                 ? NetworkImage(_imageUrl!)
//                                 : const AssetImage('assets/images/user.png')
//                                     as ImageProvider,
//                         backgroundColor: Colors.grey.shade200,
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Username
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Username',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     // Bio
//                     TextFormField(
//                       controller: _bioController,
//                       maxLines: 3,
//                       decoration: const InputDecoration(
//                         labelText: 'Bio',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     ElevatedButton(
//                       onPressed: _saveProfile,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: purpleColor,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 32,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('Save', style: TextStyle(fontSize: 16)),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }
// stilll retun nulll

// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io' as io;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import '../services/cloudinary_service.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _auth = FirebaseAuth.instance;
//   final _nameController = TextEditingController();
//   final _bioController = TextEditingController();
//   dynamic _newImageFile;
//   String? _imageUrl;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final uid = _auth.currentUser!.uid;
//     final doc =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     final data = doc.data();

//     if (data != null) {
//       _nameController.text = data['name'] ?? '';
//       _bioController.text = data['bio'] ?? '';
//       setState(() {
//         _imageUrl = data['imageUrl'];
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     if (!kIsWeb && io.Platform.isAndroid) {
//       final androidInfo = await DeviceInfoPlugin().androidInfo;
//       final sdkInt = androidInfo.version.sdkInt;

//       if (sdkInt >= 33) {
//         final status = await Permission.photos.request();
//         if (!status.isGranted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Photos permission is required')),
//           );
//           return;
//         }
//       } else {
//         final status = await Permission.storage.request();
//         if (!status.isGranted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Storage permission is required')),
//           );
//           return;
//         }
//       }
//     }

//     // ✅ Prevent crash by disabling compression (use withData: true)
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//       withData:
//           true, // ✅ Don't create temp file on disk (avoids permission denied)
//     );

//     if (result != null && result.files.single.bytes != null) {
//       final fileBytes = result.files.single.bytes!;
//       final fileName = result.files.single.name;

//       // Save to a File to upload to Cloudinary (in-memory workaround)
//       final tempDir = await io.Directory.systemTemp.createTemp();
//       final filePath = '${tempDir.path}/$fileName';
//       final file = await io.File(filePath).writeAsBytes(fileBytes);

//       setState(() => _newImageFile = file);
//     }
//   }

//   Future<void> _saveProfile() async {
//     try {
//       setState(() => _isLoading = true);
//       String? uploadedUrl = _imageUrl;

//       if (_newImageFile != null) {
//         uploadedUrl = await CloudinaryService.uploadFile(_newImageFile);
//       }

//       final uid = _auth.currentUser!.uid;
//       await FirebaseFirestore.instance.collection('users').doc(uid).update({
//         'name': _nameController.text.trim(),
//         'bio': _bioController.text.trim(),
//         'imageUrl': uploadedUrl,
//       });

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Profile updated!")));
//       _newImageFile = null;
//       setState(() => _isLoading = false);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       debugPrint("Save failed: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Save failed: $e")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final backgroundGray = const Color(0xFFF2F2F2);

//     return Scaffold(
//       backgroundColor: backgroundGray,
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: _pickImage,
//                       child: CircleAvatar(
//                         radius: 50,
//                         backgroundColor: Colors.grey.shade300,
//                         backgroundImage:
//                             _newImageFile != null && _newImageFile is io.File
//                                 ? FileImage(_newImageFile)
//                                 : _imageUrl != null
//                                 ? NetworkImage(_imageUrl!) as ImageProvider
//                                 : null,
//                         child:
//                             _imageUrl == null && _newImageFile == null
//                                 ? const Icon(Icons.camera_alt, size: 30)
//                                 : null,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(labelText: 'Username'),
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: _bioController,
//                       decoration: const InputDecoration(labelText: 'Bio'),
//                       maxLines: 2,
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _saveProfile,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF7e57c2),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 40,
//                           vertical: 14,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('Save', style: TextStyle(fontSize: 16)),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }
// forgot about it
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ownsell/screens/SettingsScreen.dart';
import '../services/cloudinary_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _newImageFile;
  String? _imageUrl;
  bool _isLoading = true;
  final Color primaryColor = const Color.fromARGB(255, 71, 129, 82);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _bioController.text = data['bio'] ?? '';
      setState(() {
        _imageUrl = data['imageUrl'];
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _newImageFile = File(picked.path));
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _isLoading = true);
      String? uploadedUrl = _imageUrl;

      if (_newImageFile != null) {
        uploadedUrl = await CloudinaryService.uploadFile(_newImageFile!);
      }

      final uid = _auth.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'imageUrl': uploadedUrl,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated!")));
      _newImageFile = null;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Save failed: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGray = const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: backgroundGray, // Same as body
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.black87, // Adjust if you want a lighter/darker tone
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      // rest of your body...
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            _newImageFile != null
                                ? FileImage(_newImageFile!)
                                : _imageUrl != null
                                ? NetworkImage(_imageUrl!) as ImageProvider
                                : null,
                        child:
                            _imageUrl == null && _newImageFile == null
                                ? const Icon(Icons.camera_alt, size: 30)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // Now Purple
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
    );
  }
}
