import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  // Firebase instances
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;
  late FirebaseMessaging _messaging;
  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;
  late FirebasePerformance _performance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  FirebaseMessaging get messaging => _messaging;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;
  FirebasePerformance get performance => _performance;

  /// Initialize Firebase services
  Future<void> initialize() async {
    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize individual services
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _messaging = FirebaseMessaging.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;
      _performance = FirebasePerformance.instance;

      // Configure services
      await _configureServices();

      print('✅ Firebase services initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Firebase services: $e');
      rethrow;
    }
  }

  /// Configure Firebase services
  Future<void> _configureServices() async {
    try {
      // Configure Firestore
      await _configureFirestore();

      // Configure Storage
      await _configureStorage();

      // Configure Messaging
      await _configureMessaging();

      // Configure Analytics
      await _configureAnalytics();

      // Configure Crashlytics
      await _configureCrashlytics();

      // Configure Performance
      await _configurePerformance();

    } catch (e) {
      print('❌ Failed to configure Firebase services: $e');
      rethrow;
    }
  }

  /// Configure Firestore
  Future<void> _configureFirestore() async {
    // Enable offline persistence
    await _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Set up security rules (these should be configured in Firebase Console)
    print('📚 Firestore configured with offline persistence');
  }

  /// Configure Storage
  Future<void> _configureStorage() async {
    // Set up storage rules (these should be configured in Firebase Console)
    print('💾 Firebase Storage configured');
  }

  /// Configure Messaging
  Future<void> _configureMessaging() async {
    // Request permission for notifications
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🔔 Notification permission granted');
      
      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        print('📱 FCM Token: ${token.substring(0, 20)}...');
        
        // Save token to user's document in Firestore
        await _saveFCMToken(token);
      }
    } else {
      print('🔕 Notification permission denied');
    }

    // Handle token refresh
    _messaging.onTokenRefresh.listen((token) {
      print('🔄 FCM Token refreshed');
      _saveFCMToken(token);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.notification?.title}');
      // Handle the message (show local notification, update UI, etc.)
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Configure Analytics
  Future<void> _configureAnalytics() async {
    // Enable analytics collection
    await _analytics.setAnalyticsCollectionEnabled(true);
    
    // Set user properties
    await _analytics.setUserProperty(name: 'app_version', value: '1.0.0');
    await _analytics.setUserProperty(name: 'platform', value: 'mobile');
    
    print('📊 Firebase Analytics configured');
  }

  /// Configure Crashlytics
  Future<void> _configureCrashlytics() async {
    // Enable crashlytics collection
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
    
    // Set user identifier when user logs in
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _crashlytics.setUserIdentifier(user.uid);
        _crashlytics.setCustomKey('user_email', user.email ?? 'unknown');
      } else {
        _crashlytics.setUserIdentifier('anonymous');
        _crashlytics.setCustomKey('user_email', 'anonymous');
      }
    });
    
    print('🚨 Firebase Crashlytics configured');
  }

  /// Configure Performance
  Future<void> _configurePerformance() async {
    // Enable performance monitoring
    await _performance.setPerformanceCollectionEnabled(true);
    
    print('⚡ Firebase Performance configured');
  }

  /// Save FCM token to user's document
  Future<void> _saveFCMToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('💾 FCM token saved to user document');
      }
    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }

  /// Get current user's FCM token
  Future<String?> getCurrentUserFCMToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        return doc.data()?['fCMToken'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      final fcmToken = userDoc.data()?['fcmToken'] as String?;
      
      if (fcmToken != null) {
        // Send notification via Cloud Functions (recommended)
        // For now, we'll just log it
        print('📤 Notification prepared for user $userId: $title');
        print('📱 FCM Token: ${fcmToken.substring(0, 20)}...');
        print('📝 Body: $body');
        if (data != null) print('🔧 Data: $data');
      } else {
        print('❌ User $userId has no FCM token');
      }
    } catch (e) {
      print('❌ Failed to send notification: $e');
    }
  }

  /// Log custom event to Analytics
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      print('📊 Analytics event logged: $name');
    } catch (e) {
      print('❌ Failed to log analytics event: $e');
    }
  }

  /// Log error to Crashlytics
  Future<void> logError({
    required String message,
    required dynamic error,
    StackTrace? stackTrace,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: message,
      );
      print('🚨 Error logged to Crashlytics: $message');
    } catch (e) {
      print('❌ Failed to log error to Crashlytics: $e');
    }
  }

  /// Start performance trace
  Future<void> startTrace(String traceName) async {
    try {
      final trace = _performance.newTrace(traceName);
      await trace.start();
      print('⚡ Performance trace started: $traceName');
    } catch (e) {
      print('❌ Failed to start performance trace: $e');
    }
  }

  /// Stop performance trace
  Future<void> stopTrace(String traceName) async {
    try {
      final trace = _performance.newTrace(traceName);
      await trace.stop();
      print('⚡ Performance trace stopped: $traceName');
    } catch (e) {
      print('❌ Failed to stop performance trace: $e');
    }
  }

  /// Cleanup resources
  Future<void> dispose() async {
    try {
      // Close any open connections
      await _firestore.terminate();
      print('🧹 Firebase services disposed');
    } catch (e) {
      print('❌ Failed to dispose Firebase services: $e');
    }
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background messages
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('📨 Background message received: ${message.notification?.title}');
  
  // Handle background message (show notification, update data, etc.)
  // This runs in a separate isolate
}