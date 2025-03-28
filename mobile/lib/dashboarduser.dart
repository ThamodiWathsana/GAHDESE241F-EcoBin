import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/binlocation.dart';

import 'binreview.dart';
import 'eventsnupdates.dart';
import 'profile.dart';
import 'request_bins.dart';
import 'signin_page.dart' as signin;
import 'signup_page.dart' as signup;

class EcoBinDashboard extends StatefulWidget {
  const EcoBinDashboard({super.key});

  @override
  State<EcoBinDashboard> createState() => _EcoBinDashboardState();
}

class _EcoBinDashboardState extends State<EcoBinDashboard> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    _currentUser = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.eco, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            const Text(
              "EcoBin",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser != null
                          ? "Welcome, ${_currentUser!.displayName ?? 'User'}"
                          : "Welcome to EcoBin",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Smart waste management",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    if (_currentUser == null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildAuthCard(
                              title: "Sign In",
                              isPrimary: true,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const signin.SignInPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAuthCard(
                              title: "Sign Up",
                              isPrimary: false,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const signup.SignUpPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      _buildUserProfileCard(),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildServiceCard(
                          icon: Icons.location_on_outlined,
                          title: "Find Bins",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoogleMapScreen(),
                              ),
                            );
                          },
                        ),
                        _buildServiceCard(
                          icon: Icons.history_outlined,
                          title: "View History",
                          onPressed: () {
                            if (_currentUser != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileOfUser(),
                                ),
                              );
                            } else {
                              _showLoginRequiredDialog();
                            }
                          },
                        ),
                        _buildServiceCard(
                          icon: Icons.category_outlined,
                          title: "Bin Request",
                          onPressed: () {
                            if (_currentUser != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BinRequestPage(),
                                ),
                              );
                            } else {
                              _showLoginRequiredDialog();
                            }
                          },
                        ),
                        _buildServiceCard(
                          icon: Icons.star_outline,
                          title: "Rate & Reviews",
                          onPressed: () {
                            if (_currentUser != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BinReviewPage(),
                                ),
                              );
                            } else {
                              _showLoginRequiredDialog();
                            }
                          },
                        ),
                        _buildServiceCard(
                          icon: Icons.event_available_outlined,
                          title: "Events & Updates",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const EventsAndUpdatesPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: "Events",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventsAndUpdatesPage(),
                ),
              );
              break;
            case 2:
              break;
            case 3:
              if (_currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileOfUser()),
                );
              } else {
                _showLoginRequiredDialog();
              }
              break;
          }
        },
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Required"),
          content: const Text(
            "You need to be logged in to access this feature. Would you like to sign in now?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const signin.SignInPage(),
                  ),
                );
              },
              child: const Text(
                "Sign In",
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFE8F5E9),
              backgroundImage:
                  _currentUser?.photoURL != null
                      ? NetworkImage(_currentUser!.photoURL!)
                      : null,
              child:
                  _currentUser?.photoURL == null
                      ? const Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF4CAF50),
                      )
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser?.displayName ?? "EcoBin User",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?.email ?? "",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: _signOut,
              icon: const Icon(
                Icons.logout,
                size: 18,
                color: Color(0xFF4CAF50),
              ),
              label: const Text(
                "Sign Out",
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard({
    required String title,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isPrimary ? Colors.transparent : const Color(0xFF4CAF50),
          width: 1,
        ),
      ),
      color: isPrimary ? const Color(0xFF4CAF50) : Colors.white,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isPrimary ? Colors.white : const Color(0xFF4CAF50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
