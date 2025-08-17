import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/social_models.dart';
import '../models/auth_models.dart';
import '../models/pet.dart';

class SocialNetworkService {
  static final SocialNetworkService _instance = SocialNetworkService._internal();
  factory SocialNetworkService() => _instance;
  SocialNetworkService._internal();

  // Mock data for demonstration
  final List<SocialPost> _posts = [];
  final List<CommunityGroup> _groups = [];
  final List<CommunityEvent> _events = [];
  final List<ExpertProfile> _experts = [];

  /// Initialize mock data
  void initializeMockData() {
    _initializePosts();
    _initializeGroups();
    _initializeEvents();
    _initializeExperts();
  }

  /// Create a new social post
  Future<SocialPost> createPost({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required PostType type,
    required String title,
    required String content,
    List<String> images = const [],
    List<String> hashtags = const [],
    String language = 'en',
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final post = SocialPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: type,
      title: title,
      content: content,
      images: images,
      hashtags: hashtags,
      likes: 0,
      comments: 0,
      shares: 0,
      likedBy: [],
      createdAt: DateTime.now(),
      metadata: {
        'language': language,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );

    _posts.add(post);
    return post;
  }

  /// Get social feed posts
  Future<List<SocialPost>> getSocialFeed({
    String? userId,
    PostType? type,
    String? hashtag,
    int page = 0,
    int limit = 20,
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    List<SocialPost> filteredPosts = List.from(_posts);

    // Filter by type
    if (type != null) {
      filteredPosts = filteredPosts.where((post) => post.type == type).toList();
    }

    // Filter by hashtag
    if (hashtag != null) {
      filteredPosts = filteredPosts.where((post) => 
        post.hashtags.any((tag) => tag.toLowerCase().contains(hashtag.toLowerCase()))
      ).toList();
    }

    // Sort by creation date (newest first)
    filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Pagination
    final startIndex = page * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredPosts.length) {
      return [];
    }

    return filteredPosts.sublist(
      startIndex, 
      endIndex > filteredPosts.length ? filteredPosts.length : endIndex
    );
  }

  /// Like/unlike a post
  Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return false;

    final post = _posts[postIndex];
    final isLiked = post.likedBy.contains(userId);

    if (isLiked) {
      post.likedBy.remove(userId);
      post.likes = (post.likes - 1).clamp(0, double.infinity).toInt();
    } else {
      post.likedBy.add(userId);
      post.likes++;
    }

    _posts[postIndex] = post;
    return !isLiked;
  }

  /// Add comment to a post
  Future<bool> addComment({
    required String postId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return false;

    final post = _posts[postIndex];
    post.comments++;
    _posts[postIndex] = post;

    return true;
  }

  /// Share a post
  Future<bool> sharePost({
    required String postId,
    required String userId,
    required SocialPlatform platform,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return false;

    final post = _posts[postIndex];
    post.shares++;
    _posts[postIndex] = post;

    return true;
  }

  /// Create a community group
  Future<CommunityGroup> createGroup({
    required String name,
    required String description,
    required String category,
    required String creatorId,
    required String creatorName,
    List<String> tags = const [],
    String imageUrl = '',
    bool isPrivate = false,
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final group = CommunityGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      category: category,
      creatorId: creatorId,
      creatorName: creatorName,
      tags: tags,
      imageUrl: imageUrl,
      isPrivate: isPrivate,
      memberCount: 1,
      members: [creatorId],
      posts: [],
      createdAt: DateTime.now(),
      language: language,
    );

    _groups.add(group);
    return group;
  }

  /// Get community groups
  Future<List<CommunityGroup>> getGroups({
    String? category,
    String? searchQuery,
    bool? isPrivate,
    int page = 0,
    int limit = 20,
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    List<CommunityGroup> filteredGroups = List.from(_groups);

    // Filter by category
    if (category != null) {
      filteredGroups = filteredGroups.where((group) => group.category == category).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredGroups = filteredGroups.where((group) => 
        group.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        group.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        group.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()))
      ).toList();
    }

    // Filter by privacy
    if (isPrivate != null) {
      filteredGroups = filteredGroups.where((group) => group.isPrivate == isPrivate).toList();
    }

    // Sort by member count (most popular first)
    filteredGroups.sort((a, b) => b.memberCount.compareTo(a.memberCount));

    // Pagination
    final startIndex = page * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredGroups.length) {
      return [];
    }

    return filteredGroups.sublist(
      startIndex, 
      endIndex > filteredGroups.length ? filteredGroups.length : endIndex
    );
  }

