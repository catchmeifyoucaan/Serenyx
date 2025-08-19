import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../models/subscription_models.dart';
import 'dart:math';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // Real API endpoints - replace with your actual backend URLs
  static const String _baseUrl = 'https://api.serenyx.com';
  static const String _apiKey = 'YOUR_SERENYX_API_KEY'; // Replace with real key
  static const String _stripeApiKey = 'YOUR_STRIPE_SECRET_KEY'; // Replace with real Stripe key

  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/plans'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final plans = data['plans'] as List;
        return plans.map((plan) => SubscriptionPlan.fromJson(plan)).toList();
      } else {
        throw Exception('Failed to fetch available plans: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch available plans: $e');
    }
  }

  Future<SubscriptionInfo?> getUserSubscription(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/users/$userId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['subscription'] != null) {
          return SubscriptionInfo.fromJson(data['subscription']);
        }
        return null;
      } else {
        throw Exception('Failed to fetch user subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user subscription: $e');
    }
  }

  Future<SubscriptionResult> subscribeToPlan({
    required String userId,
    required String planId,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/subscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'planId': planId,
          'paymentMethodId': paymentMethodId,
          'metadata': metadata ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubscriptionResult.fromJson(data);
      } else {
        throw Exception('Failed to subscribe to plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to subscribe to plan: $e');
    }
  }

  Future<SubscriptionResult> cancelSubscription({
    required String userId,
    required String subscriptionId,
    String? reason,
    bool immediate = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/$subscriptionId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'reason': reason,
          'immediate': immediate,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubscriptionResult.fromJson(data);
      } else {
        throw Exception('Failed to cancel subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  Future<SubscriptionResult> upgradeSubscription({
    required String userId,
    required String currentSubscriptionId,
    required String newPlanId,
    required DateTime effectiveDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/$currentSubscriptionId/upgrade'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'newPlanId': newPlanId,
          'effectiveDate': effectiveDate.toIso8601String(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubscriptionResult.fromJson(data);
      } else {
        throw Exception('Failed to upgrade subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upgrade subscription: $e');
    }
  }

  Future<List<FamilyMember>> getFamilyMembers(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/users/$userId/family'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final members = data['members'] as List;
        return members.map((member) => FamilyMember.fromJson(member)).toList();
      } else {
        throw Exception('Failed to fetch family members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch family members: $e');
    }
  }

  Future<bool> addFamilyMember({
    required String userId,
    required String email,
    required FamilyRole role,
    Map<String, dynamic>? permissions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/users/$userId/family'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'email': email,
          'role': role.name,
          'permissions': permissions ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to add family member: $e');
    }
  }

  Future<bool> removeFamilyMember({
    required String userId,
    required String familyMemberId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/subscriptions/users/$userId/family/$familyMemberId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to remove family member: $e');
    }
  }

  Future<List<VeterinaryPartner>> getVeterinaryPartners({
    String? location,
    String? specialization,
    double? maxDistance,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (location != null) queryParams['location'] = location;
      if (specialization != null) queryParams['specialization'] = specialization;
      if (maxDistance != null) queryParams['maxDistance'] = maxDistance.toString();

      final uri = Uri.parse('$_baseUrl/api/subscriptions/veterinary-partners').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final partners = data['partners'] as List;
        return partners.map((partner) => VeterinaryPartner.fromJson(partner)).toList();
      } else {
        throw Exception('Failed to fetch veterinary partners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch veterinary partners: $e');
    }
  }

  Future<AppointmentResult> bookVeterinaryAppointment({
    required String userId,
    required String partnerId,
    required DateTime appointmentDate,
    required String reason,
    required String petId,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/veterinary-partners/$partnerId/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'appointmentDate': appointmentDate.toIso8601String(),
          'reason': reason,
          'petId': petId,
          'additionalInfo': additionalInfo ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AppointmentResult.fromJson(data);
      } else {
        throw Exception('Failed to book appointment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }

  Future<List<InsuranceProvider>> getInsuranceProviders({
    String? location,
    String? petType,
    String? coverageType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (location != null) queryParams['location'] = location;
      if (petType != null) queryParams['petType'] = petType;
      if (coverageType != null) queryParams['coverageType'] = coverageType;

      final uri = Uri.parse('$_baseUrl/api/subscriptions/insurance-providers').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final providers = data['providers'] as List;
        return providers.map((provider) => InsuranceProvider.fromJson(provider)).toList();
      } else {
        throw Exception('Failed to fetch insurance providers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch insurance providers: $e');
    }
  }

  Future<InsuranceQuote> getInsuranceQuote({
    required String userId,
    required String providerId,
    required String petId,
    required Map<String, dynamic> petInfo,
    required Map<String, dynamic> coverageOptions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/insurance-providers/$providerId/quote'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'petId': petId,
          'petInfo': petInfo,
          'coverageOptions': coverageOptions,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InsuranceQuote.fromJson(data);
      } else {
        throw Exception('Failed to get insurance quote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get insurance quote: $e');
    }
  }

  Future<InsuranceResult> purchaseInsurance({
    required String userId,
    required String providerId,
    required String quoteId,
    required String paymentMethodId,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/insurance-providers/$providerId/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'quoteId': quoteId,
          'paymentMethodId': paymentMethodId,
          'additionalInfo': additionalInfo ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return InsuranceResult.fromJson(data);
      } else {
        throw Exception('Failed to purchase insurance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to purchase insurance: $e');
    }
  }

  Future<SubscriptionAnalytics> getSubscriptionAnalytics(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/users/$userId/analytics'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubscriptionAnalytics.fromJson(data);
      } else {
        throw Exception('Failed to fetch subscription analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch subscription analytics: $e');
    }
  }

  // Helper methods for subscription logic
  double calculateSubscriptionValue(SubscriptionPlan plan, User user) {
    final baseValue = plan.monthlyPrice;
    final userLevel = _calculateUserLevel(user);
    
    // Higher level users get better value
    final levelMultiplier = 1.0 + (userLevel * 0.02);
    final adjustedValue = baseValue * levelMultiplier;
    
    return adjustedValue;
  }

  int _calculateUserLevel(User user) {
    // Calculate user level based on various factors
    int level = 1;
    
    if (user.pets.isNotEmpty) level += 2;
    if (user.lastSignInAt != null) level += 1;
    if (user.isExpertVerified ?? false) level += 3;
    if (user.communityParticipationScore != null) {
      level += (user.communityParticipationScore! / 10).floor();
    }
    
    return level.clamp(1, 10);
  }

  Map<String, dynamic> calculateFamilyPlanSavings(
    SubscriptionPlan individualPlan,
    SubscriptionPlan familyPlan,
    int familySize,
  ) {
    final individualCost = individualPlan.monthlyPrice * familySize;
    final familyCost = familyPlan.monthlyPrice;
    final savings = individualCost - familyCost;
    final savingsPercentage = (savings / individualCost) * 100;
    
    return {
      'individualCost': individualCost,
      'familyCost': familyCost,
      'savings': savings,
      'savingsPercentage': savingsPercentage,
      'breakEvenSize': (familyPlan.monthlyPrice / individualPlan.monthlyPrice).ceil(),
    };
  }

  List<String> getRecommendedPlans(User user, List<SubscriptionPlan> availablePlans) {
    final recommendations = <String>[];
    
    if (user.pets.isEmpty) {
      recommendations.add('Start with the Basic plan to explore features');
    } else if (user.pets.length == 1) {
      recommendations.add('Premium plan offers advanced health monitoring');
    } else if (user.pets.length >= 2) {
      recommendations.add('Family plan provides best value for multiple pets');
    }
    
    if (user.isExpertVerified ?? false) {
      recommendations.add('Professional plan includes expert verification features');
    }
    
    if (user.communityParticipationScore != null && user.communityParticipationScore! > 50) {
      recommendations.add('Community plan enhances social features');
    }
    
    return recommendations;
  }

  Map<String, dynamic> getPlanComparison(List<SubscriptionPlan> plans) {
    final comparison = <String, Map<String, dynamic>>{};
    
    for (final plan in plans) {
      comparison[plan.id] = {
        'name': plan.name,
        'monthlyPrice': plan.monthlyPrice,
        'annualPrice': plan.monthlyPrice * 12,
        'features': plan.features,
        'petLimit': plan.petLimit,
        'familyMembers': plan.familyMembers,
        'veterinaryConsultations': plan.veterinaryConsultations,
        'insuranceDiscount': plan.insuranceDiscount,
        'prioritySupport': plan.prioritySupport,
      };
    }
    
    return comparison;
  }

  List<String> getFeatureUpgradeSuggestions(User user, SubscriptionInfo currentSubscription) {
    final suggestions = <String>[];
    
    if (currentSubscription.plan == 'basic') {
      if (user.pets.length >= 2) {
        suggestions.add('Upgrade to Premium for multi-pet management');
      }
      if (user.isExpertVerified ?? false) {
        suggestions.add('Professional plan includes advanced analytics');
      }
    }
    
    if (currentSubscription.plan == 'premium') {
      if (user.pets.length >= 3) {
        suggestions.add('Family plan offers unlimited pets');
      }
      if (user.communityParticipationScore != null && user.communityParticipationScore! > 70) {
        suggestions.add('Community plan enhances social features');
      }
    }
    
    return suggestions;
  }

  Map<String, dynamic> calculateBillingProjection(
    SubscriptionInfo subscription,
    DateTime endDate,
  ) {
    final now = DateTime.now();
    final monthsRemaining = (endDate.difference(now).inDays / 30).ceil();
    final monthlyCost = subscription.monthlyPrice;
    final totalCost = monthlyCost * monthsRemaining;
    
    return {
      'monthsRemaining': monthsRemaining,
      'monthlyCost': monthlyCost,
      'totalCost': totalCost,
      'nextBillingDate': subscription.nextBillingDate,
      'endDate': endDate,
    };
  }

  List<String> getPaymentMethodRecommendations(User user) {
    final recommendations = <String>[];
    
    // Add recommendations based on user's location and preferences
    recommendations.add('Credit cards offer the most flexibility');
    recommendations.add('Debit cards provide direct bank account access');
    recommendations.add('Digital wallets offer convenience and security');
    
    return recommendations;
  }

  Map<String, dynamic> getSubscriptionHealthMetrics(SubscriptionInfo subscription) {
    final now = DateTime.now();
    final daysSinceLastPayment = now.difference(subscription.lastPaymentDate).inDays;
    final daysUntilNextBilling = subscription.nextBillingDate.difference(now).inDays;
    
    String healthStatus;
    if (daysSinceLastPayment <= 5) {
      healthStatus = 'excellent';
    } else if (daysSinceLastPayment <= 15) {
      healthStatus = 'good';
    } else if (daysSinceLastPayment <= 30) {
      healthStatus = 'warning';
    } else {
      healthStatus = 'critical';
    }
    
    return {
      'healthStatus': healthStatus,
      'daysSinceLastPayment': daysSinceLastPayment,
      'daysUntilNextBilling': daysUntilNextBilling,
      'paymentHistory': subscription.paymentHistory,
      'lastPaymentAmount': subscription.lastPaymentAmount,
      'nextBillingAmount': subscription.nextBillingAmount,
    };
  }

  Future<bool> updatePaymentMethod({
    required String userId,
    required String subscriptionId,
    required String newPaymentMethodId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/subscriptions/$subscriptionId/payment-method'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'newPaymentMethodId': newPaymentMethodId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update payment method: $e');
    }
  }

  Future<bool> pauseSubscription({
    required String userId,
    required String subscriptionId,
    required DateTime pauseUntil,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/$subscriptionId/pause'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'pauseUntil': pauseUntil.toIso8601String(),
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to pause subscription: $e');
    }
  }

  Future<bool> resumeSubscription({
    required String userId,
    required String subscriptionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/$subscriptionId/resume'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to resume subscription: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBillingHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/users/$userId/billing-history'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final history = data['history'] as List;
        return history.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch billing history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch billing history: $e');
    }
  }

  Future<Map<String, dynamic>> getUsageAnalytics(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/users/$userId/usage'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch usage analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch usage analytics: $e');
    }
  }
}