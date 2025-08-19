import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/gamification_service.dart';
import '../../../../shared/models/social_models.dart';
import '../../../../core/theme/app_theme.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with TickerProviderStateMixin {
  final String _userId = 'demo-user';
  
  UserPoints? _userPoints;
  List<Achievement> _userAchievements = [];
  List<LeaderboardEntry> _leaderboard = [];
  List<DailyChallenge> _dailyChallenges = [];
  List<WeeklyGoal> _weeklyGoals = [];
  List<Reward> _rewardsCatalog = [];
  
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    _fadeController.forward();
    _bounceController.repeat(reverse: true);
    
    _initializeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gamificationService = context.read<GamificationService>();
      gamificationService.initializeMockData();
      
      // Load initial data
      await _loadUserPoints();
      await _loadUserAchievements();
      await _loadLeaderboard();
      await _loadDailyChallenges();
      await _loadWeeklyGoals();
      await _loadRewardsCatalog();
    } catch (e) {
      _showSnackBar('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPoints() async {
    try {
      final gamificationService = context.read<GamificationService>();
      final points = await gamificationService.getUserPoints(_userId);
      setState(() {
        _userPoints = points;
      });
    } catch (e) {
      _showSnackBar('Error loading user points: $e');
    }
  }

  Future<void> _loadUserAchievements() async {
    try {
      final gamificationService = context.read<GamificationService>();
      final achievements = await gamificationService.getUserAchievements(_userId);
      setState(() {
        _userAchievements = achievements;
      });
    } catch (e) {
      _showSnackBar('Error loading achievements: $e');
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      final gamificationService = context.read<GamificationService>();
      final leaderboard = await gamificationService.getLeaderboard();
      setState(() {
        _leaderboard = leaderboard;
      });
    } catch (e) {
      _showSnackBar('Error loading leaderboard: $e');
    }
  }

  Future<void> _loadDailyChallenges() async {
    try {
      final gamificationService = context.read<GamificationService>();
      final challenges = await gamificationService.getDailyChallenges();
      setState(() {
        _dailyChallenges = challenges;
      });
    } catch (e) {
      _showSnackBar('Error loading daily challenges: $e');
    }
  }

  Future<void> _loadWeeklyGoals() async {
    try {
      final gamificationService = context.read<GamificationService>();
      final goals = await gamificationService.getWeeklyGoals();
      setState(() {
        _weeklyGoals = goals;
      });
    } catch (e) {
      _showSnackBar('Error loading weekly goals: $e');
    }
  }

  Future<void> _loadRewardsCatalog() async {
    try {
      final gamificationService = context.read<GamificationService>();
      final rewards = await gamificationService.getRewardsCatalog();
      setState(() {
        _rewardsCatalog = rewards;
      });
    } catch (e) {
      _showSnackBar('Error loading rewards: $e');
    }
  }

  Future<void> _completeDailyChallenge(DailyChallenge challenge) async {
    try {
      final gamificationService = context.read<GamificationService>();
      await gamificationService.completeDailyChallenge(
        userId: _userId,
        challengeId: challenge.id,
      );
      
      // Reload data
      await _loadUserPoints();
      await _loadUserAchievements();
      await _loadDailyChallenges();
      
      _showSnackBar('Challenge completed! +${challenge.pointsReward} points');
    } catch (e) {
      _showSnackBar('Error completing challenge: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Gamification & Rewards'),
        backgroundColor: AppTheme.colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSelector,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Stats Overview
                    if (_userPoints != null) _buildUserStatsOverview(),
                    
                    const SizedBox(height: 24),
                    
                    // Daily Challenges
                    _buildDailyChallengesSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Weekly Goals
                    _buildWeeklyGoalsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Achievements
                    _buildAchievementsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Leaderboard
                    _buildLeaderboardSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Rewards Catalog
                    _buildRewardsSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUserStatsOverview() {
    if (_userPoints == null) return const SizedBox.shrink();
    
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.colors.primary,
              AppTheme.colors.secondary,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Level and Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      '${_userPoints!.level}',
                      style: AppTheme.textStyles.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userPoints!.levelTitle,
                        style: AppTheme.textStyles.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Level ${_userPoints!.level}',
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Points and Streak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.stars,
                    label: 'Total Points',
                    value: '${_userPoints!.totalPoints}',
                    color: Colors.white,
                  ),
                  _buildStatItem(
                    icon: Icons.local_fire_department,
                    label: 'Current Streak',
                    value: '${_userPoints!.currentStreak} days',
                    color: Colors.white,
                  ),
                  _buildStatItem(
                    icon: Icons.emoji_events,
                    label: 'Longest Streak',
                    value: '${_userPoints!.longestStreak} days',
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallengesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.task_alt,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daily Challenges',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_dailyChallenges.isEmpty)
              _buildEmptyState(
                icon: Icons.task_alt,
                title: 'No challenges today',
                message: 'Check back tomorrow for new daily challenges!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dailyChallenges.length,
                itemBuilder: (context, index) {
                  final challenge = _dailyChallenges[index];
                  return _buildChallengeCard(challenge);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge) {
    final isCompleted = challenge.isCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppTheme.colors.success.withOpacity(0.1)
            : AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
              ? AppTheme.colors.success.withOpacity(0.3)
              : AppTheme.colors.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppTheme.colors.success.withOpacity(0.2)
                  : AppTheme.colors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? AppTheme.colors.success : AppTheme.colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  challenge.description,
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 16,
                      color: AppTheme.colors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${challenge.pointsReward} points',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (challenge.deadline != null)
                      Text(
                        'Due: ${_formatDeadline(challenge.deadline!)}',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!isCompleted)
            ElevatedButton(
              onPressed: () => _completeDailyChallenge(challenge),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Complete'),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Goals',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_weeklyGoals.isEmpty)
              _buildEmptyState(
                icon: Icons.flag,
                title: 'No weekly goals set',
                message: 'Set weekly goals to earn bonus rewards!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _weeklyGoals.length,
                itemBuilder: (context, index) {
                  final goal = _weeklyGoals[index];
                  return _buildGoalCard(goal);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(WeeklyGoal goal) {
    final progress = goal.currentProgress / goal.targetProgress;
    final isCompleted = progress >= 1.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppTheme.colors.success.withOpacity(0.1)
            : AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted 
              ? AppTheme.colors.success.withOpacity(0.3)
              : AppTheme.colors.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.flag : Icons.flag_outlined,
                color: isCompleted ? AppTheme.colors.success : AppTheme.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completed!',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            goal.description,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${goal.currentProgress}/${goal.targetProgress}',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: AppTheme.colors.outline.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? AppTheme.colors.success : AppTheme.colors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                Icons.stars,
                size: 16,
                color: AppTheme.colors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                '+${goal.pointsReward} points',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Due: ${_formatDeadline(goal.deadline)}',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_userAchievements.length} unlocked',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_userAchievements.isEmpty)
              _buildEmptyState(
                icon: Icons.emoji_events,
                title: 'No achievements yet',
                message: 'Complete challenges and goals to unlock achievements!',
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _userAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = _userAchievements[index];
                  return _buildAchievementCard(achievement);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAchievementTypeColor(achievement.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _getAchievementTypeIcon(achievement.type),
              color: _getAchievementTypeColor(achievement.type),
              size: 32,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            achievement.title,
            style: AppTheme.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            achievement.description,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${achievement.pointsReward}',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.leaderboard,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Leaderboard',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_leaderboard.isEmpty)
              _buildEmptyState(
                icon: Icons.leaderboard,
                title: 'No leaderboard data',
                message: 'Be the first to earn points and climb the leaderboard!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leaderboard.length,
                itemBuilder: (context, index) {
                  final entry = _leaderboard[index];
                  return _buildLeaderboardEntry(entry, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, int index) {
    final isCurrentUser = entry.userId == _userId;
    final rank = index + 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? AppTheme.colors.primary.withOpacity(0.1)
            : AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentUser 
              ? AppTheme.colors.primary.withOpacity(0.3)
              : AppTheme.colors.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTheme.textStyles.titleSmall?.copyWith(
                  color: _getRankColor(rank),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  entry.levelTitle,
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${entry.points} pts',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Rewards Catalog',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_rewardsCatalog.isEmpty)
              _buildEmptyState(
                icon: Icons.card_giftcard,
                title: 'No rewards available',
                message: 'Check back later for new rewards!',
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _rewardsCatalog.length,
                itemBuilder: (context, index) {
                  final reward = _rewardsCatalog[index];
                  return _buildRewardCard(reward);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final canAfford = _userPoints?.totalPoints ?? 0 >= reward.pointsCost;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canAfford 
              ? AppTheme.colors.primary.withOpacity(0.3)
              : AppTheme.colors.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.card_giftcard,
              color: AppTheme.colors.primary,
              size: 32,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            reward.name,
            style: AppTheme.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            reward.description,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: canAfford 
                  ? AppTheme.colors.primary.withOpacity(0.1)
                  : AppTheme.colors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${reward.pointsCost} pts',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: canAfford ? AppTheme.colors.primary : AppTheme.colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          ElevatedButton(
            onPressed: canAfford ? () => _purchaseReward(reward) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? AppTheme.colors.primary : AppTheme.colors.outline,
              foregroundColor: canAfford ? Colors.white : AppTheme.colors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(canAfford ? 'Redeem' : 'Not Enough Points'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.textStyles.bodyLarge?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English', '🇺🇸'),
            _buildLanguageOption('es', 'Español', '🇪🇸'),
            _buildLanguageOption('fr', 'Français', '🇫🇷'),
            _buildLanguageOption('de', 'Deutsch', '🇩🇪'),
            _buildLanguageOption('ja', '日本語', '🇯🇵'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: _selectedLanguage == code
          ? Icon(Icons.check, color: AppTheme.colors.primary)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
        Navigator.pop(context);
        _initializeData(); // Reload data with new language
      },
    );
  }

  void _purchaseReward(Reward reward) {
    _showSnackBar('Reward redeemed: ${reward.name}');
  }

  Color _getAchievementTypeColor(AchievementType type) {
    switch (type) {
      case AchievementType.firstSteps:
        return AppTheme.colors.primary;
      case AchievementType.socialButterfly:
        return AppTheme.colors.secondary;
      case AchievementType.healthGuru:
        return AppTheme.colors.success;
      case AchievementType.trainingMaster:
        return AppTheme.colors.warning;
      case AchievementType.communityLeader:
        return AppTheme.colors.info;
      case AchievementType.legendary:
        return AppTheme.colors.error;
      default:
        return AppTheme.colors.textSecondary;
    }
  }

  IconData _getAchievementTypeIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstSteps:
        return Icons.directions_walk;
      case AchievementType.socialButterfly:
        return Icons.people;
      case AchievementType.healthGuru:
        return Icons.favorite;
      case AchievementType.trainingMaster:
        return Icons.school;
      case AchievementType.communityLeader:
        return Icons.leaderboard;
      case AchievementType.legendary:
        return Icons.auto_awesome;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return AppTheme.colors.primary;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.inDays < 0) {
      return 'Expired';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else {
      return '${difference.inDays} days';
    }
  }
}