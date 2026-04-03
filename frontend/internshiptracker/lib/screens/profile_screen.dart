import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProfessionalIdentityScreen(),
    );
  }
}

class ProfessionalIdentityScreen extends StatelessWidget {
  const ProfessionalIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A237E)),
        title: const Text(
          'Professional Identity',
          style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.settings, color: Color(0xFF1A237E)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF42A5F5), Color(0xFFC62828)],
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

            // Avatar
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
            const Text('JohnDoe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('johndoe@interntrack.edu', style: TextStyle(color: Colors.grey, fontSize: 13)),

            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                _statCard('ACTIVE LOGS', '24', Colors.white),
                const SizedBox(width: 12),
                _statCard('TIER', 'Professional', const Color(0xFFE8EAF6)),
              ],
            ),

            const SizedBox(height: 24),

            // Preferences
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('ACCOUNT PREFERENCES',
                  style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 1.1, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            _prefTile(Icons.lock_outline, 'Privacy settings'),
            const SizedBox(height: 1),
            _prefTile(Icons.person_outline, 'Export portfolio'),

            const Spacer(),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 10),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'JOURNAL'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'APPLICATIONS'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'DISCOVER'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
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