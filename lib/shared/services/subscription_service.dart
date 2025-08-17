import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../models/subscription_models.dart';
import 'dart:math';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // Mock data for demonstration
  final Map<String, SubscriptionInfo> _subscriptions = {};
  final List<SubscriptionPlan> _availablePlans = [];
  final List<VeterinaryPartner> _veterinaryPartners = [];
  final List<InsuranceProvider> _insuranceProviders = [];

  /// Initialize mock data
  void initializeMockData() {
    _initializeSubscriptionPlans();
    _initializeVeterinaryPartners();
    _initializeInsuranceProviders();
  }

  /// Get available subscription plans
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_availablePlans);
  }

  /// Get user's current subscription
  Future<SubscriptionInfo?> getUserSubscription(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _subscriptions[userId];
  }

  /// Subscribe to a plan
  Future<SubscriptionResult> subscribeToPlan({
    required String userId,
    required String planId,
    required String paymentMethodId,
    required BillingCycle billingCycle,
    String? promoCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final plan = _availablePlans.firstWhere(
        (p) => p.id == planId,
        orElse: () => SubscriptionPlan.empty(),
      );

      if (plan.id.isEmpty) {
        return SubscriptionResult(
          success: false,
          message: 'Invalid subscription plan',
          subscription: null,
        );
      }

      // Calculate pricing
      final basePrice = plan.monthlyPrice;
      final discount = promoCode != null ? _getPromoCodeDiscount(promoCode) : 0.0;
      final finalPrice = basePrice - discount;

      // Create subscription
      final subscription = SubscriptionInfo(
        plan: plan.name,
        startDate: DateTime.now(),
        isActive: true,
        features: plan.features,
        monthlyPrice: finalPrice,
        billingCycle: billingCycle,
        nextBillingDate: _calculateNextBillingDate(DateTime.now(), billingCycle),
        paymentMethodId: paymentMethodId,
        promoCode: promoCode,
        autoRenew: true,
        cancellationDate: null,
        refundAmount: 0.0,
        status: SubscriptionStatus.active,
      );

      _subscriptions[userId] = subscription;

      return SubscriptionResult(
        success: true,
        message: 'Successfully subscribed to ${plan.name}',
        subscription: subscription,
      );
    } catch (e) {
      return SubscriptionResult(
        success: false,
        message: 'Failed to subscribe: $e',
        subscription: null,
      );
    }
  }

  /// Cancel subscription
  Future<SubscriptionResult> cancelSubscription({
    required String userId,
    required String reason,
    bool requestRefund = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final subscription = _subscriptions[userId];
      if (subscription == null) {
        return SubscriptionResult(
          success: false,
          message: 'No active subscription found',
          subscription: null,
        );
      }

      // Calculate refund if requested
      double refundAmount = 0.0;
      if (requestRefund) {
        final daysRemaining = subscription.nextBillingDate.difference(DateTime.now()).inDays;
        if (daysRemaining > 0) {
          refundAmount = (subscription.monthlyPrice / 30) * daysRemaining;
        }
      }

      // Update subscription
      subscription.isActive = false;
      subscription.status = SubscriptionStatus.cancelled;
      subscription.cancellationDate = DateTime.now();
      subscription.refundAmount = refundAmount;
      subscription.autoRenew = false;

      _subscriptions[userId] = subscription;

      return SubscriptionResult(
        success: true,
        message: 'Subscription cancelled successfully',
        subscription: subscription,
      );
    } catch (e) {
      return SubscriptionResult(
        success: false,
        message: 'Failed to cancel subscription: $e',
        subscription: null,
      );
    }
  }

  /// Upgrade subscription
  Future<SubscriptionResult> upgradeSubscription({
    required String userId,
    required String newPlanId,
    bool prorate = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final currentSubscription = _subscriptions[userId];
      if (currentSubscription == null) {
        return SubscriptionResult(
          success: false,
          message: 'No active subscription found',
          subscription: null,
        );
      }

      final newPlan = _availablePlans.firstWhere(
        (p) => p.id == newPlanId,
        orElse: () => SubscriptionPlan.empty(),
      );

      if (newPlan.id.isEmpty) {
        return SubscriptionResult(
          success: false,
          message: 'Invalid subscription plan',
          subscription: null,
        );
      }

      // Calculate prorated amount if applicable
      double proratedAmount = 0.0;
      if (prorate) {
        final daysRemaining = currentSubscription.nextBillingDate.difference(DateTime.now()).inDays;
        final currentPlanDailyRate = currentSubscription.monthlyPrice / 30;
        final newPlanDailyRate = newPlan.monthlyPrice / 30;
        final dailyDifference = newPlanDailyRate - currentPlanDailyRate;
        proratedAmount = dailyDifference * daysRemaining;
      }

      // Update subscription
      currentSubscription.plan = newPlan.name;
      currentSubscription.features = newPlan.features;
      currentSubscription.monthlyPrice = newPlan.monthlyPrice;
      if (proratedAmount != 0) {
        currentSubscription.monthlyPrice += proratedAmount;
      }

      _subscriptions[userId] = currentSubscription;

      return SubscriptionResult(
        success: true,
        message: 'Successfully upgraded to ${newPlan.name}',
        subscription: currentSubscription,
      );
    } catch (e) {
      return SubscriptionResult(
        success: false,
        message: 'Failed to upgrade subscription: $e',
        subscription: null,
      );
    }
  }

  /// Get family plan members
  Future<List<FamilyMember>> getFamilyMembers(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Mock family members
    return [
      FamilyMember(
        id: 'member1',
        name: 'Sarah Johnson',
        email: 'sarah@example.com',
        role: FamilyRole.owner,
        joinedDate: DateTime.now().subtract(const Duration(days: 30)),
        pets: ['Luna', 'Buddy'],
        permissions: ['full_access'],
      ),
      FamilyMember(
        id: 'member2',
        name: 'John Johnson',
        email: 'john@example.com',
        role: FamilyRole.member,
        joinedDate: DateTime.now().subtract(const Duration(days: 25)),
        pets: ['Luna', 'Buddy'],
        permissions: ['view_pets', 'log_health'],
      ),
      FamilyMember(
        id: 'member3',
        name: 'Emma Johnson',
        email: 'emma@example.com',
        role: FamilyRole.member,
        joinedDate: DateTime.now().subtract(const Duration(days: 20)),
        pets: ['Whiskers'],
        permissions: ['view_pets', 'log_health'],
      ),
    ];
  }

  /// Add family member
  Future<bool> addFamilyMember({
    required String userId,
    required String email,
    required String name,
    required List<String> permissions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Check if user has family plan
    final subscription = await getUserSubscription(userId);
    if (subscription == null || !subscription.features.contains('family_plan')) {
      return false;
    }

    // Check family member limit
    final currentMembers = await getFamilyMembers(userId);
    if (currentMembers.length >= 6) { // Family plan limit
      return false;
    }

    // In real implementation, send invitation email
    // For now, just return success
    return true;
  }

  /// Remove family member
  Future<bool> removeFamilyMember({
    required String userId,
    required String memberId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Check if user has family plan
    final subscription = await getUserSubscription(userId);
    if (subscription == null || !subscription.features.contains('family_plan')) {
      return false;
    }

    // In real implementation, remove member and update permissions
    return true;
  }

  /// Get veterinary partners
  Future<List<VeterinaryPartner>> getVeterinaryPartners({
    String? location,
    String? specialty,
    double? maxDistance,
    int page = 0,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    List<VeterinaryPartner> filteredPartners = List.from(_veterinaryPartners);

    // Filter by location
    if (location != null) {
      filteredPartners = filteredPartners.where((partner) => 
        partner.location.toLowerCase().contains(location.toLowerCase())
      ).toList();
    }

    // Filter by specialty
    if (specialty != null) {
      filteredPartners = filteredPartners.where((partner) => 
        partner.specialties.contains(specialty)
      ).toList();
    }

    // Sort by rating (highest first)
    filteredPartners.sort((a, b) => b.rating.compareTo(a.rating));

    // Pagination
    final startIndex = page * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredPartners.length) {
      return [];
    }

    return filteredPartners.sublist(
      startIndex, 
      endIndex > filteredPartners.length ? filteredPartners.length : endIndex
    );
  }

  /// Book veterinary appointment
  Future<AppointmentResult> bookVeterinaryAppointment({
    required String userId,
    required String partnerId,
    required DateTime appointmentDate,
    required String petId,
    required String reason,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final partner = _veterinaryPartners.firstWhere(
        (p) => p.id == partnerId,
        orElse: () => VeterinaryPartner.empty(),
      );

      if (partner.id.isEmpty) {
        return AppointmentResult(
          success: false,
          message: 'Invalid veterinary partner',
          appointment: null,
        );
      }

      // Check availability
      if (!_isAppointmentAvailable(partnerId, appointmentDate)) {
        return AppointmentResult(
          success: false,
          message: 'Appointment time not available',
          appointment: null,
        );
      }

      // Create appointment
      final appointment = VeterinaryAppointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        partnerId: partnerId,
        partnerName: partner.name,
        appointmentDate: appointmentDate,
        petId: petId,
        reason: reason,
        notes: notes,
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        price: partner.consultationFee,
        duration: 30, // minutes
      );

      return AppointmentResult(
        success: true,
        message: 'Appointment booked successfully',
        appointment: appointment,
      );
    } catch (e) {
      return AppointmentResult(
        success: false,
        message: 'Failed to book appointment: $e',
        appointment: null,
      );
    }
  }

  /// Get insurance providers
  Future<List<InsuranceProvider>> getInsuranceProviders({
    String? petType,
    String? location,
    double? maxPremium,
    int page = 0,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    List<InsuranceProvider> filteredProviders = List.from(_insuranceProviders);

    // Filter by pet type
    if (petType != null) {
      filteredProviders = filteredProviders.where((provider) => 
        provider.coveredPetTypes.contains(petType)
      ).toList();
    }

    // Filter by location
    if (location != null) {
      filteredProviders = filteredProviders.where((provider) => 
        provider.serviceAreas.contains(location)
      ).toList();
    }

    // Filter by max premium
    if (maxPremium != null) {
      filteredProviders = filteredProviders.where((provider) => 
        provider.monthlyPremium <= maxPremium
      ).toList();
    }

    // Sort by rating (highest first)
    filteredProviders.sort((a, b) => b.rating.compareTo(a.rating));

    // Pagination
    final startIndex = page * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredProviders.length) {
      return [];
    }

    return filteredProviders.sublist(
      startIndex, 
      endIndex > filteredProviders.length ? filteredProviders.length : endIndex
    );
  }

  /// Get insurance quote
  Future<InsuranceQuote> getInsuranceQuote({
    required String userId,
    required String providerId,
    required String petId,
    required Pet pet,
    required List<String> coverageOptions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final provider = _insuranceProviders.firstWhere(
        (p) => p.id == providerId,
        orElse: () => InsuranceProvider.empty(),
      );

      if (provider.id.isEmpty) {
        return InsuranceQuote(
          id: '',
          providerId: '',
          providerName: '',
          monthlyPremium: 0.0,
          annualPremium: 0.0,
          deductible: 0.0,
          coverage: [],
          validUntil: DateTime.now(),
          terms: '',
        );
      }

      // Calculate premium based on pet and coverage
      double basePremium = _calculateBasePremium(pet, provider);
      double coverageMultiplier = _calculateCoverageMultiplier(coverageOptions);
      double monthlyPremium = basePremium * coverageMultiplier;

      final quote = InsuranceQuote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        providerId: providerId,
        providerName: provider.name,
        monthlyPremium: monthlyPremium,
        annualPremium: monthlyPremium * 12,
        deductible: _getDeductibleForCoverage(coverageOptions),
        coverage: coverageOptions,
        validUntil: DateTime.now().add(const Duration(days: 30)),
        terms: _getTermsForCoverage(coverageOptions),
      );

      return quote;
    } catch (e) {
      return InsuranceQuote(
        id: '',
        providerId: '',
        providerName: '',
        monthlyPremium: 0.0,
        annualPremium: 0.0,
        deductible: 0.0,
        coverage: [],
        validUntil: DateTime.now(),
        terms: '',
      );
    }
  }

  /// Purchase insurance
  Future<InsuranceResult> purchaseInsurance({
    required String userId,
    required String quoteId,
    required String paymentMethodId,
    required String petId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      // In real implementation, this would process payment and create insurance policy
      // For now, just return success
      return InsuranceResult(
        success: true,
        message: 'Insurance purchased successfully',
        policyNumber: 'POL-${DateTime.now().millisecondsSinceEpoch}',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(years: 1)),
      );
    } catch (e) {
      return InsuranceResult(
        success: false,
        message: 'Failed to purchase insurance: $e',
        policyNumber: null,
        startDate: null,
        endDate: null,
      );
    }
  }

  /// Get subscription analytics
  Future<SubscriptionAnalytics> getSubscriptionAnalytics(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final subscription = await getUserSubscription(userId);
    if (subscription == null) {
      return SubscriptionAnalytics(
        userId: userId,
        currentPlan: 'Free',
        daysRemaining: 0,
        usageStats: {},
        featureUsage: {},
        recommendations: [],
      );
    }

    return SubscriptionAnalytics(
      userId: userId,
      currentPlan: subscription.plan,
      daysRemaining: subscription.nextBillingDate.difference(DateTime.now()).inDays,
      usageStats: _getUsageStats(userId),
      featureUsage: _getFeatureUsage(userId),
      recommendations: _getRecommendations(userId, subscription),
    );
  }

  // Private helper methods
  void _initializeSubscriptionPlans() {
    _availablePlans.addAll([
      SubscriptionPlan(
        id: 'free',
        name: 'Free',
        description: 'Basic pet care features',
        monthlyPrice: 0.0,
        yearlyPrice: 0.0,
        features: [
          'basic_pet_profiles',
          'health_logging',
          'basic_reminders',
          'community_access',
        ],
        maxPets: 2,
        maxPhotos: 10,
        supportLevel: 'community',
        popular: false,
      ),
      SubscriptionPlan(
        id: 'basic',
        name: 'Basic',
        description: 'Essential pet care features',
        monthlyPrice: 4.99,
        yearlyPrice: 49.99,
        features: [
          'basic_pet_profiles',
          'health_logging',
          'advanced_reminders',
          'community_access',
          'basic_analytics',
          'email_support',
        ],
        maxPets: 5,
        maxPhotos: 50,
        supportLevel: 'email',
        popular: false,
      ),
      SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        description: 'Advanced pet care and AI features',
        monthlyPrice: 9.99,
        yearlyPrice: 99.99,
        features: [
          'unlimited_pet_profiles',
          'advanced_health_logging',
          'ai_insights',
          'behavioral_analysis',
          'advanced_analytics',
          'priority_support',
          'family_plan',
          'veterinary_discounts',
        ],
        maxPets: -1, // Unlimited
        maxPhotos: -1, // Unlimited
        supportLevel: 'priority',
        popular: true,
      ),
      SubscriptionPlan(
        id: 'family',
        name: 'Family',
        description: 'Perfect for multi-pet households',
        monthlyPrice: 14.99,
        yearlyPrice: 149.99,
        features: [
          'unlimited_pet_profiles',
          'advanced_health_logging',
          'ai_insights',
          'behavioral_analysis',
          'advanced_analytics',
          'priority_support',
          'family_plan',
          'veterinary_discounts',
          'family_analytics',
          'shared_calendars',
        ],
        maxPets: -1, // Unlimited
        maxPhotos: -1, // Unlimited
        supportLevel: 'dedicated',
        popular: false,
      ),
    ]);
  }

  void _initializeVeterinaryPartners() {
    _veterinaryPartners.addAll([
      VeterinaryPartner(
        id: '1',
        name: 'Central Park Veterinary Clinic',
        description: 'Full-service veterinary clinic with emergency care',
        location: 'New York, NY',
        specialties: ['General Practice', 'Emergency Care', 'Surgery'],
        rating: 4.8,
        reviewCount: 156,
        consultationFee: 85.0,
        isPartner: true,
        discountPercentage: 15.0,
        photoUrl: 'https://example.com/clinic1.jpg',
        contactInfo: {
          'phone': '+1-555-0123',
          'email': 'info@centralparkvet.com',
          'website': 'https://centralparkvet.com',
        },
        hours: {
          'Monday': '8:00 AM - 6:00 PM',
          'Tuesday': '8:00 AM - 6:00 PM',
          'Wednesday': '8:00 AM - 6:00 PM',
          'Thursday': '8:00 AM - 6:00 PM',
          'Friday': '8:00 AM - 6:00 PM',
          'Saturday': '9:00 AM - 4:00 PM',
          'Sunday': 'Closed',
        },
      ),
      VeterinaryPartner(
        id: '2',
        name: 'Pet Wellness Center',
        description: 'Holistic and preventive care for pets',
        location: 'Los Angeles, CA',
        specialties: ['Preventive Care', 'Holistic Medicine', 'Nutrition'],
        rating: 4.6,
        reviewCount: 89,
        consultationFee: 75.0,
        isPartner: true,
        discountPercentage: 20.0,
        photoUrl: 'https://example.com/clinic2.jpg',
        contactInfo: {
          'phone': '+1-555-0456',
          'email': 'info@petwellness.com',
          'website': 'https://petwellness.com',
        },
        hours: {
          'Monday': '9:00 AM - 5:00 PM',
          'Tuesday': '9:00 AM - 5:00 PM',
          'Wednesday': '9:00 AM - 5:00 PM',
          'Thursday': '9:00 AM - 5:00 PM',
          'Friday': '9:00 AM - 5:00 PM',
          'Saturday': '10:00 AM - 3:00 PM',
          'Sunday': 'Closed',
        },
      ),
      VeterinaryPartner(
        id: '3',
        name: 'Emergency Pet Hospital',
        description: '24/7 emergency veterinary care',
        location: 'Chicago, IL',
        specialties: ['Emergency Care', 'Critical Care', 'Trauma'],
        rating: 4.7,
        reviewCount: 234,
        consultationFee: 120.0,
        isPartner: true,
        discountPercentage: 10.0,
        photoUrl: 'https://example.com/clinic3.jpg',
        contactInfo: {
          'phone': '+1-555-0789',
          'email': 'info@emergencypethospital.com',
          'website': 'https://emergencypethospital.com',
        },
        hours: {
          'Monday': '24/7',
          'Tuesday': '24/7',
          'Wednesday': '24/7',
          'Thursday': '24/7',
          'Friday': '24/7',
          'Saturday': '24/7',
          'Sunday': '24/7',
        },
      ),
    ]);
  }

  void _initializeInsuranceProviders() {
    _insuranceProviders.addAll([
      InsuranceProvider(
        id: '1',
        name: 'PetCare Insurance',
        description: 'Comprehensive pet insurance coverage',
        rating: 4.5,
        reviewCount: 1234,
        monthlyPremium: 25.0,
        coveredPetTypes: ['Dog', 'Cat', 'Bird', 'Rabbit'],
        serviceAreas: ['United States', 'Canada'],
        coverageOptions: [
          'accident_coverage',
          'illness_coverage',
          'wellness_coverage',
          'dental_coverage',
        ],
        photoUrl: 'https://example.com/insurance1.jpg',
        website: 'https://petcareinsurance.com',
      ),
      InsuranceProvider(
        id: '2',
        name: 'HealthyPaws',
        description: 'Simple and comprehensive pet insurance',
        rating: 4.7,
        reviewCount: 2156,
        monthlyPremium: 30.0,
        coveredPetTypes: ['Dog', 'Cat'],
        serviceAreas: ['United States'],
        coverageOptions: [
          'accident_coverage',
          'illness_coverage',
          'cancer_coverage',
          'hereditary_coverage',
        ],
        photoUrl: 'https://example.com/insurance2.jpg',
        website: 'https://healthypaws.com',
      ),
      InsuranceProvider(
        id: '3',
        name: 'Trupanion',
        description: 'Lifetime pet insurance with no payout limits',
        rating: 4.6,
        reviewCount: 1890,
        monthlyPremium: 35.0,
        coveredPetTypes: ['Dog', 'Cat'],
        serviceAreas: ['United States', 'Canada'],
        coverageOptions: [
          'accident_coverage',
          'illness_coverage',
          'congenital_coverage',
          'hereditary_coverage',
        ],
        photoUrl: 'https://example.com/insurance3.jpg',
        website: 'https://trupanion.com',
      ),
    ]);
  }

  double _getPromoCodeDiscount(String promoCode) {
    // Mock promo code discounts
    final discounts = {
      'WELCOME20': 20.0,
      'SAVE15': 15.0,
      'FIRST10': 10.0,
    };
    return discounts[promoCode.toUpperCase()] ?? 0.0;
  }

  DateTime _calculateNextBillingDate(DateTime startDate, BillingCycle billingCycle) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case BillingCycle.yearly:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      case BillingCycle.quarterly:
        return DateTime(startDate.year, startDate.month + 3, startDate.day);
      default:
        return startDate.add(const Duration(days: 30));
    }
  }

  bool _isAppointmentAvailable(String partnerId, DateTime appointmentDate) {
    // Mock availability check
    final random = Random(partnerId.hashCode + appointmentDate.millisecondsSinceEpoch);
    return random.nextBool();
  }

  double _calculateBasePremium(Pet pet, InsuranceProvider provider) {
    // Mock premium calculation based on pet type and age
    double basePremium = provider.monthlyPremium;
    
    if (pet.type == 'Dog') {
      basePremium *= 1.2;
    } else if (pet.type == 'Cat') {
      basePremium *= 1.0;
    } else {
      basePremium *= 0.8;
    }
    
    // Age factor
    if (pet.age > 60) { // 5+ years
      basePremium *= 1.5;
    } else if (pet.age > 24) { // 2+ years
      basePremium *= 1.2;
    }
    
    return basePremium;
  }

  double _calculateCoverageMultiplier(List<String> coverageOptions) {
    double multiplier = 1.0;
    
    for (final coverage in coverageOptions) {
      switch (coverage) {
        case 'accident_coverage':
          multiplier += 0.3;
          break;
        case 'illness_coverage':
          multiplier += 0.4;
          break;
        case 'wellness_coverage':
          multiplier += 0.2;
          break;
        case 'dental_coverage':
          multiplier += 0.25;
          break;
        case 'cancer_coverage':
          multiplier += 0.5;
          break;
      }
    }
    
    return multiplier;
  }

  double _getDeductibleForCoverage(List<String> coverageOptions) {
    if (coverageOptions.length <= 2) return 250.0;
    if (coverageOptions.length <= 4) return 200.0;
    return 150.0;
  }

  String _getTermsForCoverage(List<String> coverageOptions) {
    return 'Coverage includes: ${coverageOptions.join(', ')}. Terms and conditions apply.';
  }

  Map<String, dynamic> _getUsageStats(String userId) {
    // Mock usage statistics
    return {
      'pets_managed': 3,
      'health_logs': 45,
      'photos_uploaded': 23,
      'training_sessions': 12,
      'community_posts': 8,
    };
  }

  Map<String, double> _getFeatureUsage(String userId) {
    // Mock feature usage percentages
    return {
      'health_logging': 0.85,
      'photo_sharing': 0.60,
      'training_tracking': 0.40,
      'community_engagement': 0.30,
      'ai_insights': 0.25,
    };
  }

  List<String> _getRecommendations(String userId, SubscriptionInfo subscription) {
    final recommendations = <String>[];
    
    if (subscription.plan == 'Free') {
      recommendations.add('Upgrade to Basic plan for advanced features');
      recommendations.add('Get email support for better assistance');
    } else if (subscription.plan == 'Basic') {
      recommendations.add('Upgrade to Premium for AI insights');
      recommendations.add('Add family members with Family plan');
    } else if (subscription.plan == 'Premium') {
      recommendations.add('Consider Family plan for multi-pet households');
      recommendations.add('Explore veterinary partnerships for discounts');
    }
    
    return recommendations;
  }
}

