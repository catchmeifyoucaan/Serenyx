import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/pet.dart';

class PetService {
  // Firestore collections
  static const String _usersCollection = 'users';
  static const String _petsCollection = 'pets';
  
  // Singleton pattern
  static final PetService _instance = PetService._internal();
  factory PetService() => _instance;
  PetService._internal();

  // In-memory cache
  List<Pet> _pets = [];
  Pet? _currentPet;
  StreamSubscription? _petsSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  List<Pet> get pets => List.unmodifiable(_pets);
  Pet? get currentPet => _currentPet;
  bool get hasPets => _pets.isNotEmpty;

  /// Initialize the service and load pets from storage
  Future<void> initialize() async {
    await _listenToPets();
  }

  Future<void> _listenToPets() async {
    await _petsSubscription?.cancel();
    final userId = fb.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _pets = [];
      _currentPet = null;
      return;
    }
    _petsSubscription = _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_petsCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      _pets = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Pet.fromJson(data);
      }).toList();
      if (_pets.isNotEmpty) {
        _currentPet ??= _pets.first;
      } else {
        _currentPet = null;
      }
    }, onError: (e) {
      print('Error listening to pets: $e');
    });
  }

  /// Dispose subscriptions
  Future<void> dispose() async {
    await _petsSubscription?.cancel();
  }

  /// No default pet creation in Firestore-backed service

  /// Add a new pet
  Future<bool> addPet(Pet pet) async {
    try {
      final userId = fb.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Not authenticated');
      final docRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_petsCollection)
          .doc(pet.id);
      await docRef.set(pet.toJson());
      return true;
    } catch (e) {
      print('Error adding pet: $e');
      return false;
    }
  }

  /// Update an existing pet
  Future<bool> updatePet(Pet updatedPet) async {
    try {
      final userId = fb.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Not authenticated');
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_petsCollection)
          .doc(updatedPet.id)
          .update(updatedPet.toJson());
      return true;
    } catch (e) {
      print('Error updating pet: $e');
      return false;
    }
  }

  /// Remove a pet
  Future<bool> removePet(String petId) async {
    try {
      final userId = fb.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Not authenticated');
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_petsCollection)
          .doc(petId)
          .delete();
      return true;
    } catch (e) {
      print('Error removing pet: $e');
      return false;
    }
  }

  /// Set the current active pet
  Future<bool> _setCurrentPet(Pet pet) async {
    // Optional: could persist current pet ID in user doc
    _currentPet = pet;
    return true;
  }

  /// Change the current active pet
  Future<bool> setCurrentPet(String petId) async {
    try {
      final pet = _pets.firstWhere((pet) => pet.id == petId);
      return await _setCurrentPet(pet);
    } catch (e) {
      print('Error setting current pet: $e');
      return false;
    }
  }

  /// Get a pet by ID
  Pet? getPetById(String petId) {
    try {
      return _pets.firstWhere((pet) => pet.id == petId);
    } catch (e) {
      return null;
    }
  }

  /// Update pet session count
  Future<bool> updatePetSession(String petId, {int? sessionCount, DateTime? lastSession}) async {
    try {
      final pet = getPetById(petId);
      if (pet != null) {
        final updatedPet = pet.copyWith(
          sessionCount: sessionCount ?? pet.sessionCount + 1,
          lastSessionDate: lastSession ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        return await updatePet(updatedPet);
      }
      return false;
    } catch (e) {
      print('Error updating pet session: $e');
      return false;
    }
  }

  /// Add health note to pet
  Future<bool> addHealthNote(String petId, String note) async {
    try {
      final pet = getPetById(petId);
      if (pet != null) {
        final updatedNotes = List<String>.from(pet.healthNotes)..add(note);
        final updatedPet = pet.copyWith(
          healthNotes: updatedNotes,
          updatedAt: DateTime.now(),
        );
        
        return await updatePet(updatedPet);
      }
      return false;
    } catch (e) {
      print('Error adding health note: $e');
      return false;
    }
  }

  /// Update pet preferences
  Future<bool> updatePetPreferences(String petId, Map<String, dynamic> preferences) async {
    try {
      final pet = getPetById(petId);
      if (pet != null) {
        final updatedPreferences = Map<String, dynamic>.from(pet.preferences)
          ..addAll(preferences);
        
        final updatedPet = pet.copyWith(
          preferences: updatedPreferences,
          updatedAt: DateTime.now(),
        );
        
        return await updatePet(updatedPet);
      }
      return false;
    } catch (e) {
      print('Error updating pet preferences: $e');
      return false;
    }
  }

  // No local persistence in Firestore-only service

  /// Get all pets
  List<Pet> getPets() {
    return List.unmodifiable(_pets);
  }

  /// Get pets by type
  List<Pet> getPetsByType(String type) {
    return _pets.where((pet) => pet.type.toLowerCase() == type.toLowerCase()).toList();
  }

  /// Get pets by age group
  List<Pet> getPetsByAgeGroup(String ageGroup) {
    switch (ageGroup.toLowerCase()) {
      case 'young':
        return _pets.where((pet) => pet.isYoung).toList();
      case 'adult':
        return _pets.where((pet) => pet.isAdult).toList();
      case 'senior':
        return _pets.where((pet) => pet.isSenior).toList();
      default:
        return _pets;
    }
  }

  /// Get pets with recent sessions
  List<Pet> getPetsWithRecentSessions({Duration? within}) {
    final threshold = within ?? const Duration(days: 7);
    final cutoff = DateTime.now().subtract(threshold);
    
    return _pets
        .where((pet) => pet.lastSessionDate != null && pet.lastSessionDate!.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.lastSessionDate!.compareTo(a.lastSessionDate!));
  }

  /// Get pets needing attention (no recent sessions)
  List<Pet> getPetsNeedingAttention({Duration? threshold}) {
    final limit = threshold ?? const Duration(days: 3);
    final cutoff = DateTime.now().subtract(limit);
    
    return _pets
        .where((pet) => pet.lastSessionDate == null || pet.lastSessionDate!.isBefore(cutoff))
        .toList();
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final userId = fb.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final batch = _firestore.batch();
    final query = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_petsCollection)
        .get();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    _pets.clear();
    _currentPet = null;
  }

  /// Export pets data (for backup)
  Future<String> exportPetsData() async {
    try {
      final data = {
        'pets': _pets.map((pet) => pet.toJson()).toList(),
        'currentPetId': _currentPet?.id,
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
      
      return jsonEncode(data);
    } catch (e) {
      print('Error exporting pets data: $e');
      return '';
    }
  }

  /// Import pets data (for restore)
  Future<bool> importPetsData(String jsonData) async {
    // Implement if needed: parse and write to Firestore
    return false;
  }
}