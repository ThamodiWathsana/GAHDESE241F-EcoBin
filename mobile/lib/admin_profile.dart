import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Profile Controllers
  final TextEditingController _nameController = TextEditingController(
    text: 'Manujaya De Silva',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'manujayadesilva2000@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '0767789647',
  );
  final TextEditingController _addressController = TextEditingController(
    text: '31/3, Bandarawatha, Habaraduwaa',
  );

  String _profilePictureUrl =
      'https://firebasestorage.googleapis.com/v0/b/smart-waste-management-3041a.firebasestorage.app/o/profile_pictures%2FDDFqaHgRttTzwHKdsxAHSKwcK7M2%2F90fb3209-6b1d-42b8-b45d-ff03ecfdf318.jpeg?alt=media&token=6d7946d2-04ee-46d3-93f0-e74c1bb86ced';

  Future<void> _updateProfile() async {
    try {
      await _firestore.collection('users').doc('admin_id').update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile Updated Successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error Updating Profile')));
    }
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        // Upload to Firebase Storage
        final storageRef = _storage
            .ref()
            .child('profile_pictures')
            .child('admin_profile.jpg');

        await storageRef.putFile(File(pickedFile.path));
        String downloadURL = await storageRef.getDownloadURL();

        // Update in Firestore
        await _firestore.collection('users').doc('admin_id').update({
          'profilePicture': downloadURL,
        });

        setState(() {
          _profilePictureUrl = downloadURL;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile Picture Updated')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Updating Profile Picture')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _changeProfilePicture,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(_profilePictureUrl),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Profile Form
            _buildProfileTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            _buildProfileTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
            ),
            SizedBox(height: 16),
            _buildProfileTextField(
              controller: _phoneController,
              label: 'Phone',
              icon: Icons.phone,
            ),
            SizedBox(height: 16),
            _buildProfileTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            SizedBox(height: 20),

            // Update Profile Button
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Colors.green,
              ),
              child: Text('Update Profile', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