  /// Join a community group
  Future<bool> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex == -1) return false;

    final group = _groups[groupIndex];
    if (group.members.contains(userId)) return false;

    group.members.add(userId);
    group.memberCount++;
    _groups[groupIndex] = group;

    return true;
  }

  /// Leave a community group
  Future<bool> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex == -1) return false;

    final group = _groups[groupIndex];
    if (!group.members.contains(userId)) return false;

    group.members.remove(userId);
    group.memberCount = (group.memberCount - 1).clamp(0, double.infinity);
    _groups[groupIndex] = group;

    return true;
  }

  /// Create a community event
  Future<CommunityEvent> createEvent({
    required String title,
    required String description,
    required String eventType,
    required DateTime startDate,
    required DateTime endDate,
    required String location,
    bool isOnline = false,
    int maxParticipants = 50,
    required String organizerId,
    required String organizerName,
    List<String> tags = const [],
    String imageUrl = '',
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final event = CommunityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      eventType: eventType,
      startDate: startDate,
      endDate: endDate,
      location: location,
      isOnline: isOnline,
      maxParticipants: maxParticipants,
      participants: [organizerId],
      tags: tags,
      imageUrl: imageUrl,
      organizerId: organizerId,
      organizerName: organizerName,
      eventColor: _getRandomEventColor(),
    );

    _events.add(event);
    return event;
  }

  /// Get community events
  Future<List<CommunityEvent>> getEvents({
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    bool? isOnline,
    int page = 0,
    int limit = 20,
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    List<CommunityEvent> filteredEvents = List.from(_events);

    // Filter by event type
    if (eventType != null) {
      filteredEvents = filteredEvents.where((event) => event.eventType == eventType).toList();
    }

    // Filter by date range
    if (startDate != null) {
      filteredEvents = filteredEvents.where((event) => event.startDate.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filteredEvents = filteredEvents.where((event) => event.endDate.isBefore(endDate)).toList();
    }

    // Filter by location
    if (location != null) {
      filteredEvents = filteredEvents.where((event) => 
        event.location.toLowerCase().contains(location.toLowerCase())
      ).toList();
    }

    // Filter by online status
    if (isOnline != null) {
      filteredEvents = filteredEvents.where((event) => event.isOnline == isOnline).toList();
    }

    // Sort by start date (upcoming first)
    filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Pagination
    final startIndex = page * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredEvents.length) {
      return [];
    }

    return filteredEvents.sublist(
      startIndex, 
      endIndex > filteredEvents.length ? filteredEvents.length : endIndex
    );
  }

  /// Join a community event
  Future<bool> joinEvent({
    required String eventId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) return false;

    final event = _events[eventIndex];
    if (event.participants.contains(userId)) return false;
    if (event.isFull) return false;

    event.participants.add(userId);
    _events[eventIndex] = event;

    return true;
  }

  /// Leave a community event
  Future<bool> leaveEvent({
    required String eventId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) return false;

    final event = _events[eventIndex];
    if (!event.participants.contains(userId)) return false;

    event.participants.remove(userId);
    _events[eventIndex] = event;

    return true;
  }

  /// Get expert profiles
  Future<List<ExpertProfile>> getExperts({
    String? category,
    String? searchQuery,
    bool? isVerified,
    int page = 0,
    int limit = 20,
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    List<ExpertProfile> filteredExperts = List.from(_experts);

    // Filter by category
    if (category != null) {
      filteredExperts = filteredExperts.where((expert) => 
        expert.categories.contains(category)
      ).toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredExperts = filteredExperts.where((expert) => 
        expert.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        expert.specialization.toLowerCase().contains(searchQuery.toLowerCase()) ||
        expert.categories.any((cat) => cat.toLowerCase().contains(searchQuery.toLowerCase()))
      ).toList();
    }

    // Filter by verification status
    if (isVerified != null) {
      filteredExperts = filteredExperts.where((expert) => expert.isVerified == isVerified).toList();
    }

    // Sort by rating (highest first)
    filteredExperts.sort((a, b) => b.rating.compareTo(a.rating));

    // Pagination
    final startIndex = page * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredExperts.length) {
      return [];
    }

    return filteredExperts.sublist(
      startIndex, 
      endIndex > filteredExperts.length ? filteredExperts.length : endIndex
    );
  }

  /// Verify an expert profile
  Future<bool> verifyExpert({
    required String expertId,
    required String verifierId,
    required String verificationNotes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final expertIndex = _experts.indexWhere((expert) => expert.id == expertId);
    if (expertIndex == -1) return false;

    final expert = _experts[expertIndex];
    expert.isVerified = true;
    expert.verificationDate = DateTime.now();
    expert.verifierId = verifierId;
    expert.verificationNotes = verificationNotes;
    _experts[expertIndex] = expert;

    return true;
  }

  /// Get trending hashtags
  Future<List<String>> getTrendingHashtags({
    int limit = 10,
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Count hashtag usage
    final hashtagCounts = <String, int>{};
    for (final post in _posts) {
      for (final hashtag in post.hashtags) {
        hashtagCounts[hashtag] = (hashtagCounts[hashtag] ?? 0) + 1;
      }
    }

    // Sort by usage count and return top hashtags
    final sortedHashtags = hashtagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHashtags.take(limit).map((e) => e.key).toList();
  }

  /// Search across all social content
  Future<SocialSearchResult> searchSocialContent({
    required String query,
    String? contentType,
    int page = 0,
    int limit = 20,
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final results = SocialSearchResult(
      query: query,
      posts: [],
      groups: [],
      events: [],
      experts: [],
      totalResults: 0,
    );

    // Search in posts
    if (contentType == null || contentType == 'posts') {
      results.posts = _posts.where((post) => 
        post.title.toLowerCase().contains(query.toLowerCase()) ||
        post.content.toLowerCase().contains(query.toLowerCase()) ||
        post.hashtags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }

    // Search in groups
    if (contentType == null || contentType == 'groups') {
      results.groups = _groups.where((group) => 
        group.name.toLowerCase().contains(query.toLowerCase()) ||
        group.description.toLowerCase().contains(query.toLowerCase()) ||
        group.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }

    // Search in events
    if (contentType == null || contentType == 'events') {
      results.events = _events.where((event) => 
        event.title.toLowerCase().contains(query.toLowerCase()) ||
        event.description.toLowerCase().contains(query.toLowerCase()) ||
        event.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }

    // Search in experts
    if (contentType == null || contentType == 'experts') {
      results.experts = _experts.where((expert) => 
        expert.name.toLowerCase().contains(query.toLowerCase()) ||
        expert.specialization.toLowerCase().contains(query.toLowerCase()) ||
        expert.categories.any((cat) => cat.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }

    results.totalResults = results.posts.length + results.groups.length + 
                          results.events.length + results.experts.length;

    return results;
  }

  // Private helper methods
  void _initializePosts() {
    _posts.addAll([
      SocialPost(
        id: '1',
        userId: 'user1',
        userName: 'Sarah Johnson',
        userPhotoUrl: 'https://example.com/sarah.jpg',
        type: PostType.petPhoto,
        title: 'Luna\'s morning walk!',
        content: 'Beautiful morning walk with my Golden Retriever Luna. She loves exploring new trails!',
        images: ['https://example.com/luna_walk1.jpg', 'https://example.com/luna_walk2.jpg'],
        hashtags: ['#GoldenRetriever', '#MorningWalk', '#PetLife', '#OutdoorAdventures'],
        likes: 24,
        comments: 8,
        shares: 3,
        likedBy: ['user2', 'user3', 'user4'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: {'language': 'en'},
      ),
      SocialPost(
        id: '2',
        userId: 'user2',
        userName: 'Mike Chen',
        userPhotoUrl: 'https://example.com/mike.jpg',
        type: PostType.achievement,
        title: 'Whiskers learned a new trick!',
        content: 'After weeks of training, Whiskers finally mastered the high-five! So proud of my smart cat.',
        images: ['https://example.com/whiskers_trick.jpg'],
        hashtags: ['#CatTraining', '#SmartCat', '#Achievement', '#PetTraining'],
        likes: 31,
        comments: 12,
        shares: 5,
        likedBy: ['user1', 'user3', 'user5'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        metadata: {'language': 'en'},
      ),
      SocialPost(
        id: '3',
        userId: 'user3',
        userName: 'Emma Rodriguez',
        userPhotoUrl: 'https://example.com/emma.jpg',
        type: PostType.healthUpdate,
        title: 'Buddy\'s recovery journey',
        content: 'Update on Buddy\'s recovery from surgery. He\'s doing great and getting stronger every day!',
        images: ['https://example.com/buddy_recovery.jpg'],
        hashtags: ['#PetRecovery', '#HealthUpdate', '#PetCare', '#RecoveryJourney'],
        likes: 45,
        comments: 15,
        shares: 8,
        likedBy: ['user1', 'user2', 'user4', 'user5'],
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        metadata: {'language': 'en'},
      ),
    ]);
  }

  void _initializeGroups() {
    _groups.addAll([
      CommunityGroup(
        id: '1',
        name: 'Golden Retriever Lovers',
        description: 'A community for Golden Retriever owners to share experiences, tips, and adorable photos.',
        category: 'Dog Breeds',
        creatorId: 'user1',
        creatorName: 'Sarah Johnson',
        tags: ['Golden Retriever', 'Dogs', 'Pet Care', 'Training'],
        imageUrl: 'https://example.com/golden_group.jpg',
        isPrivate: false,
        memberCount: 1247,
        members: ['user1', 'user2', 'user3'],
        posts: ['post1', 'post2'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        language: 'en',
      ),
      CommunityGroup(
        id: '2',
        name: 'Cat Training Enthusiasts',
        description: 'Share cat training techniques, success stories, and help each other with training challenges.',
        category: 'Cat Care',
        creatorId: 'user2',
        creatorName: 'Mike Chen',
        tags: ['Cat Training', 'Cats', 'Behavior', 'Tips'],
        imageUrl: 'https://example.com/cat_training_group.jpg',
        isPrivate: false,
        memberCount: 892,
        members: ['user2', 'user3', 'user4'],
        posts: ['post2', 'post3'],
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        language: 'en',
      ),
      CommunityGroup(
        id: '3',
        name: 'Pet Health & Wellness',
        description: 'Professional advice and community support for pet health and wellness topics.',
        category: 'Health & Wellness',
        creatorId: 'user5',
        creatorName: 'Dr. Lisa Thompson',
        tags: ['Pet Health', 'Wellness', 'Veterinary', 'Care'],
        imageUrl: 'https://example.com/health_group.jpg',
        isPrivate: false,
        memberCount: 2156,
        members: ['user1', 'user2', 'user3', 'user4', 'user5'],
        posts: ['post1', 'post3'],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        language: 'en',
      ),
    ]);
  }

  void _initializeEvents() {
    _events.addAll([
      CommunityEvent(
        id: '1',
        title: 'Pet Wellness Workshop',
        description: 'Join us for a comprehensive workshop on pet wellness, nutrition, and preventive care.',
        eventType: 'Workshop',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 7, hours: 3)),
        location: 'Central Park Community Center',
        isOnline: false,
        maxParticipants: 50,
        participants: ['user1', 'user2', 'user3'],
        tags: ['Wellness', 'Workshop', 'Education', 'Pet Care'],
        imageUrl: 'https://example.com/wellness_workshop.jpg',
        organizerId: 'user5',
        organizerName: 'Dr. Lisa Thompson',
        eventColor: Colors.blue,
      ),
      CommunityEvent(
        id: '2',
        title: 'Virtual Pet Training Session',
        description: 'Online training session covering basic obedience commands and behavior modification.',
        eventType: 'Training',
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 3, hours: 2)),
        location: 'Online (Zoom)',
        isOnline: true,
        maxParticipants: 100,
        participants: ['user2', 'user4'],
        tags: ['Training', 'Online', 'Obedience', 'Behavior'],
        imageUrl: 'https://example.com/training_session.jpg',
        organizerId: 'user2',
        organizerName: 'Mike Chen',
        eventColor: Colors.green,
      ),
      CommunityEvent(
        id: '3',
        title: 'Pet Adoption Day',
        description: 'Help find loving homes for rescue pets. Meet adoptable pets and learn about adoption process.',
        eventType: 'Adoption',
        startDate: DateTime.now().add(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 14, hours: 6)),
        location: 'Local Animal Shelter',
        isOnline: false,
        maxParticipants: 200,
        participants: ['user1', 'user3', 'user5'],
        tags: ['Adoption', 'Rescue', 'Pet Care', 'Community'],
        imageUrl: 'https://example.com/adoption_day.jpg',
        organizerId: 'user3',
        organizerName: 'Emma Rodriguez',
        eventColor: Colors.orange,
      ),
    ]);
  }

  void _initializeExperts() {
    _experts.addAll([
      ExpertProfile(
        id: '1',
        name: 'Dr. Lisa Thompson',
        specialization: 'Veterinary Medicine',
        categories: ['Health & Wellness', 'Emergency Care', 'Preventive Medicine'],
        credentials: ['DVM', 'PhD in Veterinary Science'],
        experience: 15,
        rating: 4.9,
        reviewCount: 127,
        isVerified: true,
        verificationDate: DateTime.now().subtract(const Duration(days: 180)),
        verifierId: 'admin1',
        verificationNotes: 'Verified veterinary credentials and license',
        photoUrl: 'https://example.com/dr_lisa.jpg',
        bio: 'Experienced veterinarian with expertise in preventive care and emergency medicine.',
        languages: ['English', 'Spanish'],
        consultationFee: 150.0,
        availability: ['Monday', 'Wednesday', 'Friday'],
        contactInfo: {
          'email': 'dr.lisa@example.com',
          'phone': '+1-555-0123',
        },
      ),
      ExpertProfile(
        id: '2',
        name: 'Mike Chen',
        specialization: 'Cat Behavior & Training',
        categories: ['Cat Training', 'Behavior Modification', 'Enrichment'],
        credentials: ['Certified Cat Behaviorist', 'Feline Training Specialist'],
        experience: 8,
        rating: 4.8,
        reviewCount: 89,
        isVerified: true,
        verificationDate: DateTime.now().subtract(const Duration(days: 120)),
        verifierId: 'admin1',
        verificationNotes: 'Verified cat behaviorist certification',
        photoUrl: 'https://example.com/mike_expert.jpg',
        bio: 'Specialized in understanding cat behavior and developing effective training methods.',
        languages: ['English', 'Mandarin'],
        consultationFee: 75.0,
        availability: ['Tuesday', 'Thursday', 'Saturday'],
        contactInfo: {
          'email': 'mike.chen@example.com',
          'phone': '+1-555-0456',
        },
      ),
      ExpertProfile(
        id: '3',
        name: 'Sarah Johnson',
        specialization: 'Dog Training & Socialization',
        categories: ['Dog Training', 'Socialization', 'Behavior'],
        credentials: ['Certified Dog Trainer', 'Canine Behavior Specialist'],
        experience: 12,
        rating: 4.7,
        reviewCount: 156,
        isVerified: true,
        verificationDate: DateTime.now().subtract(const Duration(days: 90)),
        verifierId: 'admin1',
        verificationNotes: 'Verified dog training certification',
        photoUrl: 'https://example.com/sarah_expert.jpg',
        bio: 'Passionate about helping dogs and their owners build strong, positive relationships.',
        languages: ['English'],
        consultationFee: 85.0,
        availability: ['Monday', 'Tuesday', 'Thursday', 'Friday'],
        contactInfo: {
          'email': 'sarah.johnson@example.com',
          'phone': '+1-555-0789',
        },
      ),
    ]);
  }

  Color _getRandomEventColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }
}

// Additional models for social network features
class CommunityGroup {
  final String id;
  final String name;
  final String description;
  final String category;
  final String creatorId;
  final String creatorName;
  final List<String> tags;
  final String imageUrl;
  final bool isPrivate;
  int memberCount;
  final List<String> members;
  final List<String> posts;
  final DateTime createdAt;
  final String language;

  CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.creatorId,
    required this.creatorName,
    required this.tags,
    required this.imageUrl,
    required this.isPrivate,
    required this.memberCount,
    required this.members,
    required this.posts,
    required this.createdAt,
    required this.language,
  });

  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      creatorId: json['creatorId'],
      creatorName: json['creatorName'],
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      isPrivate: json['isPrivate'] ?? false,
      memberCount: json['memberCount'] ?? 0,
      members: List<String>.from(json['members'] ?? []),
      posts: List<String>.from(json['posts'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'tags': tags,
      'imageUrl': imageUrl,
      'isPrivate': isPrivate,
      'memberCount': memberCount,
      'members': members,
      'posts': posts,
      'createdAt': createdAt.toIso8601String(),
      'language': language,
    };
  }
}

class ExpertProfile {
  final String id;
  final String name;
  final String specialization;
  final List<String> categories;
  final List<String> credentials;
  final int experience;
  final double rating;
  final int reviewCount;
  bool isVerified;
  DateTime? verificationDate;
  String? verifierId;
  String? verificationNotes;
  final String photoUrl;
  final String bio;
  final List<String> languages;
  final double consultationFee;
  final List<String> availability;
  final Map<String, String> contactInfo;

  ExpertProfile({
    required this.id,
    required this.name,
    required this.specialization,
    required this.categories,
    required this.credentials,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    this.verificationDate,
    this.verifierId,
    this.verificationNotes,
    required this.photoUrl,
    required this.bio,
    required this.languages,
    required this.consultationFee,
    required this.availability,
    required this.contactInfo,
  });

  factory ExpertProfile.fromJson(Map<String, dynamic> json) {
    return ExpertProfile(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      categories: List<String>.from(json['categories'] ?? []),
      credentials: List<String>.from(json['credentials'] ?? []),
      experience: json['experience'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      verificationDate: json['verificationDate'] != null 
          ? DateTime.parse(json['verificationDate']) 
          : null,
      verifierId: json['verifierId'],
      verificationNotes: json['verificationNotes'],
      photoUrl: json['photoUrl'] ?? '',
      bio: json['bio'],
      languages: List<String>.from(json['languages'] ?? []),
      consultationFee: json['consultationFee']?.toDouble() ?? 0.0,
      availability: List<String>.from(json['availability'] ?? []),
      contactInfo: Map<String, String>.from(json['contactInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'categories': categories,
      'credentials': credentials,
      'experience': experience,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'verificationDate': verificationDate?.toIso8601String(),
      'verifierId': verifierId,
      'verificationNotes': verificationNotes,
      'photoUrl': photoUrl,
      'bio': bio,
      'languages': languages,
      'consultationFee': consultationFee,
      'availability': availability,
      'contactInfo': contactInfo,
    };
  }
}

class SocialSearchResult {
  final String query;
  List<SocialPost> posts;
  List<CommunityGroup> groups;
  List<CommunityEvent> events;
  List<ExpertProfile> experts;
  int totalResults;

  SocialSearchResult({
    required this.query,
    required this.posts,
    required this.groups,
    required this.events,
    required this.experts,
    required this.totalResults,
  });
}