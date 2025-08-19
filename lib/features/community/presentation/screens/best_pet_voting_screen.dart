import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/voting_service.dart';

class BestPetVotingScreen extends StatefulWidget {
  const BestPetVotingScreen({super.key});

  @override
  State<BestPetVotingScreen> createState() => _BestPetVotingScreenState();
}

class _BestPetVotingScreenState extends State<BestPetVotingScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _candidates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final svc = context.read<VotingService>();
      final items = await svc.listCandidates();
      setState(() => _candidates = items);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Failed to load candidates'), backgroundColor: AppTheme.colors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Best Pet Voting'),
        backgroundColor: AppTheme.colors.primary,
        foregroundColor: AppTheme.colors.onPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _candidates.length,
                itemBuilder: (context, i) {
                  final c = _candidates[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.colors.primary,
                        child: Text(c['petName'] != null && (c['petName'] as String).isNotEmpty ? (c['petName'] as String)[0] : '?'),
                      ),
                      title: Text(c['petName'] ?? 'Pet'),
                      subtitle: Text('Votes: ${c['votes'] ?? 0}'),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.how_to_vote),
                        label: const Text('Vote'),
                        onPressed: () async {
                          try {
                            await context.read<VotingService>().voteForPet(candidateId: c['id']);
                            await _load();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: const Text('Vote failed'), backgroundColor: AppTheme.colors.error),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

