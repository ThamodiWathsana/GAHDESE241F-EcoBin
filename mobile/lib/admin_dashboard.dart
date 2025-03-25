import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'admin_profile.dart';
import 'binStatus_admin.dart';
import 'user_manage.dart';
import 'binlocation.dart'; // Assume this is the new bin location page

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/eco_bin_icon.svg', // You'll need to create this SVG
              height: 30,
              width: 30,
              color: Colors.green.shade800,
            ),
            SizedBox(width: 10),
            Text(
              'EcoBin',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green.shade800),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dashboard Header
              Text(
                'Waste Management\nAdministration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade900.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 40),

              // Dashboard Buttons
              _ProfessionalDashboardButton(
                icon: Icons.people_outline,
                label: 'User Management',
                iconColor: Colors.green.shade700,
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserManagementPage(),
                      ),
                    ),
              ),
              SizedBox(height: 16),
              _ProfessionalDashboardButton(
                icon: Icons.delete_outline,
                label: 'Bin Status',
                iconColor: Colors.green.shade700,
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BinStatusPage()),
                    ),
              ),
              SizedBox(height: 16),
              _ProfessionalDashboardButton(
                icon: Icons.location_on_outlined,
                label: 'Bin Locations',
                iconColor: Colors.green.shade700,
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoogleMapScreen(),
                      ),
                    ),
              ),
              SizedBox(height: 16),
              _ProfessionalDashboardButton(
                icon: Icons.person_outline,
                label: 'Admin Profile',
                iconColor: Colors.green.shade700,
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfessionalDashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onPressed;

  const _ProfessionalDashboardButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(icon, size: 24, color: iconColor),
                SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade900.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
