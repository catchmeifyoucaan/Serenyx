import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ai_models.dart';
import '../models/auth_models.dart';

enum AIModel {
  gpt5,
  gpt4,
  gpt35Turbo,
  gemini25Flash,
  geminiPro,
  claude3,
  claude3Sonnet,
  claude3Haiku,
}

enum AIFeature {
  emotionRecognition,
  behavioralPrediction,
  healthAnalysis,
  trainingRecommendations,
  nutritionAdvice,
  exercisePlanning,
  socializationGuidance,
  mindfulnessExercises,
  emergencyAssessment,
  breedSpecificInsights,
}

class AIService {
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';
  static const String _googleBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _anthropicBaseUrl = 'https://api.anthropic.com/v1';
  
  // API Keys (should be stored securely in production)
  static const String _openaiApiKey = 'YOUR_OPENAI_API_KEY';
  static const String _googleApiKey = 'YOUR_GOOGLE_API_KEY';
  static const String _anthropicApiKey = 'YOUR_ANTHROPIC_API_KEY';

  // Model configurations
  static const Map<AIModel, Map<String, dynamic>> _modelConfigs = {
    AIModel.gpt5: {
      'name': 'gpt-5',
      'maxTokens': 4096,
      'temperature': 0.7,
      'provider': 'openai',
    },
    AIModel.gpt4: {
      'name': 'gpt-4',
      'maxTokens': 8192,
      'temperature': 0.7,
      'provider': 'openai',
    },
    AIModel.gpt35Turbo: {
      'name': 'gpt-3.5-turbo',
      'maxTokens': 4096,
      'temperature': 0.7,
      'provider': 'openai',
    },
    AIModel.gemini25Flash: {
      'name': 'gemini-2.0-flash-exp',
      'maxTokens': 8192,
      'temperature': 0.7,
      'provider': 'google',
    },
    AIModel.geminiPro: {
      'name': 'gemini-1.5-pro',
      'maxTokens': 8192,
      'temperature': 0.7,
      'provider': 'google',
    },
    AIModel.claude3: {
      'name': 'claude-3-opus-20240229',
      'maxTokens': 4096,
      'temperature': 0.7,
      'provider': 'anthropic',
    },
    AIModel.claude3Sonnet: {
      'name': 'claude-3-sonnet-20240229',
      'maxTokens': 4096,
      'temperature': 0.7,
      'provider': 'anthropic',
    },
    AIModel.claude3Haiku: {
      'name': 'claude-3-haiku-20240307',
      'maxTokens': 4096,
      'temperature': 0.7,
      'provider': 'anthropic',
    },
  };

  // Feature-specific model recommendations
  static const Map<AIFeature, List<AIModel>> _featureModelMapping = {
    AIFeature.emotionRecognition: [AIModel.gpt5, AIModel.gemini25Flash, AIModel.claude3],
    AIFeature.behavioralPrediction: [AIModel.gpt5, AIModel.geminiPro, AIModel.claude3Sonnet],
    AIFeature.healthAnalysis: [AIModel.gpt5, AIModel.gemini25Flash, AIModel.claude3],
    AIFeature.trainingRecommendations: [AIModel.gpt4, AIModel.geminiPro, AIModel.claude3Sonnet],
    AIFeature.nutritionAdvice: [AIModel.gpt4, AIModel.gemini25Flash, AIModel.claude3Haiku],
    AIFeature.exercisePlanning: [AIModel.gpt35Turbo, AIModel.gemini25Flash, AIModel.claude3Haiku],
    AIFeature.socializationGuidance: [AIModel.gpt4, AIModel.geminiPro, AIModel.claude3Sonnet],
    AIFeature.mindfulnessExercises: [AIModel.gpt5, AIModel.gemini25Flash, AIModel.claude3],
    AIFeature.emergencyAssessment: [AIModel.gpt5, AIModel.gemini25Flash, AIModel.claude3],
    AIFeature.breedSpecificInsights: [AIModel.gpt4, AIModel.geminiPro, AIModel.claude3Sonnet],
  };

