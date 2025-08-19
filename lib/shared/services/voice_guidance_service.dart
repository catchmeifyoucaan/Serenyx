import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/config/api_config.dart';
import 'api_service.dart';

class VoiceGuidanceService extends ChangeNotifier {
  static final VoiceGuidanceService _instance = VoiceGuidanceService._internal();
  factory VoiceGuidanceService() => _instance;
  VoiceGuidanceService._internal();

  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isEnabled = true;
  bool _isPlaying = false;
  double _volume = 1.0;
  double _speechRate = ApiConfig.defaultSpeechRate;
  double _pitch = ApiConfig.defaultPitch;
  String _currentVoiceId = ApiConfig.defaultVoiceId;
  
  // Getters
  bool get isEnabled => _isEnabled;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  String get currentVoiceId => _currentVoiceId;

  /// Initialize the voice guidance service
  Future<void> initialize() async {
    try {
      // Set up audio player
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(_volume);
      
      // Listen to audio player state changes
      _audioPlayer.onPlayerStateChanged.listen((state) {
        _isPlaying = state == PlayerState.playing;
        notifyListeners();
      });
      
      // Load user preferences
      await _loadPreferences();
      
    } catch (e) {
      print('Error initializing voice guidance: $e');
    }
  }

  /// Load user preferences from storage
  Future<void> _loadPreferences() async {
    // Implementation would load from SharedPreferences
    // For now, using default values
  }

  /// Save user preferences to storage
  Future<void> _savePreferences() async {
    // Implementation would save to SharedPreferences
  }

