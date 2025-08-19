import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'firebase_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/pet_interaction/presentation/screens/tickle_session_screen.dart';
import 'features/feedback/presentation/screens/feedback_screen.dart';
import 'features/pet_health/presentation/screens/pet_management_screen.dart';
import 'features/pet_health/presentation/screens/enhanced_pet_health_screen.dart';
import 'features/social/presentation/screens/social_feed_screen.dart';
import 'features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'features/pet_scrapbook/presentation/screens/digital_scrapbook_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/health_wellness/presentation/screens/health_wellness_screen.dart';
import 'features/premium/presentation/screens/premium_features_screen.dart';
import 'features/community/presentation/screens/community_screen.dart';
import 'features/community/presentation/screens/marketplace_screen.dart';
import 'features/community/presentation/screens/best_pet_screen.dart';
import 'features/ai_ml/presentation/screens/ai_insights_screen.dart';
import 'features/veterinary_ai/presentation/screens/veterinary_ai_screen.dart';
import 'features/behavioral_analysis/presentation/screens/behavioral_analysis_screen.dart';
import 'features/training_tracking/presentation/screens/training_tracking_screen.dart';
import 'features/social_network/presentation/screens/social_network_screen.dart';
import 'features/gamification/presentation/screens/gamification_screen.dart';
import 'features/subscription/presentation/screens/subscription_screen.dart';
import 'features/monitoring/presentation/screens/monitoring_screen.dart';
import 'shared/services/auth_service.dart';
import 'shared/services/pet_service.dart';
import 'shared/services/session_service.dart';
import 'shared/services/advanced_ai_service.dart';
import 'shared/services/social_network_service.dart';
import 'shared/services/gamification_service.dart';
import 'shared/services/subscription_service.dart';
import 'shared/services/monitoring_service.dart';
import 'shared/models/pet.dart';
import 'shared/models/session.dart';
import 'shared/models/auth_models.dart';
import 'shared/models/social_models.dart';
import 'shared/models/subscription_models.dart';
import 'shared/models/analytics_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await FirebaseService.instance.initialize();
    print('🚀 Firebase initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize Firebase: $e');
    // Continue without Firebase for development
  }
  
  runApp(const SerenyxApp());
}

class SerenyxApp extends StatelessWidget {
  const SerenyxApp({super.key});

  /// Helper method to create a default user for testing
  User _getDefaultUser() {
    return User(
      id: 'demo-user',
      email: 'demo@serenyx.com',
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
      emailVerified: true,
      pets: [],
      profile: UserProfile(
        firstName: 'Demo',
        lastName: 'User',
        interests: ['Pet Care', 'Mindfulness'],
      ),
      preferences: UserPreferences(
        notifications: NotificationSettings(
          pushEnabled: true,
          emailEnabled: false,
          smsEnabled: false,
          enabledTypes: ['health_reminders', 'vet_appointments'],
          quietHours: TimeRange(
            start: const TimeOfDay(hour: 22, minute: 0),
            end: const TimeOfDay(hour: 7, minute: 0),
          ),
        ),
        privacy: PrivacySettings(
          profilePublic: false,
          petsPublic: false,
          healthDataShared: false,
          trustedContacts: [],
          analyticsEnabled: true,
        ),
        aiPreferences: AIPreferences(
          preferredModel: 'gpt-5',
          enabledFeatures: ['emotion_recognition', 'behavioral_prediction'],
          autoAnalysis: true,
          personalizedRecommendations: true,
          modelSettings: {},
        ),
        theme: ThemeSettings(
          themeMode: 'system',
          colorScheme: 'default',
          useSystemTheme: true,
        ),
        language: LanguageSettings(
          language: 'en',
          region: 'US',
          autoDetect: true,
        ),
      ),
      subscription: SubscriptionInfo(
        plan: 'free',
        startDate: DateTime.now(),
        isActive: true,
        features: ['basic_tracking', 'ai_insights'],
        monthlyPrice: 0.0,
        billingCycle: 'monthly',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => PetService()),
        ChangeNotifierProvider(create: (_) => SessionService()),
        ChangeNotifierProvider(create: (_) => AdvancedAIService()),
        ChangeNotifierProvider(create: (_) => SocialNetworkService()),
        ChangeNotifierProvider(create: (_) => GamificationService()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider(create: (_) => MonitoringService()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => HomeScreen(user: _getDefaultUser()),
          '/tickle-session': (context) => const TickleSessionScreen(
            petId: 'demo-pet',
            petName: 'Buddy',
          ),
          '/feedback': (context) => const FeedbackScreen(
            petId: 'demo-pet',
            sessionType: 'Tickle Session',
            interactionCount: 10,
          ),
          '/pet-management': (context) => const PetManagementScreen(),
          '/enhanced-health': (context) => EnhancedPetHealthScreen(pet: Pet.empty()),
          '/social-feed': (context) => const SocialFeedScreen(),
          '/analytics': (context) => const AnalyticsDashboardScreen(),
          '/scrapbook': (context) => DigitalScrapbookScreen(pet: Pet.empty()),
          '/notifications': (context) => const NotificationsScreen(),
          '/health-wellness': (context) => const HealthWellnessScreen(),
          '/premium-features': (context) => const PremiumFeaturesScreen(),
          '/community': (context) => const CommunityScreen(),
          '/marketplace': (context) => const MarketplaceScreen(),
          '/best-pet': (context) => const BestPetScreen(),
          '/ai-insights': (context) => const AIInsightsScreen(),
          '/veterinary-ai': (context) => const VeterinaryAIScreen(),
          '/behavioral-analysis': (context) => const BehavioralAnalysisScreen(),
          '/training-tracking': (context) => const TrainingTrackingScreen(),
          '/social-network': (context) => const SocialNetworkScreen(),
          '/gamification': (context) => const GamificationScreen(),
          '/subscription': (context) => const SubscriptionScreen(),
          '/monitoring': (context) => const MonitoringScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            
            if (snapshot.hasData && snapshot.data != null) {
              // User is authenticated
              return const HomeScreen();
            } else {
              // User is not authenticated
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.softPurpleGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.colors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.pets,
                      size: 60,
                      color: AppTheme.colors.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // App Name
                  Text(
                    AppConstants.appName,
                    style: AppTheme.textStyles.headlineLarge?.copyWith(
                      color: AppTheme.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // App Tagline
                  Text(
                    AppConstants.appTagline,
                    style: AppTheme.textStyles.bodyLarge?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Loading Indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
