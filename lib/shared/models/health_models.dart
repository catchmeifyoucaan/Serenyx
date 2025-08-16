import 'package:equatable/equatable.dart';

// Vaccination Record Model
class VaccinationRecord extends Equatable {
  final String id;
  final String name;
  final DateTime date;
  final DateTime? nextDue;
  final String? notes;
  final String veterinarian;
  final String clinic;
  final double cost;

  const VaccinationRecord({
    required this.id,
    required this.name,
    required this.date,
    this.nextDue,
    this.notes,
    required this.veterinarian,
    required this.clinic,
    required this.cost,
  });

  @override
  List<Object?> get props => [id, name, date, nextDue, notes, veterinarian, clinic, cost];

  VaccinationRecord copyWith({
    String? id,
    String? name,
    DateTime? date,
    DateTime? nextDue,
    String? notes,
    String? veterinarian,
    String? clinic,
    double? cost,
  }) {
    return VaccinationRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      nextDue: nextDue ?? this.nextDue,
      notes: notes ?? this.notes,
      veterinarian: veterinarian ?? this.veterinarian,
      clinic: clinic ?? this.clinic,
      cost: cost ?? this.cost,
    );
  }
}

// Weight Record Model
class WeightRecord extends Equatable {
  final String id;
  final double weight;
  final DateTime date;
  final String? notes;
  final String? photoUrl;

  const WeightRecord({
    required this.id,
    required this.weight,
    required this.date,
    this.notes,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, weight, date, notes, photoUrl];

  WeightRecord copyWith({
    String? id,
    double? weight,
    DateTime? date,
    String? notes,
    String? photoUrl,
  }) {
    return WeightRecord(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

// Medication Record Model
class MedicationRecord extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isActive;
  final String? photoUrl;

  const MedicationRecord({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.isActive,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, name, dosage, frequency, startDate, endDate, notes, isActive, photoUrl];

  MedicationRecord copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    bool? isActive,
    String? photoUrl,
  }) {
    return MedicationRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

// Vet Visit Record Model
class VetVisitRecord extends Equatable {
  final String id;
  final DateTime date;
  final String reason;
  final String diagnosis;
  final String treatment;
  final String veterinarian;
  final String clinic;
  final double cost;
  final String? notes;
  final DateTime? followUp;
  final String? photoUrl;

  const VetVisitRecord({
    required this.id,
    required this.date,
    required this.reason,
    required this.diagnosis,
    required this.treatment,
    required this.veterinarian,
    required this.clinic,
    required this.cost,
    this.notes,
    this.followUp,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, date, reason, diagnosis, treatment, veterinarian, clinic, cost, notes, followUp, photoUrl];

  VetVisitRecord copyWith({
    String? id,
    DateTime? date,
    String? reason,
    String? diagnosis,
    String? treatment,
    String? veterinarian,
    String? clinic,
    double? cost,
    String? notes,
    DateTime? followUp,
    String? photoUrl,
  }) {
    return VetVisitRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      veterinarian: veterinarian ?? this.veterinarian,
      clinic: clinic ?? this.clinic,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      followUp: followUp ?? this.followUp,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}