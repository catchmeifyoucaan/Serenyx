import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/social_models.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String currentUserId;
  final Function(LeaderboardEntry) onUserTap;

  const LeaderboardWidget({
    super.key,
    required this.entries,
    required this.currentUserId,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Top 3 Podium
        if (entries.length >= 3) _buildPodium(),
        
        const SizedBox(height: 24),
        
        // Full Leaderboard
        _buildLeaderboardList(),
      ],
    );
  }

  Widget _buildPodium() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.colors.outline),
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
          Text(
            '🏆 Top Performers',
            style: AppTheme.textStyles.titleLarge?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 2nd Place
              if (entries.length >= 2)
                _buildPodiumEntry(
                  entry: entries[1],
                  position: 2,
                  size: 80,
                  color: Colors.grey[400]!,
                ),
              
              // 1st Place
              _buildPodiumEntry(
                entry: entries[0],
                position: 1,
                size: 100,
                color: Colors.amber,
              ),
              
              // 3rd Place
              if (entries.length >= 3)
                _buildPodiumEntry(
                  entry: entries[2],
                  position: 3,
                  size: 70,
                  color: Colors.brown[400]!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumEntry({
    required LeaderboardEntry entry,
    required int position,
    required double size,
    required Color color,
  }) {
    final isCurrentUser = entry.userId == currentUserId;
    
    return Column(
      children: [
        // Position Badge
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentUser ? AppTheme.colors.primary : Colors.transparent,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              '$position',
              style: AppTheme.textStyles.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // User Avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentUser ? AppTheme.colors.primary : color,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: entry.userPhotoUrl != null
                ? Image.network(
                    entry.userPhotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar(entry.userName, color);
                    },
                  )
                : _buildDefaultAvatar(entry.userName, color),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // User Name
        SizedBox(
          width: size + 20,
          child: Text(
            entry.userName,
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Points
        Text(
          '${entry.totalPoints} pts',
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: AppTheme.colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Level
        Text(
          entry.levelTitle,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: position * 200));
  }

  Widget _buildDefaultAvatar(String userName, Color color) {
    return Container(
      color: color.withOpacity(0.2),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: AppTheme.textStyles.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isCurrentUser = entry.userId == currentUserId;
          
          return _buildLeaderboardEntry(entry, index + 1, isCurrentUser);
        },
      ),
    );
  }

  Widget _buildLeaderboardEntry(
    LeaderboardEntry entry,
    int rank,
    bool isCurrentUser,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppTheme.colors.primary.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: AppTheme.colors.primary, width: 2)
            : null,
      ),
      child: ListTile(
        onTap: () => onUserTap(entry),
        leading: _buildRankBadge(rank, entry.levelColor),
        
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.userName,
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'YOU',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.levelTitle,
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: entry.levelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            if (entry.recentAchievements.isNotEmpty)
              Text(
                'Recent: ${entry.recentAchievements.first}',
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalPoints}',
              style: AppTheme.textStyles.titleLarge?.copyWith(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            Text(
              'pts',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: AppTheme.colors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.streakDays}',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideInX(
      begin: 0.3,
      delay: Duration(milliseconds: rank * 100),
    );
  }

  Widget _buildRankBadge(int rank, Color levelColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: rank <= 3 ? _getRankColor(rank) : levelColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: rank <= 3 ? _getRankColor(rank) : levelColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return AppTheme.colors.primary;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.leaderboard,
            size: 64,
            color: AppTheme.colors.textSecondary,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'No Leaderboard Data',
            style: AppTheme.textStyles.titleLarge?.copyWith(
              color: AppTheme.colors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Start using the app to appear on the leaderboard!',
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}