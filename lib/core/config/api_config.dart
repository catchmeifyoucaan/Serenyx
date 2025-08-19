class ApiConfig {
  // Development
  static const String devBaseUrl = 'http://localhost:3000/api';
  
  // Production - Render deployment
  static const String prodBaseUrl = 'https://serenyx-api.onrender.com/api';
  
  // Staging
  static const String stagingBaseUrl = 'https://staging-api.serenyx.com/api';
  
  // Get base URL based on environment
  static String get baseUrl {
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    
    switch (environment) {
      case 'prod':
        return prodBaseUrl;
      case 'staging':
        return stagingBaseUrl;
      case 'dev':
      default:
        return devBaseUrl;
    }
  }
  
  // API timeout settings
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Retry settings
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 second
  
  // Rate limiting
  static const int maxRequestsPerMinute = 100;
  
  // File upload settings
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedAudioTypes = ['mp3', 'wav', 'm4a', 'aac'];
  
  // Cache settings
  static const int cacheExpirationMinutes = 5;
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  // Voice guidance settings
  static const String defaultVoiceId = 'pNInz6obpgDQGcFmaJgB'; // Warm, friendly voice
  static const double defaultSpeechRate = 1.0;
  static const double defaultPitch = 0.0;
  
  // Feature flags
  static const bool enableVoiceGuidance = true;
  static const bool enableGamification = true;
  static const bool enableSocialFeatures = true;
  static const bool enableAnalytics = true;
}