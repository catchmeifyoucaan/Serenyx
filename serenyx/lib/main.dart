import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/pet_interaction/presentation/screens/tickle_session_screen.dart';
import 'features/feedback/presentation/screens/feedback_screen.dart';
import 'features/pet_health/presentation/screens/pet_management_screen.dart';
import 'features/pet_health/presentation/screens/enhanced_pet_health_screen.dart';
import 'features/social/presentation/screens/social_feed_screen.dart';
import 'features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'features/pet_scrapbook/presentation/screens/digital_scrapbook_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'shared/services/pet_service.dart';
import 'shared/services/session_service.dart';
import 'shared/models/pet.dart';
import 'shared/models/session.dart';

void main() {
  runApp(const SerenyxApp());
}

class SerenyxApp extends StatelessWidget {
  const SerenyxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      routes: {
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
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Services
  final PetService _petService = PetService();
  final SessionService _sessionService = SessionService();
  
  // Data
  Pet? _currentPet;
  Map<String, dynamic> _sessionStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    
    // Initialize services and load data
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _petService.initialize();
      await _sessionService.initialize();
      
      setState(() {
        _currentPet = _petService.currentPet;
        _sessionStats = _sessionService.getSessionStats();
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.softPurpleGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Main Content
              Expanded(
                child: _buildMainContent(),
              ),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.heartPink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.heartPink.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.pets,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          // App Name
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Settings Button
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings,
              color: AppTheme.warmGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lgSpacing),
          child: Column(
            children: [
              // Welcome Message
              _buildWelcomeMessage(),
              
              const SizedBox(height: AppConstants.xxlSpacing),
              
              // Pet Avatar Placeholder
              _buildPetAvatarPlaceholder(),
              
              const SizedBox(height: AppConstants.xlSpacing),
              
              // Session Options
              _buildSessionOptions(),
              
              const SizedBox(height: AppConstants.xlSpacing),
              
                        // Quick Stats
          _buildQuickStats(),
          
          const SizedBox(height: AppConstants.xlSpacing),
          
          // Feature Navigation
          _buildFeatureNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      decoration: BoxDecoration(
        color: AppTheme.gentleCream,
        borderRadius: BorderRadius.circular(AppConstants.lgRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmGrey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.heartPink,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          Text(
            AppConstants.appTagline,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.warmGrey,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetAvatarPlaceholder() {
    if (_isLoading) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.softPink,
          shape: BoxShape.circle,
        ),
        child: const CircularProgressIndicator(
          color: AppTheme.heartPink,
        ),
      );
    }

    if (_currentPet == null) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.softPink,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.heartPink.withOpacity(0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.heartPink.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.pets,
          color: AppTheme.heartPink,
          size: 80,
        ),
      );
    }

    // Show real pet avatar
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: _getPetColor(),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getPetColor().withOpacity(0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _getPetColor().withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 8),
          Text(
            _currentPet!.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _currentPet!.type,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPetColor() {
    if (_currentPet == null) return AppTheme.heartPink;
    
    // Generate a consistent color based on pet ID
    final hash = _currentPet!.id.hashCode;
    final colors = [
      AppTheme.heartPink,
      AppTheme.leafGreen,
      AppTheme.softPurple,
      AppTheme.lightPink,
      AppTheme.pastelPeach,
    ];
    
    return colors[hash.abs() % colors.length];
  }

  Widget _buildSessionOptions() {
    return Column(
      children: [
        Text(
          'Choose your session',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.lgSpacing),
        
        // Tickle Session Button
        _buildSessionButton(
          title: 'Tickle Session',
          subtitle: 'Interactive playtime with your pet',
          icon: Icons.touch_app,
          color: AppTheme.heartPink,
          onTap: () => Navigator.pushNamed(context, '/tickle-session'),
        ),
        
        const SizedBox(height: AppConstants.mdSpacing),
        
        // Cuddle Time Button
        _buildSessionButton(
          title: 'Cuddle Time',
          subtitle: 'Gentle bonding and relaxation',
          icon: Icons.favorite,
          color: AppTheme.leafGreen,
          onTap: () {},
        ),
        
        const SizedBox(height: AppConstants.mdSpacing),
        
        // Playtime Button
        _buildSessionButton(
          title: 'Playtime',
          subtitle: 'Active games and exercises',
          icon: Icons.sports_esports,
          color: AppTheme.softPurple,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSessionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.lgRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.lgSpacing),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.mdSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.warmGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.xsSpacing),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.warmGrey.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.warmGrey.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
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
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.lgSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Sessions', '${_sessionStats['totalSessions'] ?? 0}', AppTheme.heartPink),
              _buildStatItem('Mood', '${(_sessionStats['averageMood'] ?? 0.0).toStringAsFixed(1)}', AppTheme.leafGreen),
              _buildStatItem('Completed', '${_sessionStats['completedSessions'] ?? 0}', AppTheme.softPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureNavigation() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
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
          Text(
            'Features',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.lgSpacing),
          _buildFeatureButton(
            title: 'Pet Management',
            subtitle: 'Manage your furry family members',
            icon: Icons.pets,
            color: AppTheme.heartPink,
            onTap: () => Navigator.pushNamed(context, '/pet-management'),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          _buildFeatureButton(
            title: 'Enhanced Health',
            subtitle: 'Complete health tracking & records',
            icon: Icons.health_and_safety,
            color: AppTheme.leafGreen,
            onTap: () => Navigator.pushNamed(context, '/enhanced-health'),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          _buildFeatureButton(
            title: 'Digital Scrapbook',
            subtitle: 'Pet life timeline & memories',
            icon: Icons.photo_library,
            color: AppTheme.softPurple,
            onTap: () => Navigator.pushNamed(context, '/scrapbook'),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          _buildFeatureButton(
            title: 'Social Feed',
            subtitle: 'Share and discover pet moments',
            icon: Icons.people,
            color: AppTheme.lightPink,
            onTap: () => Navigator.pushNamed(context, '/social-feed'),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          _buildFeatureButton(
            title: 'Analytics',
            subtitle: 'Deep insights into bonding patterns',
            icon: Icons.analytics,
            color: AppTheme.softPurple,
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
          const SizedBox(height: AppConstants.smSpacing),
          _buildFeatureButton(
            title: 'Notifications',
            subtitle: 'Smart reminders & suggestions',
            icon: Icons.notifications,
            color: AppTheme.softPurple,
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.mdRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mdSpacing),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.smRadius),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.mdSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.warmGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.warmGrey.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.warmGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Row(
        children: [
          // Add Pet Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/pet-management'),
              icon: Icon(
                Icons.add,
                color: AppTheme.leafGreen,
              ),
              label: Text(
                'Add Pet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.leafGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.mdSpacing),
                side: BorderSide(color: AppTheme.leafGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.xlRadius),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppConstants.mdSpacing),
          
          // Start Session Button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/tickle-session'),
              icon: Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
              label: Text(
                'Start Session',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.heartPink,
                padding: const EdgeInsets.symmetric(vertical: AppConstants.mdSpacing),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.xlRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