  /// Enable or disable voice guidance
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _savePreferences();
    notifyListeners();
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    await _savePreferences();
    notifyListeners();
  }

  /// Set speech rate (0.5 to 2.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.5, 2.0);
    await _savePreferences();
    notifyListeners();
  }

  /// Set pitch (-20 to 20)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(-20.0, 20.0);
    await _savePreferences();
    notifyListeners();
  }

  /// Set voice ID
  Future<void> setVoiceId(String voiceId) async {
    _currentVoiceId = voiceId;
    await _savePreferences();
    notifyListeners();
  }

  /// Convert text to speech and play it
  Future<void> speak(String text, {
    String? voiceId,
    double? speechRate,
    double? pitch,
    bool waitForCompletion = false,
  }) async {
    if (!_isEnabled || text.isEmpty) return;

    try {
      // Haptic feedback for speech start
      HapticFeedback.lightImpact();

      // Generate speech
      final audioData = await _generateSpeech(
        text,
        voiceId: voiceId ?? _currentVoiceId,
        speechRate: speechRate ?? _speechRate,
        pitch: pitch ?? _pitch,
      );

      if (audioData != null) {
        // Play the audio
        await _playAudio(audioData, waitForCompletion: waitForCompletion);
      }
    } catch (e) {
      print('Error speaking text: $e');
    }
  }

  /// Generate speech from text using the API
  Future<Uint8List?> _generateSpeech(
    String text, {
    required String voiceId,
    required double speechRate,
    required double pitch,
  }) async {
    try {
      final response = await _apiService.generateSpeech({
        'text': text,
        'voice': voiceId,
        'speed': speechRate,
        'pitch': pitch,
        'language': 'en',
      });

      if (response['success'] == true && response['audio'] != null) {
        // Decode base64 audio
        final audioBase64 = response['audio'] as String;
        return base64Decode(audioBase64);
      }
    } catch (e) {
      print('Error generating speech: $e');
    }
    return null;
  }

  /// Play audio data
  Future<void> _playAudio(Uint8List audioData, {bool waitForCompletion = false}) async {
    try {
      // Stop any currently playing audio
      await stop();

      // Play the new audio
      await _audioPlayer.playBytes(audioData);

      if (waitForCompletion) {
        // Wait for completion
        await _audioPlayer.onPlayerComplete.first;
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  /// Stop currently playing audio
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  /// Pause currently playing audio
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  /// Resume paused audio
  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  /// Speak onboarding guidance
  Future<void> speakOnboarding(String step, {String? petName, String? personalityType}) async {
    if (!_isEnabled) return;

    try {
      final response = await _apiService.generateOnboardingVoice({
        'step': step,
        'petName': petName,
        'personalityType': personalityType,
      });

      if (response['success'] == true && response['audio'] != null) {
        final audioBase64 = response['audio'] as String;
        final audioData = base64Decode(audioBase64);
        await _playAudio(audioData);
      }
    } catch (e) {
      print('Error speaking onboarding: $e');
    }
  }

  /// Speak achievement celebration
  Future<void> speakAchievement(String achievementTitle, String petName, String rarity) async {
    if (!_isEnabled) return;

    try {
      final response = await _apiService.generateAchievementVoice({
        'achievementTitle': achievementTitle,
        'petName': petName,
        'rarity': rarity,
      });

      if (response['success'] == true && response['audio'] != null) {
        final audioBase64 = response['audio'] as String;
        final audioData = base64Decode(audioBase64);
        await _playAudio(audioData);
      }
    } catch (e) {
      print('Error speaking achievement: $e');
    }
  }

  /// Speak health reminder
  Future<void> speakHealthReminder(String task, String petName, {String? time}) async {
    if (!_isEnabled) return;

    try {
      final response = await _apiService.generateHealthReminderVoice({
        'task': task,
        'petName': petName,
        'time': time,
      });

      if (response['success'] == true && response['audio'] != null) {
        final audioBase64 = response['audio'] as String;
        final audioData = base64Decode(audioBase64);
        await _playAudio(audioData);
      }
    } catch (e) {
      print('Error speaking health reminder: $e');
    }
  }

  /// Speak feedback message
  Future<void> speakFeedback(String type, String message, {int? duration}) async {
    if (!_isEnabled) return;

    try {
      final response = await _apiService.generateFeedbackVoice({
        'type': type,
        'message': message,
        'duration': duration,
      });

      if (response['success'] == true && response['audio'] != null) {
        final audioBase64 = response['audio'] as String;
        final audioData = base64Decode(audioBase64);
        await _playAudio(audioData);
      }
    } catch (e) {
      print('Error speaking feedback: $e');
    }
  }

  /// Process voice command
  Future<Map<String, dynamic>?> processVoiceCommand(String command, {String? context, String? userId}) async {
    try {
      final response = await _apiService.processVoiceCommand({
        'command': command,
        'context': context,
        'userId': userId,
      });

      if (response['success'] == true) {
        return response['response'] as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error processing voice command: $e');
    }
    return null;
  }

  /// Get available voices
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    try {
      final response = await _apiService.getAvailableVoices();
      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['voices']);
      }
    } catch (e) {
      print('Error getting available voices: $e');
    }
    return [];
  }

  /// Speak success message
  Future<void> speakSuccess(String message) async {
    await speakFeedback('success', message);
  }

  /// Speak error message
  Future<void> speakError(String message) async {
    await speakFeedback('error', message);
  }

  /// Speak warning message
  Future<void> speakWarning(String message) async {
    await speakFeedback('warning', message);
  }

  /// Speak info message
  Future<void> speakInfo(String message) async {
    await speakFeedback('info', message);
  }

  /// Speak celebration message
  Future<void> speakCelebration(String message) async {
    await speakFeedback('celebration', message);
  }

  /// Dispose resources
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Extension to add voice methods to ApiService
extension VoiceApi on ApiService {
  Future<Map<String, dynamic>> generateSpeech(Map<String, dynamic> data) async {
    final response = await _makeRequest('POST', '/voice/text-to-speech', body: data);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> generateOnboardingVoice(Map<String, dynamic> data) async {
    final response = await _makeRequest('POST', '/voice/onboarding', body: data);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> generateAchievementVoice(Map<String, dynamic> data) async {
    final response = await _makeRequest('POST', '/voice/achievement', body: data);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> generateHealthReminderVoice(Map<String, dynamic> data) async {
    final response = await _makeRequest('POST', '/voice/health-reminder', body: data);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> generateFeedbackVoice(Map<String, dynamic> data) async {
    final response = await _makeRequest('POST', '/voice/feedback', body: data);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> processVoiceCommand(Map<String, dynamic> data) async {
    final response = await _makeRequest('POST', '/voice/command', body: data);
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> getAvailableVoices() async {
    final response = await _makeRequest('GET', '/voice/voices');
    return _parseResponse(response);
  }
}