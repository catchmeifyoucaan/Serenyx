import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/scrapbook_models.dart';
import '../../../../shared/services/pet_service.dart';
import '../widgets/memory_card.dart';
import '../widgets/milestone_card.dart';
import '../widgets/photo_memory.dart';
import '../widgets/timeline_widget.dart';

class DigitalScrapbookScreen extends StatefulWidget {
  final Pet pet;
  
  const DigitalScrapbookScreen({super.key, required this.pet});

  @override
  State<DigitalScrapbookScreen> createState() => _DigitalScrapbookScreenState();
}

class _DigitalScrapbookScreenState extends State<DigitalScrapbookScreen>
    with TickerProviderStateMixin {
  final PetService _petService = PetService();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<MemoryEntry> _memories = [];
  List<Milestone> _milestones = [];
  List<PhotoMemory> _photoMemories = [];
  
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Photos', 'Milestones', 'Bonding', 'Health'];

  @override
  void initState() {
    super.initState();
    _loadScrapbookData();
  }

  Future<void> _loadScrapbookData() async {
    try {
      await _loadMemories();
      await _loadMilestones();
      await _loadPhotoMemories();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading scrapbook data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMemories() async {
    // Simulate loading memories
    _memories = [
      MemoryEntry(
        id: 'm1',
        title: 'First Day Home',
        description: 'The day ${widget.pet.name} came into our lives. So tiny and scared, but full of love.',
        date: DateTime.now().subtract(const Duration(days: 365)),
        photoUrl: null,
        type: MemoryType.bonding,
        mood: 'Joyful',
        tags: ['Adoption', 'First Day', 'Love'],
      ),
      MemoryEntry(
        id: 'm2',
        title: 'Learning to Walk on Leash',
        description: '${widget.pet.name} was so excited to explore the world outside!',
        date: DateTime.now().subtract(const Duration(days: 300)),
        photoUrl: null,
        type: MemoryType.bonding,
        mood: 'Excited',
        tags: ['Training', 'Outdoors', 'Progress'],
      ),
      MemoryEntry(
        id: 'm3',
        title: 'First Vet Visit',
        description: '${widget.pet.name} was so brave during the checkup.',
        date: DateTime.now().subtract(const Duration(days: 250)),
        photoUrl: null,
        type: MemoryType.health,
        mood: 'Nervous',
        tags: ['Vet', 'Health', 'Brave'],
      ),
      MemoryEntry(
        id: 'm4',
        title: 'Beach Adventure',
        description: 'First time at the beach! ${widget.pet.name} loved the sand and waves.',
        date: DateTime.now().subtract(const Duration(days: 180)),
        photoUrl: null,
        type: MemoryType.bonding,
        mood: 'Adventurous',
        tags: ['Beach', 'Adventure', 'Fun'],
      ),
    ];
  }

  Future<void> _loadMilestones() async {
    // Simulate loading milestones
    _milestones = [
      Milestone(
        id: 'ms1',
        title: 'First Birthday',
        description: '${widget.pet.name} turned 1 year old!',
        date: DateTime.now().subtract(const Duration(days: 200)),
        type: MilestoneType.birthday,
        icon: Icons.cake,
        color: AppTheme.heartPink,
        isCelebrated: true, // Added missing required property
      ),
      Milestone(
        id: 'ms2',
        title: 'House Training Complete',
        description: '${widget.pet.name} learned to use the bathroom outside!',
        date: DateTime.now().subtract(const Duration(days: 280)),
        type: MilestoneType.training,
        icon: Icons.check_circle,
        color: AppTheme.leafGreen,
        isCelebrated: true, // Added missing required property
      ),
      Milestone(
        id: 'ms3',
        title: 'First Friend Made',
        description: '${widget.pet.name} made their first dog friend at the park!',
        date: DateTime.now().subtract(const Duration(days: 150)),
        type: MilestoneType.social,
        icon: Icons.people,
        color: AppTheme.softPurple,
        isCelebrated: true, // Added missing required property
      ),
      Milestone(
        id: 'ms4',
        title: 'Weight Goal Reached',
        description: '${widget.pet.name} reached their healthy weight goal!',
        date: DateTime.now().subtract(const Duration(days: 100)),
        type: MilestoneType.health,
        icon: Icons.favorite,
        color: AppTheme.lightPink,
        isCelebrated: true, // Added missing required property
      ),
    ];
  }

  Future<void> _loadPhotoMemories() async {
    // Simulate loading photo memories
    _photoMemories = [
      PhotoMemory(
        id: 'pm1',
        title: 'Sleepy Puppy',
        description: '${widget.pet.name} taking their first nap in their new home',
        photoUrl: 'https://via.placeholder.com/400/FF6B6B/FFFFFF?text=Sleepy+Puppy',
        date: DateTime.now().subtract(const Duration(days: 365)),
        tags: ['Sleep', 'Home', 'Adorable'],
        location: 'Home', // Added missing required property
      ),
      PhotoMemory(
        id: 'pm2',
        title: 'Playtime Fun',
        description: 'Playing with their favorite toy for the first time',
        photoUrl: 'https://via.placeholder.com/400/8BC34A/FFFFFF?text=Playtime+Fun',
        date: DateTime.now().subtract(const Duration(days: 320)),
        tags: ['Play', 'Toys', 'Fun'],
        location: 'Living Room', // Added missing required property
      ),
      PhotoMemory(
        id: 'pm3',
        title: 'Park Adventure',
        description: 'First time exploring the local dog park',
        photoUrl: 'https://via.placeholder.com/400/9C27B0/FFFFFF?text=Park+Adventure',
        date: DateTime.now().subtract(const Duration(days: 250)),
        tags: ['Park', 'Adventure', 'Social'],
        location: 'Local Park', // Added missing required property
      ),
      PhotoMemory(
        id: 'pm4',
        title: 'Beach Day',
        description: 'Enjoying the sunshine and waves at the beach',
        photoUrl: 'https://via.placeholder.com/400/FF9800/FFFFFF?text=Beach+Day',
        date: DateTime.now().subtract(const Duration(days: 180)),
        tags: ['Beach', 'Sunshine', 'Adventure'],
        location: 'Beach', // Added missing required property
      ),
    ];
  }

  Future<void> _addNewMemory() async {
    // TODO: Implement add new memory dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add Memory feature coming soon! ✨'),
        backgroundColor: AppTheme.leafGreen,
      ),
    );
  }

  Future<void> _addNewPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _photoMemories.insert(0, PhotoMemory(
          id: 'pm${DateTime.now().millisecondsSinceEpoch}',
          title: 'New Memory',
          description: 'A special moment with ${widget.pet.name}',
          photoUrl: image.path,
          date: DateTime.now(),
          tags: ['New', 'Special'],
          location: 'Home', // Added missing required property
        ));
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo added to ${widget.pet.name}\'s scrapbook! 📸'),
          backgroundColor: AppTheme.leafGreen,
        ),
      );
    }
  }

  List<dynamic> get _filteredContent {
    switch (_selectedFilter) {
      case 'Photos':
        return _photoMemories;
      case 'Milestones':
        return _milestones;
      case 'Bonding':
        return _memories.where((m) => m.type == MemoryType.bonding).toList();
      case 'Health':
        return _memories.where((m) => m.type == MemoryType.health).toList();
      default:
        return [..._memories, ..._milestones, ..._photoMemories];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.softPinkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildScrapbookContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewPhoto,
        backgroundColor: AppTheme.heartPink,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text(
          'Add Photo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.warmGrey),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${widget.pet.name}\'s Scrapbook',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'A journey through memories',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.warmGrey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _addNewMemory,
            icon: Icon(Icons.add, color: AppTheme.warmGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.lgSpacing),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: AppConstants.smSpacing),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: AppTheme.heartPink.withOpacity(0.2),
              checkmarkColor: AppTheme.heartPink,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.heartPink : AppTheme.warmGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: AppTheme.softPink.withOpacity(0.3),
              side: BorderSide(
                color: isSelected ? AppTheme.heartPink : AppTheme.softPink,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScrapbookContent() {
    if (_filteredContent.isEmpty) {
      return _buildEmptyState();
    }

    // Sort content by date (newest first)
    final sortedContent = List.from(_filteredContent)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      children: [
        // Scrapbook Summary
        _buildScrapbookSummary(),
        
        const SizedBox(height: AppConstants.xlSpacing),
        
        // Timeline View
        TimelineWidget(
          content: sortedContent,
          onMemoryTap: (memory) => _showMemoryDetails(memory),
          onMilestoneTap: (milestone) => _showMilestoneDetails(milestone),
          onPhotoTap: (photo) => _showPhotoDetails(photo),
        ),
      ],
    );
  }

  Widget _buildScrapbookSummary() {
    final totalMemories = _memories.length;
    final totalMilestones = _milestones.length;
    final totalPhotos = _photoMemories.length;
    final totalDays = DateTime.now().difference(widget.pet.createdAt).inDays;

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
            'Scrapbook Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Memories',
                  '$totalMemories',
                  Icons.favorite,
                  AppTheme.heartPink,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Milestones',
                  '$totalMilestones',
                  Icons.star,
                  AppTheme.leafGreen,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Photos',
                  '$totalPhotos',
                  Icons.photo_library,
                  AppTheme.softPurple,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Days Together',
                  '$totalDays',
                  Icons.calendar_today,
                  AppTheme.lightPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.warmGrey.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.xlSpacing),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.heartPink.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library,
              color: AppTheme.heartPink,
              size: 50,
            ),
          ),
          const SizedBox(height: AppConstants.lgSpacing),
          Text(
            'Your scrapbook is empty',
            style: TextStyle(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          SizedBox(
            width: double.infinity,
            child: Text(
              'Start adding photos and memories to create ${widget.pet.name}\'s life story',
              style: TextStyle(
                color: AppTheme.warmGrey.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppConstants.lgSpacing),
          ElevatedButton.icon(
            onPressed: _addNewPhoto,
            icon: const Icon(Icons.add_a_photo, color: Colors.white),
            label: const Text('Add First Memory'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.heartPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showMemoryDetails(MemoryEntry memory) {
    // TODO: Implement memory details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing: ${memory.title}'),
        backgroundColor: AppTheme.softPurple,
      ),
    );
  }

  void _showMilestoneDetails(Milestone milestone) {
    // TODO: Implement milestone details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing: ${milestone.title}'),
        backgroundColor: milestone.color,
      ),
    );
  }

  void _showPhotoDetails(PhotoMemory photo) {
    // TODO: Implement photo details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing: ${photo.title}'),
        backgroundColor: AppTheme.leafGreen,
      ),
    );
  }
}