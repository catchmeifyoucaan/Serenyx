import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/community_service.dart';

class BestPetScreen extends StatefulWidget {
  const BestPetScreen({super.key});

  @override
  State<BestPetScreen> createState() => _BestPetScreenState();
}

class _BestPetScreenState extends State<BestPetScreen> {
  final CommunityService _communityService = CommunityService();
  late Future<List<BestPetEntry>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _communityService.fetchBestPetLeaderboard();
  }

  Future<void> _refresh() async {
    setState(() {
      _leaderboardFuture = _communityService.fetchBestPetLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Best Pet'),
        backgroundColor: AppTheme.colors.surface,
        scrolledUnderElevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<BestPetEntry>>(
          future: _leaderboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to load: ${snapshot.error}'),
              );
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
                    title: Text(
                      entry.name,
                      style: AppTheme.textStyles.titleMedium?.copyWith(
                        color: AppTheme.colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      entry.breed.isNotEmpty ? '${entry.type} • ${entry.breed}' : entry.type,
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${entry.votes}',
                          style: AppTheme.textStyles.titleMedium?.copyWith(
                            color: AppTheme.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'votes',
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final ok = await _communityService.voteForPet(entry.petId);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Voted for ${entry.name}!' : 'Vote failed'),
                          backgroundColor: ok ? AppTheme.colors.success : AppTheme.colors.error,
                        ),
                      );
                      if (ok) _refresh();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

