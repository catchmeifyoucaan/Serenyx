import 'dart:io';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../models/social_models.dart';

class SocialSharingService {
  static const MethodChannel _channel = MethodChannel('social_sharing');
  
  // Social media URLs
  static const Map<SocialPlatform, String> _platformUrls = {
    SocialPlatform.twitter: 'https://twitter.com/intent/tweet',
    SocialPlatform.facebook: 'https://www.facebook.com/sharer/sharer.php',
    SocialPlatform.instagram: 'https://www.instagram.com',
    SocialPlatform.tiktok: 'https://www.tiktok.com',
    SocialPlatform.whatsapp: 'https://wa.me',
    SocialPlatform.telegram: 'https://t.me',
  };

  /// Share content to multiple social platforms
  Future<bool> shareToMultiplePlatforms({
    required SocialShareContent content,
    required SocialShareSettings settings,
    required Widget widgetToCapture,
  }) async {
    try {
      // Capture widget as image if needed
      List<String> processedImages = content.imageUrls;
      if (content.imageUrls.isEmpty && widgetToCapture != null) {
        final capturedImage = await _captureWidget(widgetToCapture);
        if (capturedImage != null) {
          processedImages = [capturedImage];
        }
      }

      bool allShared = true;
      
      // Share to Twitter
      if (settings.shareToTwitter) {
        final success = await _shareToTwitter(
          content.getMessageForPlatform(SocialPlatform.twitter),
          processedImages,
          content.hashtags,
        );
        allShared = allShared && success;
      }

      // Share to Facebook
      if (settings.shareToFacebook) {
        final success = await _shareToFacebook(
          content.getMessageForPlatform(SocialPlatform.facebook),
          processedImages,
          content.url,
        );
        allShared = allShared && success;
      }

      // Share to Instagram
      if (settings.shareToInstagram) {
        final success = await _shareToInstagram(
          content.getMessageForPlatform(SocialPlatform.instagram),
          processedImages,
        );
        allShared = allShared && success;
      }

      // Share to TikTok
      if (settings.shareToTiktok) {
        final success = await _shareToTiktok(
          content.getMessageForPlatform(SocialPlatform.tiktok),
          processedImages,
        );
        allShared = allShared && success;
      }

      // Share to WhatsApp
      if (settings.shareToWhatsapp) {
        final success = await _shareToWhatsapp(
          content.getMessageForPlatform(SocialPlatform.whatsapp),
          processedImages,
        );
        allShared = allShared && success;
      }

      // Share to Telegram
      if (settings.shareToTelegram) {
        final success = await _shareToTelegram(
          content.getMessageForPlatform(SocialPlatform.telegram),
          processedImages,
        );
        allShared = allShared && success;
      }

      // Share via Email
      if (settings.shareViaEmail) {
        final success = await _shareViaEmail(
          content.title,
          content.getMessageForPlatform(SocialPlatform.email),
          processedImages,
        );
        allShared = allShared && success;
      }

      // Share via SMS
      if (settings.shareViaSMS) {
        final success = await _shareViaSMS(
          content.getMessageForPlatform(SocialPlatform.sms),
        );
        allShared = allShared && success;
      }

      return allShared;
    } catch (e) {
      print('Error sharing to multiple platforms: $e');
      return false;
    }
  }

  /// Share to Twitter/X
  Future<bool> _shareToTwitter(
    String message,
    List<String> images,
    List<String> hashtags,
  ) async {
    try {
      final hashtagString = hashtags.isNotEmpty ? ' ${hashtags.join(' ')}' : '';
      final fullMessage = '$message$hashtagString';
      
      final url = Uri.parse('$_platformUrls[SocialPlatform.twitter]!?text=${Uri.encodeComponent(fullMessage)}');
      
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error sharing to Twitter: $e');
      return false;
    }
  }