  /// Analyze pet emotions from uploaded images
  Future<EmotionAnalysis> analyzePetEmotion({
    required File imageFile,
    required Pet pet,
    required User user,
    AIModel? preferredModel,
  }) async {
    try {
      final model = preferredModel ?? _getBestModelForFeature(AIFeature.emotionRecognition);
      final prompt = _buildEmotionAnalysisPrompt(pet, user);
      
      final result = await _processWithAI(
        model: model,
        prompt: prompt,
        imageFile: imageFile,
        feature: AIFeature.emotionRecognition,
      );

      return _parseEmotionAnalysis(result, pet);
    } catch (e) {
      throw AIException('Failed to analyze pet emotion: $e');
    }
  }

  /// Predict behavioral patterns and future behaviors
  Future<BehavioralPrediction> predictPetBehavior({
    required Pet pet,
    required User user,
    required List<BehavioralPattern> historicalPatterns,
    AIModel? preferredModel,
  }) async {
    try {
      final model = preferredModel ?? _getBestModelForFeature(AIFeature.behavioralPrediction);
      final prompt = _buildBehaviorPredictionPrompt(pet, user, historicalPatterns);
      
      final result = await _processWithAI(
        model: model,
        prompt: prompt,
        feature: AIFeature.behavioralPrediction,
      );

      return _parseBehaviorPrediction(result, pet);
    } catch (e) {
      throw AIException('Failed to predict pet behavior: $e');
    }
  }

  /// Analyze pet health from images and data
  Future<HealthAnalysis> analyzePetHealth({
    required Pet pet,
    required User user,
    required List<File> healthImages,
    required Map<String, dynamic> healthData,
    AIModel? preferredModel,
  }) async {
    try {
      final model = preferredModel ?? _getBestModelForFeature(AIFeature.healthAnalysis);
      final prompt = _buildHealthAnalysisPrompt(pet, user, healthData);
      
      final result = await _processWithAI(
        model: model,
        prompt: prompt,
        imageFiles: healthImages,
        feature: AIFeature.healthAnalysis,
      );

      return _parseHealthAnalysis(result, pet);
    } catch (e) {
      throw AIException('Failed to analyze pet health: $e');
    }
  }

  /// Generate personalized training recommendations
  Future<List<TrainingRecommendation>> generateTrainingRecommendations({
    required Pet pet,
    required User user,
    required List<String> goals,
    required List<String> challenges,
    AIModel? preferredModel,
  }) async {
    try {
      final model = preferredModel ?? _getBestModelForFeature(AIFeature.trainingRecommendations);
      final prompt = _buildTrainingPrompt(pet, user, goals, challenges);
      
      final result = await _processWithAI(
        model: model,
        prompt: prompt,
        feature: AIFeature.trainingRecommendations,
      );

      return _parseTrainingRecommendations(result);
    } catch (e) {
      throw AIException('Failed to generate training recommendations: $e');
    }
  }

  /// Create personalized mindfulness exercises
  Future<List<MindfulnessExercise>> generateMindfulnessExercises({
    required Pet pet,
    required User user,
    required String focusArea,
    required int duration,
    AIModel? preferredModel,
  }) async {
    try {
      final model = preferredModel ?? _getBestModelForFeature(AIFeature.mindfulnessExercises);
      final prompt = _buildMindfulnessPrompt(pet, user, focusArea, duration);
      
      final result = await _processWithAI(
        model: model,
        prompt: prompt,
        feature: AIFeature.mindfulnessExercises,
      );

      return _parseMindfulnessExercises(result);
    } catch (e) {
      throw AIException('Failed to generate mindfulness exercises: $e');
    }
  }

  /// Emergency health assessment
  Future<EmergencyAssessment> assessEmergency({
    required Pet pet,
    required User user,
    required String symptoms,
    required List<File>? images,
    AIModel? preferredModel,
  }) async {
    try {
      final model = preferredModel ?? _getBestModelForFeature(AIFeature.emergencyAssessment);
      final prompt = _buildEmergencyPrompt(pet, user, symptoms);
      
      final result = await _processWithAI(
        model: model,
        prompt: prompt,
        imageFiles: images,
        feature: AIFeature.emergencyAssessment,
      );

      return _parseEmergencyAssessment(result);
    } catch (e) {
      throw AIException('Failed to assess emergency: $e');
    }
  }

