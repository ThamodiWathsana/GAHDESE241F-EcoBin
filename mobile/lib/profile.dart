import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProfileOfUser());
}

class ProfileOfUser extends StatelessWidget {
  const ProfileOfUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF689F38),
          background: Colors.white,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E7D32)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  String _profileImageUrl = '';
  bool _isLoading = true;
  User? _currentUser;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _fetchUserData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _fullNameController.text = data['name'] ?? '';
          _emailController.text = _currentUser!.email ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _profileImageUrl = data['photoURL'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _fullNameController.text = _currentUser!.displayName ?? '';
          _emailController.text = _currentUser!.email ?? '';
          _phoneController.text = _currentUser!.phoneNumber ?? '';
          _addressController.text = '';
          _profileImageUrl = _currentUser!.photoURL ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        String? photoURL;
        if (_selectedImage != null) {
          String filename = path.basename(_selectedImage!.path);
          int dotIndex = filename.indexOf('.');
          String fileExtension;
          if (dotIndex != -1 && dotIndex < filename.length - 1) {
            fileExtension = filename.substring(dotIndex + 1);
          } else {
            fileExtension = 'jpg'; // default extension
          }

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_pictures')
              .child(
                '${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
              );
          await storageRef.putFile(_selectedImage!);
          photoURL = await storageRef.getDownloadURL();

          await _currentUser!.updatePhotoURL(photoURL);
        }

        Map<String, dynamic> userData = {
          'name': _fullNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        };

        if (photoURL != null) {
          userData['photoURL'] = photoURL;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set(userData, SetOptions(merge: true));

        await _currentUser!.updateDisplayName(_fullNameController.text);

        setState(() {
          _isEditing = false;
          _isLoading = false;
          _selectedImage = null;
          _profileImageUrl = photoURL ?? _profileImageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'My Profile'),
        centerTitle: true,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: _toggleEditMode,
            )
          else
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: _toggleEditMode,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, size: 20),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_currentUser == null
                  ? _buildNotLoggedInView()
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!_isEditing)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(
                                'EcoBin',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2E7D32),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 32),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 58,
                                      backgroundColor: Colors.grey[100],
                                      backgroundImage:
                                          _selectedImage != null
                                              ? FileImage(_selectedImage!)
                                              : (_profileImageUrl.isNotEmpty
                                                  ? NetworkImage(
                                                    _profileImageUrl,
                                                  )
                                                  : (_currentUser!.photoURL !=
                                                              null
                                                          ? NetworkImage(
                                                            _currentUser!
                                                                .photoURL!,
                                                          )
                                                          : null)
                                                      as ImageProvider?),
                                      child:
                                          (_selectedImage == null &&
                                                  _profileImageUrl.isEmpty &&
                                                  _currentUser!.photoURL ==
                                                      null)
                                              ? const Icon(
                                                Icons.person,
                                                size: 48,
                                                color: Color(0xFFAEAEAE),
                                              )
                                              : null,
                                    ),
                                  ),
                                ),
                                if (_isEditing)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        radius: 18,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          onPressed: _pickImage,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(bottom: 16, left: 4),
                            child: Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _isEditing
                                    ? TextFormField(
                                      controller: _fullNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Full Name',
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: Color(0xFF2E7D32),
                                          size: 20,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your full name';
                                        }
                                        return null;
                                      },
                                    )
                                    : _buildProfileField(
                                      Icons.person_outline,
                                      'Full Name',
                                      _fullNameController.text,
                                    ),
                                const SizedBox(height: 24),
                                _isEditing
                                    ? TextFormField(
                                      controller: _emailController,
                                      enabled: false,
                                      decoration: const InputDecoration(
                                        labelText: 'Email Address',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: Color(0xFF2E7D32),
                                          size: 20,
                                        ),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    )
                                    : _buildProfileField(
                                      Icons.email_outlined,
                                      'Email Address',
                                      _emailController.text,
                                    ),
                                const SizedBox(height: 24),
                                _isEditing
                                    ? TextFormField(
                                      controller: _phoneController,
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number',
                                        prefixIcon: Icon(
                                          Icons.phone_outlined,
                                          color: Color(0xFF2E7D32),
                                          size: 20,
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        return null;
                                      },
                                    )
                                    : _buildProfileField(
                                      Icons.phone_outlined,
                                      'Phone Number',
                                      _phoneController.text,
                                    ),
                                const SizedBox(height: 24),
                                _isEditing
                                    ? TextFormField(
                                      controller: _addressController,
                                      decoration: const InputDecoration(
                                        labelText: 'Address',
                                        prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                          color: Color(0xFF2E7D32),
                                          size: 20,
                                        ),
                                        alignLabelWithHint: true,
                                      ),
                                      keyboardType: TextInputType.streetAddress,
                                      maxLines: 2,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your address';
                                        }
                                        return null;
                                      },
                                    )
                                    : _buildProfileField(
                                      Icons.location_on_outlined,
                                      'Address',
                                      _addressController.text,
                                    ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (_isEditing)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    'Save Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                setState(() {
                                  _currentUser = null;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 100, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          const Text(
            'You are not logged in',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () {}, child: const Text('Log In')),
        ],
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
