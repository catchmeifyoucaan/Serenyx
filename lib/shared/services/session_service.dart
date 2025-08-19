import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';

class SessionService {
  static const String _sessionsKey = 'user_sessions';
  static const String _currentSessionKey = 'current_session';
  
  // Singleton pattern
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // In-memory cache
  List<Session> _sessions = [];
  Session? _currentSession;

  // Getters
  List<Session> get sessions => List.unmodifiable(_sessions);
  Session? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession != null && _currentSession!.isActive;

  /// Initialize the service and load sessions from storage
  Future<void> initialize() async {
    await _loadSessions();
    await _loadCurrentSession();
  }

  /// Load sessions from local storage
  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];
      
      _sessions = sessionsJson
          .map((json) => Session.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading sessions: $e');
      _sessions = [];
    }
  }

  /// Load current session from local storage
  Future<void> _loadCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentSessionJson = prefs.getString(_currentSessionKey);
      
      if (currentSessionJson != null) {
        final sessionData = jsonDecode(currentSessionJson);
        _currentSession = Session.fromJson(sessionData);
        
        // Check if current session is still valid
        if (_currentSession!.startTime.isBefore(DateTime.now().subtract(const Duration(hours: 24)))) {
          await _completeSession(_currentSession!.id);
        }
      }
    } catch (e) {
      print('Error loading current session: $e');
      _currentSession = null;
    }
  }

  /// Start a new session
  Future<Session?> startSession({
    required String petId,
    required String userId,
    required SessionType type,
    Duration duration = const Duration(minutes: 10),
  }) async {
    try {
      // Complete any existing session
      if (_currentSession != null) {
        await _completeSession(_currentSession!.id);
      }

      final session = Session(
        id: 'session-${DateTime.now().millisecondsSinceEpoch}',
        petId: petId,
        userId: userId,
        type: type,
        status: SessionStatus.inProgress,
        startTime: DateTime.now(),
        duration: duration,
        progress: 0.0,
        interactions: [],
        metadata: {
          'startMood': null,
          'endMood': null,
          'interactionTypes': [],
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _currentSession = session;
      _sessions.add(session);
      
      await _saveSessions();
      await _saveCurrentSession();
      
      return session;
    } catch (e) {
      print('Error starting session: $e');
      return null;
    }
  }

  /// Update session progress
  Future<bool> updateSessionProgress(String sessionId, double progress, {List<String>? interactions}) async {
    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      final updatedSession = session.copyWith(
        progress: progress.clamp(0.0, 1.0),
        interactions: interactions ?? session.interactions,
        updatedAt: DateTime.now(),
      );

      final index = _sessions.indexWhere((s) => s.id == sessionId);
      _sessions[index] = updatedSession;

      if (_currentSession?.id == sessionId) {
        _currentSession = updatedSession;
        await _saveCurrentSession();
      }

      await _saveSessions();
      return true;
    } catch (e) {
      print('Error updating session progress: $e');
      return false;
    }
  }

  /// Add interaction to current session
  Future<bool> addInteraction(String interactionType, {String? note}) async {
    if (_currentSession == null) return false;

    try {
      final interaction = {
        'type': interactionType,
        'timestamp': DateTime.now().toIso8601String(),
        'note': note,
      };

      final updatedInteractions = List<String>.from(_currentSession!.interactions)
        ..add(jsonEncode(interaction));

      final progress = (_currentSession!.interactions.length + 1) / 10.0;
      
      return await updateSessionProgress(
        _currentSession!.id,
        progress.clamp(0.0, 1.0),
        interactions: updatedInteractions,
      );
    } catch (e) {
      print('Error adding interaction: $e');
      return false;
    }
  }

  /// Complete a session
  Future<bool> _completeSession(String sessionId) async {
    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      final completedSession = session.copyWith(
        status: SessionStatus.completed,
        endTime: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final index = _sessions.indexWhere((s) => s.id == sessionId);
      _sessions[index] = completedSession;

      if (_currentSession?.id == sessionId) {
        _currentSession = null;
        await _clearCurrentSession();
      }

      await _saveSessions();
      return true;
    } catch (e) {
      print('Error completing session: $e');
      return false;
    }
  }

  /// Complete current session with feedback
  Future<bool> completeCurrentSession({
    required int moodRating,
    String? feedback,
  }) async {
    if (_currentSession == null) return false;

    try {
      final session = _currentSession!;
      final completedSession = session.copyWith(
        status: SessionStatus.completed,
        endTime: DateTime.now(),
        moodRating: moodRating,
        feedback: feedback,
        metadata: {
          ...session.metadata,
          'endMood': moodRating,
          'feedback': feedback,
        },
        updatedAt: DateTime.now(),
      );

      final index = _sessions.indexWhere((s) => s.id == session.id);
      _sessions[index] = completedSession;

      _currentSession = null;
      await _clearCurrentSession();
      await _saveSessions();

      return true;
    } catch (e) {
      print('Error completing current session: $e');
      return false;
    }
  }

  /// Pause current session
  Future<bool> pauseCurrentSession() async {
    if (_currentSession == null) return false;

    try {
      final session = _currentSession!;
      final pausedSession = session.copyWith(
        status: SessionStatus.paused,
        updatedAt: DateTime.now(),
      );

      final index = _sessions.indexWhere((s) => s.id == session.id);
      _sessions[index] = pausedSession;

      _currentSession = pausedSession;
      await _saveCurrentSession();
      await _saveSessions();

      return true;
    } catch (e) {
      print('Error pausing session: $e');
      return false;
    }
  }

  /// Resume paused session
  Future<bool> resumeSession(String sessionId) async {
    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      final resumedSession = session.copyWith(
        status: SessionStatus.inProgress,
        updatedAt: DateTime.now(),
      );

      final index = _sessions.indexWhere((s) => s.id == session.id);
      _sessions[index] = resumedSession;

      _currentSession = resumedSession;
      await _saveCurrentSession();
      await _saveSessions();

      return true;
    } catch (e) {
      print('Error resuming session: $e');
      return false;
    }
  }

  /// Get sessions for a specific pet
  List<Session> getSessionsForPet(String petId) {
    return _sessions
        .where((session) => session.petId == petId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get sessions by type
  List<Session> getSessionsByType(SessionType type) {
    return _sessions
        .where((session) => session.type == type)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get recent sessions
  List<Session> getRecentSessions({int limit = 10}) {
    final sortedSessions = List<Session>.from(_sessions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sortedSessions.take(limit).toList();
  }

  /// Get sessions within date range
  List<Session> getSessionsInRange(DateTime start, DateTime end) {
    return _sessions
        .where((session) => 
          session.createdAt.isAfter(start) && 
          session.createdAt.isBefore(end))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get session statistics
  Map<String, dynamic> getSessionStats({String? petId}) {
    final sessions = petId != null 
        ? getSessionsForPet(petId)
        : _sessions;

    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalDuration': Duration.zero,
        'averageProgress': 0.0,
        'averageMood': 0.0,
        'favoriteType': null,
        'completionRate': 0.0,
      };
    }

    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    final totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (total, session) => total + session.elapsedTime,
    );

    final averageProgress = sessions.fold<double>(
      0.0,
      (total, session) => total + session.progress,
    ) / sessions.length;

    final averageMood = completedSessions.fold<double>(
      0.0,
      (total, session) => total + session.moodRating,
    ) / completedSessions.length;

    // Find favorite session type
    final typeCounts = <SessionType, int>{};
    for (final session in sessions) {
      typeCounts[session.type] = (typeCounts[session.type] ?? 0) + 1;
    }
    
    final favoriteType = typeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final completionRate = completedSessions.length / sessions.length;

    return {
      'totalSessions': sessions.length,
      'totalDuration': totalDuration,
      'averageProgress': averageProgress,
      'averageMood': averageMood,
      'favoriteType': favoriteType,
      'completionRate': completionRate,
      'completedSessions': completedSessions.length,
      'pausedSessions': sessions.where((s) => s.status == SessionStatus.paused).length,
    };
  }

  /// Save sessions to local storage
  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _sessions
          .map((session) => jsonEncode(session.toJson()))
          .toList();
      
      await prefs.setStringList(_sessionsKey, sessionsJson);
    } catch (e) {
      print('Error saving sessions: $e');
    }
  }

  /// Save current session to local storage
  Future<void> _saveCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentSession != null) {
        await prefs.setString(_currentSessionKey, jsonEncode(_currentSession!.toJson()));
      }
    } catch (e) {
      print('Error saving current session: $e');
    }
  }

  /// Clear current session from storage
  Future<void> _clearCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentSessionKey);
    } catch (e) {
      print('Error clearing current session: $e');
    }
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionsKey);
      await prefs.remove(_currentSessionKey);
      
      _sessions.clear();
      _currentSession = null;
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  /// Export sessions data (for backup)
  Future<String> exportSessionsData() async {
    try {
      final data = {
        'sessions': _sessions.map((session) => session.toJson()).toList(),
        'currentSession': _currentSession?.toJson(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
      
      return jsonEncode(data);
    } catch (e) {
      print('Error exporting sessions data: $e');
      return '';
    }
  }

  /// Import sessions data (for restore)
  Future<bool> importSessionsData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      final sessionsData = data['sessions'] as List;
      
      _sessions = sessionsData
          .map((sessionJson) => Session.fromJson(sessionJson))
          .toList();
      
      if (data['currentSession'] != null) {
        _currentSession = Session.fromJson(data['currentSession']);
        await _saveCurrentSession();
      }
      
      await _saveSessions();
      return true;
    } catch (e) {
      print('Error importing sessions data: $e');
      return false;
    }
  }
}