  /// Get breed-specific insights and recommendations
  Future<BreedInsights> getBreedInsights({
    required Pet pet,
    required User user,
    required String breed,
    AIModel? preferredModel,
  }) async {
    try {
      final model = preferredModel ?? _getBestModelForFeature(AIFeature.breedSpecificInsights);
      final prompt = _buildBreedInsightsPrompt(pet, user, breed);
      
      final result = await _processWithAI(
        model: model,
        prompt: prompt,
        feature: AIFeature.breedSpecificInsights,
      );

      return _parseBreedInsights(result, breed);
    } catch (e) {
      throw AIException('Failed to get breed insights: $e');
    }
  }

  /// Process AI request with the specified model
  Future<String> _processWithAI({
    required AIModel model,
    required String prompt,
    File? imageFile,
    List<File>? imageFiles,
    required AIFeature feature,
  }) async {
    final config = _modelConfigs[model]!;
    final provider = config['provider'] as String;

    switch (provider) {
      case 'openai':
        return await _processWithOpenAI(model, prompt, imageFile, imageFiles);
      case 'google':
        return await _processWithGoogle(model, prompt, imageFile, imageFiles);
      case 'anthropic':
        return await _processWithAnthropic(model, prompt, imageFile, imageFiles);
      default:
        throw AIException('Unsupported AI provider: $provider');
    }
  }

