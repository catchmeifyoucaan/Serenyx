import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/pet.dart';
import '../widgets/service_card.dart';
import '../widgets/product_card.dart';
import '../widgets/marketplace_filter.dart';

class MarketplaceScreen extends StatefulWidget {
  final Pet pet;

  const MarketplaceScreen({super.key, required this.pet});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _selectedFilter = 'Recommended';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: Text(
          'Pet Marketplace',
          style: AppTheme.textStyles.headlineMedium?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.colors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.colors.primary,
          unselectedLabelColor: AppTheme.colors.textSecondary,
          indicatorColor: AppTheme.colors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.store), text: 'Services'),
            Tab(icon: Icon(Icons.shopping_bag), text: 'Products'),
          ],
        ),
      ),
      body: Column(
        children: [
          MarketplaceFilter(
            selectedCategory: _selectedCategory,
            selectedFilter: _selectedFilter,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServicesTab(),
                _buildProductsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServicesSummary(),
          const SizedBox(height: 24),
          _buildServicesList(),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductsSummary(),
          const SizedBox(height: 24),
          _buildProductsList(),
        ],
      ),
    );
  }

  Widget _buildServicesSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pet Services',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildServiceStat(
                    'Available',
                    '24',
                    Icons.check_circle,
                    AppTheme.colors.success,
                  ),
                ),
                Expanded(
                  child: _buildServiceStat(
                    'Top Rated',
                    '8',
                    Icons.star,
                    AppTheme.colors.warning,
                  ),
                ),
                Expanded(
                  child: _buildServiceStat(
                    'Near You',
                    '12',
                    Icons.location_on,
                    AppTheme.colors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  color: AppTheme.colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pet Products',
                  style: AppTheme.textStyles.headlineSmall?.copyWith(
                    color: AppTheme.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildServiceStat(
                    'Available',
                    '156',
                    Icons.inventory,
                    AppTheme.colors.success,
                  ),
                ),
                Expanded(
                  child: _buildServiceStat(
                    'On Sale',
                    '23',
                    Icons.local_offer,
                    AppTheme.colors.error,
                  ),
                ),
                Expanded(
                  child: _buildServiceStat(
                    'Top Picks',
                    '12',
                    Icons.favorite,
                    AppTheme.colors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.textStyles.titleLarge?.copyWith(
            color: AppTheme.colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildServicesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Services',
          style: AppTheme.textStyles.titleLarge?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // Service cards would go here
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.colors.outline),
          ),
          child: Text(
            'Professional grooming, training, pet sitting, and veterinary services available in your area.',
            style: AppTheme.textStyles.bodyMedium?.copyWith(
              color: AppTheme.colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Products',
          style: AppTheme.textStyles.titleLarge?.copyWith(
            color: AppTheme.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.colors.outline),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        color: AppTheme.colors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Product ${index + 1}',
                      style: AppTheme.textStyles.titleMedium?.copyWith(
                        color: AppTheme.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}// Marketplace Screen
