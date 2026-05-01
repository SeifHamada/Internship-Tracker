import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../services/api_service.dart';

// Profile screen — displays user info and active application count from backend
class ProfileScreen extends StatefulWidget {
  // Name passed in from HomeScreen
  final String userName;

  const ProfileScreen({super.key, required this.userName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ApiService _api = ApiService(widget.userName);
  int _activeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadActiveCount();
  }

  // Fetches all applications and counts them for the Active Logs stat
  Future<void> _loadActiveCount() async {
    try {
      final apps = await _api.getApplications();
      if (!mounted) return;
      setState(() => _activeCount = apps.length);
    } catch (_) {
      // If backend unreachable just show 0
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // App bar with gradient bottom border
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF42A5F5),
                  Color(0xFFC62828),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // User avatar
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: const Icon(Icons.person, size: 52, color: Color(0xFF1A237E)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3949AB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 15, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Display the name passed in from RegisterScreen
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'interntrack user',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 20),

            // Stats row — Active Logs shows real count from backend
            Row(
              children: [
                _statCard('ACTIVE LOGS', '$_activeCount', Colors.white),
                const SizedBox(width: 12),
                _statCard('TIER', 'Professional', const Color(0xFFE8EAF6)),
              ],
            ),

            const SizedBox(height: 24),

            // Account preferences
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ACCOUNT PREFERENCES',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _prefTile(Icons.lock_outline, 'Privacy settings'),
            const SizedBox(height: 1),
            _prefTile(Icons.person_outline, 'Export portfolio'),

            const Spacer(),

            // Logout — clears navigation stack and returns to Register
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prefTile(IconData icon, String label) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(label, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}