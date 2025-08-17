import 'package:flutter/material.dart';

// ============================================================================
// SUBSCRIPTION MODELS
// ============================================================================

class SubscriptionInfo {
  String plan;
  DateTime startDate;
  bool isActive;
  List<String> features;
  double monthlyPrice;
  String billingCycle;
  DateTime? nextBillingDate;
  String? paymentMethodId;
  String? promoCode;
  bool autoRenew;
  DateTime? cancellationDate;
  double refundAmount;
  SubscriptionStatus status;

  SubscriptionInfo({
    required this.plan,
    required this.startDate,
    required this.isActive,
    required this.features,
    required this.monthlyPrice,
    required this.billingCycle,
    this.nextBillingDate,
    this.paymentMethodId,
    this.promoCode,
    required this.autoRenew,
    this.cancellationDate,
    this.refundAmount = 0.0,
    required this.status,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      plan: json['plan'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      isActive: json['isActive'] ?? false,
      features: List<String>.from(json['features'] ?? []),
      monthlyPrice: json['monthlyPrice']?.toDouble() ?? 0.0,
      billingCycle: json['billingCycle'] ?? 'monthly',
      nextBillingDate: json['nextBillingDate'] != null 
          ? DateTime.parse(json['nextBillingDate']) 
          : null,
      paymentMethodId: json['paymentMethodId'],
      promoCode: json['promoCode'],
      autoRenew: json['autoRenew'] ?? true,
      cancellationDate: json['cancellationDate'] != null 
          ? DateTime.parse(json['cancellationDate']) 
          : null,
      refundAmount: json['refundAmount']?.toDouble() ?? 0.0,
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'startDate': startDate.toIso8601String(),
      'isActive': isActive,
      'features': features,
      'monthlyPrice': monthlyPrice,
      'billingCycle': billingCycle,
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'paymentMethodId': paymentMethodId,
      'promoCode': promoCode,
      'autoRenew': autoRenew,
      'cancellationDate': cancellationDate?.toIso8601String(),
      'refundAmount': refundAmount,
      'status': status.name,
    };
  }

  SubscriptionInfo copyWith({
    String? plan,
    DateTime? startDate,
    bool? isActive,
    List<String>? features,
    double? monthlyPrice,
    String? billingCycle,
    DateTime? nextBillingDate,
    String? paymentMethodId,
    String? promoCode,
    bool? autoRenew,
    DateTime? cancellationDate,
    double? refundAmount,
    SubscriptionStatus? status,
  }) {
    return SubscriptionInfo(
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      features: features ?? this.features,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      promoCode: promoCode ?? this.promoCode,
      autoRenew: autoRenew ?? this.autoRenew,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      refundAmount: refundAmount ?? this.refundAmount,
      status: status ?? this.status,
    );
  }
}

// ============================================================================
// SUBSCRIPTION STATUS ENUMS
// ============================================================================

enum SubscriptionStatus {
  active,
  cancelled,
  suspended,
  expired,
  pending,
  trial,
}

enum BillingCycle {
  monthly,
  yearly,
  quarterly,
  weekly,
}

// ============================================================================
// PAYMENT MODELS
// ============================================================================

class PaymentMethod {
  final String id;
  final String type;
  final String last4;
  final String brand;
  final String holderName;
  final DateTime expiryDate;
  final bool isDefault;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.brand,
    required this.holderName,
    required this.expiryDate,
    required this.isDefault,
    required this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      last4: json['last4'],
      brand: json['brand'],
      holderName: json['holderName'],
      expiryDate: DateTime.parse(json['expiryDate']),
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'last4': last4,
      'brand': brand,
      'holderName': holderName,
      'expiryDate': expiryDate.toIso8601String(),
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PaymentTransaction {
  final String id;
  final String userId;
  final String subscriptionId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethodId;
  final DateTime createdAt;
  final String? description;
  final Map<String, dynamic>? metadata;

  PaymentTransaction({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethodId,
    required this.createdAt,
    this.description,
    this.metadata,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'],
      userId: json['userId'],
      subscriptionId: json['subscriptionId'],
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'],
      paymentMethodId: json['paymentMethodId'],
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionId': subscriptionId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethodId': paymentMethodId,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'metadata': metadata,
    };
  }
}

// ============================================================================
// INVOICE MODELS
// ============================================================================

class Invoice {
  final String id;
  final String userId;
  final String subscriptionId;
  final double amount;
  final String currency;
  final String status;
  final DateTime dueDate;
  final DateTime? paidDate;
  final List<InvoiceItem> items;
  final double taxAmount;
  final double totalAmount;
  final String? notes;

