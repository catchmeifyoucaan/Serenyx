import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/pet.dart';
import '../../../../shared/models/health_models.dart';
import '../../../../shared/services/pet_service.dart';
import '../widgets/health_record_card.dart';
import '../widgets/vaccination_tracker.dart';
import '../widgets/weight_monitor.dart';
import '../widgets/medication_log.dart';
import '../widgets/vet_visit_record.dart';

class EnhancedPetHealthScreen extends StatefulWidget {
  final Pet pet;
  
  const EnhancedPetHealthScreen({super.key, required this.pet});

  @override
  State<EnhancedPetHealthScreen> createState() => _EnhancedPetHealthScreenState();
}

class _EnhancedPetHealthScreenState extends State<EnhancedPetHealthScreen>
    with TickerProviderStateMixin {
  final PetService _petService = PetService();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<String> _petPhotos = [];
  List<VaccinationRecord> _vaccinations = [];
  List<WeightRecord> _weightRecords = [];
  List<MedicationRecord> _medications = [];
  List<VetVisitRecord> _vetVisits = [];
  
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    try {
      // Load all health data for the pet
      await _loadPhotos();
      await _loadVaccinations();
      await _loadWeightRecords();
      await _loadMedications();
      await _loadVetVisits();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading health data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPhotos() async {
    // Simulate loading photos from storage
    _petPhotos = [
      'https://via.placeholder.com/300/FF6B6B/FFFFFF?text=Photo+1',
      'https://via.placeholder.com/300/8BC34A/FFFFFF?text=Photo+2',
      'https://via.placeholder.com/300/9C27B0/FFFFFF?text=Photo+3',
    ];
  }

  Future<void> _loadVaccinations() async {
    // Simulate vaccination records
    _vaccinations = [
      VaccinationRecord(
        id: 'v1',
        name: 'Rabies',
        date: DateTime.now().subtract(const Duration(days: 180)),
        nextDue: DateTime.now().add(const Duration(days: 185)),
        veterinarian: 'Dr. Smith',
        clinic: 'Happy Paws Vet Clinic',
        cost: 45.00,
        notes: 'Annual rabies vaccination',
      ),
      VaccinationRecord(
        id: 'v2',
        name: 'DHPP',
        date: DateTime.now().subtract(const Duration(days: 90)),
        nextDue: DateTime.now().add(const Duration(days: 275)),
        veterinarian: 'Dr. Johnson',
        clinic: 'Happy Paws Vet Clinic',
        cost: 35.00,
        notes: 'Core vaccination series',
      ),
    ];
  }

  Future<void> _loadWeightRecords() async {
    // Simulate weight records
    _weightRecords = [
      WeightRecord(
        id: 'w1',
        weight: 15.2,
        date: DateTime.now().subtract(const Duration(days: 30)),
        notes: 'Monthly checkup',
      ),
      WeightRecord(
        id: 'w2',
        weight: 14.8,
        date: DateTime.now().subtract(const Duration(days: 60)),
        notes: 'Vet visit',
      ),
      WeightRecord(
        id: 'w3',
        weight: 14.5,
        date: DateTime.now().subtract(const Duration(days: 90)),
        notes: 'Regular monitoring',
      ),
    ];
  }

  Future<void> _loadMedications() async {
    // Simulate medication records
    _medications = [
      MedicationRecord(
        id: 'm1',
        name: 'Heartgard Plus',
        dosage: '1 chewable tablet',
        frequency: 'Monthly',
        startDate: DateTime.now().subtract(const Duration(days: 365)),
        endDate: null,
        notes: 'Heartworm prevention',
        isActive: true,
      ),
      MedicationRecord(
        id: 'm2',
        name: 'Flea & Tick Treatment',
        dosage: 'Topical application',
        frequency: 'Monthly',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: null,
        notes: 'Flea and tick prevention',
        isActive: true,
      ),
    ];
  }

  Future<void> _loadVetVisits() async {
    // Simulate vet visit records
    _vetVisits = [
      VetVisitRecord(
        id: 'vv1',
        date: DateTime.now().subtract(const Duration(days: 30)),
        reason: 'Annual checkup',
        veterinarian: 'Dr. Smith',
        clinic: 'Happy Paws Vet Clinic',
        diagnosis: 'Healthy',
        treatment: 'Routine examination',
        followUp: null,
        cost: 85.00, // Added missing cost parameter
        notes: 'Pet is in excellent health',
      ),
      VetVisitRecord(
        id: 'vv2',
        date: DateTime.now().subtract(const Duration(days: 90)),
        reason: 'Vaccination update',
        veterinarian: 'Dr. Johnson',
        clinic: 'Happy Paws Vet Clinic',
        diagnosis: 'N/A',
        treatment: 'DHPP vaccination',
        followUp: null,
        cost: 45.00, // Added missing cost parameter
        notes: 'Vaccination administered successfully',
      ),
    ];
  }

  Future<void> _addPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _petPhotos.insert(0, image.path);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo added to ${widget.pet.name}\'s collection! 📸'),
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
          gradient: AppTheme.softPinkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPhoto,
        backgroundColor: AppTheme.heartPink,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text(
          'Add Photo',
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
            child: Column(
              children: [
                Text(
                  '${widget.pet.name}\'s Health',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.warmGrey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Complete health management',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.warmGrey.withOpacity(0.7),
                  ),
                ),
              ],
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

  Widget _buildTabBar() {
    final tabs = [
      {'icon': Icons.photo_library, 'label': 'Photos'},
      {'icon': Icons.vaccines, 'label': 'Vaccinations'},
      {'icon': Icons.monitor_weight, 'label': 'Weight'},
      {'icon': Icons.medication, 'label': 'Medications'},
      {'icon': Icons.local_hospital, 'label': 'Vet Visits'},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.lgSpacing),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = _selectedTabIndex == index;
          
          return Container(
            margin: const EdgeInsets.only(right: AppConstants.smSpacing),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(AppConstants.mdRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.mdSpacing,
                  vertical: AppConstants.smSpacing,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.heartPink : AppTheme.softPink.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppConstants.mdRadius),
                  border: Border.all(
                    color: isSelected ? AppTheme.heartPink : AppTheme.softPink,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isSelected ? Colors.white : AppTheme.heartPink,
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.xsSpacing),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.heartPink,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPhotosTab();
      case 1:
        return VaccinationTracker(
          vaccinations: _vaccinations,
          onAddVaccination: _addVaccination,
          onEditVaccination: _editVaccination,
        );
      case 2:
        return WeightMonitor(
          weightRecords: _weightRecords,
          onAddWeight: _addWeightRecord,
          onEditWeight: _editWeightRecord,
        );
      case 3:
        return MedicationLog(
          medications: _medications,
          onAddMedication: _addMedication,
          onEditMedication: _editMedication,
        );
      case 4:
        return VetVisitRecordWidget(
          vetVisits: _vetVisits,
          onAddVetVisit: _addVetVisit,
          onEditVetVisit: _editVetVisit,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhotosTab() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
      children: [
        // Photo Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.mdSpacing,
            mainAxisSpacing: AppConstants.mdSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: _petPhotos.length,
          itemBuilder: (context, index) {
            return _buildPhotoCard(_petPhotos[index], index);
          },
        ),
        
        const SizedBox(height: AppConstants.xlSpacing),
        
        // Health Summary
        _buildHealthSummary(),
      ],
    );
  }

  Widget _buildPhotoCard(String photoUrl, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.mdRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warmGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.mdRadius),
        child: Stack(
          children: [
            Image.network(
              photoUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: AppConstants.smSpacing,
              right: AppConstants.smSpacing,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.heartPink,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: AppConstants.mediumAnimation, delay: Duration(milliseconds: index * 100))
      .scale(begin: const Offset(0.8, 0.8), duration: AppConstants.mediumAnimation, delay: Duration(milliseconds: index * 100));
  }

  Widget _buildHealthSummary() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.lgSpacing),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.mdSpacing),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Vaccinations',
                  '${_vaccinations.length}',
                  Icons.vaccines,
                  AppTheme.leafGreen,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Weight Records',
                  '${_weightRecords.length}',
                  Icons.monitor_weight,
                  AppTheme.heartPink,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Medications',
                  '${_medications.where((m) => m.isActive).length}',
                  Icons.medication,
                  AppTheme.softPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: AppConstants.smSpacing),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.warmGrey.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Placeholder methods for CRUD operations
  void _addVaccination() {
    // TODO: Implement add vaccination
  }

  void _editVaccination(VaccinationRecord vaccination) {
    // TODO: Implement edit vaccination
  }

  void _addWeightRecord() {
    // TODO: Implement add weight record
  }

  void _editWeightRecord(WeightRecord weightRecord) {
    // TODO: Implement edit weight record
  }

  void _addMedication() {
    // TODO: Implement add medication
  }

  void _editMedication(MedicationRecord medication) {
    // TODO: Implement edit medication
  }

  void _addVetVisit() {
    // TODO: Implement add vet visit
  }

  void _editVetVisit(VetVisitRecord vetVisit) {
    // TODO: Implement edit vet visit
  }
}





