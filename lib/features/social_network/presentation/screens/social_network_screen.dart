import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/social_network_service.dart';
import '../../../../shared/models/social_models.dart';
import '../../../../core/theme/app_theme.dart';

class SocialNetworkScreen extends StatefulWidget {
  const SocialNetworkScreen({super.key});

  @override
  State<SocialNetworkScreen> createState() => _SocialNetworkScreenState();
}

class _SocialNetworkScreenState extends State<SocialNetworkScreen>
    with TickerProviderStateMixin {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  int _currentTabIndex = 0;
  List<SocialPost> _posts = [];
  List<CommunityGroup> _groups = [];
  List<CommunityEvent> _events = [];
  List<ExpertProfile> _experts = [];
  List<String> _trendingHashtags = [];
  
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  PostType _selectedPostType = PostType.petPhoto;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
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
    
    _initializeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _postController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final socialService = context.read<SocialNetworkService>();
      socialService.initializeMockData();
      
      // Load initial data
      await _loadPosts();
      await _loadGroups();
      await _loadEvents();
      await _loadExperts();
      await _loadTrendingHashtags();
    } catch (e) {
      _showSnackBar('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPosts() async {
    try {
      final socialService = context.read<SocialNetworkService>();
      final posts = await socialService.getSocialFeed(language: _selectedLanguage);
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      _showSnackBar('Error loading posts: $e');
    }
  }

  Future<void> _loadGroups() async {
    try {
      final socialService = context.read<SocialNetworkService>();
      final groups = await socialService.getGroups(language: _selectedLanguage);
      setState(() {
        _groups = groups;
      });
    } catch (e) {
      _showSnackBar('Error loading groups: $e');
    }
  }

  Future<void> _loadEvents() async {
    try {
      final socialService = context.read<SocialNetworkService>();
      final events = await socialService.getEvents(language: _selectedLanguage);
      setState(() {
        _events = events;
      });
    } catch (e) {
      _showSnackBar('Error loading events: $e');
    }
  }

  Future<void> _loadExperts() async {
    try {
      final socialService = context.read<SocialNetworkService>();
      final experts = await socialService.getExperts(language: _selectedLanguage);
      setState(() {
        _experts = experts;
      });
    } catch (e) {
      _showSnackBar('Error loading experts: $e');
    }
  }

  Future<void> _loadTrendingHashtags() async {
    try {
      final socialService = context.read<SocialNetworkService>();
      final hashtags = await socialService.getTrendingHashtags(language: _selectedLanguage);
      setState(() {
        _trendingHashtags = hashtags;
      });
    } catch (e) {
      _showSnackBar('Error loading hashtags: $e');
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final socialService = context.read<SocialNetworkService>();
      final post = await socialService.createPost(
        userId: 'demo-user',
        userName: 'Demo User',
        type: _selectedPostType,
        title: 'New Post',
        content: _postController.text.trim(),
        hashtags: _extractHashtags(_postController.text.trim()),
        language: _selectedLanguage,
      );

      setState(() {
        _posts.insert(0, post);
        _postController.clear();
      });

      _showSnackBar('Post created successfully!');
    } catch (e) {
      _showSnackBar('Error creating post: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _extractHashtags(String text) {
    final hashtagRegex = RegExp(r'#\w+');
    return hashtagRegex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  Future<void> _toggleLike(SocialPost post) async {
    try {
      final socialService = context.read<SocialNetworkService>();
      final isLiked = await socialService.toggleLike(
        postId: post.id,
        userId: 'demo-user',
      );

      if (isLiked) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _posts[index] = post.copyWith(
              likes: post.likes + 1,
              likedBy: [...post.likedBy, 'demo-user'],
            );
          }
        });
      } else {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _posts[index] = post.copyWith(
              likes: (post.likes - 1).clamp(0, double.infinity).toInt(),
              likedBy: post.likedBy.where((id) => id != 'demo-user').toList(),
            );
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error toggling like: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Social Network'),
        backgroundColor: AppTheme.colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSelector,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Create Post Section
              _buildCreatePostSection(),
              
              // Tab Bar
              _buildTabBar(),
              
              // Tab Content
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatePostSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.colors.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: const InputDecoration(
                      hintText: 'What\'s on your mind about your pet?',
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Post Type Selector
                DropdownButtonFormField<PostType>(
                  value: _selectedPostType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  items: PostType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getPostTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPostType = value ?? PostType.petPhoto;
                    });
                  },
                ),
                
                const SizedBox(width: 12),
                
                // Post Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.colors.surface,
      child: TabBar(
        controller: TabController(
          length: 4,
          vsync: this,
          initialIndex: _currentTabIndex,
        ),
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        labelColor: AppTheme.colors.primary,
        unselectedLabelColor: AppTheme.colors.textSecondary,
        indicatorColor: AppTheme.colors.primary,
        tabs: const [
          Tab(icon: Icon(Icons.home), text: 'Feed'),
          Tab(icon: Icon(Icons.group), text: 'Groups'),
          Tab(icon: Icon(Icons.event), text: 'Events'),
          Tab(icon: Icon(Icons.verified), text: 'Experts'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildFeedTab();
      case 1:
        return _buildGroupsTab();
      case 2:
        return _buildEventsTab();
      case 3:
        return _buildExpertsTab();
      default:
        return _buildFeedTab();
    }
  }

  Widget _buildFeedTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.feed,
        title: 'No posts yet',
        message: 'Be the first to share something about your pet!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildGroupsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_groups.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group,
        title: 'No groups yet',
        message: 'Join or create a community group to connect with other pet owners!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          return _buildGroupCard(group);
        },
      ),
    );
  }

  Widget _buildEventsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return _buildEmptyState(
        icon: Icons.event,
        title: 'No events yet',
        message: 'Join or create an event to meet other pet owners!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildExpertsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_experts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.verified,
        title: 'No experts yet',
        message: 'Connect with verified pet care experts for professional advice!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExperts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _experts.length,
        itemBuilder: (context, index) {
          final expert = _experts[index];
          return _buildExpertCard(expert);
        },
      ),
    );
  }

  Widget _buildPostCard(SocialPost post) {
    final isLiked = post.likedBy.contains('demo-user');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.colors.primary,
                  child: Text(
                    post.userName[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: AppTheme.textStyles.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.createdAt),
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPostTypeColor(post.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPostTypeLabel(post.type),
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: _getPostTypeColor(post.type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Post Content
            Text(
              post.content,
              style: AppTheme.textStyles.bodyMedium,
            ),
            
            // Hashtags
            if (post.hashtags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: post.hashtags.map((hashtag) => Chip(
                  label: Text(hashtag),
                  backgroundColor: AppTheme.colors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.colors.primary),
                )).toList(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Post Actions
            Row(
              children: [
                // Like Button
                InkWell(
                  onTap: () => _toggleLike(post),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? AppTheme.colors.error : AppTheme.colors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: AppTheme.textStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Comment Button
                InkWell(
                  onTap: () => _showCommentsDialog(post),
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        color: AppTheme.colors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.comments}',
                        style: AppTheme.textStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Share Button
                InkWell(
                  onTap: () => _showShareDialog(post),
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_outlined,
                        color: AppTheme.colors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.shares}',
                        style: AppTheme.textStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(CommunityGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: group.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            group.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.group,
                          size: 30,
                          color: AppTheme.colors.primary,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: AppTheme.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        group.category,
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                      Text(
                        '${group.memberCount} members',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _joinGroup(group),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Join'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              group.description,
              style: AppTheme.textStyles.bodyMedium,
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              children: group.tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: AppTheme.colors.secondary.withOpacity(0.1),
                labelStyle: TextStyle(color: AppTheme.colors.secondary),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(CommunityEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: event.eventColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: event.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            event.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.event,
                          size: 30,
                          color: event.eventColor,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTheme.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        event.eventType,
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                      Text(
                        '${event.participants.length}/${event.maxParticipants} participants',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _joinEvent(event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Join'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              event.description,
              style: AppTheme.textStyles.bodyMedium,
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  event.location,
                  style: AppTheme.textStyles.bodySmall,
                ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatEventDate(event.startDate),
                  style: AppTheme.textStyles.bodySmall,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              children: event.tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: AppTheme.colors.secondary.withOpacity(0.1),
                labelStyle: TextStyle(color: AppTheme.colors.secondary),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCard(ExpertProfile expert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.colors.primary.withOpacity(0.1),
                  child: expert.photoUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            expert.photoUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          expert.name[0],
                          style: TextStyle(
                            color: AppTheme.colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            expert.name,
                            style: AppTheme.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (expert.isVerified) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              color: AppTheme.colors.primary,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        expert.specialization,
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppTheme.colors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${expert.rating} (${expert.reviewCount} reviews)',
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _contactExpert(expert),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Contact'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              expert.bio,
              style: AppTheme.textStyles.bodyMedium,
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              children: expert.categories.map((category) => Chip(
                label: Text(category),
                backgroundColor: AppTheme.colors.secondary.withOpacity(0.1),
                labelStyle: TextStyle(color: AppTheme.colors.secondary),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.textStyles.titleLarge?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English', '🇺🇸'),
            _buildLanguageOption('es', 'Español', '🇪🇸'),
            _buildLanguageOption('fr', 'Français', '🇫🇷'),
            _buildLanguageOption('de', 'Deutsch', '🇩🇪'),
            _buildLanguageOption('ja', '日本語', '🇯🇵'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: _selectedLanguage == code
          ? Icon(Icons.check, color: AppTheme.colors.primary)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
        Navigator.pop(context);
        _initializeData(); // Reload data with new language
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search posts, groups, events, or experts...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_trendingHashtags.isNotEmpty) ...[
              Text(
                'Trending Hashtags:',
                style: AppTheme.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _trendingHashtags.map((hashtag) => ActionChip(
                  label: Text(hashtag),
                  onPressed: () {
                    _searchController.text = hashtag;
                    Navigator.pop(context);
                    _performSearch(hashtag);
                  },
                )).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch(_searchController.text.trim());
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    // For now, just show a snackbar. In a real app, this would perform the search
    _showSnackBar('Searching for: $query');
  }

  void _showCommentsDialog(SocialPost post) {
    _showSnackBar('Comments feature coming soon!');
  }

  void _showShareDialog(SocialPost post) {
    _showSnackBar('Share feature coming soon!');
  }

  void _joinGroup(CommunityGroup group) {
    _showSnackBar('Joined ${group.name}!');
  }

  void _joinEvent(CommunityEvent event) {
    _showSnackBar('Joined ${event.title}!');
  }

  void _contactExpert(ExpertProfile expert) {
    _showSnackBar('Contacting ${expert.name}...');
  }

  String _getPostTypeLabel(PostType type) {
    switch (type) {
      case PostType.petPhoto:
        return 'Photo';
      case PostType.achievement:
        return 'Achievement';
      case PostType.healthUpdate:
        return 'Health';
      case PostType.training:
        return 'Training';
      case PostType.question:
        return 'Question';
      case PostType.tip:
        return 'Tip';
      default:
        return 'Post';
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.petPhoto:
        return AppTheme.colors.primary;
      case PostType.achievement:
        return AppTheme.colors.success;
      case PostType.healthUpdate:
        return AppTheme.colors.warning;
      case PostType.training:
        return AppTheme.colors.secondary;
      case PostType.question:
        return AppTheme.colors.info;
      case PostType.tip:
        return AppTheme.colors.primary;
      default:
        return AppTheme.colors.textSecondary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays < 0) {
      return 'Past';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else {
      return '${difference.inDays} days';
    }
  }
}