import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String provider;
  final double rating;
  final int reviewCount;
  final double price;
  final String imageUrl;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.provider,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.pets,
                      color: AppTheme.colors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.textStyles.titleMedium?.copyWith(
                            color: AppTheme.colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider,
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: AppTheme.textStyles.titleMedium?.copyWith(
                          color: AppTheme.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.colors.warning,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                          ),
                          Text(
                            ' ($reviewCount)',
                            style: AppTheme.textStyles.bodySmall?.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.colors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Local Service',
                        style: AppTheme.textStyles.bodySmall?.copyWith(
                          color: AppTheme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colors.primary,
                      foregroundColor: AppTheme.colors.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Book Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}