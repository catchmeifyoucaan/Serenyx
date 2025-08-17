class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final bool emailVerified;
  final List<String> pets;
  final UserProfile profile;
  final UserPreferences preferences;
  final SubscriptionInfo subscription;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastSignInAt,
    required this.emailVerified,
    required this.pets,
    required this.profile,
    required this.preferences,
    required this.subscription,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      createdAt: DateTime.parse(json['createdAt']),
      lastSignInAt: DateTime.parse(json['lastSignInAt']),
      emailVerified: json['emailVerified'] ?? false,
      pets: List<String>.from(json['pets'] ?? []),
      profile: UserProfile.fromJson(json['profile'] ?? {}),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      subscription: SubscriptionInfo.fromJson(json['subscription'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt.toIso8601String(),
      'emailVerified': emailVerified,
      'pets': pets,
      'profile': profile.toJson(),
      'preferences': preferences.toJson(),
      'subscription': subscription.toJson(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? emailVerified,
    List<String>? pets,
    UserProfile? profile,
    UserPreferences? preferences,
    SubscriptionInfo? subscription,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      emailVerified: emailVerified ?? this.emailVerified,
      pets: pets ?? this.pets,
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      subscription: subscription ?? this.subscription,
    );
  }
}

class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? location;
  final String? bio;
  final List<String> interests;
  final String? emergencyContact;

  UserProfile({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.location,
    this.bio,
    required this.interests,
    this.emergencyContact,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      location: json['location'],
      bio: json['bio'],
      interests: List<String>.from(json['interests'] ?? []),
      emergencyContact: json['emergencyContact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'location': location,
      'bio': bio,
      'interests': interests,
      'emergencyContact': emergencyContact,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return 'Unknown User';
  }
}

class UserPreferences {
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final AIPreferences aiPreferences;
  final ThemeSettings theme;
  final LanguageSettings language;

  UserPreferences({
    required this.notifications,
    required this.privacy,
    required this.aiPreferences,
    required this.theme,
    required this.language,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notifications: NotificationSettings.fromJson(json['notifications'] ?? {}),
      privacy: PrivacySettings.fromJson(json['privacy'] ?? {}),
      aiPreferences: AIPreferences.fromJson(json['aiPreferences'] ?? {}),
      theme: ThemeSettings.fromJson(json['theme'] ?? {}),
      language: LanguageSettings.fromJson(json['language'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.toJson(),
      'privacy': privacy.toJson(),
      'aiPreferences': aiPreferences.toJson(),
      'theme': theme.toJson(),
      'language': language.toJson(),
    };
  }
}

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final List<String> enabledTypes;
  final TimeRange quietHours;

  NotificationSettings({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.enabledTypes,
    required this.quietHours,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? false,
      smsEnabled: json['smsEnabled'] ?? false,
      enabledTypes: List<String>.from(json['enabledTypes'] ?? [
        'health_reminders',
        'vet_appointments',
        'feeding_schedule',
        'exercise_reminders',
        'ai_insights'
      ]),
      quietHours: TimeRange.fromJson(json['quietHours'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
      'enabledTypes': enabledTypes,
      'quietHours': quietHours.toJson(),
    };
  }
}

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({
    required this.start,
    required this.end,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: TimeOfDay(
        hour: json['startHour'] ?? 22,
        minute: json['startMinute'] ?? 0,
      ),
      end: TimeOfDay(
        hour: json['endHour'] ?? 7,
        minute: json['endMinute'] ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startHour': start.hour,
      'startMinute': start.minute,
      'endHour': end.hour,
      'endMinute': end.minute,
    };
  }
}

class PrivacySettings {
  final bool profilePublic;
  final bool petsPublic;
  final bool healthDataShared;
  final List<String> trustedContacts;
  final bool analyticsEnabled;

  PrivacySettings({
    required this.profilePublic,
    required this.petsPublic,
    required this.healthDataShared,
    required this.trustedContacts,
    required this.analyticsEnabled,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profilePublic: json['profilePublic'] ?? false,
      petsPublic: json['petsPublic'] ?? false,
      healthDataShared: json['healthDataShared'] ?? false,
      trustedContacts: List<String>.from(json['trustedContacts'] ?? []),
      analyticsEnabled: json['analyticsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profilePublic': profilePublic,
      'petsPublic': petsPublic,
      'healthDataShared': healthDataShared,
      'trustedContacts': trustedContacts,
      'analyticsEnabled': analyticsEnabled,
    };
  }
}

class AIPreferences {
  final String preferredModel;
  final List<String> enabledFeatures;
  final bool autoAnalysis;
  final bool personalizedRecommendations;
  final Map<String, dynamic> modelSettings;

  AIPreferences({
    required this.preferredModel,
    required this.enabledFeatures,
    required this.autoAnalysis,
    required this.personalizedRecommendations,
    required this.modelSettings,
  });

  factory AIPreferences.fromJson(Map<String, dynamic> json) {
    return AIPreferences(
      preferredModel: json['preferredModel'] ?? 'gpt-5',
      enabledFeatures: List<String>.from(json['enabledFeatures'] ?? [
        'emotion_recognition',
        'behavioral_prediction',
        'health_analysis',
        'training_recommendations'
      ]),
      autoAnalysis: json['autoAnalysis'] ?? true,
      personalizedRecommendations: json['personalizedRecommendations'] ?? true,
      modelSettings: Map<String, dynamic>.from(json['modelSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredModel': preferredModel,
      'enabledFeatures': enabledFeatures,
      'autoAnalysis': autoAnalysis,
      'personalizedRecommendations': personalizedRecommendations,
      'modelSettings': modelSettings,
    };
  }
}

class ThemeSettings {
  final String themeMode;
  final String colorScheme;
  final bool useSystemTheme;

  ThemeSettings({
    required this.themeMode,
    required this.colorScheme,
    required this.useSystemTheme,
  });

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: json['themeMode'] ?? 'system',
      colorScheme: json['colorScheme'] ?? 'default',
      useSystemTheme: json['useSystemTheme'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'colorScheme': colorScheme,
      'useSystemTheme': useSystemTheme,
    };
  }
}

class LanguageSettings {
  final String language;
  final String region;
  final bool autoDetect;

  LanguageSettings({
    required this.language,
    required this.region,
    required this.autoDetect,
  });

  factory LanguageSettings.fromJson(Map<String, dynamic> json) {
    return LanguageSettings(
      language: json['language'] ?? 'en',
      region: json['region'] ?? 'US',
      autoDetect: json['autoDetect'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'region': region,
      'autoDetect': autoDetect,
    };
  }
}

class SubscriptionInfo {
  final String plan;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<String> features;
  final double monthlyPrice;
  final String billingCycle;

  SubscriptionInfo({
    required this.plan,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.features,
    required this.monthlyPrice,
    required this.billingCycle,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      plan: json['plan'] ?? 'free',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      isActive: json['isActive'] ?? false,
      features: List<String>.from(json['features'] ?? []),
      monthlyPrice: (json['monthlyPrice'] ?? 0.0).toDouble(),
      billingCycle: json['billingCycle'] ?? 'monthly',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'features': features,
      'monthlyPrice': monthlyPrice,
      'billingCycle': billingCycle,
    };
  }

  bool get isPremium => plan != 'free' && isActive;
}

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;
  final String? token;

  AuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.user,
    this.token,
  });

  factory AuthResult.success({User? user, String? token}) {
    return AuthResult(
      isSuccess: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure({required String errorMessage}) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

class LoginCredentials {
  final String email;
  final String password;
  final bool rememberMe;

  LoginCredentials({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

class RegistrationData {
  final String email;
  final String password;
  final String confirmPassword;
  final String? displayName;
  final bool acceptTerms;
  final bool acceptPrivacyPolicy;
  final bool acceptMarketing;

  RegistrationData({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.displayName,
    required this.acceptTerms,
    required this.acceptPrivacyPolicy,
    this.acceptMarketing = false,
  });

  bool get isValid {
    return email.isNotEmpty &&
           password.isNotEmpty &&
           password == confirmPassword &&
           password.length >= 6 &&
           acceptTerms &&
           acceptPrivacyPolicy;
  }
}