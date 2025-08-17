import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/social_models.dart';
import '../../../../shared/services/points_service.dart';
import '../../../../shared/services/social_sharing_service.dart';
import '../../../../shared/widgets/interactive_pet_image.dart';
import '../widgets/leaderboard_widget.dart';
import '../widgets/achievement_card.dart';
import '../widgets/community_event_card.dart';
import '../widgets/social_share_dialog.dart';
import '../widgets/pet_progress_card.dart';

class CommunityScreen extends StatefulWidget {
  final User user;

  const CommunityScreen({
    super.key,
    required this.user,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PointsService _pointsService = PointsService();
  final SocialSharingService _socialSharingService = SocialSharingService();
  
  List<LeaderboardEntry> _leaderboardEntries = [];
  List<Achievement> _achievements = [];
  List<CommunityEvent> _communityEvents = [];
  List<PetProgress> _petProgress = [];
  UserPoints? _userPoints;
  
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCommunityData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCommunityData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load mock data - in real app, this would come from services
      await _loadMockData();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading community data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMockData() async {
    // Mock achievements
    _achievements = [
      Achievement(
        id: '1',
        title: 'First Pet Parent',
        description: 'Welcome to Serenyx! You\'ve added your first pet.',
        type: AchievementType.firstPet,
        pointsReward: 100,
        iconPath: 'assets/icons/achievements/first_pet.png',
        unlockedAt: DateTime.now(),
        isUnlocked: true,
        criteria: {'required_pets': 1},
      ),
      Achievement(
        id: '2',
        title: 'Photo Master',
        description: 'Upload 10 photos of your pets.',
        type: AchievementType.photoMaster,
        pointsReward: 200,
        iconPath: 'assets/icons/achievements/photo_master.png',
        unlockedAt: DateTime.now(),
        isUnlocked: false,
        criteria: {'required_photos': 10},
      ),
      Achievement(
        id: '3',
        title: 'Health Champion',
        description: 'Complete 50 health checkups.',
        type: AchievementType.healthChampion,
        pointsReward: 300,
        iconPath: 'assets/icons/achievements/health_champion.png',
        unlockedAt: DateTime.now(),
        isUnlocked: false,
        criteria: {'required_health_checks': 50},
      ),
      Achievement(
        id: '4',
        title: 'Streak Keeper',
        description: 'Maintain a 7-day activity streak.',
        type: AchievementType.streakKeeper,
        pointsReward: 150,
        iconPath: 'assets/icons/achievements/streak_keeper.png',
        unlockedAt: DateTime.now(),
        isUnlocked: false,
        criteria: {'required_streak': 7},
      ),
    ];

    // Mock user points
    _userPoints = UserPoints(
      userId: widget.user.id,
      totalPoints: 1250,
      level: 8,
      experiencePoints: 1750,
      experienceToNextLevel: 2000,
      achievements: _achievements.where((a) => a.isUnlocked).toList(),
      categoryPoints: {
        'pet_management': 300,
        'health_wellness': 450,
        'training_behavior': 200,
        'mindfulness': 150,
        'community': 100,
        'ai_features': 50,
      },
      lastActivity: DateTime.now(),
      streakDays: 5,
      maxStreakDays: 12,
    );

    // Mock leaderboard
    _leaderboardEntries = [
      LeaderboardEntry(
        userId: '1',
        userName: 'Sarah Johnson',
        userPhotoUrl: null,
        totalPoints: 2500,
        level: 15,
        rank: 1,
        levelTitle: 'Expert Pet Caretaker',
        streakDays: 25,
        lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
        recentAchievements: ['Health Champion', 'Training Guru'],
      ),
      LeaderboardEntry(
        userId: '2',
        userName: 'Mike Chen',
        userPhotoUrl: null,
        totalPoints: 2100,
        level: 12,
        rank: 2,
        levelTitle: 'Advanced Pet Lover',
        streakDays: 18,
        lastActivity: DateTime.now().subtract(const Duration(hours: 4)),
        recentAchievements: ['Photo Master', 'Mindfulness Master'],
      ),
      LeaderboardEntry(
        userId: '3',
        userName: 'Emma Davis',
        userPhotoUrl: null,
        totalPoints: 1800,
        level: 10,
        rank: 3,
        levelTitle: 'Advanced Pet Lover',
        streakDays: 12,
        lastActivity: DateTime.now().subtract(const Duration(hours: 6)),
        recentAchievements: ['Streak Keeper', 'Community Helper'],
      ),
      LeaderboardEntry(
        userId: widget.user.id,
        userName: widget.user.profile.fullName,
        userPhotoUrl: widget.user.photoURL,
        totalPoints: _userPoints!.totalPoints,
        level: _userPoints!.level,
        rank: 4,
        levelTitle: _userPoints!.levelTitle,
        streakDays: _userPoints!.streakDays,
        lastActivity: _userPoints!.lastActivity,
        recentAchievements: _userPoints!.achievements.map((a) => a.title).toList(),
      ),
    ];

    // Mock community events
    _communityEvents = [
      CommunityEvent(
        id: '1',
        title: 'Pet Wellness Workshop',
        description: 'Join us for an interactive workshop on pet nutrition, exercise, and mental health.',
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 3, hours: 2)),
        location: 'Online',
        organizerId: '1',
        organizerName: 'Dr. Sarah Johnson',
        participants: ['1', '2', '3'],
        maxParticipants: 50,
        eventType: 'Workshop',
        tags: ['wellness', 'nutrition', 'exercise'],
        imageUrl: 'assets/images/events/wellness_workshop.jpg',
        isOnline: true,
        meetingLink: 'https://meet.google.com/abc-defg-hij',
        metadata: {},
      ),
      CommunityEvent(
        id: '2',
        title: 'Training Tips Exchange',
        description: 'Share your best training techniques and learn from other pet parents.',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 1)),
        location: 'Community Forum',
        organizerId: '2',
        organizerName: 'Mike Chen',
        participants: ['2', '3'],
        maxParticipants: 100,
        eventType: 'Discussion',
        tags: ['training', 'tips', 'community'],
        imageUrl: 'assets/images/events/training_tips.jpg',
        isOnline: true,
        metadata: {},
      ),
    ];

    // Mock pet progress
    _petProgress = [
      PetProgress(
        petId: '1',
        petName: 'Luna',
        petType: 'Dog',
        petBreed: 'Golden Retriever',
        age: 24,
        photos: ['assets/images/pets/luna_1.jpg'],
        healthMetrics: {
          'weight': 25.5,
          'energy_level': 'High',
          'appetite': 'Good',
        },
        trainingProgress: {
          'basic_commands': 'Mastered',
          'socialization': 'Excellent',
          'house_training': 'Complete',
        },
        wellnessStats: {
          'daily_exercise': '45 minutes',
          'mental_stimulation': 'High',
          'sleep_quality': 'Excellent',
        },
        petAchievements: _achievements.where((a) => a.isUnlocked).toList(),
        lastUpdated: DateTime.now(),
        overallStatus: 'Excellent',
        recentMilestones: [
          'Completed advanced obedience training',
          'Reached ideal weight',
          'Improved social skills',
        ],
      ),
    ];
  }

  void _showSocialShareDialog() {
    showDialog(
      context: context,
      builder: (context) => SocialShareDialog(
        user: widget.user,
        petProgress: _petProgress.isNotEmpty ? _petProgress.first : null,
        achievements: _userPoints?.achievements ?? [],
        onShare: _handleSocialShare,
      ),
    );
  }

  Future<void> _handleSocialShare(SocialShareSettings settings) async {
    if (_petProgress.isNotEmpty) {
      final content = _socialSharingService.generatePetProgressContent(
        petProgress: _petProgress.first,
        userName: widget.user.profile.fullName,
      );

      final success = await _socialSharingService.shareToMultiplePlatforms(
        content: content,
        settings: settings,
        widgetToCapture: _buildShareableWidget(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully shared to selected platforms!'),
            backgroundColor: AppTheme.colors.success,
          ),
        );
      }
    }
  }

  Widget _buildShareableWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_petProgress.first.petName}\'s Progress',
            style: AppTheme.textStyles.headlineSmall?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tracked with Serenyx',
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Tab Bar
          _buildTabBar(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(),
                _buildAchievementsTab(),
                _buildEventsTab(),
                _buildProgressTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSocialShareDialog,
        backgroundColor: AppTheme.colors.primary,
        child: Icon(
          Icons.share,
          color: AppTheme.colors.onPrimary,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Stats
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _userPoints?.levelColor ?? AppTheme.colors.primary,
                child: Text(
                  '${_userPoints?.level ?? 1}',
                  style: AppTheme.textStyles.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userPoints?.levelTitle ?? 'New Pet Parent',
                      style: AppTheme.textStyles.titleLarge?.copyWith(
                        color: AppTheme.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_userPoints?.totalPoints ?? 0} points • Rank #${_userPoints != null ? _getUserRank() : 'N/A'}',
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Share button
              IconButton(
                onPressed: _showSocialShareDialog,
                icon: Icon(
                  Icons.share,
                  color: AppTheme.colors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to Level ${(_userPoints?.level ?? 1) + 1}',
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_userPoints?.experiencePoints ?? 0}/${(_userPoints?.experiencePoints ?? 0) + (_userPoints?.experienceToNextLevel ?? 100)} XP',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _userPoints?.progressToNextLevel ?? 0.0,
                backgroundColor: AppTheme.colors.outline,
                valueColor: AlwaysStoppedAnimation<Color>(_userPoints?.levelColor ?? AppTheme.colors.primary),
                minHeight: 8,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Streak Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStreakCard(
                'Current Streak',
                '${_userPoints?.streakDays ?? 0} days',
                Icons.local_fire_department,
                AppTheme.colors.warning,
              ),
              _buildStreakCard(
                'Best Streak',
                '${_userPoints?.maxStreakDays ?? 0} days',
                Icons.emoji_events,
                AppTheme.colors.success,
              ),
              _buildStreakCard(
                'Achievements',
                '${_userPoints?.achievements.length ?? 0}',
                Icons.star,
                AppTheme.colors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.colors.primary,
        unselectedLabelColor: AppTheme.colors.textSecondary,
        indicatorColor: AppTheme.colors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.leaderboard), text: 'Leaderboard'),
          Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
          Tab(icon: Icon(Icons.event), text: 'Events'),
          Tab(icon: Icon(Icons.trending_up), text: 'Progress'),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter
          _buildCategoryFilter(),
          
          const SizedBox(height: 20),
          
          // Leaderboard
          LeaderboardWidget(
            entries: _getFilteredLeaderboard(),
            currentUserId: widget.user.id,
            onUserTap: (entry) {
              // Show user profile
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'id': 'all', 'name': 'All', 'icon': Icons.leaderboard},
      {'id': 'health_wellness', 'name': 'Health', 'icon': Icons.health_and_safety},
      {'id': 'training_behavior', 'name': 'Training', 'icon': Icons.school},
      {'id': 'community', 'name': 'Community', 'icon': Icons.people},
      {'id': 'streak', 'name': 'Streaks', 'icon': Icons.local_fire_department},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leaderboard Categories',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category['id'];
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['id'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.colors.primary : AppTheme.colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.colors.primary : AppTheme.colors.outline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 16,
                      color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['name'] as String,
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<LeaderboardEntry> _getFilteredLeaderboard() {
    if (_selectedCategory == 'all') {
      return _leaderboardEntries;
    }
    
    return _pointsService.getCategoryLeaderboard(
      allEntries: _leaderboardEntries,
      category: _selectedCategory,
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Achievements',
            style: AppTheme.textStyles.headlineSmall?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Achievement Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _achievements.length,
            itemBuilder: (context, index) {
              return AchievementCard(
                achievement: _achievements[index],
                onTap: () {
                  // Show achievement details
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Events',
            style: AppTheme.textStyles.headlineSmall?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Events List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _communityEvents.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CommunityEventCard(
                  event: _communityEvents[index],
                  onTap: () {
                    // Show event details
                  },
                  onJoin: () {
                    // Join event
                  },
                  onShare: () {
                    // Share event
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pet Progress',
            style: AppTheme.textStyles.headlineSmall?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Pet Progress Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _petProgress.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PetProgressCard(
                  petProgress: _petProgress[index],
                  onTap: () {
                    // Show detailed progress
                  },
                  onShare: () {
                    // Share progress
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _getUserRank() {
    final userEntry = _leaderboardEntries.firstWhere(
      (entry) => entry.userId == widget.user.id,
      orElse: () => LeaderboardEntry(
        userId: widget.user.id,
        userName: widget.user.profile.fullName,
        totalPoints: 0,
        level: 1,
        rank: 0,
        levelTitle: 'New Pet Parent',
        streakDays: 0,
        lastActivity: DateTime.now(),
        recentAchievements: [],
      ),
    );
    
    return userEntry.rank;
  }
}