  Invoice({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.dueDate,
    this.paidDate,
    required this.items,
    required this.taxAmount,
    required this.totalAmount,
    this.notes,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      userId: json['userId'],
      subscriptionId: json['subscriptionId'],
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'],
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null 
          ? DateTime.parse(json['paidDate']) 
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromJson(item))
              .toList() ??
          [],
      taxAmount: json['taxAmount']?.toDouble() ?? 0.0,
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionId': subscriptionId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'notes': notes,
    };
  }
}

class InvoiceItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? category;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.category,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      description: json['description'],
      quantity: json['quantity'] ?? 1,
      unitPrice: json['unitPrice']?.toDouble() ?? 0.0,
      totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'category': category,
    };
  }
}

// ============================================================================
// USAGE TRACKING MODELS
// ============================================================================

class FeatureUsage {
  final String featureId;
  final String featureName;
  final int usageCount;
  final DateTime lastUsed;
  final Map<String, dynamic> usageData;

  FeatureUsage({
    required this.featureId,
    required this.featureName,
    required this.usageCount,
    required this.lastUsed,
    required this.usageData,
  });

  factory FeatureUsage.fromJson(Map<String, dynamic> json) {
    return FeatureUsage(
      featureId: json['featureId'],
      featureName: json['featureName'],
      usageCount: json['usageCount'] ?? 0,
      lastUsed: DateTime.parse(json['lastUsed']),
      usageData: Map<String, dynamic>.from(json['usageData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'featureId': featureId,
      'featureName': featureName,
      'usageCount': usageCount,
      'lastUsed': lastUsed.toIso8601String(),
      'usageData': usageData,
    };
  }
}

class UsageLimit {
  final String featureId;
  final String featureName;
  final int currentUsage;
  final int limit;
  final String period;
  final DateTime resetDate;

  UsageLimit({
    required this.featureId,
    required this.featureName,
    required this.currentUsage,
    required this.limit,
    required this.period,
    required this.resetDate,
  });

  factory UsageLimit.fromJson(Map<String, dynamic> json) {
    return UsageLimit(
      featureId: json['featureId'],
      featureName: json['featureName'],
      currentUsage: json['currentUsage'] ?? 0,
      limit: json['limit'] ?? 0,
      period: json['period'] ?? 'monthly',
      resetDate: DateTime.parse(json['resetDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'featureId': featureId,
      'featureName': featureName,
      'currentUsage': currentUsage,
      'limit': limit,
      'period': period,
      'resetDate': resetDate.toIso8601String(),
    };
  }

  bool get isExceeded => currentUsage >= limit;
  double get usagePercentage => (currentUsage / limit) * 100;
  int get remainingUsage => (limit - currentUsage).clamp(0, limit);
}

// ============================================================================
// PROMOTION MODELS
// ============================================================================

class PromoCode {
  final String code;
  final String description;
  final double discountAmount;
  final String discountType;
  final DateTime validFrom;
  final DateTime validUntil;
  final int maxUses;
  final int currentUses;
  final List<String> applicablePlans;
  final bool isActive;

  PromoCode({
    required this.code,
    required this.description,
    required this.discountAmount,
    required this.discountType,
    required this.validFrom,
    required this.validUntil,
    required this.maxUses,
    required this.currentUses,
    required this.applicablePlans,
    required this.isActive,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      code: json['code'],
      description: json['description'],
      discountAmount: json['discountAmount']?.toDouble() ?? 0.0,
      discountType: json['discountType'] ?? 'percentage',
      validFrom: DateTime.parse(json['validFrom']),
      validUntil: DateTime.parse(json['validUntil']),
      maxUses: json['maxUses'] ?? -1,
      currentUses: json['currentUses'] ?? 0,
      applicablePlans: List<String>.from(json['applicablePlans'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'discountAmount': discountAmount,
      'discountType': discountType,
      'validFrom': validFrom.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'maxUses': maxUses,
      'currentUses': currentUses,
      'applicablePlans': applicablePlans,
      'isActive': isActive,
    };
  }

  bool get isValid => DateTime.now().isAfter(validFrom) && 
                      DateTime.now().isBefore(validUntil) && 
                      isActive;
  
  bool get canUse => maxUses == -1 || currentUses < maxUses;
  
  double calculateDiscount(double originalPrice) {
    if (discountType == 'percentage') {
      return (originalPrice * discountAmount) / 100;
    } else {
      return discountAmount;
    }
  }
}

// ============================================================================
// SUBSCRIPTION ANALYTICS MODELS
// ============================================================================

class SubscriptionMetrics {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int activeDays;
  final Map<String, int> featureUsage;
  final Map<String, double> engagementScores;
  final List<String> topFeatures;
  final List<String> recommendations;

  SubscriptionMetrics({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.activeDays,
    required this.featureUsage,
    required this.engagementScores,
    required this.topFeatures,
    required this.recommendations,
  });

  factory SubscriptionMetrics.fromJson(Map<String, dynamic> json) {
    return SubscriptionMetrics(
      userId: json['userId'],
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      activeDays: json['activeDays'] ?? 0,
      featureUsage: Map<String, int>.from(json['featureUsage'] ?? {}),
      engagementScores: Map<String, double>.from(json['engagementScores'] ?? {}),
      topFeatures: List<String>.from(json['topFeatures'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'activeDays': activeDays,
      'featureUsage': featureUsage,
      'engagementScores': engagementScores,
      'topFeatures': topFeatures,
      'recommendations': recommendations,
    };
  }
}

// ============================================================================
// SUBSCRIPTION PLAN FEATURES
// ============================================================================

class PlanFeature {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool isAvailable;
  final String? icon;
  final Color? color;
  final List<String>? dependencies;

  PlanFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isAvailable,
    this.icon,
    this.color,
    this.dependencies,
  });

  factory PlanFeature.fromJson(Map<String, dynamic> json) {
    return PlanFeature(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      isAvailable: json['isAvailable'] ?? false,
      icon: json['icon'],
      color: json['color'] != null ? _parseColor(json['color']) : null,
      dependencies: json['dependencies'] != null 
          ? List<String>.from(json['dependencies']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'isAvailable': isAvailable,
      'icon': icon,
      'color': color?.value,
      'dependencies': dependencies,
    };
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    } else if (colorValue is String) {
      // Handle hex color strings
      if (colorValue.startsWith('#')) {
        final hex = colorValue.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      }
    }
    return Colors.blue; // Default color
  }
}

// ============================================================================
// SUBSCRIPTION UPGRADE/DOWNGRADE MODELS
// ============================================================================

class PlanChangeRequest {
  final String id;
  final String userId;
  final String currentPlanId;
  final String newPlanId;
  final String reason;
  final DateTime requestedAt;
  final String status;
  final DateTime? effectiveDate;
  final String? notes;

  PlanChangeRequest({
    required this.id,
    required this.userId,
    required this.currentPlanId,
    required this.newPlanId,
    required this.reason,
    required this.requestedAt,
    required this.status,
    this.effectiveDate,
    this.notes,
  });

  factory PlanChangeRequest.fromJson(Map<String, dynamic> json) {
    return PlanChangeRequest(
      id: json['id'],
      userId: json['userId'],
      currentPlanId: json['currentPlanId'],
      newPlanId: json['newPlanId'],
      reason: json['reason'],
      requestedAt: DateTime.parse(json['requestedAt']),
      status: json['status'],
      effectiveDate: json['effectiveDate'] != null 
          ? DateTime.parse(json['effectiveDate']) 
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'currentPlanId': currentPlanId,
      'newPlanId': newPlanId,
      'reason': reason,
      'requestedAt': requestedAt.toIso8601String(),
      'status': status,
      'effectiveDate': effectiveDate?.toIso8601String(),
      'notes': notes,
    };
  }
}

enum PlanChangeStatus {
  pending,
  approved,
  rejected,
  cancelled,
  completed,
}