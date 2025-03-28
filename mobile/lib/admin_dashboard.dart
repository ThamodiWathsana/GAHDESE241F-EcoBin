import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Events_admin.dart';
import 'admin_profile.dart';
import 'binStatus_admin.dart';
import 'feedback_look.dart';
import 'user_manage.dart';
import 'binlocation.dart';
import 'signin_page.dart' as signin;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  User? _currentAdmin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    _currentAdmin = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const signin.SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings_outlined, color: Colors.green[700]),
            const SizedBox(width: 8),
            const Text(
              "EcoBin Admin",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 27, 188, 33),
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome, Admin",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Manage waste disposal efficiently",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    _buildAdminProfileCard(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildAdminServiceCard(
                            icon: Icons.people_outline,
                            title: "User Management",
                            onPressed: () => _navigateTo(UserManagementPage()),
                          ),
                          _buildAdminServiceCard(
                            icon: Icons.delete_outline,
                            title: "Bin Status",
                            onPressed: () => _navigateTo(BinStatusPage()),
                          ),
                          _buildAdminServiceCard(
                            icon: Icons.location_on_outlined,
                            title: "Bin Locations",
                            onPressed: () => _navigateTo(GoogleMapScreen()),
                          ),
                          _buildAdminServiceCard(
                            icon: Icons.event_available_outlined,
                            title: "Event Management",
                            onPressed: () => _navigateTo(EventManagementPage()),
                          ),
                          _buildAdminServiceCard(
                            icon: Icons.feedback_outlined,
                            title: "Feedback Management",
                            onPressed:
                                () => _navigateTo(FeedbackManagementPage()),
                          ),
                          _buildAdminServiceCard(
                            icon: Icons.person_outline,
                            title: "Admin Profile",
                            onPressed: () => _navigateTo(AdminProfileApp()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildAdminProfileCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green[100],
              child: const Icon(
                Icons.admin_panel_settings,
                size: 30,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentAdmin?.displayName ?? "EcoBin Admin",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentAdmin?.email ?? "",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminServiceCard({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green[700]),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
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
