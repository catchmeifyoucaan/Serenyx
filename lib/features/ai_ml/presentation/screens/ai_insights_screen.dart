import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/pet.dart';
import '../widgets/emotion_recognition_widget.dart';
import '../widgets/behavioral_prediction_widget.dart';
import '../widgets/personalized_content_widget.dart';
import '../widgets/smart_scheduling_widget.dart';

class AIInsightsScreen extends StatefulWidget {
  final Pet pet;

  const AIInsightsScreen({super.key, required this.pet});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen>
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
          'AI Insights for ${widget.pet.name}',
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
            Tab(icon: Icon(Icons.face), text: 'Emotions'),
            Tab(icon: Icon(Icons.psychology), text: 'Behavior'),
            Tab(icon: Icon(Icons.recommend), text: 'Content'),
            Tab(icon: Icon(Icons.schedule), text: 'Schedule'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EmotionRecognitionWidget(pet: widget.pet),
          BehavioralPredictionWidget(pet: widget.pet),
          PersonalizedContentWidget(pet: widget.pet),
          SmartSchedulingWidget(pet: widget.pet),
        ],
      ),
    );
  }
}
