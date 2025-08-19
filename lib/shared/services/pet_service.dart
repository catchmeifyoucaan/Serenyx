import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/pet.dart';
import 'api_service.dart';

class PetService extends ChangeNotifier {
  static const String _petsKey = 'user_pets';
  static const String _currentPetKey = 'current_pet';
  
  // Singleton pattern
  static final PetService _instance = PetService._internal();
  factory PetService() => _instance;
  PetService._internal();

  // API service
  final ApiService _apiService = ApiService();
  
  // In-memory cache
  List<Pet> _pets = [];
  Pet? _currentPet;
  bool _isLoading = false;

  // Getters
  List<Pet> get pets => List.unmodifiable(_pets);
  Pet? get currentPet => _currentPet;
  bool get hasPets => _pets.isNotEmpty;
  bool get isLoading => _isLoading;

  /// Initialize the service and load pets from API
  Future<void> initialize() async {
    await _loadPets();
    await _loadCurrentPet();
  }

  /// Load pets from API
  Future<void> _loadPets() async {
    try {
      _isLoading = true;
      _notifyListeners();
      
      final pets = await _apiService.getPets();
      _pets = pets;
      
      _isLoading = false;
      _notifyListeners();
    } catch (e) {
      print('Error loading pets: $e');
      // Fallback to local storage if API is not available
      await _loadPetsFromLocalStorage();
      _isLoading = false;
      _notifyListeners();
    }
  }

  /// Load pets from local storage as fallback
  Future<void> _loadPetsFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petsJson = prefs.getStringList(_petsKey) ?? [];
      
      _pets = petsJson
          .map((json) => Pet.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading pets from local storage: $e');
      _pets = [];
    }
  }

  /// Load current pet from local storage
  Future<void> _loadCurrentPet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPetId = prefs.getString(_currentPetKey);
      
      if (currentPetId != null && _pets.isNotEmpty) {
        _currentPet = _pets.firstWhere(
          (pet) => pet.id == currentPetId,
          orElse: () => _pets.first,
        );
      } else if (_pets.isNotEmpty) {
        _currentPet = _pets.first;
        await _setCurrentPet(_currentPet!);
      }
    } catch (e) {
      print('Error loading current pet: $e');
      _currentPet = null;
    }
  }

  /// Add a new pet
  Future<bool> addPet(Pet pet) async {
    try {
      final petData = pet.toJson();
      final newPet = await _apiService.createPet(petData);
      
      _pets.add(newPet);
      
      if (_currentPet == null) {
        await _setCurrentPet(newPet);
      }
      
      // Save to local storage as backup
      await _savePetsToLocalStorage();
      
      _notifyListeners();
      return true;
    } catch (e) {
      print('Error adding pet: $e');
      // Fallback to local storage only
      _pets.add(pet);
      await _savePetsToLocalStorage();
      _notifyListeners();
      return false;
    }
  }

  /// Update an existing pet
  Future<bool> updatePet(Pet updatedPet) async {
    try {
      final petData = updatedPet.toJson();
      final updatedPetFromApi = await _apiService.updatePet(updatedPet.id, petData);
      
      final index = _pets.indexWhere((pet) => pet.id == updatedPet.id);
      if (index != -1) {
        _pets[index] = updatedPetFromApi;
        
        if (_currentPet?.id == updatedPet.id) {
          _currentPet = updatedPetFromApi;
          await _setCurrentPet(updatedPetFromApi);
        }
        
        _notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating pet: $e');
      return false;
    }
  }

  /// Remove a pet
  Future<bool> removePet(String petId) async {
    try {
      await _apiService.deletePet(petId);
      
      _pets.removeWhere((pet) => pet.id == petId);
      
      if (_currentPet?.id == petId) {
        _currentPet = _pets.isNotEmpty ? _pets.first : null;
        if (_currentPet != null) {
          await _setCurrentPet(_currentPet!);
        }
      }
      
      _notifyListeners();
      return true;
    } catch (e) {
      print('Error removing pet: $e');
      return false;
    }
  }

  /// Set the current active pet
  Future<bool> _setCurrentPet(Pet pet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentPetKey, pet.id);
      _currentPet = pet;
      return true;
    } catch (e) {
      print('Error setting current pet: $e');
      return false;
    }
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

  /// Notify listeners of state changes
  void _notifyListeners() {
    notifyListeners();
  }

  /// Save pets to local storage as backup
  Future<void> _savePetsToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petsJson = _pets
          .map((pet) => jsonEncode(pet.toJson()))
          .toList();
      
      await prefs.setStringList(_petsKey, petsJson);
    } catch (e) {
      print('Error saving pets to local storage: $e');
    }
  }

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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_petsKey);
      await prefs.remove(_currentPetKey);
      
      _pets.clear();
      _currentPet = null;
    } catch (e) {
      print('Error clearing data: $e');
    }
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
    try {
      final data = jsonDecode(jsonData);
      final petsData = data['pets'] as List;
      
      _pets = petsData
          .map((petJson) => Pet.fromJson(petJson))
          .toList();
      
      if (data['currentPetId'] != null) {
        await _setCurrentPet(_pets.firstWhere(
          (pet) => pet.id == data['currentPetId'],
          orElse: () => _pets.first,
        ));
      }
      
      await _savePets();
      return true;
    } catch (e) {
      print('Error importing pets data: $e');
      return false;
    }
  }
}