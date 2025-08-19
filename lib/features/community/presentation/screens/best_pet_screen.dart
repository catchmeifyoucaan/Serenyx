import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/social_models.dart';
import '../../../../shared/services/api_service.dart';
import '../../../../shared/widgets/interactive_pet_image.dart';

class BestPetScreen extends StatefulWidget {
  const BestPetScreen({super.key});

  @override
  State<BestPetScreen> createState() => _BestPetScreenState();
}

class _BestPetScreenState extends State<BestPetScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<BestPetEntry> _bestPets = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBestPets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBestPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _apiService.getBestPetEntries(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
      );
      
      setState(() {
        _bestPets = entries;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading best pets: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load best pets: ${e.toString()}'),
            backgroundColor: AppTheme.colors.error,
          ),
        );
      }
    }
  }

  Future<void> _voteForPet(String petId) async {
    try {
      final entry = _bestPets.firstWhere((entry) => entry.id == petId);
      
      final voteData = {
        'petId': entry.pet.id,
        'category': entry.category,
      };
      
      final result = await _apiService.voteForPet(voteData);
      
      // Update local state
      setState(() {
        entry.votes = result['newVoteCount'];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vote recorded! Thank you for participating.'),
          backgroundColor: AppTheme.colors.success,
        ),
      );
    } catch (e) {
      print('Error voting for pet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to record vote: ${e.toString()}'),
          backgroundColor: AppTheme.colors.error,
        ),
      );
    }
  }

  void _showPetDetails(BestPetEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PetDetailsSheet(entry: entry),
    );
  }

  List<BestPetEntry> _getFilteredPets() {
    if (_selectedCategory == 'all') {
      return _bestPets;
    }
    return _bestPets.where((entry) => entry.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.colors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.colors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Category Filter
          _buildCategoryFilter(),
          
          // Tab Bar
          _buildTabBar(),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTimeTab(),
                _buildMonthlyTab(),
                _buildWeeklyTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubmitPetDialog(),
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
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: AppTheme.colors.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  'Best Pet Contest',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => _showRulesDialog(),
                icon: Icon(
                  Icons.help_outline,
                  color: AppTheme.colors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Vote for your favorite pets and discover amazing companions!',
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Total Pets',
                '${_bestPets.length}',
                Icons.pets,
                AppTheme.colors.primary,
              ),
              _buildStatCard(
                'Total Votes',
                '${_bestPets.fold(0, (sum, entry) => sum + entry.votes)}',
                Icons.thumb_up,
                AppTheme.colors.success,
              ),
              _buildStatCard(
                'Categories',
                '4',
                Icons.category,
                AppTheme.colors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
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
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'id': 'all', 'name': 'All', 'icon': Icons.all_inclusive},
      {'id': 'photogenic', 'name': 'Photogenic', 'icon': Icons.camera_alt},
      {'id': 'adorable', 'name': 'Adorable', 'icon': Icons.favorite},
      {'id': 'athletic', 'name': 'Athletic', 'icon': Icons.sports_soccer},
      {'id': 'smart', 'name': 'Smart', 'icon': Icons.psychology},
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(category['name'] as String),
                ],
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['id'] as String;
                });
              },
              backgroundColor: AppTheme.colors.surface,
              selectedColor: AppTheme.colors.primary,
              checkmarkColor: AppTheme.colors.onPrimary,
              side: BorderSide(
                color: isSelected ? AppTheme.colors.primary : AppTheme.colors.outline,
              ),
            ),
          );
        },
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
          Tab(icon: Icon(Icons.emoji_events), text: 'All Time'),
          Tab(icon: Icon(Icons.calendar_month), text: 'Monthly'),
          Tab(icon: Icon(Icons.calendar_today), text: 'Weekly'),
          Tab(icon: Icon(Icons.category), text: 'Categories'),
        ],
      ),
    );
  }

  Widget _buildAllTimeTab() {
    final filteredPets = _getFilteredPets();
    return _buildPetList(filteredPets);
  }

  Widget _buildMonthlyTab() {
    final filteredPets = _getFilteredPets();
    return _buildPetList(filteredPets);
  }

  Widget _buildWeeklyTab() {
    final filteredPets = _getFilteredPets();
    return _buildPetList(filteredPets);
  }

  Widget _buildCategoriesTab() {
    final categories = ['Most Photogenic', 'Most Adorable', 'Most Athletic', 'Most Smart'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: categories.map((category) {
          final categoryPets = _bestPets.where((entry) => entry.category == category).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: AppTheme.textStyles.titleLarge?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (categoryPets.isNotEmpty)
                _buildPetList(categoryPets, showCategory: false)
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.colors.outline),
                  ),
                  child: Center(
                    child: Text(
                      'No pets in this category yet',
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPetList(List<BestPetEntry> pets, {bool showCategory = true}) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final entry = pets[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colors.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Pet Image and Info
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Pet Image
                    GestureDetector(
                      onTap: () => _showPetDetails(entry),
                      child: InteractivePetImage(
                        imagePath: entry.pet.photos.isNotEmpty 
                            ? entry.pet.photos.first 
                            : 'assets/images/pets/placeholder.jpg',
                        petName: entry.pet.name,
                        size: 80,
                        overlayText: '#${index + 1}',
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Pet Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.pet.name,
                            style: AppTheme.textStyles.titleLarge?.copyWith(
                              color: AppTheme.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          Text(
                            '${entry.pet.breed} • ${entry.pet.age} months old',
                            style: AppTheme.textStyles.bodyMedium?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                          ),
                          
                          if (showCategory) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                entry.category,
                                style: AppTheme.textStyles.bodySmall?.copyWith(
                                  color: AppTheme.colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 8),
                          
                          // Owner Info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppTheme.colors.primary,
                                child: Text(
                                  entry.ownerName.substring(0, 1).toUpperCase(),
                                  style: AppTheme.textStyles.bodySmall?.copyWith(
                                    color: AppTheme.colors.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'by ${entry.ownerName}',
                                style: AppTheme.textStyles.bodySmall?.copyWith(
                                  color: AppTheme.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Vote Button
                    Column(
                      children: [
                                                 IconButton(
                           onPressed: () async => await _voteForPet(entry.id),
                           icon: Icon(
                             Icons.thumb_up,
                             color: AppTheme.colors.primary,
                           ),
                         ),
                        Text(
                          '${entry.votes}',
                          style: AppTheme.textStyles.bodyMedium?.copyWith(
                            color: AppTheme.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Description
              if (entry.description.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.background,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    entry.description,
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms);
      },
    );
  }

  void _showSubmitPetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit Your Pet'),
        content: Text('Feature coming soon! You\'ll be able to submit your pet for the Best Pet contest.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contest Rules'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Vote once per pet per day'),
            Text('• Pets must be real and owned by the submitter'),
            Text('• No inappropriate content'),
            Text('• Winners are determined by total votes'),
            Text('• Contest runs monthly with new categories'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class BestPetEntry {
  final String id;
  final Pet pet;
  final String ownerName;
  final String ownerAvatar;
  final String category;
  int votes;
  final String description;
  final List<String> achievements;
  final List<String> tags;
  final DateTime createdAt;

  BestPetEntry({
    required this.id,
    required this.pet,
    required this.ownerName,
    required this.ownerAvatar,
    required this.category,
    required this.votes,
    required this.description,
    required this.achievements,
    required this.tags,
    required this.createdAt,
  });
}

class _PetDetailsSheet extends StatelessWidget {
  final BestPetEntry entry;

  const _PetDetailsSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
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
          
          // Pet Image
          Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Image.asset(
                entry.pet.photos.isNotEmpty 
                    ? entry.pet.photos.first 
                    : 'assets/images/pets/placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Pet Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  entry.pet.name,
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '${entry.pet.breed} • ${entry.pet.age} months old',
                  style: AppTheme.textStyles.bodyLarge?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    entry.category,
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: AppTheme.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Description
                Text(
                  entry.description,
                  style: AppTheme.textStyles.bodyMedium?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Achievements
                if (entry.achievements.isNotEmpty) ...[
                  Text(
                    'Achievements',
                    style: AppTheme.textStyles.titleMedium?.copyWith(
                      color: AppTheme.colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.achievements.map((achievement) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.colors.success.withOpacity(0.3)),
                        ),
                        child: Text(
                          achievement,
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: AppTheme.colors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Vote count
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.thumb_up,
                      color: AppTheme.colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.votes} votes',
                      style: AppTheme.textStyles.titleLarge?.copyWith(
                        color: AppTheme.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.colors.primary,
                      side: BorderSide(color: AppTheme.colors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Close'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Vote functionality
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: AppTheme.colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Vote'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}