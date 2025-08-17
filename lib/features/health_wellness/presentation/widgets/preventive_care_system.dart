import 'package:flutter/material.dart';
import '../../../../shared/models/pet.dart';

class PreventiveCareSystem extends StatelessWidget {
  final Pet pet;

  const PreventiveCareSystem({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Preventive care system for \'${pet.name}\' coming soon',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}