import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/advanced_ai_service.dart';
import '../../../../shared/models/ai_models.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/auth_models.dart';
import '../../../../core/theme/app_theme.dart';

class VeterinaryAIScreen extends StatefulWidget {
  const VeterinaryAIScreen({super.key});

  @override
  State<VeterinaryAIScreen> createState() => _VeterinaryAIScreenState();
}

class _VeterinaryAIScreenState extends State<VeterinaryAIScreen>
    with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<VeterinaryAIResponse> _conversation = [];
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  String _selectedPetId = '';
  List<Pet> _userPets = [];
  User? _currentUser;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
    
    _initializeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Initialize mock data for demonstration
    _userPets = [
      Pet(
        id: 'pet1',
        name: 'Luna',
        type: 'Dog',
        breed: 'Golden Retriever',
        age: 3,
        weight: 25.5,
        ownerId: 'user1',
      ),
      Pet(
        id: 'pet2',
        name: 'Whiskers',
        type: 'Cat',
        breed: 'Domestic Shorthair',
        age: 2,
        weight: 4.2,
        ownerId: 'user1',
      ),
    ];
    
    _selectedPetId = _userPets.isNotEmpty ? _userPets.first.id : '';
    
    // Create demo user
    _currentUser = User(
      id: 'demo-user',
      email: 'demo@serenyx.com',
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
      emailVerified: true,
      pets: _userPets,
      profile: UserProfile(
        firstName: 'Demo',
        lastName: 'User',
        interests: ['Pet Care', 'Veterinary Medicine'],
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
        plan: 'premium',
        startDate: DateTime.now(),
        isActive: true,
        features: ['veterinary_ai', 'advanced_insights', 'behavioral_analysis'],
        monthlyPrice: 19.99,
        billingCycle: 'monthly',
      ),
    );

    // Add welcome message
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeResponse = VeterinaryAIResponse(
      id: 'welcome',
      question: '',
      answer: 'Hello! I\'m your AI veterinary assistant. I can help you with pet care questions, health concerns, and behavioral advice. What would you like to know about your pet?',
      confidence: 1.0,
      recommendations: ['Ask about nutrition', 'Get health advice', 'Discuss behavior concerns'],
      warnings: ['This is general advice. Always consult a veterinarian for serious concerns.'],
      language: _selectedLanguage,
      timestamp: DateTime.now(),
      petId: '',
      userId: _currentUser?.id ?? '',
    );
    
    setState(() {
      _conversation.add(welcomeResponse);
    });
  }

  Future<void> _askQuestion() async {
    if (_questionController.text.trim().isEmpty) return;
    if (_selectedPetId.isEmpty) {
      _showSnackBar('Please select a pet first');
      return;
    }

    final question = _questionController.text.trim();
    final selectedPet = _userPets.firstWhere((pet) => pet.id == _selectedPetId);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final aiService = context.read<AdvancedAIService>();
      final response = await aiService.getVeterinaryAdvice(
        question: question,
        pet: selectedPet,
        user: _currentUser!,
        language: _selectedLanguage,
        context: _conversation.map((r) => r.question).toList(),
      );

      setState(() {
        _conversation.add(response);
        _isLoading = false;
      });

      _questionController.clear();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error getting AI response: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Veterinary AI Assistant'),
        backgroundColor: AppTheme.colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSelector,
          ),
          IconButton(
            icon: const Icon(Icons.pets),
            onPressed: _showPetSelector,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Pet and Language Selector
            _buildSelectorBar(),
            
            // Conversation Area
            Expanded(
              child: _buildConversationArea(),
            ),
            
            // Input Area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pet Selector
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPetId.isNotEmpty ? _selectedPetId : null,
              decoration: const InputDecoration(
                labelText: 'Select Pet',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _userPets.map((pet) {
                return DropdownMenuItem(
                  value: pet.id,
                  child: Text('${pet.name} (${pet.type})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPetId = value ?? '';
                });
              },
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Language Selector
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'es', child: Text('Español')),
              DropdownMenuItem(value: 'fr', child: Text('Français')),
              DropdownMenuItem(value: 'de', child: Text('Deutsch')),
              DropdownMenuItem(value: 'ja', child: Text('日本語')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value ?? 'en';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConversationArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _conversation.length,
      itemBuilder: (context, index) {
        final response = _conversation[index];
        return _buildConversationBubble(response, index);
      },
    );
  }

  Widget _buildConversationBubble(VeterinaryAIResponse response, int index) {
    final isUser = response.question.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser) const Spacer(),
          
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUser ? AppTheme.colors.primary : AppTheme.colors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isUser ? Icons.person : Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Message Content
          Expanded(
            flex: isUser ? 0 : 1,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.colors.primary : AppTheme.colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question (if user message)
                  if (isUser) ...[
                    Text(
                      response.question,
                      style: AppTheme.textStyles.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Answer
                  Text(
                    response.answer,
                    style: AppTheme.textStyles.bodyMedium?.copyWith(
                      color: isUser ? Colors.white : AppTheme.colors.textPrimary,
                    ),
                  ),
                  
                  // Recommendations (if AI response)
                  if (!isUser && response.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Recommendations:',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...response.recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppTheme.colors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rec,
                              style: AppTheme.textStyles.bodySmall?.copyWith(
                                color: AppTheme.colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  
                  // Warnings (if AI response)
                  if (!isUser && response.warnings.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.colors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠️ Important:',
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: AppTheme.colors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...response.warnings.map((warning) => Text(
                            warning,
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: AppTheme.colors.warning,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                  
                  // Timestamp
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(response.timestamp),
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (!isUser) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: 'Ask about your pet\'s health, behavior, or care...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _askQuestion(),
            ),
          ),
          
          const SizedBox(width: 12),
          
          FloatingActionButton(
            onPressed: _isLoading ? null : _askQuestion,
            backgroundColor: AppTheme.colors.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.send),
          ),
        ],
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
      },
    );
  }

  void _showPetSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Pet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _userPets.map((pet) => ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.colors.primary,
              child: Text(
                pet.name[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(pet.name),
            subtitle: Text('${pet.breed} • ${pet.age} years old'),
            trailing: _selectedPetId == pet.id
                ? Icon(Icons.check, color: AppTheme.colors.primary)
                : null,
            onTap: () {
              setState(() {
                _selectedPetId = pet.id;
              });
              Navigator.pop(context);
            },
          )).toList(),
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
}