import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/session.dart';
import '../../../../shared/services/pet_service.dart';
import '../../../../shared/services/session_service.dart';
import '../widgets/analytics_card.dart';
import '../widgets/session_chart.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/bonding_insights_card.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  final PetService _petService = PetService();
  final SessionService _sessionService = SessionService();
  
  List<Pet> _pets = [];
  List<Session> _sessions = [];
  bool _isLoading = true;
  String _selectedTimeRange = 'week';
  Pet? _selectedPet;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _petService.initialize();
      await _sessionService.initialize();
      
      setState(() {
        _pets = _petService.pets;
        _sessions = _sessionService.sessions;
        if (_pets.isNotEmpty) {
          _selectedPet = _pets.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Session> get _filteredSessions {
    if (_selectedPet == null) return _sessions;
    return _sessions.where((session) => session.petId == _selectedPet!.id).toList();
  }

  List<Session> get _timeFilteredSessions {
    final now = DateTime.now();
    final filtered = _filteredSessions.where((session) {
      switch (_selectedTimeRange) {
        case 'week':
          return session.createdAt.isAfter(now.subtract(const Duration(days: 7)));
        case 'month':
          return session.createdAt.isAfter(now.subtract(const Duration(days: 30)));
        case 'quarter':
          return session.createdAt.isAfter(now.subtract(const Duration(days: 90)));
        case 'year':
          return session.createdAt.isAfter(now.subtract(const Duration(days: 365)));
        default:
          return true;
      }
    }).toList();
    
    return filtered;
  }

  Map<String, dynamic> get _sessionStats {
    final sessions = _timeFilteredSessions;
    if (sessions.isEmpty) return {};
    
    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    final totalDuration = completedSessions.fold<Duration>(
      Duration.zero,
      (total, session) => total + (session.duration ?? Duration.zero),
    );
    
    final averageMood = completedSessions
        .where((s) => s.moodRating != null)
        .map((s) => s.moodRating!)
        .fold(0.0, (sum, rating) => sum + rating);
    
    final moodCount = completedSessions.where((s) => s.moodRating != null).length;
    
    return {
      'total_sessions': sessions.length,
      'completed_sessions': completedSessions.length,
      'completion_rate': sessions.isNotEmpty ? (completedSessions.length / sessions.length) * 100 : 0,
      'total_duration': totalDuration,
      'average_duration': sessions.isNotEmpty ? totalDuration.inMinutes / sessions.length : 0,
      'average_mood': moodCount > 0 ? averageMood / moodCount : 0,
      'total_interactions': sessions.fold(0, (sum, s) => sum + s.interactions.length),
      'favorite_session_type': _getFavoriteSessionType(sessions),
      'best_time_of_day': _getBestTimeOfDay(sessions),
      'mood_trend': _getMoodTrend(completedSessions),
      'session_frequency': _getSessionFrequency(sessions),
    };
  }

  String _getFavoriteSessionType(List<Session> sessions) {
    final typeCounts = <String, int>{};
    for (final session in sessions) {
      typeCounts[session.typeDisplayName] = (typeCounts[session.typeDisplayName] ?? 0) + 1;
    }
    
    if (typeCounts.isEmpty) return 'None';
    
    final favorite = typeCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return favorite.key;
  }

  String _getBestTimeOfDay(List<Session> sessions) {
    final hourCounts = <int, int>{};
    for (final session in sessions) {
      final hour = session.createdAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    if (hourCounts.isEmpty) return 'Unknown';
    
    final bestHour = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    if (bestHour < 12) {
      return '${bestHour == 0 ? 12 : bestHour} AM';
    } else if (bestHour == 12) {
      return '12 PM';
    } else {
      return '${bestHour - 12} PM';
    }
  }

  List<double> _getMoodTrend(List<Session> sessions) {
    final moodSessions = sessions.where((s) => s.moodRating != null).toList();
    if (moodSessions.isEmpty) return [];
    
    // Group by week and calculate average mood
    final weeklyMoods = <int, List<double>>{};
    for (final session in moodSessions) {
      final weekNumber = session.createdAt.difference(DateTime(2024)).inDays ~/ 7;
      weeklyMoods.putIfAbsent(weekNumber, () => <double>[]).add(session.moodRating!.toDouble());
    }
    
    return weeklyMoods.values.map((moods) => 
      moods.reduce((a, b) => a + b) / moods.length
    ).toList();
  }

  Map<String, int> _getSessionFrequency(List<Session> sessions) {
    final frequency = <String, int>{};
    for (final session in sessions) {
      final date = '${session.createdAt.year}-${session.createdAt.month.toString().padLeft(2, '0')}';
      frequency[date] = (frequency[date] ?? 0) + 1;
    }
    return frequency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.softPurpleGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTimeRangeSelector(),
              _buildPetSelector(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildAnalyticsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.warmGrey),
          ),
          Expanded(
            child: Text(
              'Bonding Insights',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.warmGrey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.info_outline, color: AppTheme.warmGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    final timeRanges = [
      {'key': 'week', 'label': 'Week', 'icon': Icons.view_week},
      {'key': 'month', 'label': 'Month', 'icon': Icons.calendar_month},
      {'key': 'quarter', 'label': 'Quarter', 'icon': Icons.calendar_view_month},
      {'key': 'year', 'label': 'Year', 'icon': Icons.calendar_today},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.lgSpacing),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: timeRanges.length,
        itemBuilder: (context, index) {
          final timeRange = timeRanges[index];
          final isSelected = _selectedTimeRange == timeRange['key'];
          
          return Container(
            margin: const EdgeInsets.only(right: AppConstants.smSpacing),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    timeRange['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppTheme.warmGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(timeRange['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedTimeRange = timeRange['key'] as String;
                });
              },
              selectedColor: AppTheme.softPurple,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.warmGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetSelector() {
    if (_pets.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.lgSpacing),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _pets.length + 1, // +1 for "All Pets"
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All Pets" option
            final isSelected = _selectedPet == null;
            return Container(
              margin: const EdgeInsets.only(right: AppConstants.smSpacing),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPet = null;
                  });
                },
                borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.mdSpacing,
                    vertical: AppConstants.smSpacing,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.softPurple : AppTheme.softPink.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                    border: Border.all(
                      color: isSelected ? AppTheme.softPurple : AppTheme.softPink,
                    ),
                  ),
                  child: Text(
                    'All Pets',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.warmGrey,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }

          final pet = _pets[index - 1];
          final isSelected = _selectedPet?.id == pet.id;
          
          return Container(
            margin: const EdgeInsets.only(right: AppConstants.smSpacing),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPet = pet;
                });
              },
              borderRadius: BorderRadius.circular(AppConstants.mdRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.mdSpacing,
                  vertical: AppConstants.smSpacing,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.softPurple : AppTheme.softPink.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                  border: Border.all(
                    color: isSelected ? AppTheme.softPurple : AppTheme.softPink,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getPetColor(pet),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smSpacing),
                    Text(
                      pet.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.warmGrey,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
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

  Widget _buildAnalyticsContent() {
    if (_pets.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      children: [
        // Key Metrics Row
        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: 'Total Sessions',
                value: '${_sessionStats['total_sessions'] ?? 0}',
                subtitle: '${_sessionStats['completed_sessions'] ?? 0} completed',
                icon: Icons.play_circle_outline,
                color: AppTheme.heartPink,
                trend: _sessionStats['completion_rate'] ?? 0,
                trendLabel: 'completion rate',
              ),
            ),
            const SizedBox(width: AppConstants.mdSpacing),
            Expanded(
              child: AnalyticsCard(
                title: 'Total Time',
                value: _formatDuration(_sessionStats['total_duration'] ?? Duration.zero),
                subtitle: '${(_sessionStats['average_duration'] ?? 0).round()} min avg',
                icon: Icons.timer,
                color: AppTheme.leafGreen,
                trend: _sessionStats['average_mood'] ?? 0,
                trendLabel: 'avg mood',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.mdSpacing),
        
        // Second Row
        Row(
          children: [
            Expanded(
              child: AnalyticsCard(
                title: 'Interactions',
                value: '${_sessionStats['total_interactions'] ?? 0}',
                subtitle: 'Total touches & interactions',
                icon: Icons.touch_app,
                color: AppTheme.softPurple,
                trend: null,
                trendLabel: null,
              ),
            ),
            const SizedBox(width: AppConstants.mdSpacing),
            Expanded(
              child: AnalyticsCard(
                title: 'Favorite Type',
                value: _sessionStats['favorite_session_type'] ?? 'None',
                subtitle: 'Most chosen session type',
                icon: Icons.favorite,
                color: AppTheme.lightPink,
                trend: null,
                trendLabel: null,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Session Chart
        Container(
          padding: const EdgeInsets.all(AppConstants.lgSpacing),
          decoration: BoxDecoration(
            color: AppTheme.gentleCream,
            borderRadius: BorderRadius.circular(AppConstants.lgRadius),
            boxShadow: [
              BoxShadow(
                color: AppTheme.warmGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session Frequency',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.warmGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.mdSpacing),
              SessionChart(
                sessionFrequency: _sessionStats['session_frequency'] ?? {},
                timeRange: _selectedTimeRange,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Mood Trend Chart
        Container(
          padding: const EdgeInsets.all(AppConstants.lgSpacing),
          decoration: BoxDecoration(
            color: AppTheme.gentleCream,
            borderRadius: BorderRadius.circular(AppConstants.lgRadius),
            boxShadow: [
              BoxShadow(
                color: AppTheme.warmGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mood Trends',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.warmGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.mdSpacing),
              MoodTrendChart(
                moodTrend: _sessionStats['mood_trend'] ?? [],
                timeRange: _selectedTimeRange,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Bonding Insights
        BondingInsightsCard(
          stats: _sessionStats,
          pet: _selectedPet,
          timeRange: _selectedTimeRange,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.softPink.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics,
              color: AppTheme.heartPink,
              size: 60,
            ),
          ),
          const SizedBox(height: AppConstants.lgSpacing),
          Text(
            'No analytics yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'Complete some sessions with your pets to see insights!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.warmGrey.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPetColor(Pet pet) {
    final hash = pet.id.hashCode;
    final colors = [
      AppTheme.heartPink,
      AppTheme.leafGreen,
      AppTheme.softPurple,
      AppTheme.lightPink,
      AppTheme.pastelPeach,
    ];
    
    return colors[hash.abs() % colors.length];
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}