import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/pet.dart';

class AddPetDialog extends StatefulWidget {
  const AddPetDialog({super.key});

  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _selectedType = 'Dog';
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365));
  String _selectedEnergyLevel = 'medium';
  
  final List<String> _petTypes = ['Dog', 'Cat', 'Bird', 'Fish', 'Hamster', 'Rabbit', 'Other'];
  final List<String> _energyLevels = ['low', 'medium', 'high'];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppTheme.gentleCream,
          borderRadius: BorderRadius.circular(AppConstants.lgRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.warmGrey.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.lgSpacing),
              decoration: BoxDecoration(
                color: AppTheme.heartPink,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.lgRadius),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pets,
                      color: AppTheme.heartPink,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppConstants.mdSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Pet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Welcome to the family!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Form
            Padding(
              padding: const EdgeInsets.all(AppConstants.lgSpacing),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Pet Type Selection
                    _buildTypeSelector(),
                    
                    const SizedBox(height: AppConstants.mdSpacing),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Pet Name',
                        hintText: 'Enter your pet\'s name',
                        prefixIcon: Icon(Icons.pets, color: AppTheme.heartPink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppConstants.mdSpacing),
                    
                    // Breed Field
                    TextFormField(
                      controller: _breedController,
                      decoration: InputDecoration(
                        labelText: 'Breed',
                        hintText: 'e.g., Golden Retriever, Persian Cat',
                        prefixIcon: Icon(Icons.pets, color: AppTheme.leafGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a breed';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppConstants.mdSpacing),
                    
                    // Weight Field
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        hintText: 'e.g., 15.5',
                        prefixIcon: Icon(Icons.monitor_weight, color: AppTheme.softPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Please enter a valid weight';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppConstants.mdSpacing),
                    
                    // Birth Date Selection
                    _buildDateSelector(),
                    
                    const SizedBox(height: AppConstants.mdSpacing),
                    
                    // Energy Level Selection
                    _buildEnergyLevelSelector(),
                    
                    const SizedBox(height: AppConstants.xlSpacing),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppConstants.mdSpacing),
                              side: BorderSide(color: AppTheme.warmGrey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.xlRadius),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: AppTheme.warmGrey),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.mdSpacing),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _createPet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.heartPink,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: AppConstants.mdSpacing),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.xlRadius),
                              ),
                            ),
                            child: Text(
                              'Add Pet',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation)
      .scale(begin: const Offset(0.8, 0.8), duration: AppConstants.mediumAnimation);
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pet Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _petTypes.length,
            itemBuilder: (context, index) {
              final type = _petTypes[index];
              final isSelected = _selectedType == type;
              
              return Container(
                margin: const EdgeInsets.only(right: AppConstants.smSpacing),
                child: ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  selectedColor: AppTheme.heartPink,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.warmGrey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(AppConstants.mdRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.mdSpacing,
              vertical: AppConstants.smSpacing,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.softPink),
              borderRadius: BorderRadius.circular(AppConstants.mdRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.heartPink,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.smSpacing),
                Text(
                  _formatDate(_selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.warmGrey,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.warmGrey.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Energy Level',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.warmGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        Row(
          children: _energyLevels.map((level) {
            final isSelected = _selectedEnergyLevel == level;
            final color = _getEnergyLevelColor(level);
            
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: AppConstants.xsSpacing),
                child: ChoiceChip(
                  label: Text(level.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedEnergyLevel = level;
                    });
                  },
                  selectedColor: color,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.warmGrey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.heartPink,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _createPet() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final pet = Pet(
        id: 'pet-${now.millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        type: _selectedType,
        avatar: 'default',
        birthDate: _selectedDate,
        breed: _breedController.text.trim(),
        weight: double.parse(_weightController.text),
        ownerId: 'default-user',
        createdAt: now,
        updatedAt: now,
        preferences: {
          'energy_level': _selectedEnergyLevel,
          'favorite_toy': 'Ball',
          'favorite_treat': 'Treats',
        },
        healthNotes: [
          'New family member!',
          'Loves attention and cuddles',
        ],
      );
      
      Navigator.pop(context, pet);
    }
  }

  Color _getEnergyLevelColor(String level) {
    switch (level) {
      case 'low':
        return AppTheme.softPurple;
      case 'medium':
        return AppTheme.leafGreen;
      case 'high':
        return AppTheme.heartPink;
      default:
        return AppTheme.leafGreen;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}