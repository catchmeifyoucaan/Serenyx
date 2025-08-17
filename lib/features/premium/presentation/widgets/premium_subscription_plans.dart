import 'package:flutter/material.dart';

class PremiumSubscriptionPlans extends StatelessWidget {
  final VoidCallback onUpgrade;

  const PremiumSubscriptionPlans({super.key, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onUpgrade,
        icon: const Icon(Icons.star),
        label: const Text('Upgrade to Premium'),
      ),
    );
  }
}