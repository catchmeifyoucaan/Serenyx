import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/social_models.dart';

class SocialShareDialog extends StatefulWidget {
  final User user;
  final PetProgress? petProgress;
  final List<Achievement> achievements;
  final Function(SocialShareSettings) onShare;

  const SocialShareDialog({
    super.key,
    required this.user,
    this.petProgress,
    required this.achievements,
    required this.onShare,
  });

  @override
  State<SocialShareDialog> createState() => _SocialShareDialogState();
}

class _SocialShareDialogState extends State<SocialShareDialog> {
  late SocialShareSettings _shareSettings;
  final TextEditingController _customMessageController = TextEditingController();
  final List<String> _availableHashtags = [
    '#Serenyx',
    '#PetWellness',
    '#PetProgress',
    '#PetParent',
    '#PetCare',
    '#WellnessJourney',
    '#PetCommunity',
    '#PetAchievement',
  ];

  @override
  void initState() {
    super.initState();
    _shareSettings = SocialShareSettings(
      customMessage: _generateDefaultMessage(),
      selectedHashtags: _availableHashtags.take(3).toList(),
    );
    _customMessageController.text = _shareSettings.customMessage;
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }

  String _generateDefaultMessage() {
    if (widget.petProgress != null) {
      return 'Check out ${widget.petProgress!.petName}\'s amazing progress on Serenyx! 🐾✨';
    } else if (widget.achievements.isNotEmpty) {
      return 'I just unlocked "${widget.achievements.first.title}" on Serenyx! 🎉';
    } else {
      return 'Join me on Serenyx for the ultimate pet wellness experience! 🌟';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Content Preview
            if (widget.petProgress != null) _buildContentPreview(),
            
            // Share Options
            _buildShareOptions(),
            
            // Custom Message
            _buildCustomMessage(),
            
            // Hashtag Selection
            _buildHashtagSelection(),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.share,
            color: AppTheme.colors.onPrimary,
            size: 28,
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Text(
              'Share Your Progress',
              style: AppTheme.textStyles.titleLarge?.copyWith(
                color: AppTheme.colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: AppTheme.colors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPreview() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Pet Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.colors.outline,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: widget.petProgress!.photos.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          widget.petProgress!.photos.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.pets,
                              color: AppTheme.colors.textSecondary,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.pets,
                        color: AppTheme.colors.textSecondary,
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // Pet Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.petProgress!.petName,
                      style: AppTheme.textStyles.titleMedium?.copyWith(
                        color: AppTheme.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    Text(
                      '${widget.petProgress!.petBreed} • ${widget.petProgress!.ageDescription}',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.petProgress!.statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.petProgress!.overallStatus,
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: widget.petProgress!.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Achievements',
                '${widget.petProgress!.petAchievements.length}',
                Icons.emoji_events,
              ),
              _buildStatItem(
                'Milestones',
                '${widget.petProgress!.recentMilestones.length}',
                Icons.flag,
              ),
              _buildStatItem(
                'Photos',
                '${widget.petProgress!.photos.length}',
                Icons.photo_camera,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.colors.primary,
          size: 20,
        ),
        
        const SizedBox(height: 4),
        
        Text(
          value,
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        Text(
          label,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildShareOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share to Platforms',
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPlatformToggle(SocialPlatform.twitter, 'Twitter', Icons.flutter_dash),
              _buildPlatformToggle(SocialPlatform.facebook, 'Facebook', Icons.facebook),
              _buildPlatformToggle(SocialPlatform.instagram, 'Instagram', Icons.camera_alt),
              _buildPlatformToggle(SocialPlatform.tiktok, 'TikTok', Icons.music_note),
              _buildPlatformToggle(SocialPlatform.whatsapp, 'WhatsApp', Icons.chat),
              _buildPlatformToggle(SocialPlatform.telegram, 'Telegram', Icons.send),
              _buildPlatformToggle(SocialPlatform.email, 'Email', Icons.email),
              _buildPlatformToggle(SocialPlatform.sms, 'SMS', Icons.sms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformToggle(SocialPlatform platform, String label, IconData icon) {
    final isSelected = _getPlatformSelection(platform);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _updatePlatformSelection(platform, !isSelected);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.colors.primary : AppTheme.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.colors.primary : AppTheme.colors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textSecondary,
              size: 20,
            ),
            
            const SizedBox(width: 8),
            
            Text(
              label,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomMessage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Message',
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          TextField(
            controller: _customMessageController,
            maxLines: 3,
            maxLength: 280,
            decoration: InputDecoration(
              hintText: 'Write your custom message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.colors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.colors.background,
            ),
            onChanged: (value) {
              setState(() {
                _shareSettings = _shareSettings.copyWith(customMessage: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHashtagSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Hashtags',
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableHashtags.map((hashtag) {
              final isSelected = _shareSettings.selectedHashtags.contains(hashtag);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    final newHashtags = List<String>.from(_shareSettings.selectedHashtags);
                    if (isSelected) {
                      newHashtags.remove(hashtag);
                    } else {
                      newHashtags.add(hashtag);
                    }
                    _shareSettings = _shareSettings.copyWith(selectedHashtags: newHashtags);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.colors.primary : AppTheme.colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.colors.primary : AppTheme.colors.outline,
                    ),
                  ),
                  child: Text(
                    hashtag,
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Cancel Button
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.colors.textSecondary,
                side: BorderSide(color: AppTheme.colors.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Cancel'),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Share Button
          Expanded(
            child: ElevatedButton(
              onPressed: _canShare() ? () {
                widget.onShare(_shareSettings);
                Navigator.of(context).pop();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: AppTheme.colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Share Now',
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _getPlatformSelection(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.twitter:
        return _shareSettings.shareToTwitter;
      case SocialPlatform.facebook:
        return _shareSettings.shareToFacebook;
      case SocialPlatform.instagram:
        return _shareSettings.shareToInstagram;
      case SocialPlatform.tiktok:
        return _shareSettings.shareToTiktok;
      case SocialPlatform.whatsapp:
        return _shareSettings.shareToWhatsapp;
      case SocialPlatform.telegram:
        return _shareSettings.shareToTelegram;
      case SocialPlatform.email:
        return _shareSettings.shareViaEmail;
      case SocialPlatform.sms:
        return _shareSettings.shareViaSMS;
    }
  }

  void _updatePlatformSelection(SocialPlatform platform, bool value) {
    switch (platform) {
      case SocialPlatform.twitter:
        _shareSettings = _shareSettings.copyWith(shareToTwitter: value);
        break;
      case SocialPlatform.facebook:
        _shareSettings = _shareSettings.copyWith(shareToFacebook: value);
        break;
      case SocialPlatform.instagram:
        _shareSettings = _shareSettings.copyWith(shareToInstagram: value);
        break;
      case SocialPlatform.tiktok:
        _shareSettings = _shareSettings.copyWith(shareToTiktok: value);
        break;
      case SocialPlatform.whatsapp:
        _shareSettings = _shareSettings.copyWith(shareToWhatsapp: value);
        break;
      case SocialPlatform.telegram:
        _shareSettings = _shareSettings.copyWith(shareToTelegram: value);
        break;
      case SocialPlatform.email:
        _shareSettings = _shareSettings.copyWith(shareViaEmail: value);
        break;
      case SocialPlatform.sms:
        _shareSettings = _shareSettings.copyWith(shareViaSMS: value);
        break;
    }
  }

  bool _canShare() {
    return _shareSettings.shareToTwitter ||
           _shareSettings.shareToFacebook ||
           _shareSettings.shareToInstagram ||
           _shareSettings.shareToTiktok ||
           _shareSettings.shareToWhatsapp ||
           _shareSettings.shareToTelegram ||
           _shareSettings.shareViaEmail ||
           _shareSettings.shareViaSMS;
  }
}