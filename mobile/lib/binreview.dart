import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class BinReviewPage extends StatefulWidget {
  const BinReviewPage({super.key});

  @override
  _BinReviewPageState createState() => _BinReviewPageState();
}

class _BinReviewPageState extends State<BinReviewPage> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  
  // Colors for green theme
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color lightGreen = const Color(0xFFE8F5E9);
  final Color darkGreen = const Color(0xFF2E7D32);

  // Sample customer reviews data
  final List<Map<String, dynamic>> _customerReviews = [
    {
      'name': 'Emily Johnson',
      'rating': 4.5,
      'date': '28 Feb 2025',
      'comment': 'This bin is perfect for sorting recyclables. It has clear labels and enough compartments for different materials.',
      'imageUrl': 'https://example.com/image1.jpg', // Sample URL, won't actually display
      'hasImage': true,
    },
    {
      'name': 'Michael Chen',
      'rating': 5.0,
      'date': '25 Feb 2025',
      'comment': 'Excellent design and durability. It fits perfectly in my kitchen and helps me stay organized with waste separation.',
      'hasImage': false,
    },
    {
      'name': 'Sarah Williams',
      'rating': 3.5,
      'date': '20 Feb 2025',
      'comment': 'Good bin but could use more compartments. The lid sometimes sticks which can be annoying.',
      'hasImage': false,
    },
    {
      'name': 'David Rodriguez',
      'rating': 4.0,
      'date': '15 Feb 2025',
      'comment': 'Sturdy construction and easy to clean. I like the eco-friendly materials used in making this bin.',
      'imageUrl': 'https://example.com/image2.jpg', // Sample URL, won't actually display
      'hasImage': true,
    },
  ];

  // Calculate average rating from all reviews
  double get _averageRating {
    if (_customerReviews.isEmpty) return 0;
    double total = _customerReviews.fold(0, (sum, review) => sum + (review['rating'] as double));
    return total / _customerReviews.length;
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text(
          'Rate & Review',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w600
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating stars
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: index < _rating ? Colors.amber : Colors.grey,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Review text field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _reviewController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Tell us about this bin...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Image upload section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryGreen, width: 1),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 50,
                              color: primaryGreen,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to add a photo',
                              style: TextStyle(color: darkGreen),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle submit logic
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Review & Rate submitted successfully!'),
                        backgroundColor: darkGreen,
                      ),
                    );
                    
                    // Clear form after submission
                    setState(() {
                      _rating = 0;
                      _reviewController.clear();
                      _image = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Customer Reviews Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${_averageRating.toStringAsFixed(1)}/5.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Review stats summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Ratings distribution
                    Row(
                      children: [
                        // Stars count
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(5, (index) {
                            int starCount = 5 - index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(
                                    '$starCount ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                ],
                              ),
                            );
                          }),
                        ),
                        
                        const SizedBox(width: 10),
                        
                        // Progress bars
                        Expanded(
                          child: Column(
                            children: List.generate(5, (index) {
                              int starCount = 5 - index;
                              // Calculate how many reviews have this star rating
                              int reviewsWithThisRating = _customerReviews
                                  .where((review) => (review['rating'] as double).round() == starCount)
                                  .length;
                              double percentage = _customerReviews.isNotEmpty
                                  ? reviewsWithThisRating / _customerReviews.length
                                  : 0;
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: percentage,
                                      child: Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: primaryGreen,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        
                        const SizedBox(width: 10),
                        
                        // Count of reviews
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(5, (index) {
                            int starCount = 5 - index;
                            int reviewsWithThisRating = _customerReviews
                                .where((review) => (review['rating'] as double).round() == starCount)
                                .length;
                                
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '($reviewsWithThisRating)',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Total reviews count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Based on ${_customerReviews.length} reviews',
                          style: TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Customer Review List
              ..._customerReviews.map((review) => _buildReviewCard(review)),
            ],
          ),
        ),
      ),
    );
  }
  
  // Method to build individual review cards
  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review header with name, rating and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: lightGreen,
                    child: Text(
                      review['name'].substring(0, 1),
                      style: TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    review['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              
              // Date
              Text(
                review['date'],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Rating stars
          Row(
            children: List.generate(5, (index) {
              // Show full, half or empty stars based on rating
              IconData starIcon;
              if (index < review['rating'].floor()) {
                starIcon = Icons.star;
              } else if (index < review['rating']) {
                starIcon = Icons.star_half;
              } else {
                starIcon = Icons.star_border;
              }
              
              return Icon(
                starIcon,
                color: Colors.amber,
                size: 18,
              );
            }),
          ),
          
          const SizedBox(height: 10),
          
          // Review comment
          Text(
            review['comment'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          // Review image if available
          if (review['hasImage'])
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 120,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: primaryGreen.withOpacity(0.7),
                ),
              ),
            ),
            
          // Helpful buttons and report option
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Was this helpful buttons
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.thumb_up_outlined,
                            size: 14,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Helpful',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.thumb_down_outlined,
                            size: 14,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Not helpful',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Report button
                Text(
                  'Report',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}