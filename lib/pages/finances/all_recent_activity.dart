import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../components/recent_activities.dart';

class AllRecentActivityPage extends StatelessWidget {
  const AllRecentActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Recent Activity", style: AppTextStyles.headline(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: RecentActivities(limit: 100),
      ),
    );
  }
}
