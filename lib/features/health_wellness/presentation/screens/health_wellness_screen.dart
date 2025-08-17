import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/pet.dart';
import '../widgets/nutrition_tracker.dart';
import '../widgets/exercise_monitor.dart';
import '../widgets/mental_health_monitor.dart';
import '../widgets/preventive_care_system.dart';

class HealthWellnessScreen extends StatefulWidget {
  final Pet pet;

  const HealthWellnessScreen({super.key, required this.pet});

  @override
  State<HealthWellnessScreen> createState() => _HealthWellnessScreenState();
}

class _HealthWellnessScreenState extends State<HealthWellnessScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: Text(
          'Health & Wellness',
          style: AppTheme.textStyles.headlineMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.colors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.colors.primary,
          unselectedLabelColor: AppTheme.colors.textSecondary,
          indicatorColor: AppTheme.colors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant), text: 'Nutrition'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Exercise'),
            Tab(icon: Icon(Icons.psychology), text: 'Mental Health'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'Preventive'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NutritionTracker(pet: widget.pet),
          ExerciseMonitor(pet: widget.pet),
          MentalHealthMonitor(pet: widget.pet),
          PreventiveCareSystem(pet: widget.pet),
        ],
      ),
    );
  }
}
