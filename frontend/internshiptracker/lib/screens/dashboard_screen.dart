import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/api_service.dart';
import 'application_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ApiService _api = ApiService(widget.userName);
  List<Application> _applications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _api.getApplications();
      if (!mounted) return;
      setState(() {
        _applications = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Could not load data.";
        _isLoading = false;
      });
    }
  }

  // Here we crunch the numbers to show you some quick insights about your internship hunt.
  int get _totalApps => _applications.length;

  String get _successRate {
    if (_applications.isEmpty) return "0%";
    int offers = _applications.where((a) => a.status == 'Offer').length;
    return "${((offers / _applications.length) * 100).toStringAsFixed(0)}%";
  }

  int get _rejectionsCount {
    return _applications.where((a) => a.status == 'Rejected').length;
  }

  /// Filter applications that have a deadline in the future, then sort them by date.
  List<Application> get _upcomingDeadlines {
    final now = DateTime.now();
    final withDeadlines = _applications
        .where((a) => a.deadlineDate != null)
        .toList();
    // Only keeping future deadlines and sorting nearest first
    withDeadlines.retainWhere(
      (a) =>
          a.deadlineDate!.isAfter(now) || a.deadlineDate!.isAtSameMomentAs(now),
    );
    withDeadlines.sort((a, b) => a.deadlineDate!.compareTo(b.deadlineDate!));
    return withDeadlines.take(5).toList(); // Show top 5
  }

  Color _getDeadlineColor(int daysDifference) {
    if (daysDifference <= 3) return Colors.red;
    if (daysDifference <= 7) return Colors.orange;
    return Colors.green;
  }

  String _getDeadlineTag(int daysDifference) {
    if (daysDifference == 0) return "Today";
    if (daysDifference == 1) return "Tomorrow";
    if (daysDifference <= 7) return "In $daysDifference days";
    return "In $daysDifference days";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    TextButton(
                      onPressed: _fetchDashboardData,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The friendly greeting right at the top of your screen
                    const Center(
                      child: Text(
                        "InternTrack",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Hello, ${widget.userName}!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // A quick glance at your application numbers: totals, wins, and rejections
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: "Total Apps",
                            value: "$_totalApps",
                            color: const Color(0xFF4A90E2),
                            icon: Icons.description,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: "Success Rate",
                            value: _successRate,
                            color: const Color(0xFF50C878),
                            icon: Icons.check_circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: "Rejections",
                            value: "$_rejectionsCount",
                            color: const Color(
                              0xFFD32F2F,
                            ), // Red color for rejections
                            icon: Icons.cancel,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Header for your deadlines, plus a handy shortcut to view all your applications
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Upcoming Deadlines",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ApplicationListScreen(userName: widget.userName),
                              ),
                            ).then(
                              (_) => _fetchDashboardData(),
                            ); // Refresh on return
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: const Text("View Applications"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // The list where we display your upcoming tasks so nothing slips through the cracks
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _upcomingDeadlines.isEmpty
                            ? const Center(
                                child: Text(
                                  "No upcoming deadlines",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _upcomingDeadlines.length,
                                itemBuilder: (context, index) {
                                  final app = _upcomingDeadlines[index];
                                  final diff = app.deadlineDate!
                                      .difference(DateTime.now())
                                      .inDays;

                                  return DeadlineTile(
                                    company: app.company,
                                    role: app.role,
                                    tag: _getDeadlineTag(diff),
                                    tagColor: _getDeadlineColor(diff),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// 📊 A beautifully simple card used to display key statistics (like 'Total Apps' or 'Success Rate')
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// 📄 A neat little row that displays an upcoming deadline for a specific role and company
class DeadlineTile extends StatelessWidget {
  final String company;
  final String role;
  final String tag;
  final Color tagColor;

  const DeadlineTile({
    super.key,
    required this.company,
    required this.role,
    required this.tag,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: const CircleAvatar(
        backgroundColor: Colors.black12,
        child: Icon(Icons.business, color: Colors.black),
      ),
      title: Text(company),
      subtitle: Text(role),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: tagColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: tagColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
