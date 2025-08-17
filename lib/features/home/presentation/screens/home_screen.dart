import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/auth_models.dart';
import '../../../../shared/models/pet.dart';
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
  final List<Pet> _pets = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _petCarouselController = PageController();
    _loadPets();
  }

  void _loadPets() {
    // Load user's pets - in real app, this would come from a service
    _pets.addAll([
      Pet(
        id: '1',
        name: 'Luna',
        type: 'Dog',
        breed: 'Golden Retriever',
        age: 24,
        photos: [
          'assets/images/pets/luna_1.jpg',
          'assets/images/pets/luna_2.jpg',
        ],
        ownerId: widget.user.id,
      ),
      Pet(
        id: '2',
        name: 'Whiskers',
        type: 'Cat',
        breed: 'Persian',
        age: 36,
        photos: [
          'assets/images/pets/whiskers_1.jpg',
        ],
        ownerId: widget.user.id,
      ),
      Pet(
        id: '3',
        name: 'Buddy',
        type: 'Dog',
        breed: 'Labrador',
        age: 12,
        photos: [
          'assets/images/pets/buddy_1.jpg',
          'assets/images/pets/buddy_2.jpg',
          'assets/images/pets/buddy_3.jpg',
        ],
        ownerId: widget.user.id,
      ),
    ]);
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
        onPetAdded: (pet) {
          setState(() {
            _pets.add(pet);
            _currentPetIndex = _pets.length - 1;
          });
          _petCarouselController.animateToPage(
            _currentPetIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  void _addPetPhoto() async {
    if (_pets.isEmpty) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pets[_currentPetIndex].photos.add(image.path);
      });
    }
  }

  Pet? get currentPet => _pets.isNotEmpty ? _pets[_currentPetIndex] : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: Column(
        children: [
          // Header with Pet Carousel
          _buildHeader(),
          
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPet,
        backgroundColor: AppTheme.colors.primary,
        child: Icon(
          Icons.add,
          color: AppTheme.colors.onPrimary,
        ),
      ),
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
              
              // Settings button
              IconButton(
                onPressed: () {
                  // Navigate to settings
                },
                icon: Icon(
                  Icons.settings,
                  color: AppTheme.colors.textSecondary,
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