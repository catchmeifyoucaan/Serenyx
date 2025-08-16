class AppConstants {
  // App Information
  static const String appName = 'Serenyx';
  static const String appTagline = 'Your pet\'s giggle is just a tickle away';
  static const String appVersion = '1.0.0';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);
  static const Duration bounceAnimation = Duration(milliseconds: 600);
  
  // Spacing
  static const double xsSpacing = 4.0;
  static const double smSpacing = 8.0;
  static const double mdSpacing = 16.0;
  static const double lgSpacing = 24.0;
  static const double xlSpacing = 32.0;
  static const double xxlSpacing = 48.0;
  
  // Border Radius
  static const double smRadius = 8.0;
  static const double mdRadius = 16.0;
  static const double lgRadius = 20.0;
  static const double xlRadius = 50.0;
  
  // Session Types
  static const String tickleSession = 'Tickle Session';
  static const String cuddleTime = 'Cuddle Time';
  static const String playtime = 'Playtime';
  static const String zenTime = 'Zen Time';
  
  // Mood States
  static const List<String> moodStates = [
    'I feel overjoyed',
    'I feel happy',
    'I feel content',
    'I feel calm',
    'I feel relaxed'
  ];
  
  // Pet Interaction Prompts
  static const List<String> interactionPrompts = [
    'Gently tap on their feet, arms, or tummy',
    'Give them a gentle scratch behind the ears',
    'Tap their nose for a surprise',
    'Stroke their back gently',
    'Give them a belly rub'
  ];
  
  // Audio Feedback
  static const Map<String, String> audioFeedback = {
    'wobble': 'Hehehe..... Staaap',
    'giggle': 'Haha, that tickles!',
    'purr': 'Mmm, so relaxing...',
    'bark': 'Woof! More please!',
    'meow': 'Purrrr... don\'t stop!'
  };
  
  // Progress Bar States
  static const double minProgress = 0.0;
  static const double maxProgress = 1.0;
  static const double progressStep = 0.1;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String petsCollection = 'pets';
  static const String sessionsCollection = 'sessions';
  static const String feedbackCollection = 'feedback';
  static const String healthRecordsCollection = 'health_records';
  
  // Shared Preferences Keys
  static const String userIdKey = 'user_id';
  static const String petIdKey = 'pet_id';
  static const String sessionCountKey = 'session_count';
  static const String lastSessionDateKey = 'last_session_date';
  static const String themeKey = 'theme';
  
  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';
  
  // Success Messages
  static const String sessionCompleted = 'Great job! Your pet loved that session!';
  static const String feedbackSubmitted = 'Thank you for sharing how you feel!';
  static const String profileUpdated = 'Profile updated successfully!';
}