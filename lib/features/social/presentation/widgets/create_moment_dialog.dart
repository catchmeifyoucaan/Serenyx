import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/services/pet_service.dart';
import '../../../../shared/models/pet.dart';
import '../screens/social_feed_screen.dart';

class CreateMomentDialog extends StatefulWidget {
  const CreateMomentDialog({super.key});

  @override
  State<CreateMomentDialog> createState() => _CreateMomentDialogState();
}

class _CreateMomentDialogState extends State<CreateMomentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final PetService _petService = PetService();
  
  Pet? _selectedPet;
  List<Pet> _pets = [];
  String? _selectedMood;
  List<String> _selectedTags = [];
  
  final List<String> _moods = [
    'overjoyed',
    'happy',
    'content',
    'calm',
    'peaceful',
  ];
  
  final List<String> _availableTags = [
    'cuddles',
    'playtime',
    'training',
    'bonding',
    'discovery',
    'adventure',
    'relaxation',
    'love',
    'friendship',
    'growth',
  ];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    try {
      await _petService.initialize();
      setState(() {
        _pets = _petService.pets;
        if (_pets.isNotEmpty) {
          _selectedPet = _pets.first;
        }
      });
    } catch (e) {
      print('Error loading pets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: AppTheme.gentleCream,
          borderRadius: BorderRadius.circular(AppConstants.lgRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.warmGrey.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.lgSpacing),
              decoration: BoxDecoration(
                color: AppTheme.heartPink,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.lgRadius),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo,
                      color: AppTheme.heartPink,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppConstants.mdSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share a Moment',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Capture and share your special time together',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.lgSpacing),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Selection
                      _buildPetSelector(),
                      
                      const SizedBox(height: AppConstants.mdSpacing),
                      
                      // Content Field
                      _buildContentField(),
                      
                      const SizedBox(height: AppConstants.mdSpacing),
                      
                      // Mood Selection
                      _buildMoodSelector(),
                      
                      const SizedBox(height: AppConstants.mdSpacing),
                      
                      // Tags Selection
                      _buildTagsSelector(),
                      
                      const SizedBox(height: AppConstants.xlSpacing),
                      
                      // Action Buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .scale(begin: const Offset(0.8, 0.8), duration: AppConstants.mediumAnimation);
  }

  Widget _buildPetSelector() {
    if (_pets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.mdSpacing),
        decoration: BoxDecoration(
          color: AppTheme.softPink.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
          border: Border.all(color: AppTheme.softPink),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.heartPink),
            const SizedBox(width: AppConstants.smSpacing),
            Expanded(
              child: Text(
                'No pets found. Add a pet first to share moments!',
                style: TextStyle(color: AppTheme.warmGrey),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share with',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _pets.length,
            itemBuilder: (context, index) {
              final pet = _pets[index];
              final isSelected = _selectedPet?.id == pet.id;
              
              return Container(
                margin: const EdgeInsets.only(right: AppConstants.smSpacing),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPet = pet;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.mdSpacing,
                      vertical: AppConstants.smSpacing,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.heartPink : AppTheme.softPink.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                      border: Border.all(
                        color: isSelected ? AppTheme.heartPink : AppTheme.softPink,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _getPetColor(pet),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pets,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppConstants.smSpacing),
                        Text(
                          pet.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.warmGrey,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s happening?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        TextFormField(
          controller: _contentController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Share your special moment with your pet...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mdRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mdRadius),
              borderSide: BorderSide(color: AppTheme.heartPink, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please share what\'s happening';
            }
            if (value.trim().length < 10) {
              return 'Please share a bit more detail (at least 10 characters)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _moods.length,
            itemBuilder: (context, index) {
              final mood = _moods[index];
              final isSelected = _selectedMood == mood;
              
              return Container(
                margin: const EdgeInsets.only(right: AppConstants.smSpacing),
                child: ChoiceChip(
                  label: Text(mood.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = selected ? mood : null;
                    });
                  },
                  selectedColor: AppTheme.leafGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.warmGrey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add tags (optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        Wrap(
          spacing: AppConstants.xsSpacing,
          runSpacing: AppConstants.xsSpacing,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            
            return FilterChip(
              label: Text('#$tag'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              selectedColor: AppTheme.softPink,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.warmGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.mdSpacing),
              side: BorderSide(color: AppTheme.warmGrey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.xlRadius),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.warmGrey),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.mdSpacing),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _canCreateMoment() ? _createMoment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.heartPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppConstants.mdSpacing),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.xlRadius),
              ),
            ),
            child: Text(
              'Share Moment',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  bool _canCreateMoment() {
    return _selectedPet != null && 
           _contentController.text.trim().isNotEmpty &&
           _contentController.text.trim().length >= 10;
  }

  void _createMoment() {
    if (_formKey.currentState!.validate() && _selectedPet != null) {
      final now = DateTime.now();
      final moment = PetMoment(
        id: 'moment-${now.millisecondsSinceEpoch}',
        userId: 'user-${_selectedPet!.ownerId}',
        userName: 'Pet Parent',
        userAvatar: 'https://via.placeholder.com/50',
        petName: _selectedPet!.name,
        petType: _selectedPet!.type,
        content: _contentController.text.trim(),
        imageUrl: null,
        likes: 0,
        comments: 0,
        timestamp: now,
        tags: [
          if (_selectedMood != null) _selectedMood!,
          ..._selectedTags,
          _selectedPet!.type.toLowerCase(),
          'serenyx',
        ],
      );
      
      Navigator.pop(context, moment);
    }
  }

  Color _getPetColor(Pet pet) {
    final hash = pet.id.hashCode;
    final colors = [
      AppTheme.heartPink,
      AppTheme.leafGreen,
      AppTheme.softPurple,
      AppTheme.lightPink,
      AppTheme.pastelPeach,
    ];
    
    return colors[hash.abs() % colors.length];
  }
}