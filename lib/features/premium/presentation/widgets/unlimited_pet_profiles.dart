import 'package:flutter/material.dart';

class UnlimitedPetProfiles extends StatelessWidget {
  final bool isPremium;

  const UnlimitedPetProfiles({super.key, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        isPremium ? 'Unlimited Pet Profiles enabled' : 'Upgrade to unlock unlimited pet profiles',
      ),
    );
  }
}