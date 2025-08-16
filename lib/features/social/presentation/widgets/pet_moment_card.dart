import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../screens/social_feed_screen.dart';

class PetMomentCard extends StatelessWidget {
  final PetMoment moment;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PetMomentCard({
    super.key,
    required this.moment,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mdSpacing),
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
          // Header
          _buildHeader(),
          
          // Content
          _buildContent(),
          
          // Tags
          if (moment.tags.isNotEmpty) _buildTags(),
          
          // Actions
          _buildActions(),
          
          // Stats
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getUserAvatarColor(moment.userName),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                moment.userName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppConstants.smSpacing),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moment.userName,
                  style: const TextStyle(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'with ${moment.petName} • ${_formatTimestamp(moment.timestamp)}',
                  style: TextStyle(
                    color: AppTheme.warmGrey.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Pet Type Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getPetTypeColor(moment.petType).withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.smRadius),
            ),
            child: Icon(
              _getPetTypeIcon(moment.petType),
              color: _getPetTypeColor(moment.petType),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mdSpacing),
      child: Text(
        moment.content,
        style: const TextStyle(
          color: AppTheme.warmGrey,
          fontSize: 16,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mdSpacing),
      child: Wrap(
        spacing: AppConstants.xsSpacing,
        runSpacing: AppConstants.xsSpacing,
        children: moment.tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.smSpacing,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.softPink.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.smRadius),
            ),
            child: Text(
              '#$tag',
              style: TextStyle(
                color: AppTheme.heartPink,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.mdSpacing),
      child: Row(
        children: [
          // Like Button
          Expanded(
            child: InkWell(
              onTap: onLike,
              borderRadius: BorderRadius.circular(AppConstants.smRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.smSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      moment.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: moment.isLiked ? AppTheme.heartPink : AppTheme.warmGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Like',
                      style: TextStyle(
                        color: moment.isLiked ? AppTheme.heartPink : AppTheme.warmGrey,
                        fontWeight: moment.isLiked ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Comment Button
          Expanded(
            child: InkWell(
              onTap: onComment,
              borderRadius: BorderRadius.circular(AppConstants.smRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.smSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppTheme.warmGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Comment',
                      style: TextStyle(
                        color: AppTheme.warmGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Share Button
          Expanded(
            child: InkWell(
              onTap: onShare,
              borderRadius: BorderRadius.circular(AppConstants.smRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.smSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share_outlined,
                      color: AppTheme.warmGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Share',
                      style: TextStyle(
                        color: AppTheme.warmGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.mdSpacing,
        vertical: AppConstants.smSpacing,
      ),
      decoration: BoxDecoration(
        color: AppTheme.softPink.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppConstants.lgRadius),
        ),
      ),
      child: Row(
        children: [
          // Likes Count
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppTheme.heartPink,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${moment.likes}',
                style: TextStyle(
                  color: AppTheme.heartPink,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: AppConstants.mdSpacing),
          
          // Comments Count
          Row(
            children: [
              Icon(
                Icons.chat_bubble,
                color: AppTheme.softPurple,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${moment.comments}',
                style: TextStyle(
                  color: AppTheme.softPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Time Ago
          Text(
            _getTimeAgo(moment.timestamp),
            style: TextStyle(
              color: AppTheme.warmGrey.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getUserAvatarColor(String userName) {
    final hash = userName.hashCode;
    final colors = [
      AppTheme.heartPink,
      AppTheme.leafGreen,
      AppTheme.softPurple,
      AppTheme.lightPink,
      AppTheme.pastelPeach,
    ];
    
    return colors[hash.abs() % colors.length];
  }

  Color _getPetTypeColor(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return AppTheme.leafGreen;
      case 'cat':
        return AppTheme.heartPink;
      case 'bird':
        return AppTheme.softPurple;
      case 'fish':
        return AppTheme.lightPink;
      case 'hamster':
        return AppTheme.pastelPeach;
      case 'rabbit':
        return AppTheme.softPink;
      default:
        return AppTheme.warmGrey;
    }
  }

  IconData _getPetTypeIcon(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      case 'fish':
        return Icons.water;
      case 'hamster':
        return Icons.pets;
      case 'rabbit':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}