// Additional models for subscription service
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final int maxPets;
  final int maxPhotos;
  final String supportLevel;
  final bool popular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.maxPets,
    required this.maxPhotos,
    required this.supportLevel,
    required this.popular,
  });

  factory SubscriptionPlan.empty() {
    return SubscriptionPlan(
      id: '',
      name: '',
      description: '',
      monthlyPrice: 0.0,
      yearlyPrice: 0.0,
      features: [],
      maxPets: 0,
      maxPhotos: 0,
      supportLevel: '',
      popular: false,
    );
  }
}

class SubscriptionResult {
  final bool success;
  final String message;
  final SubscriptionInfo? subscription;

  SubscriptionResult({
    required this.success,
    required this.message,
    this.subscription,
  });
}

class FamilyMember {
  final String id;
  final String name;
  final String email;
  final FamilyRole role;
  final DateTime joinedDate;
  final List<String> pets;
  final List<String> permissions;

  FamilyMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedDate,
    required this.pets,
    required this.permissions,
  });
}

enum FamilyRole { owner, member, guest }

class VeterinaryPartner {
  final String id;
  final String name;
  final String description;
  final String location;
  final List<String> specialties;
  final double rating;
  final int reviewCount;
  final double consultationFee;
  final bool isPartner;
  final double discountPercentage;
  final String photoUrl;
  final Map<String, String> contactInfo;
  final Map<String, String> hours;

