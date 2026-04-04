// Application list: loads rows from the API, search + status filters, FAB to add.
import 'package:flutter/material.dart';

import '../models/application.dart';
import '../services/api_service.dart';
import 'add_edit_screen.dart';

/// Lists internship applications from the backend with search and status filters.
class ApplicationListScreen extends StatefulWidget {
  const ApplicationListScreen({super.key});

  @override
  State<ApplicationListScreen> createState() => _ApplicationListScreenState();
}

class _ApplicationListScreenState extends State<ApplicationListScreen> {
  // --- API & form state ---
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  /// Full list from GET /applications; filtering happens in [_visibleApplications].
  List<Application> _applications = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  /// `null` means show all statuses.
  String? _statusFilter;

  /// Must stay in sync with [AddEditScreen] so chips match what users can save.
  static const List<String> _statusOptions = [
    'Applied',
    'Interview',
    'Offer',
    'Rejected',
    'Ghosted',
  ];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches all applications from the backend; used on first load, pull-to-refresh, retry, and after returning from add screen.
  Future<void> _loadApplications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.getApplications();
      if (!mounted) return;
      setState(() {
        _applications = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Applies status chip filter, then search text on company and role.
  Iterable<Application> get _visibleApplications {
    var list = _applications;
    if (_statusFilter != null) {
      list = list.where((a) => a.status == _statusFilter).toList();
    }
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where(
      (a) =>
          a.company.toLowerCase().contains(q) ||
          a.role.toLowerCase().contains(q),
    );
  }

  static const List<String> _monthAbbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Human-readable deadline line (relative for soon dates, else month + day).
  String _deadlineCaption(DateTime? deadline) {
    if (deadline == null) return 'No deadline set';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(deadline.year, deadline.month, deadline.day);
    final diff = d.difference(today).inDays;
    final dateStr = '${_monthAbbr[d.month - 1]} ${d.day}';

    if (diff < 0) return 'Past due · $dateStr';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    if (diff <= 7) return 'Due in $diff days · $dateStr';
    return 'Due $dateStr';
  }

  /// Background and text colors for status badges and filter chips.
  ({Color bg, Color fg}) _statusColors(String status) {
    switch (status) {
      case 'Applied':
        return (bg: const Color(0xFFE3F2FD), fg: const Color(0xFF1565C0));
      case 'Interview':
        return (bg: const Color(0xFFFFF3E0), fg: const Color(0xFFE65100));
      case 'Offer':
        return (bg: const Color(0xFFE8F5E9), fg: const Color(0xFF2E7D32));
      case 'Rejected':
        return (bg: const Color(0xFFFFEBEE), fg: const Color(0xFFC62828));
      case 'Ghosted':
        return (bg: const Color(0xFFEEEEEE), fg: const Color(0xFF616161));
      default:
        return (bg: const Color(0xFFF5F5F5), fg: const Color(0xFF424242));
    }
  }

  /// Opens add form; reloads list when user pops back so new entries appear.
  Future<void> _openAddScreen() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const AddEditScreen()),
    );
    if (mounted) await _loadApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Applications',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search filters [_visibleApplications] by company / role substring.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search applications',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF757575)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Horizontal status filters; "All" clears [_statusFilter].
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _statusFilter == null,
                  selectedBg: const Color(0xFFE8EAF6),
                  selectedFg: const Color(0xFF1A237E),
                  onTap: () => setState(() => _statusFilter = null),
                ),
                ..._statusOptions.map((status) {
                  final c = _statusColors(status);
                  return _FilterChip(
                    label: status,
                    selected: _statusFilter == status,
                    selectedBg: c.bg,
                    selectedFg: c.fg,
                    onTap: () => setState(() => _statusFilter = status),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
      // Navigates to [AddEditScreen] (same pattern as design mock).
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Loading spinner, error + retry, empty states, or scrollable application cards.
  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF616161)),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadApplications,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final visible = _visibleApplications.toList();
    if (visible.isEmpty) {
      return Center(
        child: Text(
          _applications.isEmpty
              ? 'No applications yet.\nTap + to add one.'
              : 'No matches for your search or filter.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF757575), fontSize: 16),
        ),
      );
    }

    // Bottom padding keeps last card above the FAB.
    return RefreshIndicator(
      onRefresh: _loadApplications,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final app = visible[index];
          final colors = _statusColors(app.status);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 1,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: company, role, deadline caption.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.company,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            app.role,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _deadlineCaption(app.deadlineDate),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right: colored status pill.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            app.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.fg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Simple tappable pill for the horizontal status filter row.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.selectedBg,
    required this.selectedFg,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedBg;
  final Color selectedFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? selectedBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? selectedFg : const Color(0xFF757575),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
