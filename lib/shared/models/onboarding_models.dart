enum OnboardingStepType {
  welcome,
  selection,
  input,
  ageInput,
  photoUpload,
  multiSelection,
  routineInput,
  rating,
  final,
}

class OnboardingStep {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final OnboardingStepType type;
  final String image;
  final bool showProgress;
  final List<String>? options;
  final String? inputHint;
  final int? maxSelections;
  final List<String>? ratingLabels;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    required this.image,
    required this.showProgress,
    this.options,
    this.inputHint,
    this.maxSelections,
    this.ratingLabels,
  });
}

class OnboardingData {
  final Map<String, dynamic> _data = {};

  // Pet Information
  String? get petType => _data['petType'];
  String? get petBreed => _data['petBreed'];
  String? get petName => _data['petName'];
  int? get petAge => _data['petAge'];
  List<String>? get petPhotos => _data['petPhotos'];

  // Goals and Challenges
  List<String>? get primaryGoals => _data['primaryGoals'];
  List<String>? get currentChallenges => _data['currentChallenges'];
  String? get dailyRoutine => _data['dailyRoutine'];

  // Mindfulness and Wellness
  List<String>? get mindfulnessPractices => _data['mindfulnessPractices'];
  int? get petHealthStatus => _data['petHealthStatus'];
  int? get ownerStressLevel => _data['ownerStressLevel'];

  // Lifestyle and Preferences
  String? get timeAvailability => _data['timeAvailability'];
  List<String>? get socialGoals => _data['socialGoals'];
  List<String>? get specialEvents => _data['specialEvents'];
  List<String>? get petPersonality => _data['petPersonality'];
  List<String>? get healthConcerns => _data['healthConcerns'];
  String? get lifestylePreference => _data['lifestylePreference'];
  int? get commitmentLevel => _data['commitmentLevel'];

  void updateData(String key, dynamic value) {
    _data[key] = value;
  }

  Map<String, dynamic> toJson() {
    return Map.from(_data);
  }

  void fromJson(Map<String, dynamic> json) {
    _data.clear();
    _data.addAll(json);
  }

  bool get isComplete {
    return _data.length >= 20; // All required fields filled
  }

  // Validation methods
  bool get hasPetInfo => petType != null && petBreed != null && petName != null && petAge != null;
  bool get hasGoals => primaryGoals != null && primaryGoals!.isNotEmpty;
  bool get hasChallenges => currentChallenges != null && currentChallenges!.isNotEmpty;
  bool get hasWellnessData => petHealthStatus != null && ownerStressLevel != null;
  bool get hasLifestyleData => timeAvailability != null && lifestylePreference != null;

  // Get summary for display
  Map<String, dynamic> getSummary() {
    return {
      'petInfo': {
        'type': petType,
        'breed': petBreed,
        'name': petName,
        'age': petAge,
      },
      'goals': primaryGoals,
      'challenges': currentChallenges,
      'wellness': {
        'petHealth': petHealthStatus,
        'ownerStress': ownerStressLevel,
      },
      'lifestyle': {
        'timeAvailable': timeAvailability,
        'preference': lifestylePreference,
        'commitment': commitmentLevel,
      },
    };
  }
}

class PetWellnessConsultation {
  final OnboardingData data;
  final DateTime createdAt;
  final String consultationId;

  PetWellnessConsultation({
    required this.data,
    required this.createdAt,
    required this.consultationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'consultationId': consultationId,
    };
  }

  factory PetWellnessConsultation.fromJson(Map<String, dynamic> json) {
    final data = OnboardingData();
    data.fromJson(json['data']);
    
    return PetWellnessConsultation(
      data: data,
      createdAt: DateTime.parse(json['createdAt']),
      consultationId: json['consultationId'],
    );
  }
}

class LifePlanSummary {
  final OnboardingData data;
  final List<String> recommendations;
  final List<String> nextSteps;
  final Map<String, dynamic> personalizedMetrics;

  LifePlanSummary({
    required this.data,
    required this.recommendations,
    required this.nextSteps,
    required this.personalizedMetrics,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'recommendations': recommendations,
      'nextSteps': nextSteps,
      'personalizedMetrics': personalizedMetrics,
    };
  }

  factory LifePlanSummary.fromJson(Map<String, dynamic> json) {
    final data = OnboardingData();
    data.fromJson(json['data']);
    
    return LifePlanSummary(
      data: data,
      recommendations: List<String>.from(json['recommendations']),
      nextSteps: List<String>.from(json['nextSteps']),
      personalizedMetrics: Map<String, dynamic>.from(json['personalizedMetrics']),
    );
  }
}

class OnboardingProgress {
  final int currentStep;
  final int totalSteps;
  final double completionPercentage;
  final bool canProceed;
  final List<String> validationErrors;

  OnboardingProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.completionPercentage,
    required this.canProceed,
    required this.validationErrors,
  });

  bool get isComplete => currentStep >= totalSteps;
  bool get hasErrors => validationErrors.isNotEmpty;
}