  VeterinaryPartner({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.specialties,
    required this.rating,
    required this.reviewCount,
    required this.consultationFee,
    required this.isPartner,
    required this.discountPercentage,
    required this.photoUrl,
    required this.contactInfo,
    required this.hours,
  });

  factory VeterinaryPartner.empty() {
    return VeterinaryPartner(
      id: '',
      name: '',
      description: '',
      location: '',
      specialties: [],
      rating: 0.0,
      reviewCount: 0,
      consultationFee: 0.0,
      isPartner: false,
      discountPercentage: 0.0,
      photoUrl: '',
      contactInfo: {},
      hours: {},
    );
  }
}

class VeterinaryAppointment {
  final String id;
  final String userId;
  final String partnerId;
  final String partnerName;
  final DateTime appointmentDate;
  final String petId;
  final String reason;
  final String? notes;
  final AppointmentStatus status;
  final DateTime createdAt;
  final double price;
  final int duration;

  VeterinaryAppointment({
    required this.id,
    required this.userId,
    required this.partnerId,
    required this.partnerName,
    required this.appointmentDate,
    required this.petId,
    required this.reason,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.price,
    required this.duration,
  });
}

enum AppointmentStatus { scheduled, confirmed, completed, cancelled }

class AppointmentResult {
  final bool success;
  final String message;
  final VeterinaryAppointment? appointment;

