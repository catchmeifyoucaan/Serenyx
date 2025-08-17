+import 'package:flutter/material.dart';
+import 'package:flutter_animate/flutter_animate.dart';
+import '../../../../core/theme/app_theme.dart';
+import '../../../../shared/models/pet.dart';
+import '../../../../shared/models/ai_models.dart';
+
+class PersonalizedContentWidget extends StatefulWidget {
+  final Pet pet;
+
+  const PersonalizedContentWidget({super.key, required this.pet});
+
+  @override
+  State<PersonalizedContentWidget> createState() => _PersonalizedContentWidgetState();
+}
+
+class _PersonalizedContentWidgetState extends State<PersonalizedContentWidget> {
+  List<PersonalizedContent> _recommendations = [];
+  List<PersonalizedContent> _recentContent = [];
+  bool _isLoading = false;
+
+  @override
+  void initState() {
+    super.initState();
+    _loadRecommendations();
+    _loadRecentContent();
+  }
+
+  void _loadRecommendations() {
+    // Mock data - in real app, this would come from AI service
+    _recommendations = [
+      PersonalizedContent(
+        id: '1',
+        title: 'Interactive Puzzle Games',
+        description: 'Based on ${widget.pet.name}\'s problem-solving skills, these puzzle games will provide mental stimulation and bonding opportunities.',
+        category: 'Training & Enrichment',
+        contentUrl: 'https://example.com/puzzle-games',
+        relevanceScore: 0.94,
+        tags: ['mental stimulation', 'problem solving', 'bonding'],
+        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
+      ),
+      PersonalizedContent(
+        id: '2',
+        title: 'Evening Relaxation Routine',
+        description: 'Perfect for ${widget.pet.name}\'s evening energy patterns. Create a calming routine to help with relaxation and sleep preparation.',
+        category: 'Wellness & Care',
+        contentUrl: 'https://example.com/relaxation-routine',
+        relevanceScore: 0.87,
+        tags: ['relaxation', 'sleep', 'evening routine'],
+        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
+      ),
+      PersonalizedContent(
+        id: '3',
+        title: 'Socialization Activities',
+        description: '${widget.pet.name} shows high social needs. These activities will help strengthen your bond and provide social stimulation.',
+        category: 'Social & Bonding',
+        contentUrl: 'https://example.com/socialization',
+        relevanceScore: 0.91,
+        tags: ['socialization', 'bonding', 'interaction'],
+        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
+      ),
+      PersonalizedContent(
+        id: '4',
+        title: 'Nutrition Optimization Guide',
+        description: 'Tailored nutrition advice based on ${widget.pet.name}\'s age, activity level, and health indicators.',
+        category: 'Health & Nutrition',
+        contentUrl: 'https://example.com/nutrition',
+        relevanceScore: 0.83,
+        tags: ['nutrition', 'health', 'diet'],
+        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
+      ),
+    ];
+  }
+
+  void _loadRecentContent() {
+    // Mock data for recently consumed content
+    _recentContent = [
+      PersonalizedContent(
+        id: '5',
+        title: 'Morning Exercise Routine',
+        description: 'A 15-minute morning exercise routine that ${widget.pet.name} enjoyed and responded well to.',
+        category: 'Exercise & Activity',
+        contentUrl: 'https://example.com/morning-exercise',
+        relevanceScore: 0.89,
+        tags: ['exercise', 'morning routine', 'energy'],
+        createdAt: DateTime.now().subtract(const Duration(days: 1)),
+      ),
+      PersonalizedContent(
+        id: '6',
+        title: 'Grooming Best Practices',
+        description: 'Grooming techniques that ${widget.pet.name} finds comfortable and enjoyable.',
+        category: 'Grooming & Care',
+        contentUrl: 'https://example.com/grooming',
+        relevanceScore: 0.76,
+        tags: ['grooming', 'care', 'comfort'],
+        createdAt: DateTime.now().subtract(const Duration(days: 2)),
+      ),
+    ];
+  }
+
+  Future<void> _refreshRecommendations() async {
+    setState(() {
+      _isLoading = true;
+    });
+
+    // Simulate AI refresh
+    await Future.delayed(const Duration(seconds: 2));
+
+    // Mock new recommendation
+    final newRecommendation = PersonalizedContent(
+      id: DateTime.now().millisecondsSinceEpoch.toString(),
+      title: 'Weekend Adventure Planning',
+      description: 'Based on ${widget.pet.name}\'s energy levels and preferences, plan an exciting weekend adventure.',
+      category: 'Adventure & Exploration',
+      contentUrl: 'https://example.com/weekend-adventure',
+      relevanceScore: 0.88,
+      tags: ['adventure', 'weekend', 'exploration'],
+      createdAt: DateTime.now(),
+    );
+
+    setState(() {
+      _recommendations.insert(0, newRecommendation);
+      _isLoading = false;
+    });
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    return SingleChildScrollView(
+      padding: const EdgeInsets.all(16.0),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          _buildContentSummary(),
+          const SizedBox(height: 24),
+          _buildRefreshSection(),
+          const SizedBox(height: 24),
+          _buildRecommendationsList(),
+          const SizedBox(height: 24),
+          _buildRecentContent(),
+        ],
+      ),
+    );
+  }
+
+  Widget _buildContentSummary() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Row(
+              children: [
+                Icon(
+                  Icons.recommend,
+                  color: AppTheme.colors.primary,
+                  size: 28,
+                ),
+                const SizedBox(width: 12),
+                Text(
+                  'Personalized Content',
+                  style: AppTheme.textStyles.headlineSmall?.copyWith(
+                    color: AppTheme.colors.textPrimary,
+                  ),
+                ),
+              ],
+            ),
+            const SizedBox(height: 16),
+            Row(
+              children: [
+                Expanded(
+                  child: _buildContentStat(
+                    'Recommendations',
+                    '${_recommendations.length}',
+                    Icons.lightbulb,
+                    AppTheme.colors.primary,
+                  ),
+                ),
+                Expanded(
+                  child: _buildContentStat(
+                    'Avg Relevance',
+                    '89%',
+                    Icons.trending_up,
+                    AppTheme.colors.success,
+                  ),
+                ),
+                Expanded(
+                  child: _buildContentStat(
+                    'Categories',
+                    '4',
+                    Icons.category,
+                    AppTheme.colors.secondary,
+                  ),
+                ),
+              ],
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildContentStat(String label, String value, IconData icon, Color color) {
+    return Column(
+      children: [
+        Icon(icon, color: color, size: 32),
+        const SizedBox(height: 8),
+        Text(
+          value,
+          style: AppTheme.textStyles.titleLarge?.copyWith(
+            color: AppTheme.colors.textPrimary,
+            fontWeight: FontWeight.bold,
+          ),
+        ),
+        Text(
+          label,
+          style: AppTheme.textStyles.bodySmall?.copyWith(
+            color: AppTheme.colors.textSecondary,
+          ),
+          textAlign: TextAlign.center,
+        ),
+      ],
+    );
+  }
+
+  Widget _buildRefreshSection() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Refresh Recommendations',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 12),
+            Text(
+              'Get new personalized content based on ${widget.pet.name}\'s latest behavior patterns and preferences',
+              style: AppTheme.textStyles.bodyMedium?.copyWith(
+                color: AppTheme.colors.textSecondary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            SizedBox(
+              width: double.infinity,
+              child: ElevatedButton.icon(
+                onPressed: !_isLoading ? _refreshRecommendations : null,
+                icon: _isLoading
+                    ? SizedBox(
+                        width: 16,
+                        height: 16,
+                        child: CircularProgressIndicator(
+                          strokeWidth: 2,
+                          valueColor: AlwaysStoppedAnimation<Color>(
+                            Colors.white,
+                          ),
+                        ),
+                      )
+                    : const Icon(Icons.refresh),
+                label: Text(_isLoading ? 'Refreshing...' : 'Refresh'),
+                style: ElevatedButton.styleFrom(
+                  backgroundColor: AppTheme.colors.secondary,
+                  foregroundColor: Colors.white,
+                  padding: const EdgeInsets.symmetric(vertical: 16),
+                ),
+              ),
+            ),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildRecommendationsList() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Recommended for You',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            ..._recommendations.map((content) => _buildContentCard(content, true)),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildRecentContent() {
+    return Card(
+      elevation: 4,
+      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
+      child: Padding(
+        padding: const EdgeInsets.all(20.0),
+        child: Column(
+          crossAxisAlignment: CrossAxisAlignment.start,
+          children: [
+            Text(
+              'Recently Viewed',
+              style: AppTheme.textStyles.titleLarge?.copyWith(
+                color: AppTheme.colors.textPrimary,
+              ),
+            ),
+            const SizedBox(height: 16),
+            ..._recentContent.map((content) => _buildContentCard(content, false)),
+          ],
+        ),
+      ),
+    );
+  }
+
+  Widget _buildContentCard(PersonalizedContent content, bool isRecommendation) {
+    return Container(
+      margin: const EdgeInsets.only(bottom: 16),
+      padding: const EdgeInsets.all(16),
+      decoration: BoxDecoration(
+        color: AppTheme.colors.surface,
+        borderRadius: BorderRadius.circular(12),
+        border: Border.all(
+          color: isRecommendation 
+              ? AppTheme.colors.primary.withOpacity(0.3)
+              : AppTheme.colors.outline,
+        ),
+      ),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Row(
+            children: [
+              Container(
+                width: 40,
+                height: 40,
+                decoration: BoxDecoration(
+                  color: _getCategoryColor(content.category).withOpacity(0.2),
+                  borderRadius: BorderRadius.circular(20),
+                ),
+                child: Icon(
+                  _getCategoryIcon(content.category),
+                  color: _getCategoryColor(content.category),
+                  size: 20,
+                ),
+              ),
+              const SizedBox(width: 12),
+              Expanded(
+                child: Column(
+                  crossAxisAlignment: CrossAxisAlignment.start,
+                  children: [
+                    Text(
+                      content.title,
+                      style: AppTheme.textStyles.titleMedium?.copyWith(
+                        color: AppTheme.colors.textPrimary,
+                        fontWeight: FontWeight.bold,
+                      ),
+                    ),
+                    Text(
+                      content.category,
+                      style: AppTheme.textStyles.bodySmall?.copyWith(
+                        color: AppTheme.colors.textSecondary,
+                      ),
+                    ),
+                  ],
+                ),
+              ),
+              if (isRecommendation)
+                Container(
+                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
+                  decoration: BoxDecoration(
+                    color: AppTheme.colors.primary.withOpacity(0.2),
+                    borderRadius: BorderRadius.circular(12),
+                  ),
+                  child: Text(
+                    '${(content.relevanceScore * 100).toInt()}%',
+                    style: AppTheme.textStyles.bodySmall?.copyWith(
+                      color: AppTheme.colors.primary,
+                      fontWeight: FontWeight.bold,
+                    ),
+                  ),
+                ),
+            ],
+          ),
+          const SizedBox(height: 12),
+          Text(
+            content.description,
+            style: AppTheme.textStyles.bodyMedium?.copyWith(
+              color: AppTheme.colors.textSecondary,
+            ),
+          ),
+          const SizedBox(height: 12),
+          Wrap(
+            spacing: 8,
+            runSpacing: 4,
+            children: content.tags.map((tag) => Container(
+              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
+              decoration: BoxDecoration(
+                color: AppTheme.colors.primary.withOpacity(0.1),
+                borderRadius: BorderRadius.circular(12),
+              ),
+              child: Text(
+                tag,
+                style: AppTheme.textStyles.bodySmall?.copyWith(
+                  color: AppTheme.colors.primary,
+                  fontSize: 10,
+                ),
+              ),
+            )).toList(),
+          ),
+          const SizedBox(height: 12),
+          Row(
+            children: [
+              Expanded(
+                child: OutlinedButton.icon(
+                  onPressed: () {
+                    // TODO: Implement content viewing
+                  },
+                  icon: const Icon(Icons.visibility),
+                  label: const Text('View Content'),
+                  style: OutlinedButton.styleFrom(
+                    foregroundColor: AppTheme.colors.primary,
+                    side: BorderSide(color: AppTheme.colors.primary),
+                  ),
+                ),
+              ),
+              const SizedBox(width: 12),
+              Expanded(
+                child: ElevatedButton.icon(
+                  onPressed: () {
+                    // TODO: Implement content saving
+                  },
+                  icon: const Icon(Icons.bookmark_border),
+                  label: const Text('Save'),
+                  style: ElevatedButton.styleFrom(
+                    backgroundColor: AppTheme.colors.primary,
+                    foregroundColor: Colors.white,
+                  ),
+                ),
+              ),
+            ],
+          ),
+        ],
+      ),
+    ).animate().fadeIn().slideX(begin: 0.3);
+  }
+
+  Color _getCategoryColor(String category) {
+    switch (category.toLowerCase()) {
+      case 'training & enrichment':
+        return AppTheme.colors.primary;
+      case 'wellness & care':
+        return AppTheme.colors.success;
+      case 'social & bonding':
+        return AppTheme.colors.secondary;
+      case 'health & nutrition':
+        return AppTheme.colors.warning;
+      case 'exercise & activity':
+        return AppTheme.colors.info;
+      case 'grooming & care':
+        return AppTheme.colors.secondary;
+      case 'adventure & exploration':
+        return AppTheme.colors.primary;
+      default:
+        return AppTheme.colors.textSecondary;
+    }
+  }
+
+  IconData _getCategoryIcon(String category) {
+    switch (category.toLowerCase()) {
+      case 'training & enrichment':
+        return Icons.school;
+      case 'wellness & care':
+        return Icons.favorite;
+      case 'social & bonding':
+        return Icons.people;
+      case 'health & nutrition':
+        return Icons.health_and_safety;
+      case 'exercise & activity':
+        return Icons.fitness_center;
+      case 'grooming & care':
+        return Icons.brush;
+      case 'adventure & exploration':
+        return Icons.explore;
+      default:
+        return Icons.article;
+    }
+  }
+}// Personalized Content Widget
