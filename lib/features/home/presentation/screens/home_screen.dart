import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/auth_models.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/services/pet_service.dart';
import '../../../../shared/widgets/interactive_pet_image.dart';
import '../../../ai_ml/presentation/widgets/emotion_recognition_widget.dart';
import '../../../ai_ml/presentation/widgets/behavioral_prediction_widget.dart';
import '../../../ai_ml/presentation/widgets/smart_scheduling_widget.dart';
import '../../../ai_ml/presentation/widgets/personalized_content_widget.dart';
import '../../../health_wellness/presentation/widgets/nutrition_tracker.dart';
import '../../../health_wellness/presentation/widgets/exercise_monitor.dart';
import '../../../health_wellness/presentation/widgets/mental_health_monitor.dart';
import '../../../health_wellness/presentation/widgets/preventive_care_system.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../premium/presentation/widgets/premium_analytics_dashboard.dart';
import '../../../community/presentation/screens/marketplace_screen.dart';
import '../../../digital_scrapbook/presentation/screens/digital_scrapbook_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _petCarouselController;
  int _currentPetIndex = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _petCarouselController = PageController();
  }

  List<Pet> get _pets {
    final petService = Provider.of<PetService>(context, listen: false);
    return petService.pets;
  }

  Pet? get currentPet {
    final petService = Provider.of<PetService>(context, listen: false);
    return petService.currentPet;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _petCarouselController.dispose();
    super.dispose();
  }

  void _addNewPet() {
    showDialog(
      context: context,
      builder: (context) => _AddPetDialog(
        onPetAdded: (pet) async {
          final petService = Provider.of<PetService>(context, listen: false);
          final success = await petService.addPet(pet);
          if (success && mounted) {
            setState(() {
              _currentPetIndex = _pets.length;
            });
            _petCarouselController.animateToPage(
              _currentPetIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        },
      ),
    );
  }

  void _addPetPhoto() async {
    if (_pets.isEmpty) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final petService = Provider.of<PetService>(context, listen: false);
      final currentPet = _pets[_currentPetIndex];
      final updatedPet = currentPet.copyWith(
        photos: [...currentPet.photos, image.path],
      );
      await petService.updatePet(updatedPet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: Column(
        children: [
          // Header with Pet Carousel
          _buildHeader(),
          
          // Quick Navigation Bar - Easy access to main features
          _buildQuickNavigationBar(),
          
          // Tab Bar
          _buildTabBar(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildHealthWellnessTab(),
                _buildAITab(),
                _buildNotificationsTab(),
                _buildCommunityTab(),
                _buildScrapbookTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickAccessMenu,
        backgroundColor: AppTheme.colors.primary,
        foregroundColor: AppTheme.colors.onPrimary,
        icon: Icon(Icons.navigation),
        label: Text('Quick Access'),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Quick Access Toolbar
          _buildTopQuickAccessToolbar(),
          
          const SizedBox(height: 20),
          
          // User Welcome
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.colors.primary,
                child: Text(
                  widget.user.profile.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppTheme.textStyles.titleLarge?.copyWith(
                    color: AppTheme.colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${widget.user.profile.firstName ?? 'Pet Parent'}!',
                      style: AppTheme.textStyles.titleLarge?.copyWith(
                        color: AppTheme.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ready to give your pets the best care?',
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Pet Carousel
          if (_pets.isNotEmpty) ...[
            Text(
              'Your Pets',
              style: AppTheme.textStyles.titleMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _petCarouselController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPetIndex = index;
                  });
                },
                itemCount: _pets.length,
                itemBuilder: (context, index) {
                  final pet = _pets[index];
                  return Column(
                    children: [
                      // Interactive Pet Image
                      InteractivePetImage(
                        imagePath: pet.photos.isNotEmpty 
                            ? pet.photos.first 
                            : 'assets/images/pets/placeholder.jpg',
                        petName: pet.name,
                        size: 120,
                        onTap: () {
                          // Show pet details
                        },
                        overlayText: '${index + 1}/${_pets.length}',
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Pet Info
                      Text(
                        pet.name,
                        style: AppTheme.textStyles.titleLarge?.copyWith(
                          color: AppTheme.colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      Text(
                        '${pet.breed} • ${pet.age} months old',
                        style: AppTheme.textStyles.bodyMedium?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Pet Navigation Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pets.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPetIndex == index
                        ? AppTheme.colors.primary
                        : AppTheme.colors.outline,
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 16),
            
            // Add Photo Button
            OutlinedButton.icon(
              onPressed: _addPetPhoto,
              icon: Icon(Icons.add_a_photo),
              label: Text('Add Photo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.colors.primary,
                side: BorderSide(color: AppTheme.colors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ] else ...[
            // No pets state
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.pets,
                    size: 64,
                    color: AppTheme.colors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pets yet',
                    style: AppTheme.textStyles.titleLarge?.copyWith(
                      color: AppTheme.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first pet to get started',
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Top Quick Access Toolbar - Instant access to key features
  Widget _buildTopQuickAccessToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile Quick Access
        InkWell(
          onTap: () => _showProfileOptions(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.colors.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  color: AppTheme.colors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Profile',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Center - App Logo/Title
        Text(
          'Serenyx',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Right side - Settings & Notifications
        Row(
          children: [
            // Notifications
            InkWell(
              onTap: () => Navigator.pushNamed(context, '/notifications'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.colors.primary.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.notifications,
                  color: AppTheme.colors.primary,
                  size: 18,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Settings
            InkWell(
              onTap: () => _showSettingsOptions(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.colors.primary.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.settings,
                  color: AppTheme.colors.primary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Quick Navigation Bar - Easy access to main features
  Widget _buildQuickNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.colors.primary.withOpacity(0.1),
            AppTheme.colors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.colors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.navigation,
                color: AppTheme.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Access',
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Navigation Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildQuickNavItem(
                icon: Icons.home,
                label: 'Home',
                color: AppTheme.colors.primary,
                onTap: () {
                  // Already on home, maybe scroll to top
                  _scrollToTop();
                },
              ),
              _buildQuickNavItem(
                icon: Icons.pets,
                label: 'CRM',
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, '/pet-management');
                },
              ),
              _buildQuickNavItem(
                icon: Icons.self_improvement,
                label: 'Mindfulness',
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, '/health-wellness');
                },
              ),
              _buildQuickNavItem(
                icon: Icons.person,
                label: 'Profile',
                color: Colors.blue,
                onTap: () {
                  _showProfileOptions();
                },
              ),
              _buildQuickNavItem(
                icon: Icons.settings,
                label: 'Settings',
                color: Colors.orange,
                onTap: () {
                  _showSettingsOptions();
                },
              ),
              _buildQuickNavItem(
                icon: Icons.add_circle_outline,
                label: 'Add Pet',
                color: Colors.teal,
                onTap: _addNewPet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Individual Quick Navigation Item
  Widget _buildQuickNavItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Scroll to top of the screen
  void _scrollToTop() {
    // This will be implemented when we add scrolling capability
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You\'re already on the home screen!'),
        backgroundColor: AppTheme.colors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show profile options
  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: AppTheme.colors.primary),
              title: Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile screen
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppTheme.colors.primary),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit profile screen
              },
            ),
            ListTile(
              leading: Icon(Icons.pets, color: AppTheme.colors.primary),
              title: Text('My Pets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pet-management');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Show settings options
  void _showSettingsOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: AppTheme.colors.primary),
              title: Text('App Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to app settings
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: AppTheme.colors.primary),
              title: Text('Notification Preferences'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: AppTheme.colors.primary),
              title: Text('Privacy & Security'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to privacy settings
              },
            ),
            ListTile(
              leading: Icon(Icons.help, color: AppTheme.colors.primary),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to help screen
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Show quick access menu
  void _showQuickAccessMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.navigation,
                    color: AppTheme.colors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quick Access Menu',
                    style: AppTheme.textStyles.titleLarge?.copyWith(
                      color: AppTheme.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quick access grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildQuickAccessItem(
                    icon: Icons.home,
                    label: 'Home',
                    color: AppTheme.colors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      _scrollToTop();
                    },
                  ),
                  _buildQuickAccessItem(
                    icon: Icons.pets,
                    label: 'Pet CRM',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/pet-management');
                    },
                  ),
                  _buildQuickAccessItem(
                    icon: Icons.self_improvement,
                    label: 'Mindfulness',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/health-wellness');
                    },
                  ),
                  _buildQuickAccessItem(
                    icon: Icons.psychology,
                    label: 'AI Insights',
                    color: Colors.indigo,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/ai-insights');
                    },
                  ),
                  _buildQuickAccessItem(
                    icon: Icons.analytics,
                    label: 'Analytics',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/analytics');
                    },
                  ),
                  _buildQuickAccessItem(
                    icon: Icons.people,
                    label: 'Community',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/best-pet');
                    },
                  ),
                  _buildQuickAccessItem(
                    icon: Icons.photo_library,
                    label: 'Scrapbook',
                    color: Colors.pink,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/scrapbook');
                    },
                  ),
                  _buildQuickAccessItem(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  _buildQuickAccessItem(
                    icon: Icons.person,
                    label: 'Profile',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pop(context);
                      _showProfileOptions();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Add Pet Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _addNewPet();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: AppTheme.colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(Icons.add),
                  label: Text(
                    'Add New Pet',
                    style: AppTheme.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Individual Quick Access Item for the menu
  Widget _buildQuickAccessItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTheme.textStyles.bodySmall?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.colors.primary,
        unselectedLabelColor: AppTheme.colors.textSecondary,
        indicatorColor: AppTheme.colors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
          Tab(icon: Icon(Icons.health_and_safety), text: 'Health'),
          Tab(icon: Icon(Icons.psychology), text: 'AI Insights'),
          Tab(icon: Icon(Icons.notifications), text: 'Reminders'),
          Tab(icon: Icon(Icons.people), text: 'Community'),
          Tab(icon: Icon(Icons.photo_library), text: 'Scrapbook'),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _tabController.index,
      onTap: (index) {
        _tabController.animateTo(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.colors.primary,
      unselectedItemColor: AppTheme.colors.textSecondary,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.health_and_safety),
          label: 'Health',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: 'AI',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Reminders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: 'Scrapbook',
        ),
      ],
    );
  }

  Widget _buildDashboardTab() {
    if (currentPet == null) {
      return _buildEmptyState('Add a pet to see your dashboard');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // Pet Stats
          _buildPetStats(),
          
          const SizedBox(height: 24),
          
          // Recent Activities
          _buildRecentActivities(),
          
          const SizedBox(height: 24),
          
          // Premium Features Preview
          if (!widget.user.subscription.isPremium)
            _buildPremiumPreview(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.camera_alt, 'label': 'Take Photo', 'onTap': _addPetPhoto},
      {'icon': Icons.health_and_safety, 'label': 'Health Check', 'onTap': () {}},
      {'icon': Icons.schedule, 'label': 'Schedule', 'onTap': () {}},
      {'icon': Icons.psychology, 'label': 'AI Analysis', 'onTap': () {}},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTheme.textStyles.titleLarge?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: action['onTap'] as VoidCallback,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.colors.outline),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      size: 32,
                      color: AppTheme.colors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: AppTheme.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPetStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${currentPet!.name}\'s Stats',
          style: AppTheme.textStyles.titleLarge?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Age',
                '${currentPet!.age} months',
                Icons.cake,
                AppTheme.colors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Photos',
                '${currentPet!.photos.length}',
                Icons.photo_library,
                AppTheme.colors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Health',
                'Excellent',
                Icons.favorite,
                AppTheme.colors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: AppTheme.textStyles.titleLarge?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colors.outline),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'Photo added',
                '2 hours ago',
                Icons.add_a_photo,
                AppTheme.colors.success,
              ),
              _buildActivityItem(
                'Health check completed',
                '1 day ago',
                Icons.health_and_safety,
                AppTheme.colors.primary,
              ),
              _buildActivityItem(
                'AI analysis updated',
                '2 days ago',
                Icons.psychology,
                AppTheme.colors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textPrimary,
              ),
            ),
          ),
          Text(
            time,
            style: AppTheme.textStyles.bodySmall?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.colors.primary.withOpacity(0.1),
            AppTheme.colors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.primary),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star,
            size: 48,
            color: AppTheme.colors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock Premium Features',
            style: AppTheme.textStyles.titleLarge?.copyWith(
              color: AppTheme.colors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get advanced AI insights, detailed analytics, and exclusive features',
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to premium
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: AppTheme.colors.onPrimary,
            ),
            child: Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthWellnessTab() {
    if (currentPet == null) {
      return _buildEmptyState('Add a pet to access health features');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          NutritionTracker(pet: currentPet!),
          const SizedBox(height: 24),
          ExerciseMonitor(pet: currentPet!),
          const SizedBox(height: 24),
          MentalHealthMonitor(pet: currentPet!),
          const SizedBox(height: 24),
          PreventiveCareSystem(pet: currentPet!),
        ],
      ),
    );
  }

  Widget _buildAITab() {
    if (currentPet == null) {
      return _buildEmptyState('Add a pet to access AI features');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          EmotionRecognitionWidget(pet: currentPet!),
          const SizedBox(height: 24),
          BehavioralPredictionWidget(pet: currentPet!),
          const SizedBox(height: 24),
          SmartSchedulingWidget(pet: currentPet!),
          const SizedBox(height: 24),
          PersonalizedContentWidget(pet: currentPet!),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    if (currentPet == null) {
      return _buildEmptyState('Add a pet to access notifications');
    }

    return NotificationsScreen(pet: currentPet!);
  }

  Widget _buildCommunityTab() {
    return const MarketplaceScreen();
  }

  Widget _buildScrapbookTab() {
    if (currentPet == null) {
      return _buildEmptyState('Add a pet to access scrapbook');
    }

    return DigitalScrapbookScreen(pet: currentPet!);
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: AppTheme.colors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTheme.textStyles.titleMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddPetDialog extends StatefulWidget {
  final Function(Pet) onPetAdded;

  const _AddPetDialog({required this.onPetAdded});

  @override
  State<_AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<_AddPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  String _selectedType = 'Dog';
  int _ageMonths = 12;
  final List<String> _photos = [];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  void _addPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos.add(image.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final pet = Pet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        breed: _breedController.text.trim(),
        age: _ageMonths,
        photos: _photos,
        ownerId: 'current_user_id', // This should come from auth service
      );
      
      widget.onPetAdded(pet);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Pet',
                style: AppTheme.textStyles.headlineSmall?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Type selection
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Pet Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Dog', 'Cat', 'Bird', 'Fish', 'Other'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Breed field
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: 'Breed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a breed';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Age selection
              Row(
                children: [
                  Text(
                    'Age: $_ageMonths months',
                    style: AppTheme.textStyles.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: _ageMonths.toDouble(),
                      min: 1,
                      max: 240, // 20 years
                      divisions: 239,
                      onChanged: (value) {
                        setState(() {
                          _ageMonths = value.round();
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Photo upload
              if (_photos.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _photos.map((photo) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(photo)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _photos.remove(photo);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              OutlinedButton.icon(
                onPressed: _addPhoto,
                icon: Icon(Icons.add_a_photo),
                label: Text('Add Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.colors.primary,
                  side: BorderSide(color: AppTheme.colors.primary),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: AppTheme.colors.onPrimary,
                    ),
                    child: Text('Add Pet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}