  /// Share to Facebook
  Future<bool> _shareToFacebook(
    String message,
    List<String> images,
    String? url,
  ) async {
    try {
      String shareUrl = _platformUrls[SocialPlatform.facebook]!;
      final params = <String, String>{};
      
      if (message.isNotEmpty) {
        params['quote'] = message;
      }
      
      if (url != null) {
        params['u'] = url;
      }
      
      if (params.isNotEmpty) {
        final queryString = params.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        shareUrl += '?$queryString';
      }
      
      final uri = Uri.parse(shareUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error sharing to Facebook: $e');
      return false;
    }
  }

  /// Share to Instagram
  Future<bool> _shareToInstagram(
    String message,
    List<String> images,
  ) async {
    try {
      if (images.isNotEmpty) {
        // For Instagram, we need to save the image and open the app
        final imageFile = File(images.first);
        if (await imageFile.exists()) {
          // Use share_plus to open Instagram with the image
          await Share.shareXFiles(
            [XFile(imageFile.path)],
            text: message,
            subject: 'Check out my pet!',
          );
          return true;
        }
      }
      
      // Fallback: open Instagram app
      final uri = Uri.parse(_platformUrls[SocialPlatform.instagram]!);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error sharing to Instagram: $e');
      return false;
    }
  }

  /// Share to TikTok
  Future<bool> _shareToTiktok(
    String message,
    List<String> images,
  ) async {
    try {
      if (images.isNotEmpty) {
        // For TikTok, we need to save the image and open the app
        final imageFile = File(images.first);
        if (await imageFile.exists()) {
          // Use share_plus to open TikTok with the image
          await Share.shareXFiles(
            [XFile(imageFile.path)],
            text: message,
            subject: 'Check out my pet!',
          );
          return true;
        }
      }
      
      // Fallback: open TikTok app
      final uri = Uri.parse(_platformUrls[SocialPlatform.tiktok]!);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error sharing to TikTok: $e');
      return false;
    }
  }

  /// Share to WhatsApp
  Future<bool> _shareToWhatsapp(
    String message,
    List<String> images,
  ) async {
    try {
      if (images.isNotEmpty) {
        // For WhatsApp, we need to save the image and open the app
        final imageFile = File(images.first);
        if (await imageFile.exists()) {
          // Use share_plus to open WhatsApp with the image
          await Share.shareXFiles(
            [XFile(imageFile.path)],
            text: message,
            subject: 'Check out my pet!',
          );
          return true;
        }
      }
      
      // Fallback: open WhatsApp with text only
      final url = Uri.parse('${_platformUrls[SocialPlatform.whatsapp]}?text=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
      return false;
    }
  }

  /// Share to Telegram
  Future<bool> _shareToTelegram(
    String message,
    List<String> images,
  ) async {
    try {
      if (images.isNotEmpty) {
        // For Telegram, we need to save the image and open the app
        final imageFile = File(images.first);
        if (await imageFile.exists()) {
          // Use share_plus to open Telegram with the image
          await Share.shareXFiles(
            [XFile(imageFile.path)],
            text: message,
            subject: 'Check out my pet!',
          );
          return true;
        }
      }
      
      // Fallback: open Telegram with text only
      final url = Uri.parse('${_platformUrls[SocialPlatform.telegram]}?text=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error sharing to Telegram: $e');
      return false;
    }
  }

  /// Share via Email
  Future<bool> _shareViaEmail(
    String subject,
    String message,
    List<String> images,
  ) async {
    try {
      final emailUrl = Uri.parse(
        'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(message)}',
      );
      
      if (await canLaunchUrl(emailUrl)) {
        return await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error sharing via email: $e');
      return false;
    }
  }

  /// Share via SMS
  Future<bool> _shareViaSMS(String message) async {
    try {
      final smsUrl = Uri.parse('sms:?body=${Uri.encodeComponent(message)}');
      
      if (await canLaunchUrl(smsUrl)) {
        return await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('Error sharing via SMS: $e');
      return false;
    }
  }

  /// Capture widget as image
  Future<String?> _captureWidget(Widget widget) async {
    try {
      final controller = ScreenshotController();
      final bytes = await controller.captureFromWidget(widget);
      
      if (bytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/shared_pet_${DateTime.now().millisecondsSinceEpoch}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(bytes);
        return imagePath;
      }
      return null;
    } catch (e) {
      print('Error capturing widget: $e');
      return null;
    }
  }

  /// Generate shareable content for pet progress
  SocialShareContent generatePetProgressContent({
    required PetProgress petProgress,
    required String userName,
    String? customMessage,
  }) {
    final message = customMessage ?? 
        'Check out ${petProgress.petName}\'s amazing progress! 🐾\n\n'
        '${petProgress.petBreed} • ${petProgress.ageDescription}\n'
        'Overall Status: ${petProgress.overallStatus}\n'
        'Achievements: ${petProgress.petAchievements.length}\n\n'
        'Join me on Serenyx to track your pet\'s wellness journey! 🌟';

    final hashtags = [
      '#Serenyx',
      '#PetWellness',
      '#${petProgress.petType}Life',
      '#${petProgress.petBreed.replaceAll(' ', '')}',
      '#PetProgress',
      '#WellnessJourney',
      '#PetParent',
      '#PetCare',
    ];

    return SocialShareContent(
      title: '${petProgress.petName}\'s Wellness Progress',
      message: message,
      imageUrls: petProgress.photos,
      hashtags: hashtags,
      platformSpecificMessages: {
        SocialPlatform.twitter: '${petProgress.petName} is thriving on Serenyx! 🐾✨\n\n${petProgress.overallStatus} status • ${petProgress.petAchievements.length} achievements\n\nTrack your pet\'s wellness journey too! #Serenyx #PetWellness',
        SocialPlatform.instagram: '🐾 ${petProgress.petName} is living their best life!\n\n${petProgress.petBreed} • ${petProgress.overallStatus} status\n${petProgress.petAchievements.length} achievements unlocked ✨\n\nJoin the Serenyx community! 🌟 #PetWellness #Serenyx',
        SocialPlatform.facebook: '${petProgress.petName} is making amazing progress on their wellness journey! 🐾\n\nBreed: ${petProgress.petBreed}\nStatus: ${petProgress.overallStatus}\nAchievements: ${petProgress.petAchievements.length}\n\nSerenyx is helping us track every milestone! 🌟',
        SocialPlatform.tiktok: '🐾 ${petProgress.petName} update!\n\n${petProgress.petBreed} • ${petProgress.overallStatus}\n${petProgress.petAchievements.length} achievements ✨\n\nSerenyx makes pet care amazing! #PetTikTok #Serenyx',
      },
    );
  }

  /// Generate shareable content for achievements
  SocialShareContent generateAchievementContent({
    required Achievement achievement,
    required String petName,
    required String userName,
  }) {
    final message = '🎉 I just unlocked "${achievement.title}" with ${petName} on Serenyx!\n\n'
        '${achievement.description}\n'
        'Points earned: ${achievement.pointsReward} ✨\n\n'
        'Join me on Serenyx and unlock achievements with your pets! 🐾';

    final hashtags = [
      '#Serenyx',
      '#PetAchievement',
      '#${achievement.title.replaceAll(' ', '')}',
      '#PetWellness',
      '#AchievementUnlocked',
      '#PetParent',
    ];

    return SocialShareContent(
      title: 'Achievement Unlocked: ${achievement.title}',
      message: message,
      imageUrls: [],
      hashtags: hashtags,
      platformSpecificMessages: {
        SocialPlatform.twitter: '🎉 Just unlocked "${achievement.title}" with ${petName}!\n\n${achievement.pointsReward} points earned ✨\n\nJoin Serenyx and unlock achievements with your pets! #Serenyx #PetAchievement',
        SocialPlatform.instagram: '🎉 Achievement unlocked!\n\n"${achievement.title}" with ${petName}\n${achievement.pointsReward} points ✨\n\nSerenyx makes pet care rewarding! 🌟 #PetAchievement #Serenyx',
        SocialPlatform.facebook: '🎉 Achievement unlocked: "${achievement.title}"!\n\n${achievement.description}\n\n${achievement.pointsReward} points earned with ${petName} ✨\n\nSerenyx is amazing for tracking pet progress!',
        SocialPlatform.tiktok: '🎉 Achievement unlocked!\n\n"${achievement.title}"\n${achievement.pointsReward} points ✨\n\n${petName} is thriving on Serenyx! #PetTikTok #Achievement #Serenyx',
      },
    );
  }

  /// Generate shareable content for community events
  SocialShareContent generateEventContent({
    required CommunityEvent event,
    required String userName,
  }) {
    final message = '🌟 Join me at "${event.title}" on Serenyx!\n\n'
        '${event.description}\n\n'
        '📅 ${_formatDate(event.startDate)}\n'
        '📍 ${event.location}\n'
        '👥 ${event.participants.length}/${event.maxParticipants} participants\n\n'
        'Come join the Serenyx community! 🐾';

    final hashtags = [
      '#Serenyx',
      '#CommunityEvent',
      '#PetCommunity',
      '#${event.eventType.replaceAll(' ', '')}',
      '#PetWellness',
      '#Community',
    ];

    return SocialShareContent(
      title: 'Community Event: ${event.title}',
      message: message,
      imageUrls: [event.imageUrl],
      hashtags: hashtags,
      platformSpecificMessages: {
        SocialPlatform.twitter: '🌟 Join "${event.title}" on Serenyx!\n\n${event.description}\n\n📅 ${_formatDate(event.startDate)}\n📍 ${event.location}\n\nCome join the pet wellness community! #Serenyx #PetCommunity',
        SocialPlatform.instagram: '🌟 Community Event Alert!\n\n"${event.title}"\n\n${event.description}\n\n📅 ${_formatDate(event.startDate)}\n📍 ${event.location}\n\nJoin the Serenyx community! 🐾 #PetCommunity #Serenyx',
        SocialPlatform.facebook: '🌟 Community Event: "${event.title}"\n\n${event.description}\n\n📅 ${_formatDate(event.startDate)}\n📍 ${event.location}\n👥 ${event.participants.length}/${event.maxParticipants} participants\n\nJoin the Serenyx pet wellness community!',
        SocialPlatform.tiktok: '🌟 Community Event!\n\n"${event.title}"\n\n${event.description}\n\n📅 ${_formatDate(event.startDate)}\n📍 ${event.location}\n\nJoin Serenyx! #PetCommunity #Serenyx #CommunityEvent',
      },
    );
  }

  /// Format date for social sharing
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) return 'In $difference days';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Check if social platform is available
  Future<bool> isPlatformAvailable(SocialPlatform platform) async {
    try {
      switch (platform) {
        case SocialPlatform.twitter:
        case SocialPlatform.facebook:
          return await canLaunchUrl(Uri.parse(_platformUrls[platform]!));
        case SocialPlatform.instagram:
        case SocialPlatform.tiktok:
        case SocialPlatform.whatsapp:
        case SocialPlatform.telegram:
          // These platforms require native app integration
          return true;
        case SocialPlatform.email:
          return await canLaunchUrl(Uri.parse('mailto:'));
        case SocialPlatform.sms:
          return await canLaunchUrl(Uri.parse('sms:'));
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  /// Get available platforms for the device
  Future<List<SocialPlatform>> getAvailablePlatforms() async {
    final platforms = <SocialPlatform>[];
    
    for (final platform in SocialPlatform.values) {
      if (await isPlatformAvailable(platform)) {
        platforms.add(platform);
      }
    }
    
    return platforms;
  }
}