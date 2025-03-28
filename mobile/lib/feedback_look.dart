import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackManagementPage extends StatefulWidget {
  const FeedbackManagementPage({Key? key}) : super(key: key);

  @override
  _FeedbackManagementPageState createState() => _FeedbackManagementPageState();
}

class _FeedbackManagementPageState extends State<FeedbackManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _responseController = TextEditingController();

  Future<void> _respondToFeedback(DocumentSnapshot review) async {
    final response = _responseController.text.trim();
    if (response.isEmpty) {
      _showSnackBar('Response cannot be empty', isError: true);
      return;
    }

    try {
      await _firestore.collection('reviews').doc(review.id).update({
        'adminResponse': response,
        'resolved': true,
        'resolvedAt': FieldValue.serverTimestamp(),
      });

      _responseController.clear();
      if (mounted) Navigator.of(context).pop();

      _showSnackBar('Response sent successfully', isError: false);
    } catch (e) {
      _showSnackBar('Error sending response: $e', isError: true);
    }
  }

  Future<void> _deleteReview(DocumentSnapshot review) async {
    try {
      await _firestore.collection('reviews').doc(review.id).delete();
      _showSnackBar('Review deleted successfully', isError: false);
    } catch (e) {
      _showSnackBar('Error deleting review: $e', isError: true);
    }
  }

  void _showResponseDialog(DocumentSnapshot review) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Respond to Feedback'),
          content: TextField(
            controller: _responseController,
            decoration: InputDecoration(
              hintText: 'Type your official response',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _respondToFeedback(review),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Management'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('reviews')
                .orderBy('date', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reviews',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feedback_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No reviews found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var review = snapshot.data!.docs[index];
              var reviewData = review.data() as Map<String, dynamic>? ?? {};

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    reviewData['name'] ?? 'Anonymous User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (starIndex) => Icon(
                            starIndex < (reviewData['rating'] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(reviewData['comment'] ?? 'No comment'),
                      Text(
                        'Date: ${_formatDate(reviewData['date'])}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (reviewData['adminResponse'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Admin Response: ${reviewData['adminResponse']}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        reviewData['resolved'] == true
                            ? Icons.check_circle
                            : Icons.pending,
                        color:
                            reviewData['resolved'] == true
                                ? Colors.green
                                : Colors.orange,
                      ),
                      IconButton(
                        icon: const Icon(Icons.reply, color: Color(0xFF4CAF50)),
                        onPressed: () => _showResponseDialog(review),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteReview(review),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown Date';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return 'Invalid Date';
    }

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }
}
