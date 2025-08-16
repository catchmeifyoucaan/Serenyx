import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/session.dart';
import '../../../../shared/services/pet_service.dart';
import '../../../../shared/services/session_service.dart';
import '../widgets/pet_moment_card.dart';
import '../widgets/create_moment_dialog.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with TickerProviderStateMixin {
  final PetService _petService = PetService();
  final SessionService _sessionService = SessionService();
  
  List<PetMoment> _moments = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMoments();
  }

  Future<void> _loadMoments() async {
    try {
      await _petService.initialize();
      await _sessionService.initialize();
      
      // Generate sample moments for demonstration
      _moments = _generateSampleMoments();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading moments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<PetMoment> _generateSampleMoments() {
    final pets = _petService.pets;
    if (pets.isEmpty) return [];
    
    final moments = <PetMoment>[];
    final now = DateTime.now();
    
    // Add moments from completed sessions
    final sessions = _sessionService.sessions.take(10).toList();
    for (final session in sessions) {
      if (session.isCompleted && session.moodRating != null) {
        final pet = _petService.getPetById(session.petId);
        if (pet != null) {
          moments.add(PetMoment(
            id: 'moment-${session.id}',
            userId: 'user-${pet.ownerId}',
            userName: 'Pet Parent',
            userAvatar: 'https://via.placeholder.com/50',
            petName: pet.name,
            petType: pet.type,
            content: _generateMomentContent(session, pet),
            imageUrl: null,
            likes: (session.moodRating! * 2).round(),
            comments: (session.moodRating! * 1.5).round(),
            timestamp: session.endTime ?? session.createdAt,
            tags: _generateTags(session, pet),
          ));
        }
      }
    }
    
    // Add some community moments
    moments.addAll([
      PetMoment(
        id: 'community-1',
        userId: 'community-user-1',
        userName: 'Luna\'s Mom',
        userAvatar: 'https://via.placeholder.com/50/FF6B6B/FFFFFF?text=L',
        petName: 'Luna',
        petType: 'Cat',
        content: 'Just had the most amazing cuddle session with Luna! She purred the entire time and fell asleep in my arms. These moments make everything worth it! 🐱💕',
        imageUrl: null,
        likes: 24,
        comments: 8,
        timestamp: now.subtract(const Duration(hours: 2)),
        tags: ['cuddles', 'purring', 'bonding'],
      ),
      PetMoment(
        id: 'community-2',
        userId: 'community-user-2',
        userName: 'Max\'s Dad',
        userAvatar: 'https://via.placeholder.com/50/8BC34A/FFFFFF?text=M',
        petName: 'Max',
        petType: 'Dog',
        content: 'Max learned a new trick today! He can now give high-fives and it\'s the cutest thing ever. Training with love and treats works wonders! 🐕🦴',
        imageUrl: null,
        likes: 31,
        comments: 12,
        timestamp: now.subtract(const Duration(hours: 4)),
        tags: ['training', 'tricks', 'high-five'],
      ),
      PetMoment(
        id: 'community-3',
        userId: 'community-user-3',
        userName: 'Bella\'s Family',
        userAvatar: 'https://via.placeholder.com/50/9C27B0/FFFFFF?text=B',
        petName: 'Bella',
        petType: 'Rabbit',
        content: 'Bella discovered her new favorite spot - right next to the window where she can watch the birds. She\'s been there for hours! 🐰🪟',
        imageUrl: null,
        likes: 18,
        comments: 5,
        timestamp: now.subtract(const Duration(hours: 6)),
        tags: ['discovery', 'window-watching', 'comfort'],
      ),
    ]);
    
    // Sort by timestamp (newest first)
    moments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return moments;
  }

  String _generateMomentContent(Session session, Pet pet) {
    final mood = session.moodRating!;
    if (mood >= 4.5) {
      return 'Had an incredible session with ${pet.name}! We both feel amazing and connected. The bond we\'re building is truly special! ✨💖';
    } else if (mood >= 3.5) {
      return 'Great session with ${pet.name}! We\'re both feeling good and relaxed. Love these peaceful moments together. 🐾💕';
    } else {
      return 'Nice session with ${pet.name}. We\'re both feeling calm and content. Every moment together is precious. 🌸💫';
    }
  }

  List<String> _generateTags(Session session, Pet pet) {
    final tags = <String>[];
    
    if (session.type == SessionType.tickle) {
      tags.add('tickle-session');
      tags.add('playtime');
    } else if (session.type == SessionType.cuddle) {
      tags.add('cuddle-time');
      tags.add('bonding');
    } else if (session.type == SessionType.cuddle) {
      tags.add('cuddle-time');
      tags.add('bonding');
    }
    
    if (session.moodRating! >= 4.5) {
      tags.add('amazing');
      tags.add('overjoyed');
    } else if (session.moodRating! >= 3.5) {
      tags.add('great');
      tags.add('happy');
    } else {
      tags.add('good');
      tags.add('content');
    }
    
    tags.add(pet.type.toLowerCase());
    tags.add('serenyx');
    
    return tags;
  }

  Future<void> _createNewMoment() async {
    final result = await showDialog<PetMoment>(
      context: context,
      builder: (context) => const CreateMomentDialog(),
    );

    if (result != null) {
      setState(() {
        _moments.insert(0, result);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your moment has been shared! 🎉'),
          backgroundColor: AppTheme.leafGreen,
        ),
      );
    }
  }

  void _filterMoments(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<PetMoment> get _filteredMoments {
    if (_selectedFilter == 'all') return _moments;
    
    return _moments.where((moment) {
      switch (_selectedFilter) {
        case 'my-pets':
          return moment.userId.startsWith('user-');
        case 'community':
          return moment.userId.startsWith('community-');
        case 'dogs':
          return moment.petType.toLowerCase() == 'dog';
        case 'cats':
          return moment.petType.toLowerCase() == 'cat';
        case 'other':
          return !['dog', 'cat'].contains(moment.petType.toLowerCase());
        default:
          return true;
      }
    }).toList();
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
                    : _buildMomentsList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewMoment,
        backgroundColor: AppTheme.heartPink,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text(
          'Share Moment',
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
            child: Text(
              'Pet Community',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.warmGrey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: AppTheme.warmGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.all_inclusive},
      {'key': 'my-pets', 'label': 'My Pets', 'icon': Icons.pets},
      {'key': 'community', 'label': 'Community', 'icon': Icons.people},
      {'key': 'dogs', 'label': 'Dogs', 'icon': Icons.pets},
      {'key': 'cats', 'label': 'Cats', 'icon': Icons.pets},
      {'key': 'other', 'label': 'Other', 'icon': Icons.pets},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.lgSpacing),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          
          return Container(
            margin: const EdgeInsets.only(right: AppConstants.smSpacing),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppTheme.warmGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(filter['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) => _filterMoments(filter['key'] as String),
              selectedColor: AppTheme.heartPink,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.warmGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMomentsList() {
    if (_filteredMoments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      itemCount: _filteredMoments.length,
      itemBuilder: (context, index) {
        final moment = _filteredMoments[index];
        
        return PetMomentCard(
          moment: moment,
          onLike: () => _handleLike(moment),
          onComment: () => _handleComment(moment),
          onShare: () => _handleShare(moment),
        ).animate()
          .fadeIn(duration: AppConstants.mediumAnimation, delay: Duration(milliseconds: index * 100))
          .slideX(begin: 0.3, duration: AppConstants.mediumAnimation, delay: Duration(milliseconds: index * 100));
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.softPink.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people,
              color: AppTheme.heartPink,
              size: 60,
            ),
          ),
          const SizedBox(height: AppConstants.lgSpacing),
          Text(
            'No moments yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'Be the first to share a special moment with your pet!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.warmGrey.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.xlSpacing),
          ElevatedButton.icon(
            onPressed: _createNewMoment,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Share Your First Moment'),
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

  void _handleLike(PetMoment moment) {
    setState(() {
      if (moment.isLiked) {
        moment.likes--;
        moment.isLiked = false;
      } else {
        moment.likes++;
        moment.isLiked = true;
      }
    });
  }

  void _handleComment(PetMoment moment) {
    // TODO: Implement comment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comment feature coming soon! 💬'),
        backgroundColor: AppTheme.softPurple,
      ),
    );
  }

  void _handleShare(PetMoment moment) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared ${moment.petName}\'s moment! 📤'),
        backgroundColor: AppTheme.leafGreen,
      ),
    );
  }
}

class PetMoment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String petName;
  final String petType;
  final String content;
  final String? imageUrl;
  int likes;
  final int comments;
  final DateTime timestamp;
  final List<String> tags;
  bool isLiked;

  PetMoment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.petName,
    required this.petType,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.timestamp,
    required this.tags,
    this.isLiked = false,
  });
}