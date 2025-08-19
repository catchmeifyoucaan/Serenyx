import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/onboarding_models.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class OnboardingStepWidget extends StatefulWidget {
  final OnboardingStep step;
  final OnboardingData onboardingData;
  final Function(String, dynamic) onDataUpdate;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isLastStep;
  final bool isLoading;

  const OnboardingStepWidget({
    super.key,
    required this.step,
    required this.onboardingData,
    required this.onDataUpdate,
    required this.onNext,
    required this.onPrevious,
    required this.isLastStep,
    required this.isLoading,
  });

  @override
  State<OnboardingStepWidget> createState() => _OnboardingStepWidgetState();
}

class _OnboardingStepWidgetState extends State<OnboardingStepWidget> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _selectedOptions = [];
  int? _selectedRating;
  String? _selectedSingleOption;
  String? _routineText;
  int? _ageYears;
  int? _ageMonths;
  List<File> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _toggleValue = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    switch (widget.step.type) {
      case OnboardingStepType.input:
        if (widget.step.id == 3) { // Breed
          _textController.text = widget.onboardingData.petBreed ?? '';
        } else if (widget.step.id == 4) { // Name
          _textController.text = widget.onboardingData.petName ?? '';
        } else if (widget.step.id == 23) { // Preferred pet nickname
          _textController.text = widget.onboardingData.preferredPetNickname ?? '';
        }
        break;
      case OnboardingStepType.selection:
        if (widget.step.id == 2) { // Pet type
          _selectedSingleOption = widget.onboardingData.petType;
        } else if (widget.step.id == 13) { // Time availability
          _selectedSingleOption = widget.onboardingData.timeAvailability;
        } else if (widget.step.id == 18) { // Lifestyle
          _selectedSingleOption = widget.onboardingData.lifestylePreference;
        } else if (widget.step.id == 21) { // Caregiver title
          _selectedSingleOption = widget.onboardingData.caregiverTitle;
        } else if (widget.step.id == 26) { // Soundscape style
          _selectedSingleOption = widget.onboardingData.soundscapeStyle;
        }
        break;
      case OnboardingStepType.ageInput:
        // no-op
        break;
      case OnboardingStepType.photoUpload:
        // no-op
        break;
      case OnboardingStepType.multiSelection:
        if (widget.step.id == 7) {
          _selectedOptions.addAll(widget.onboardingData.primaryGoals ?? []);
        } else if (widget.step.id == 8) {
          _selectedOptions.addAll(widget.onboardingData.currentChallenges ?? []);
        } else if (widget.step.id == 10) {
          _selectedOptions.addAll(widget.onboardingData.mindfulnessPractices ?? []);
        } else if (widget.step.id == 14) {
          _selectedOptions.addAll(widget.onboardingData.socialGoals ?? []);
        } else if (widget.step.id == 15) {
          _selectedOptions.addAll(widget.onboardingData.specialEvents ?? []);
        } else if (widget.step.id == 16) {
          _selectedOptions.addAll(widget.onboardingData.petPersonality ?? []);
        } else if (widget.step.id == 17) {
          _selectedOptions.addAll(widget.onboardingData.healthConcerns ?? []);
        } else if (widget.step.id == 27) {
          _selectedOptions.addAll(widget.onboardingData.favoritePetSounds ?? []);
        } else if (widget.step.id == 29) {
          _selectedOptions.addAll(List<String>.from(widget.onboardingData.toJson()['preferredAIFeatures'] ?? []));
        } else if (widget.step.id == 30) {
          _selectedOptions.addAll(List<String>.from(widget.onboardingData.toJson()['preferredNotifications'] ?? []));
        }
        break;
      case OnboardingStepType.routineInput:
        _routineText = widget.onboardingData.dailyRoutine;
        break;
      case OnboardingStepType.rating:
        if (widget.step.id == 11) {
          _selectedRating = widget.onboardingData.petHealthStatus;
        } else if (widget.step.id == 12) {
          _selectedRating = widget.onboardingData.ownerStressLevel;
        } else if (widget.step.id == 19) {
          _selectedRating = widget.onboardingData.commitmentLevel;
        }
        break;
      case OnboardingStepType.toggle:
        if (widget.step.id == 22) {
          _toggleValue = widget.onboardingData.useNicknameInGreetings;
        } else if (widget.step.id == 24) {
          _toggleValue = widget.onboardingData.useNicknameInCommunity;
        } else if (widget.step.id == 25) {
          _toggleValue = widget.onboardingData.enableSoundscape;
        } else if (widget.step.id == 28) {
          _toggleValue = (widget.onboardingData.toJson()['optInBestPetVoting'] ?? true) as bool;
        }
        break;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (widget.step.type) {
      case OnboardingStepType.welcome:
      case OnboardingStepType.final:
        return true;
      case OnboardingStepType.selection:
        return _selectedSingleOption != null;
      case OnboardingStepType.input:
        return _textController.text.trim().isNotEmpty;
      case OnboardingStepType.ageInput:
        return _ageYears != null || _ageMonths != null;
      case OnboardingStepType.photoUpload:
        return _selectedPhotos.isNotEmpty;
      case OnboardingStepType.multiSelection:
        return _selectedOptions.isNotEmpty;
      case OnboardingStepType.routineInput:
        return _routineText != null && _routineText!.trim().isNotEmpty;
      case OnboardingStepType.rating:
        return _selectedRating != null;
      case OnboardingStepType.toggle:
        return true;
    }
  }

  void _saveData() {
    switch (widget.step.type) {
      case OnboardingStepType.selection:
        if (_selectedSingleOption != null) {
          _saveSingleSelection();
        }
        break;
      case OnboardingStepType.input:
        if (_textController.text.trim().isNotEmpty) {
          _saveTextInput();
        }
        break;
      case OnboardingStepType.ageInput:
        if (_ageYears != null || _ageMonths != null) {
          _saveAgeInput();
        }
        break;
      case OnboardingStepType.photoUpload:
        if (_selectedPhotos.isNotEmpty) {
          _savePhotoUpload();
        }
        break;
      case OnboardingStepType.multiSelection:
        if (_selectedOptions.isNotEmpty) {
          _saveMultiSelection();
        }
        break;
      case OnboardingStepType.routineInput:
        if (_routineText != null && _routineText!.trim().isNotEmpty) {
          _saveRoutineInput();
        }
        break;
      case OnboardingStepType.rating:
        if (_selectedRating != null) {
          _saveRating();
        }
        break;
      case OnboardingStepType.toggle:
        _saveToggle();
        break;
    }
  }

  void _saveSingleSelection() {
    switch (widget.step.id) {
      case 2: // Pet type
        widget.onDataUpdate('petType', _selectedSingleOption);
        break;
      case 13: // Time availability
        widget.onDataUpdate('timeAvailability', _selectedSingleOption);
        break;
      case 18: // Lifestyle
        widget.onDataUpdate('lifestylePreference', _selectedSingleOption);
        break;
      case 21: // Caregiver title
        widget.onDataUpdate('caregiverTitle', _selectedSingleOption);
        break;
      case 26: // Soundscape style
        widget.onDataUpdate('soundscapeStyle', _selectedSingleOption);
        break;
    }
  }

  void _saveTextInput() {
    switch (widget.step.id) {
      case 3: // Breed
        widget.onDataUpdate('petBreed', _textController.text.trim());
        break;
      case 4: // Name
        widget.onDataUpdate('petName', _textController.text.trim());
        break;
      case 23: // Preferred pet nickname
        widget.onDataUpdate('preferredPetNickname', _textController.text.trim());
        break;
    }
  }

  void _saveAgeInput() {
    final totalMonths = (_ageYears ?? 0) * 12 + (_ageMonths ?? 0);
    widget.onDataUpdate('petAge', totalMonths);
  }

  void _savePhotoUpload() {
    final photoPaths = _selectedPhotos.map((file) => file.path).toList();
    widget.onDataUpdate('petPhotos', photoPaths);
  }

  void _saveMultiSelection() {
    switch (widget.step.id) {
      case 7: // Goals
        widget.onDataUpdate('primaryGoals', List.from(_selectedOptions));
        break;
      case 8: // Challenges
        widget.onDataUpdate('currentChallenges', List.from(_selectedOptions));
        break;
      case 10: // Mindfulness
        widget.onDataUpdate('mindfulnessPractices', List.from(_selectedOptions));
        break;
      case 14: // Social goals
        widget.onDataUpdate('socialGoals', List.from(_selectedOptions));
        break;
      case 15: // Special events
        widget.onDataUpdate('specialEvents', List.from(_selectedOptions));
        break;
      case 16: // Personality
        widget.onDataUpdate('petPersonality', List.from(_selectedOptions));
        break;
      case 17: // Health concerns
        widget.onDataUpdate('healthConcerns', List.from(_selectedOptions));
        break;
      case 27: // Favorite pet sounds
        widget.onDataUpdate('favoritePetSounds', List.from(_selectedOptions));
        break;
      case 29: // AI features
        widget.onDataUpdate('preferredAIFeatures', List.from(_selectedOptions));
        break;
      case 30: // Notifications
        widget.onDataUpdate('preferredNotifications', List.from(_selectedOptions));
        break;
    }
  }

  void _saveRoutineInput() {
    widget.onDataUpdate('dailyRoutine', _routineText!.trim());
  }

  void _saveRating() {
    switch (widget.step.id) {
      case 11: // Health status
        widget.onDataUpdate('petHealthStatus', _selectedRating);
        break;
      case 12: // Stress level
        widget.onDataUpdate('ownerStressLevel', _selectedRating);
        break;
      case 19: // Commitment
        widget.onDataUpdate('commitmentLevel', _selectedRating);
        break;
    }
  }

  void _saveToggle() {
    switch (widget.step.id) {
      case 22:
        widget.onDataUpdate('useNicknameInGreetings', _toggleValue);
        break;
      case 24:
        widget.onDataUpdate('useNicknameInCommunity', _toggleValue);
        break;
      case 25:
        widget.onDataUpdate('enableSoundscape', _toggleValue);
        break;
      case 28:
        widget.onDataUpdate('optInBestPetVoting', _toggleValue);
        break;
    }
  }

  void _handleNext() {
    if (_canProceed) {
      _saveData();
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          const SizedBox(height: 32),

          // Content based on step type
          _buildStepContent(),

          const SizedBox(height: 32),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.step.title,
          style: AppTheme.textStyles.headlineMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Subtitle
        Text(
          widget.step.subtitle,
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Description
        Text(
          widget.step.description,
          style: AppTheme.textStyles.bodyLarge?.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.3);
  }

  Widget _buildStepContent() {
    switch (widget.step.type) {
      case OnboardingStepType.welcome:
        return _buildWelcomeContent();
      case OnboardingStepType.selection:
        return _buildSelectionContent();
      case OnboardingStepType.input:
        return _buildInputContent();
      case OnboardingStepType.ageInput:
        return _buildAgeInputContent();
      case OnboardingStepType.photoUpload:
        return _buildPhotoUploadContent();
      case OnboardingStepType.multiSelection:
        return _buildMultiSelectionContent();
      case OnboardingStepType.routineInput:
        return _buildRoutineInputContent();
      case OnboardingStepType.rating:
        return _buildRatingContent();
      case OnboardingStepType.final:
        return _buildFinalContent();
      case OnboardingStepType.toggle:
        return _buildToggleContent();
    }
  }

  Widget _buildWelcomeContent() {
    return Column(
      children: [
        if (widget.step.lottieAsset != null)
          SizedBox(
            width: 220,
            height: 220,
            child: Lottie.asset(widget.step.lottieAsset!),
          )
        else
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.pets,
              size: 100,
              color: AppTheme.colors.primary,
            ),
          ),

        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colors.outline),
          ),
          child: Column(
            children: [
              Icon(
                Icons.health_and_safety,
                size: 48,
                color: AppTheme.colors.success,
              ),
              const SizedBox(height: 16),
              Text(
                'Pet Wellness Consultation',
                style: AppTheme.textStyles.titleLarge?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll ask you 20 thoughtful questions to create a personalized wellness plan for your pet.',
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionContent() {
    return Column(
      children: [
        if (widget.step.lottieAsset != null)
          SizedBox(
            width: 180,
            height: 180,
            child: Lottie.asset(widget.step.lottieAsset!),
          )
        else if (widget.step.image.isNotEmpty)
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.colors.outline),
            ),
            child: Icon(
              Icons.image,
              size: 64,
              color: AppTheme.colors.textSecondary,
            ),
          ),

        const SizedBox(height: 24),

        ...widget.step.options!.map((option) =>
          _buildSelectionOption(option)
        ),
      ],
    );
  }

  Widget _buildSelectionOption(String option) {
    final isSelected = _selectedSingleOption == option;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSingleOption = option;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.colors.primary : AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.colors.primary : AppTheme.colors.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputContent() {
    return Column(
      children: [
        if (widget.step.lottieAsset != null)
          SizedBox(
            width: 160,
            height: 160,
            child: Lottie.asset(widget.step.lottieAsset!),
          )
        else if (widget.step.image.isNotEmpty)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.colors.outline),
            ),
            child: Icon(
              Icons.edit,
              size: 48,
              color: AppTheme.colors.primary,
            ),
          ),

        const SizedBox(height: 24),

        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: widget.step.inputHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppTheme.colors.surface,
            contentPadding: const EdgeInsets.all(20),
          ),
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildAgeInputContent() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colors.outline),
          ),
          child: Icon(
            Icons.cake,
            size: 48,
            color: AppTheme.colors.primary,
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Years',
                    style: AppTheme.textStyles.titleMedium?.copyWith(
                      color: AppTheme.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAgeSelector(
                    value: _ageYears,
                    onChanged: (value) {
                      setState(() {
                        _ageYears = value;
                      });
                    },
                    maxValue: 25,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            Expanded(
              child: Column(
                children: [
                  Text(
                    'Months',
                    style: AppTheme.textStyles.titleMedium?.copyWith(
                      color: AppTheme.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAgeSelector(
                    value: _ageMonths,
                    onChanged: (value) {
                      setState(() {
                        _ageMonths = value;
                      });
                    },
                    maxValue: 11,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeSelector({int? value, required Function(int?) onChanged, required int maxValue}) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colors.outline),
      ),
      child: ListWheelScrollView(
        itemExtent: 50,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        children: [
          for (int i = 0; i <= maxValue; i++)
            Center(
              child: Text(
                i.toString(),
                style: AppTheme.textStyles.titleLarge?.copyWith(
                  color: value == i ? AppTheme.colors.primary : AppTheme.colors.textSecondary,
                  fontWeight: value == i ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
        ],
        onSelectedItemChanged: (index) {
          onChanged(index);
        },
      ),
    );
  }

  Widget _buildPhotoUploadContent() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colors.outline),
          ),
          child: Icon(
            Icons.camera_alt,
            size: 48,
            color: AppTheme.colors.primary,
          ),
        ),

        const SizedBox(height: 24),

        if (_selectedPhotos.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _selectedPhotos.asMap().entries.map((entry) {
              final index = entry.key;
              final photo = entry.value;

              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(photo),
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
                          _selectedPhotos.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppTheme.colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
        ],

        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.add_a_photo),
          label: Text(_selectedPhotos.isEmpty ? 'Add Photos' : 'Add More Photos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.primary,
            foregroundColor: AppTheme.colors.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedPhotos.add(File(image.path));
      });
    }
  }

  Widget _buildMultiSelectionContent() {
    return Column(
      children: [
        if (widget.step.lottieAsset != null)
          SizedBox(
            width: 160,
            height: 160,
            child: Lottie.asset(widget.step.lottieAsset!),
          )
        else if (widget.step.image.isNotEmpty)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.colors.outline),
            ),
            child: Icon(
              Icons.checklist,
              size: 48,
              color: AppTheme.colors.primary,
            ),
          ),

        const SizedBox(height: 24),

        if (widget.step.maxSelections != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.colors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.colors.info),
            ),
            child: Text(
              'Select up to ${widget.step.maxSelections} options',
              style: AppTheme.textStyles.bodyMedium?.copyWith(
                color: AppTheme.colors.info,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 24),

        ...widget.step.options!.map((option) =>
          _buildMultiSelectionOption(option)
        ),
      ],
    );
  }

  Widget _buildMultiSelectionOption(String option) {
    final isSelected = _selectedOptions.contains(option);
    final canSelect = _selectedOptions.length < (widget.step.maxSelections ?? 999) || isSelected;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: canSelect ? () {
          setState(() {
            if (isSelected) {
              _selectedOptions.remove(option);
            } else {
              _selectedOptions.add(option);
            }
          });
        } : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.colors.primary : AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.colors.primary : AppTheme.colors.outline,
              width: isSelected ? 2 : 1,
            ),
            opacity: canSelect ? 1.0 : 0.5,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineInputContent() {
    return Column(
      children: [
        if (widget.step.lottieAsset != null)
          SizedBox(
            width: 140,
            height: 140,
            child: Lottie.asset(widget.step.lottieAsset!),
          )
        else
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.colors.outline),
            ),
            child: Icon(
              Icons.schedule,
              size: 48,
              color: AppTheme.colors.primary,
            ),
          ),

        const SizedBox(height: 24),

        TextField(
          onChanged: (value) {
            setState(() {
              _routineText = value;
            });
          },
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe your pet\'s typical daily routine...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppTheme.colors.surface,
            contentPadding: const EdgeInsets.all(20),
          ),
          style: AppTheme.textStyles.bodyLarge?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingContent() {
    return Column(
      children: [
        if (widget.step.lottieAsset != null)
          SizedBox(
            width: 140,
            height: 140,
            child: Lottie.asset(widget.step.lottieAsset!),
          )
        else
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.colors.outline),
            ),
            child: Icon(
              Icons.star_rate,
              size: 48,
              color: AppTheme.colors.primary,
            ),
          ),

        const SizedBox(height: 24),

        Text(
          'Rate from 1 to 5',
          style: AppTheme.textStyles.titleMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = _selectedRating == rating;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = rating;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.colors.primary : AppTheme.colors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? AppTheme.colors.primary : AppTheme.colors.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textSecondary,
                      size: 24,
                    ),
                    Text(
                      rating.toString(),
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: isSelected ? AppTheme.colors.onPrimary : AppTheme.colors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        if (_selectedRating != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.colors.primary),
            ),
            child: Text(
              widget.step.ratingLabels![_selectedRating! - 1],
              style: AppTheme.textStyles.titleMedium?.copyWith(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildFinalContent() {
    return Column(
      children: [
        if (widget.step.lottieAsset != null)
          SizedBox(
            width: 180,
            height: 180,
            child: Lottie.asset(widget.step.lottieAsset!),
          )
        else
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.colors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Icon(
              Icons.celebration,
              size: 80,
              color: AppTheme.colors.success,
            ),
          ),

        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.colors.outline),
          ),
          child: Column(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppTheme.colors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Creating Your Pet Life Plan',
                style: AppTheme.textStyles.titleLarge?.copyWith(
                  color: AppTheme.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'re analyzing your responses to create a comprehensive, personalized wellness plan.',
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleContent() {
    return Column(
      children: [
        if (widget.step.lottieAsset != null)
          SizedBox(
            width: 140,
            height: 140,
            child: Lottie.asset(widget.step.lottieAsset!),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.colors.outline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.step.title,
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    color: AppTheme.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: _toggleValue,
                activeColor: AppTheme.colors.primary,
                onChanged: (val) {
                  setState(() {
                    _toggleValue = val;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Previous Button
        if (widget.step.id > 1)
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onPrevious,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.colors.primary,
                side: BorderSide(color: AppTheme.colors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Previous'),
            ),
          ),

        if (widget.step.id > 1) const SizedBox(width: 16),

        // Next/Complete Button
        Expanded(
          child: ElevatedButton(
            onPressed: _canProceed ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: AppTheme.colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(widget.isLastStep ? 'Create Plan' : 'Continue'),
          ),
        ),
      ],
    );
  }
}