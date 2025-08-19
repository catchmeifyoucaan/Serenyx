import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/soundscape_service.dart';

class SoundscapeScreen extends StatefulWidget {
  const SoundscapeScreen({super.key});

  @override
  State<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends State<SoundscapeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _style = 'Calm';
  final Set<String> _selected = {};
  bool _isLoading = false;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final service = context.read<SoundscapeService>();
      final items = await service.listSoundscapes();
      setState(() {
        _items = items;
      });
    } catch (e) {
      _showError('Failed to load soundscapes');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.colors.error),
    );
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final service = context.read<SoundscapeService>();
      await service.generateSoundscape(
        title: _titleController.text.trim(),
        style: _style,
        favoritePetSounds: _selected.toList(),
        durationSeconds: 90,
      );
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Soundscape created'), backgroundColor: AppTheme.colors.success),
        );
      }
    } catch (e) {
      _showError('Failed to generate');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Soundscape'),
        backgroundColor: AppTheme.colors.primary,
        foregroundColor: AppTheme.colors.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCreateForm(),
              const SizedBox(height: 24),
              _buildList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    final sounds = const ['Birds', 'Water', 'Bells', 'Chimes', 'Soft piano', 'Nature'];
    final styles = const ['Calm', 'Playful', 'Focus', 'Sleep'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create', style: AppTheme.textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _style,
                items: styles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _style = v ?? 'Calm'),
                decoration: const InputDecoration(labelText: 'Style'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sounds.map((s) {
                  final selected = _selected.contains(s);
                  return FilterChip(
                    selected: selected,
                    label: Text(s),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selected.add(s);
                        } else {
                          _selected.remove(s);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generate,
                  child: _isLoading ? const CircularProgressIndicator(strokeWidth: 2) : const Text('Generate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Soundscapes', style: AppTheme.textStyles.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          Text('No soundscapes yet', style: AppTheme.textStyles.bodyMedium)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final it = _items[index];
              final title = it['title'] as String? ?? 'Untitled';
              final url = it['audioUrl'] as String?;
              return ListTile(
                leading: Icon(Icons.music_note, color: AppTheme.colors.primary),
                title: Text(title),
                subtitle: Text(it['style'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (url != null)
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () {
                          // The app uses url_launcher for playback externally or a dedicated player widget
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        try {
                          await context.read<SoundscapeService>().deleteSoundscape(soundscapeId: it['id']);
                          await _refresh();
                        } catch (e) {
                          _showError('Delete failed');
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

