import 'package:flutter/material.dart';

import 'application_list_screen.dart';

/// Primary home: list of applications (search, filters, FAB to add).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ApplicationListScreen();
  }
}
