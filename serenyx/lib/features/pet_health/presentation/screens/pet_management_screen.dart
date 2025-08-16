import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/services/pet_service.dart';
import '../../../../shared/widgets/animated_pet_avatar.dart';
import '../widgets/add_pet_dialog.dart';
import '../widgets/edit_pet_dialog.dart';

class PetManagementScreen extends StatefulWidget {
  const PetManagementScreen({super.key});

  @override
  State<PetManagementScreen> createState() => _PetManagementScreenState();
}

class _PetManagementScreenState extends State<PetManagementScreen>
    with TickerProviderStateMixin {
  final PetService _petService = PetService();
  List<Pet> _pets = [];
  Pet? _currentPet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      await _petService.initialize();
      setState(() {
        _pets = _petService.pets;
        _currentPet = _petService.currentPet;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading pets: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewPet() async {
    final result = await showDialog<Pet>(
      context: context,
      builder: (context) => const AddPetDialog(),
    );

    if (result != null) {
      final success = await _petService.addPet(result);
      if (success) {
        await _loadPets();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} has been added to your family! 🐾'),
            backgroundColor: AppTheme.leafGreen,
          ),
        );
      }
    }
  }

  Future<void> _editPet(Pet pet) async {
    final result = await showDialog<Pet>(
      context: context,
      builder: (context) => EditPetDialog(pet: pet),
    );

    if (result != null) {
      final success = await _petService.updatePet(result);
      if (success) {
        await _loadPets();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name}\'s profile has been updated! ✨'),
            backgroundColor: AppTheme.leafGreen,
          ),
        );
      }
    }
  }

  Future<void> _deletePet(Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${pet.name}?'),
        content: Text('Are you sure you want to remove ${pet.name} from your family? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _petService.removePet(pet.id);
      if (success) {
        await _loadPets();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pet.name} has been removed from your family. 💔'),
            backgroundColor: AppTheme.heartPink,
          ),
        );
      }
    }
  }

  Future<void> _setCurrentPet(Pet pet) async {
    final success = await _petService.setCurrentPet(pet.id);
    if (success) {
      await _loadPets();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pet.name} is now your active pet! 🎯'),
          backgroundColor: AppTheme.leafGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.softPurpleGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPetList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewPet,
        backgroundColor: AppTheme.heartPink,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Pet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.warmGrey),
          ),
          Expanded(
            child: Text(
              'Pet Family',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.warmGrey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings, color: AppTheme.warmGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildPetList() {
    if (_pets.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      itemCount: _pets.length,
      itemBuilder: (context, index) {
        final pet = _pets[index];
        final isCurrentPet = _currentPet?.id == pet.id;
        
        return _buildPetCard(pet, isCurrentPet).animate()
          .fadeIn(duration: AppConstants.mediumAnimation, delay: Duration(milliseconds: index * 100))
          .slideX(begin: 0.3, duration: AppConstants.mediumAnimation, delay: Duration(milliseconds: index * 100));
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.softPink.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              color: AppTheme.heartPink,
              size: 60,
            ),
          ),
          const SizedBox(height: AppConstants.lgSpacing),
          Text(
            'No pets yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Text(
            'Add your first furry friend to get started!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.warmGrey.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.xlSpacing),
          ElevatedButton.icon(
            onPressed: _addNewPet,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Pet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.heartPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet, bool isCurrentPet) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.mdSpacing),
      decoration: BoxDecoration(
        color: AppTheme.gentleCream,
        borderRadius: BorderRadius.circular(AppConstants.lgRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPetDetails(pet),
          borderRadius: BorderRadius.circular(AppConstants.lgRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.lgSpacing),
            child: Row(
              children: [
                // Pet Avatar
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getPetColor(pet),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getPetColor(pet).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    if (isCurrentPet)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.leafGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: AppConstants.mdSpacing),
                
                // Pet Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.warmGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.xsSpacing),
                      Text(
                        '${pet.breed} • ${pet.age} years old',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.warmGrey.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: AppConstants.xsSpacing),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: AppTheme.heartPink,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pet.sessionCount} sessions',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.heartPink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editPet(pet);
                        break;
                      case 'delete':
                        _deletePet(pet);
                        break;
                      case 'set_current':
                        _setCurrentPet(pet);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isCurrentPet)
                      const PopupMenuItem(
                        value: 'set_current',
                        child: Row(
                          children: [
                            Icon(Icons.star, color: AppTheme.leafGreen),
                            SizedBox(width: 8),
                            Text('Set as Active'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppTheme.heartPink),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remove'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: AppTheme.warmGrey.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetDetails(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      decoration: BoxDecoration(
        color: AppTheme.gentleCream,
        borderRadius: BorderRadius.circular(AppConstants.lgRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getPetColor(pet),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppConstants.mdSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.warmGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${pet.breed} • ${pet.weight} kg',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.warmGrey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.lgSpacing),
          
          _buildDetailRow('Age', '${pet.age} years old'),
          _buildDetailRow('Birth Date', _formatDate(pet.birthDate)),
          _buildDetailRow('Sessions', '${pet.sessionCount} completed'),
          if (pet.lastSessionDate != null)
            _buildDetailRow('Last Session', _formatDate(pet.lastSessionDate!)),
          
          if (pet.preferences.isNotEmpty) ...[
            const SizedBox(height: AppConstants.mdSpacing),
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.warmGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.smSpacing),
            ...pet.preferences.entries.map((entry) => 
              _buildDetailRow(entry.key.replaceAll('_', ' ').toTitleCase(), entry.value.toString())
            ),
          ],
          
          if (pet.healthNotes.isNotEmpty) ...[
            const SizedBox(height: AppConstants.mdSpacing),
            Text(
              'Health Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.warmGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.smSpacing),
            ...pet.healthNotes.map((note) => 
              Container(
                margin: const EdgeInsets.only(bottom: AppConstants.xsSpacing),
                padding: const EdgeInsets.all(AppConstants.smSpacing),
                decoration: BoxDecoration(
                  color: AppTheme.softPink.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.smRadius),
                ),
                child: Text(
                  note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warmGrey,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smSpacing),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.warmGrey.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showPetDetails(Pet pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppTheme.gentleCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.lgRadius)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppConstants.mdSpacing),
              decoration: BoxDecoration(
                color: AppTheme.warmGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.lgSpacing),
                child: _buildPetDetails(pet),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPetColor(Pet pet) {
    final hash = pet.id.hashCode;
    final colors = [
      AppTheme.heartPink,
      AppTheme.leafGreen,
      AppTheme.softPurple,
      AppTheme.lightPink,
      AppTheme.pastelPeach,
    ];
    
    return colors[hash.abs() % colors.length];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}