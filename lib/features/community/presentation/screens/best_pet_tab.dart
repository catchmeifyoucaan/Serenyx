import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/community_service.dart';

class BestPetTab extends StatefulWidget {
  const BestPetTab({super.key});

  @override
  State<BestPetTab> createState() => _BestPetTabState();
}

class _BestPetTabState extends State<BestPetTab> {
  final CommunityService _communityService = CommunityService();
  late Future<List<BestPetEntry>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _communityService.fetchBestPetLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BestPetEntry>>(
      future: _leaderboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load: ${snapshot.error}'));
        }
        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return const Center(child: Text('No entries yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.colors.outline),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.colors.primary.withOpacity(0.1),
                  backgroundImage: entry.avatarUrl != null ? NetworkImage(entry.avatarUrl!) : null,
                  child: entry.avatarUrl == null ? Icon(Icons.pets, color: AppTheme.colors.primary) : null,
                ),
                title: Text(entry.name),
                subtitle: Text(entry.breed.isNotEmpty ? '${entry.type} • ${entry.breed}' : entry.type),
                trailing: Text('${entry.votes}'),
                onTap: () async {
                  final ok = await _communityService.voteForPet(entry.petId);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Voted for ${entry.name}!' : 'Vote failed'),
                    ),
                  );
                  if (ok) {
                    setState(() {
                      _leaderboardFuture = _communityService.fetchBestPetLeaderboard();
                    });
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

