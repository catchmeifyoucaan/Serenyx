import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Enums for Reminder and Smart Suggestion types
enum ReminderType {
  bonding,
  health,
  medication,
  vet,
  grooming,
}

enum ReminderFrequency {
  daily,
  weekly,
  monthly,
  yearly, // Added missing constant
  oneTime, // Added missing constant
  custom,
}

enum SuggestionType {
  health,
  bonding,
  training,
  care,
  social,
  timing, // Added missing constant
  behavior, // Added missing constant
}

enum SuggestionPriority {
  low,
  medium,
  high,
  urgent, // Added missing constant
}

// Reminder Model
class Reminder extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final ReminderFrequency frequency; // Changed from String to ReminderFrequency
  bool isActive; // Removed final to make it mutable
  final String petId;
  final ReminderType type; // Changed from String to ReminderType
  final DateTime? lastTriggered;
  final DateTime scheduledTime;
  final Color color; // Changed from String to Color
  final IconData icon; // Changed from String to IconData

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.frequency,
    required this.isActive,
    required this.petId,
    required this.type,
    this.lastTriggered,
    required this.scheduledTime,
    required this.color,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, title, description, time, frequency, isActive, petId, type, lastTriggered, scheduledTime, color, icon];

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? time,
    ReminderFrequency? frequency, // Changed from String to ReminderFrequency
    bool? isActive,
    String? petId,
    ReminderType? type, // Changed from String to ReminderType
    DateTime? lastTriggered,
    DateTime? scheduledTime,
    Color? color, // Changed from String to Color
    IconData? icon, // Changed from String to IconData
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}

// Smart Suggestion Model
class SmartSuggestion extends Equatable {
  final String id;
  final String title;
  final String description;
  final SuggestionType type; // Changed from String to SuggestionType
  final SuggestionPriority priority; // Changed from String to SuggestionPriority
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final Color color; // Changed from String to Color
  final IconData icon; // Changed from String to IconData

  const SmartSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.createdAt,
    required this.isRead,
    this.actionUrl,
    this.metadata,
    required this.color,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, title, description, type, priority, createdAt, isRead, actionUrl, metadata, color, icon];

  SmartSuggestion copyWith({
    String? id,
    String? title,
    String? description,
    SuggestionType? type, // Changed from String to SuggestionType
    SuggestionPriority? priority, // Changed from String to SuggestionPriority
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    Color? color, // Changed from String to Color
    IconData? icon, // Changed from String to IconData
  }) {
    return SmartSuggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}