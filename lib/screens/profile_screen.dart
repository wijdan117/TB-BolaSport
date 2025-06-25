// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:tb_project/providers/auth_provider.dart'; // Import AuthProvider
import 'package:tb_project/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>( // Gunakan Consumer untuk mengakses AuthProvider
      builder: (context, authProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Pengguna',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildProfileInfoRow('Email:', authProvider.userEmail ?? 'Tidak Tersedia'),
                      const SizedBox(height: 8),
                      _buildProfileInfoRow('Username:', authProvider.userName ?? 'Tidak Tersedia'),
                      const SizedBox(height: 8),
                      _buildProfileInfoRow('Role:', authProvider.userRole),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authProvider.logout(); // Panggil logout dari AuthProvider
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget untuk baris info profil
  Widget _buildProfileInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90, // Lebar tetap untuk label
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
