import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Enums
enum MemoryType { bonding, health, training, adventure, milestone }
enum MilestoneType { birthday, training, social, health, achievement }

// Memory Entry Model
class MemoryEntry extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? photoUrl;
  final List<String> tags;
  final String mood;
  final MemoryType type;

  const MemoryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.photoUrl,
    required this.tags,
    required this.mood,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, description, date, photoUrl, tags, mood, type];

  MemoryEntry copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? photoUrl,
    List<String>? tags,
    String? mood,
    MemoryType? type,
  }) {
    return MemoryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      photoUrl: photoUrl ?? this.photoUrl,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      type: type ?? this.type,
    );
  }
}

// Milestone Model
class Milestone extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final MilestoneType type;
  final IconData icon;
  final Color color;
  final String? photoUrl;
  final bool isCelebrated;

  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.icon,
    required this.color,
    this.photoUrl,
    required this.isCelebrated,
  });

  @override
  List<Object?> get props => [id, title, description, date, type, icon, color, photoUrl, isCelebrated];

  Milestone copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    MilestoneType? type,
    IconData? icon,
    Color? color,
    String? photoUrl,
    bool? isCelebrated,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      photoUrl: photoUrl ?? this.photoUrl,
      isCelebrated: isCelebrated ?? this.isCelebrated,
    );
  }
}

// Photo Memory Model
class PhotoMemory extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String photoUrl;
  final List<String> tags;
  final String location;

  const PhotoMemory({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.photoUrl,
    required this.tags,
    required this.location,
  });

  @override
  List<Object?> get props => [id, title, description, date, photoUrl, tags, location];

  PhotoMemory copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? photoUrl,
    List<String>? tags,
    String? location,
  }) {
    return PhotoMemory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      photoUrl: photoUrl ?? this.photoUrl,
      tags: tags ?? this.tags,
      location: location ?? this.location,
    );
  }
}