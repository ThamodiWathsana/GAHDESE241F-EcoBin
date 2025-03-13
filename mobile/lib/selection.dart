import 'package:flutter/material.dart';
import 'package:flutter_application_1/admin_signin.dart';
import 'package:flutter_application_1/admin_signup.dart';
import 'package:flutter_application_1/user_signup.dart';
import 'user_signin.dart'; // Import User Sign-In Page

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.8),
              const Color(0xFF2E7D32).withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 1),

                // App Logo/Icon
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 60,
                    color: Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(height: 32),

                // App Title
                const Text(
                  "EcoBins",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Select your account type",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const Spacer(flex: 1),

                // User Card
                _buildSelectionCard(
                  context: context,
                  icon: Icons.person,
                  title: "User",
                  onSignInTap: () {
                    // Navigate to User Sign-In Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserSignInPage()),
                    );
                  },
                  onSignUpTap: () {
                    // Navigate to User Sign-Up Page
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserSignUpPage()),
                      );
                  },
                ),

                const SizedBox(height: 20),

                // Admin Card
                _buildSelectionCard(
                  context: context,
                  icon: Icons.admin_panel_settings,
                  title: "Admin",
                  onSignInTap: () {
                    // Navigate to Admin Sign-In Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminSignInPage()),
                    );
                  },
                  onSignUpTap: () {
                    // Navigate to Admin Sign-Up Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminSignUpPage()),
                    );
                  },
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onSignInTap,
    required VoidCallback onSignUpTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2E7D32),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSignInTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFF2E7D32),
                      elevation: 0,
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSignUpTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
