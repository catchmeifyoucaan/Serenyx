import 'package:flutter/material.dart';
import '../../../../shared/models/pet.dart';

class AdvancedInsights extends StatelessWidget {
  final Pet pet;
  final bool isPremium;

  const AdvancedInsights({super.key, required this.pet, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          isPremium
              ? 'Advanced insights for ${pet.name}'
              : 'Upgrade to Premium to unlock advanced insights for ${pet.name}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}