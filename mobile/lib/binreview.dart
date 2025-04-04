import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BinReviewPage extends StatefulWidget {
  const BinReviewPage({Key? key}) : super(key: key);

  @override
  _BinReviewPageState createState() => _BinReviewPageState();
}

class _BinReviewPageState extends State<BinReviewPage> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 0;
  String _reviewText = '';
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isAdmin = false; // Track if current user is admin
  String _userName = 'Anonymous User'; // Store user's actual name

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Color get _primaryColor => Colors.green.shade600;
  Color get _backgroundColor => Colors.white;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _getUserName(); // Fetch user's name when page loads
  }

  // Check if current user is an admin
  Future<void> _checkIfAdmin() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _isAdmin = userData['isAdmin'] == true;
        });
      }
    }
  }

  // Fetch user's name from Firestore
  Future<void> _getUserName() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          // Use the name field from your users collection, fallback to displayName, then email
          _userName =
              userData['name'] ?? currentUser.displayName ?? 'Anonymous User';
        });
      }
    }
  }

  void _selectRating(int rating) {
    setState(() {
      _rating = rating.toDouble();
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showErrorSnackBar('Please log in to submit a review');
      return;
    }

    try {
      // Refresh user name before submitting to ensure we have the latest
      await _getUserName();

      Map<String, dynamic> reviewData = {
        'name': _userName, // Use the stored user name
        'userId': currentUser.uid,
        'rating': _rating,
        'comment': _reviewText.trim(),
        'date': FieldValue.serverTimestamp(),
        'hasImage': _image != null,
        'adminResponse': null, // Initialize admin response as null
        'hasAdminResponse': false, // Flag to check if admin has responded
      };

      if (_image != null) {
        final String fileName =
            'reviews/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.png';
        final Reference storageRef = _storage.ref().child(fileName);
        await storageRef.putFile(_image!);
        final String imageUrl = await storageRef.getDownloadURL();
        reviewData['imageUrl'] = imageUrl;
      }

      await _firestore.collection('reviews').add(reviewData);

      _resetForm();
      _showSuccessSnackBar('Review submitted successfully');
    } catch (e) {
      _showErrorSnackBar('Error submitting review: $e');
    }
  }

  // Function for admin to submit a reply
  Future<void> _submitAdminReply(String reviewId, String replyText) async {
    try {
      if (replyText.trim().isNotEmpty) {
        await _firestore.collection('reviews').doc(reviewId).update({
          'adminResponse': replyText.trim(),
          'adminResponseDate': FieldValue.serverTimestamp(),
          'hasAdminResponse': true,
        });
        _showSuccessSnackBar('Reply submitted successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Error submitting reply: $e');
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _rating = 0;
      _reviewText = '';
      _image = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Show admin reply dialog
  void _showAdminReplyDialog(String reviewId) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Admin Response',
              style: TextStyle(color: _primaryColor),
            ),
            content: TextField(
              controller: replyController,
              decoration: InputDecoration(
                hintText: 'Write your response here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  _submitAdminReply(reviewId, replyController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                child: Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Rate & Reviews',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRatingSection(),
                const SizedBox(height: 16),
                _buildReviewInput(),
                const SizedBox(height: 16),
                _buildImageUploadSection(),
                const SizedBox(height: 16),
                _buildSubmitButton(),
                const SizedBox(height: 24),
                _buildReviewsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: _primaryColor,
            size: 40,
          ),
          onPressed: () => _selectRating(index + 1),
        );
      }),
    );
  }

  Widget _buildReviewInput() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Write your review here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryColor),
        ),
      ),
      maxLines: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a review';
        }
        return null;
      },
      onSaved: (value) => _reviewText = value ?? '',
    );
  }

  Widget _buildImageUploadSection() {
    return SizedBox(
      height: 48, // Reduced height
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.image, color: Colors.white),
        label: Text(
          _image == null ? 'Upload Image (Optional)' : 'Image Selected',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _image == null ? _primaryColor : Colors.green,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48, // Reduced height
      child: ElevatedButton(
        onPressed: _submitReview,
        style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
        child: const Text(
          'Submit Review',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('reviews')
                  .orderBy('date', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No reviews yet'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = snapshot.data!.docs[index];
                Map<String, dynamic> reviewData =
                    doc.data() as Map<String, dynamic>;
                String reviewId = doc.id;
                return _buildReviewCard(reviewData, reviewId);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, String reviewId) {
    // Null-safe handling of review data
    final String userName = review['name'] ?? 'Anonymous User';
    final double rating = (review['rating'] ?? 0.0).toDouble();
    final String comment = review['comment'] ?? 'No comments available';
    final bool hasImage = review['hasImage'] == true;
    final String? imageUrl = hasImage ? review['imageUrl'] : null;
    final bool hasAdminResponse = review['hasAdminResponse'] == true;
    final String? adminResponse = review['adminResponse'];
    final Timestamp? adminResponseDate =
        review['adminResponseDate'] as Timestamp?;

    String formattedDate = '';
    if (adminResponseDate != null) {
      DateTime date = adminResponseDate.toDate();
      formattedDate = '${date.day}/${date.month}/${date.year}';
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User information and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: _primaryColor,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // User comment
            Text(comment, style: const TextStyle(fontSize: 15)),

            // Review image if available
            if (hasImage && imageUrl != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 150, // Increased height for better visibility
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

            // Admin response section
            if (hasAdminResponse && adminResponse != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin response header
                    Row(
                      children: [
                        Icon(
                          Icons.support_agent,
                          color: _primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Admin Response',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                            fontSize: 15,
                          ),
                        ),
                        if (formattedDate.isNotEmpty) ...[
                          const Spacer(),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const Divider(height: 16),

                    // Admin response content
                    Text(adminResponse, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),

            // Admin reply button (only visible to admins for reviews without responses)
            if (_isAdmin)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child:
                      hasAdminResponse
                          ? TextButton.icon(
                            onPressed: () => _showAdminReplyDialog(reviewId),
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 18,
                            ),
                            label: Text(
                              'Edit Response',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                          : TextButton.icon(
                            onPressed: () => _showAdminReplyDialog(reviewId),
                            icon: Icon(
                              Icons.reply,
                              color: _primaryColor,
                              size: 18,
                            ),
                            label: Text(
                              'Reply',
                              style: TextStyle(color: _primaryColor),
                            ),
                          ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
