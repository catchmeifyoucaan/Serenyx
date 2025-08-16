import 'package:equatable/equatable.dart';

class Pet extends Equatable {
  final String id;
  final String name;
  final String type;
  final String avatar;
  final DateTime birthDate;
  final String breed;
  final double weight;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> preferences;
  final List<String> healthNotes;
  final int sessionCount;
  final DateTime? lastSessionDate;

  const Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.avatar,
    required this.birthDate,
    required this.breed,
    required this.weight,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.preferences = const {},
    this.healthNotes = const [],
    this.sessionCount = 0,
    this.lastSessionDate,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? type,
    String? avatar,
    DateTime? birthDate,
    String? breed,
    double? weight,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? preferences,
    List<String>? healthNotes,
    int? sessionCount,
    DateTime? lastSessionDate,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      avatar: avatar ?? this.avatar,
      birthDate: birthDate ?? this.birthDate,
      breed: breed ?? this.breed,
      weight: weight ?? this.weight,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      healthNotes: healthNotes ?? this.healthNotes,
      sessionCount: sessionCount ?? this.sessionCount,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'avatar': avatar,
      'birthDate': birthDate.toIso8601String(),
      'breed': breed,
      'weight': weight,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'preferences': preferences,
      'healthNotes': healthNotes,
      'sessionCount': sessionCount,
      'lastSessionDate': lastSessionDate?.toIso8601String(),
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      avatar: json['avatar'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      breed: json['breed'] as String,
      weight: (json['weight'] as num).toDouble(),
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      healthNotes: List<String>.from(json['healthNotes'] ?? []),
      sessionCount: json['sessionCount'] as int? ?? 0,
      lastSessionDate: json['lastSessionDate'] != null
          ? DateTime.parse(json['lastSessionDate'] as String)
          : null,
    );
  }

  factory Pet.empty() {
    return Pet(
      id: '',
      name: '',
      type: '',
      avatar: '',
      birthDate: DateTime.now(),
      breed: '',
      weight: 0.0,
      ownerId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        avatar,
        birthDate,
        breed,
        weight,
        ownerId,
        createdAt,
        updatedAt,
        preferences,
        healthNotes,
        sessionCount,
        lastSessionDate,
      ];

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool get isYoung => age < 3;
  bool get isAdult => age >= 3 && age < 8;
  bool get isSenior => age >= 8;
}