  AppointmentResult({
    required this.success,
    required this.message,
    this.appointment,
  });
}

class InsuranceProvider {
  final String id;
  final String name;
  final String description;
  final double rating;
  final int reviewCount;
  final double monthlyPremium;
  final List<String> coveredPetTypes;
  final List<String> serviceAreas;
  final List<String> coverageOptions;
  final String photoUrl;
  final String website;

  InsuranceProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.monthlyPremium,
    required this.coveredPetTypes,
    required this.serviceAreas,
    required this.coverageOptions,
    required this.photoUrl,
    required this.website,
  });

  factory InsuranceProvider.empty() {
    return InsuranceProvider(
      id: '',
      name: '',
      description: '',
      rating: 0.0,
      reviewCount: 0,
      monthlyPremium: 0.0,
      coveredPetTypes: [],
      serviceAreas: [],
      coverageOptions: [],
      photoUrl: '',
      website: '',
    );
  }
}

class InsuranceQuote {
  final String id;
  final String providerId;
  final String providerName;
  final double monthlyPremium;
  final double annualPremium;
  final double deductible;
  final List<String> coverage;
  final DateTime validUntil;
  final String terms;

  InsuranceQuote({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.monthlyPremium,
    required this.annualPremium,
    required this.deductible,
    required this.coverage,
    required this.validUntil,
    required this.terms,
  });
}

class InsuranceResult {
  final bool success;
  final String message;
  final String? policyNumber;
  final DateTime? startDate;
  final DateTime? endDate;

  InsuranceResult({
    required this.success,
    required this.message,
    this.policyNumber,
    this.startDate,
    this.endDate,
  });
}

class SubscriptionAnalytics {
  final String userId;
  final String currentPlan;
  final int daysRemaining;
  final Map<String, dynamic> usageStats;
  final Map<String, double> featureUsage;
  final List<String> recommendations;

  SubscriptionAnalytics({
    required this.userId,
    required this.currentPlan,
    required this.daysRemaining,
    required this.usageStats,
    required this.featureUsage,
    required this.recommendations,
  });
}

enum BillingCycle { monthly, yearly, quarterly }
enum SubscriptionStatus { active, cancelled, suspended, expired }