  /// Process with OpenAI models (GPT-5, GPT-4, GPT-3.5)
  Future<String> _processWithOpenAI(
    AIModel model,
    String prompt,
    File? imageFile,
    List<File>? imageFiles,
  ) async {
    final config = _modelConfigs[model]!;
    final modelName = config['name'] as String;
    
    final headers = {
      'Authorization': 'Bearer $_openaiApiKey',
      'Content-Type': 'application/json',
    };

    final messages = [
      {
        'role': 'system',
        'content': 'You are an expert pet wellness AI assistant. Provide helpful, accurate, and compassionate advice for pet owners.',
      },
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text': prompt,
          },
          if (imageFile != null)
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,${base64Encode(imageFile.readAsBytesSync())}',
              },
            },
          if (imageFiles != null)
            ...imageFiles.map((file) => {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,${base64Encode(file.readAsBytesSync())}',
              },
            }),
        ],
      },
    ];

    final body = {
      'model': modelName,
      'messages': messages,
      'max_tokens': config['maxTokens'],
      'temperature': config['temperature'],
    };

    final response = await http.post(
      Uri.parse('$_openaiBaseUrl/chat/completions'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw AIException('OpenAI API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Process with Google models (Gemini 2.5 Flash, Gemini Pro)
  Future<String> _processWithGoogle(
    AIModel model,
    String prompt,
    File? imageFile,
    List<File>? imageFiles,
  ) async {
    final config = _modelConfigs[model]!;
    final modelName = config['name'] as String;
    
    final headers = {
      'Content-Type': 'application/json',
    };

    final contents = [
      {
        'parts': [
          {
            'text': prompt,
          },
          if (imageFile != null)
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Encode(imageFile.readAsBytesSync()),
              },
            },
          if (imageFiles != null)
            ...imageFiles.map((file) => {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Encode(file.readAsBytesSync()),
              },
            }),
        ],
      },
    ];

    final body = {
      'contents': contents,
      'generationConfig': {
        'maxOutputTokens': config['maxTokens'],
        'temperature': config['temperature'],
      },
    };

    final response = await http.post(
      Uri.parse('$_googleBaseUrl/models/$modelName:generateContent?key=$_googleApiKey'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw AIException('Google API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Process with Anthropic models (Claude 3 Opus, Sonnet, Haiku)
  Future<String> _processWithAnthropic(
    AIModel model,
    String prompt,
    File? imageFile,
    List<File>? imageFiles,
  ) async {
    final config = _modelConfigs[model]!;
    final modelName = config['name'] as String;
    
    final headers = {
      'x-api-key': _anthropicApiKey,
      'Content-Type': 'application/json',
      'anthropic-version': '2023-06-01',
    };

    final content = [
      {
        'type': 'text',
        'text': prompt,
      },
      if (imageFile != null)
        {
          'type': 'image',
          'source': {
            'type': 'base64',
            'media_type': 'image/jpeg',
            'data': base64Encode(imageFile.readAsBytesSync()),
          },
        },
      if (imageFiles != null)
        ...imageFiles.map((file) => {
          'type': 'image',
          'source': {
            'type': 'base64',
            'media_type': 'image/jpeg',
            'data': base64Encode(file.readAsBytesSync()),
          },
        }),
    ];

    final body = {
      'model': modelName,
      'max_tokens': config['maxTokens'],
      'messages': [
        {
          'role': 'user',
          'content': content,
        },
      ],
    };

    final response = await http.post(
      Uri.parse('$_anthropicBaseUrl/messages'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'];
    } else {
      throw AIException('Anthropic API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Get the best model for a specific feature
  AIModel _getBestModelForFeature(AIFeature feature) {
    final models = _featureModelMapping[feature] ?? [AIModel.gpt4];
    return models.first; // Return the first (best) model for the feature
  }

  /// Build prompts for different AI features
  String _buildEmotionAnalysisPrompt(Pet pet, User user) {
    return '''
    Analyze the emotional state of ${pet.name}, a ${pet.breed} ${pet.type.toLowerCase()}.
    
    Pet Details:
    - Name: ${pet.name}
    - Age: ${pet.age} months
    - Breed: ${pet.breed}
    - Type: ${pet.type}
    
    Owner Context:
    - Owner: ${user.profile.fullName}
    - Location: ${user.profile.location ?? 'Unknown'}
    
    Please analyze the uploaded image and provide:
    1. Primary emotion detected
    2. Confidence level (0-100%)
    3. Behavioral indicators
    4. Recommendations for the owner
    5. Any concerns to watch for
    
    Be specific, compassionate, and actionable in your analysis.
    ''';
  }

  String _buildBehaviorPredictionPrompt(
    Pet pet,
    User user,
    List<BehavioralPattern> patterns,
  ) {
    return '''
    Predict future behavioral patterns for ${pet.name}, a ${pet.breed} ${pet.type.toLowerCase()}.
    
    Pet Details:
    - Name: ${pet.name}
    - Age: ${pet.age} months
    - Breed: ${pet.breed}
    - Type: ${pet.type}
    
    Historical Patterns:
    ${patterns.map((p) => '- ${p.pattern}: ${p.description}').join('\n')}
    
    Owner Context:
    - Owner: ${user.profile.fullName}
    - Lifestyle: ${user.preferences.aiPreferences.preferredModel}
    
    Please provide:
    1. Predicted behaviors for the next 24-48 hours
    2. Triggers and patterns to watch for
    3. Recommendations for positive reinforcement
    4. Potential challenges and solutions
    5. Optimal timing for activities
    
    Base predictions on breed characteristics, age, and historical patterns.
    ''';
  }

  String _buildHealthAnalysisPrompt(
    Pet pet,
    User user,
    Map<String, dynamic> healthData,
  ) {
    return '''
    Analyze the health status of ${pet.name}, a ${pet.breed} ${pet.type.toLowerCase()}.
    
    Pet Details:
    - Name: ${pet.name}
    - Age: ${pet.age} months
    - Breed: ${pet.breed}
    - Type: ${pet.type}
    
    Health Data:
    ${healthData.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}
    
    Owner Context:
    - Owner: ${user.profile.fullName}
    - Location: ${user.profile.location ?? 'Unknown'}
    
    Please provide:
    1. Overall health assessment
    2. Areas of concern
    3. Recommendations for improvement
    4. Preventive measures
    5. When to consult a veterinarian
    
    Be thorough but accessible in your analysis.
    ''';
  }

  String _buildTrainingPrompt(
    Pet pet,
    User user,
    List<String> goals,
    List<String> challenges,
  ) {
    return '''
    Generate personalized training recommendations for ${pet.name}, a ${pet.breed} ${pet.type.toLowerCase()}.
    
    Pet Details:
    - Name: ${pet.name}
    - Age: ${pet.age} months
    - Breed: ${pet.breed}
    - Type: ${pet.type}
    
    Training Goals:
    ${goals.map((g) => '- $g').join('\n')}
    
    Current Challenges:
    ${challenges.map((c) => '- $c').join('\n')}
    
    Owner Context:
    - Owner: ${user.profile.fullName}
    - Experience Level: ${user.preferences.aiPreferences.preferredModel}
    
    Please provide:
    1. Step-by-step training plan
    2. Recommended techniques for this breed
    3. Solutions for specific challenges
    4. Timeline expectations
    5. Positive reinforcement strategies
    
    Make recommendations age-appropriate and breed-specific.
    ''';
  }

  String _buildMindfulnessPrompt(
    Pet pet,
    User user,
    String focusArea,
    int duration,
  ) {
    return '''
    Create mindfulness exercises for ${user.profile.fullName} and ${pet.name}, a ${pet.breed} ${pet.type.toLowerCase()}.
    
    Focus Area: $focusArea
    Duration: $duration minutes
    Pet: ${pet.name} (${pet.age} months old)
    
    Owner Context:
    - Name: ${user.profile.fullName}
    - Interests: ${user.profile.interests.join(', ')}
    - Location: ${user.profile.location ?? 'Unknown'}
    
    Please provide:
    1. Guided mindfulness exercise
    2. Pet bonding activities
    3. Breathing techniques
    4. Environmental setup
    5. Benefits for both owner and pet
    
    Make exercises practical and enjoyable for both human and pet.
    ''';
  }

  String _buildEmergencyPrompt(Pet pet, User user, String symptoms) {
    return '''
    Assess emergency situation for ${pet.name}, a ${pet.breed} ${pet.type.toLowerCase()}.
    
    Pet Details:
    - Name: ${pet.name}
    - Age: ${pet.age} months
    - Breed: ${pet.breed}
    - Type: ${pet.type}
    
    Symptoms: $symptoms
    
    Owner Context:
    - Owner: ${user.profile.fullName}
    - Location: ${user.profile.location ?? 'Unknown'}
    
    Please provide:
    1. Emergency level assessment (Low/Medium/High/Critical)
    2. Immediate actions to take
    3. When to seek veterinary care
    4. Signs of worsening
    5. Preventive measures for future
    
    Be clear about urgency and when professional help is needed.
    ''';
  }

  String _buildBreedInsightsPrompt(Pet pet, User user, String breed) {
    return '''
    Provide breed-specific insights for $breed ${pet.type.toLowerCase()}s.
    
    Pet Details:
    - Name: ${pet.name}
    - Age: ${pet.age} months
    - Breed: $breed
    - Type: ${pet.type}
    
    Owner Context:
    - Owner: ${user.profile.fullName}
    - Experience Level: ${user.preferences.aiPreferences.preferredModel}
    
    Please provide:
    1. Breed characteristics and temperament
    2. Health considerations for this breed
    3. Exercise and training needs
    4. Grooming requirements
    5. Common behavioral traits
    6. Tips for this specific breed
    
    Make insights practical and actionable for the owner.
    ''';
  }

  // Parse AI responses into structured data
  EmotionAnalysis _parseEmotionAnalysis(String response, Pet pet) {
    // Parse AI response and create EmotionAnalysis object
    // This is a simplified parser - in production, you'd want more robust parsing
    return EmotionAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: pet.id,
      emotion: PetEmotion.happy, // Parse from response
      confidence: 0.85, // Parse from response
      timestamp: DateTime.now(),
      description: response,
      recommendations: ['Continue positive interactions', 'Monitor for changes'],
    );
  }

  BehavioralPrediction _parseBehaviorPrediction(String response, Pet pet) {
    return BehavioralPrediction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: pet.id,
      behavior: 'Predicted behavior based on AI analysis',
      probability: 0.8,
      timeframe: DateTime.now().add(const Duration(hours: 2)),
      confidence: 0.75,
      timestamp: DateTime.now(),
      recommendations: ['Follow AI recommendations', 'Monitor behavior patterns'],
      riskLevel: RiskLevel.low,
    );
  }

  HealthAnalysis _parseHealthAnalysis(String response, Pet pet) {
    return HealthAnalysis(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: pet.id,
      overallHealth: 'Good',
      concerns: ['None detected'],
      recommendations: ['Continue current care routine'],
      timestamp: DateTime.now(),
      confidence: 0.8,
    );
  }

  List<TrainingRecommendation> _parseTrainingRecommendations(String response) {
    return [
      TrainingRecommendation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'AI-Generated Training Plan',
        description: response,
        difficulty: 'Beginner',
        estimatedDuration: '2 weeks',
        steps: ['Follow AI recommendations', 'Practice daily', 'Monitor progress'],
      ),
    ];
  }

  List<MindfulnessExercise> _parseMindfulnessExercises(String response) {
    return [
      MindfulnessExercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'AI-Generated Mindfulness Session',
        description: response,
        duration: 10,
        focusArea: 'Pet Bonding',
        steps: ['Follow AI guidance', 'Create peaceful environment', 'Practice with pet'],
      ),
    ];
  }

  EmergencyAssessment _parseEmergencyAssessment(String response) {
    return EmergencyAssessment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      emergencyLevel: 'Low',
      immediateActions: ['Monitor symptoms', 'Follow AI recommendations'],
      whenToSeekHelp: 'If symptoms worsen',
      timestamp: DateTime.now(),
      confidence: 0.8,
    );
  }

  BreedInsights _parseBreedInsights(String response, String breed) {
    return BreedInsights(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      breed: breed,
      characteristics: response,
      healthConsiderations: ['Regular checkups', 'Breed-specific monitoring'],
      exerciseNeeds: 'Moderate',
      groomingRequirements: 'Regular',
      trainingTips: ['Positive reinforcement', 'Consistent routine'],
    );
  }
}

class AIException implements Exception {
  final String message;
  AIException(this.message);

  @override
  String toString() => 'AIException: $message';
}

// Additional models for AI responses
class HealthAnalysis {
  final String id;
  final String petId;
  final String overallHealth;
  final List<String> concerns;
  final List<String> recommendations;
  final DateTime timestamp;
  final double confidence;

  HealthAnalysis({
    required this.id,
    required this.petId,
    required this.overallHealth,
    required this.concerns,
    required this.recommendations,
    required this.timestamp,
    required this.confidence,
  });
}

class TrainingRecommendation {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String estimatedDuration;
  final List<String> steps;

  TrainingRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.estimatedDuration,
    required this.steps,
  });
}

class MindfulnessExercise {
  final String id;
  final String title;
  final String description;
  final int duration;
  final String focusArea;
  final List<String> steps;

  MindfulnessExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.focusArea,
    required this.steps,
  });
}

class EmergencyAssessment {
  final String id;
  final String emergencyLevel;
  final List<String> immediateActions;
  final String whenToSeekHelp;
  final DateTime timestamp;
  final double confidence;

  EmergencyAssessment({
    required this.id,
    required this.emergencyLevel,
    required this.immediateActions,
    required this.whenToSeekHelp,
    required this.timestamp,
    required this.confidence,
  });
}

class BreedInsights {
  final String id;
  final String breed;
  final String characteristics;
  final List<String> healthConsiderations;
  final String exerciseNeeds;
  final String groomingRequirements;
  final List<String> trainingTips;

  BreedInsights({
    required this.id,
    required this.breed,
    required this.characteristics,
    required this.healthConsiderations,
    required this.exerciseNeeds,
    required this.groomingRequirements,
    required this.trainingTips,
  });
}