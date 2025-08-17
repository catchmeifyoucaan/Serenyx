import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/services/subscription_service.dart';
import '../../../../shared/models/subscription_models.dart';
import '../../../../core/theme/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with TickerProviderStateMixin {
  final String _userId = 'demo-user';
  
  List<SubscriptionPlan> _availablePlans = [];
  SubscriptionInfo? _currentSubscription;
  List<FamilyMember> _familyMembers = [];
  List<VeterinaryPartner> _veterinaryPartners = [];
  List<InsuranceProvider> _insuranceProviders = [];
  List<Invoice> _invoices = [];
  
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
    _slideController.forward();
    
    _initializeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final subscriptionService = context.read<SubscriptionService>();
      
      // Load initial data
      await _loadAvailablePlans();
      await _loadCurrentSubscription();
      await _loadFamilyMembers();
      await _loadVeterinaryPartners();
      await _loadInsuranceProviders();
      await _loadInvoices();
    } catch (e) {
      _showSnackBar('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailablePlans() async {
    try {
      final subscriptionService = context.read<SubscriptionService>();
      final plans = await subscriptionService.getAvailablePlans();
      setState(() {
        _availablePlans = plans;
      });
    } catch (e) {
      _showSnackBar('Error loading plans: $e');
    }
  }

  Future<void> _loadCurrentSubscription() async {
    try {
      final subscriptionService = context.read<SubscriptionService>();
      final subscription = await subscriptionService.getCurrentSubscription(_userId);
      setState(() {
        _currentSubscription = subscription;
      });
    } catch (e) {
      _showSnackBar('Error loading subscription: $e');
    }
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final subscriptionService = context.read<SubscriptionService>();
      final members = await subscriptionService.getFamilyMembers(_userId);
      setState(() {
        _familyMembers = members;
      });
    } catch (e) {
      _showSnackBar('Error loading family members: $e');
    }
  }

  Future<void> _loadVeterinaryPartners() async {
    try {
      final subscriptionService = context.read<SubscriptionService>();
      final partners = await subscriptionService.getVeterinaryPartners();
      setState(() {
        _veterinaryPartners = partners;
      });
    } catch (e) {
      _showSnackBar('Error loading veterinary partners: $e');
    }
  }

  Future<void> _loadInsuranceProviders() async {
    try {
      final subscriptionService = context.read<SubscriptionService>();
      final providers = await subscriptionService.getInsuranceProviders();
      setState(() {
        _insuranceProviders = providers;
      });
    } catch (e) {
      _showSnackBar('Error loading insurance providers: $e');
    }
  }

  Future<void> _loadInvoices() async {
    try {
      final subscriptionService = context.read<SubscriptionService>();
      final invoices = await subscriptionService.getInvoices(_userId);
      setState(() {
        _invoices = invoices;
      });
    } catch (e) {
      _showSnackBar('Error loading invoices: $e');
    }
  }

  Future<void> _subscribeToPlan(SubscriptionPlan plan) async {
    try {
      final subscriptionService = context.read<SubscriptionService>();
      final result = await subscriptionService.subscribeToPlan(
        userId: _userId,
        planId: plan.id,
        paymentMethod: 'credit_card', // Demo payment method
      );
      
      if (result.success) {
        _showSnackBar('Successfully subscribed to ${plan.name}!');
        await _loadCurrentSubscription();
      } else {
        _showSnackBar('Subscription failed: ${result.message}');
      }
    } catch (e) {
      _showSnackBar('Error subscribing: $e');
    }
  }

  Future<void> _addFamilyMember() async {
    _showAddFamilyMemberDialog();
  }

  Future<void> _getInsuranceQuote() async {
    _showInsuranceQuoteDialog();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: const Text('Subscription & Billing'),
        backgroundColor: AppTheme.colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSelector,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Subscription Status
                      if (_currentSubscription != null) _buildCurrentSubscriptionCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Available Plans
                      _buildAvailablePlansSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Family Plan Management
                      _buildFamilyPlanSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Veterinary Partnerships
                      _buildVeterinaryPartnersSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Insurance Integration
                      _buildInsuranceSection(),
                      
                      const SizedBox(height: 24),
                      
                      // Billing & Invoices
                      _buildBillingSection(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    if (_currentSubscription == null) return const SizedBox.shrink();
    
    final subscription = _currentSubscription!;
    final isActive = subscription.isActive;
    
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [AppTheme.colors.success, AppTheme.colors.primary]
                : [AppTheme.colors.error, AppTheme.colors.warning],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isActive ? Icons.check_circle : Icons.error,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.plan.toUpperCase(),
                          style: AppTheme.textStyles.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isActive ? 'Active Subscription' : 'Subscription Inactive',
                          style: AppTheme.textStyles.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${subscription.monthlyPrice.toStringAsFixed(2)}/month',
                      style: AppTheme.textStyles.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Started: ${_formatDate(subscription.startDate)}',
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                children: subscription.features.map((feature) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    feature,
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailablePlansSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_membership,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Available Plans',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_availablePlans.isEmpty)
              _buildEmptyState(
                icon: Icons.card_membership,
                title: 'No plans available',
                message: 'Check back later for subscription plans!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availablePlans.length,
                itemBuilder: (context, index) {
                  final plan = _availablePlans[index];
                  return _buildPlanCard(plan);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = _currentSubscription?.plan == plan.id;
    final isPopular = plan.id == 'premium';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCurrentPlan 
            ? AppTheme.colors.primary.withOpacity(0.1)
            : AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan 
              ? AppTheme.colors.primary.withOpacity(0.5)
              : isPopular
                  ? AppTheme.colors.warning.withOpacity(0.5)
                  : AppTheme.colors.outline.withOpacity(0.3),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name,
                          style: AppTheme.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.warning.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'MOST POPULAR',
                              style: AppTheme.textStyles.bodySmall?.copyWith(
                                color: AppTheme.colors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      plan.description,
                      style: AppTheme.textStyles.bodyMedium?.copyWith(
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
                    '\$${plan.monthlyPrice.toStringAsFixed(2)}',
                    style: AppTheme.textStyles.headlineMedium?.copyWith(
                      color: AppTheme.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'per month',
                    style: AppTheme.textStyles.bodySmall?.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Features
          Text(
            'Features:',
            style: AppTheme.textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...plan.features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.colors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: AppTheme.textStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
          
          const SizedBox(height: 20),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrentPlan ? null : () => _subscribeToPlan(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentPlan 
                    ? AppTheme.colors.outline
                    : AppTheme.colors.primary,
                foregroundColor: isCurrentPlan 
                    ? AppTheme.colors.textSecondary
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isCurrentPlan ? 'Current Plan' : 'Subscribe Now',
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyPlanSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.family_restroom,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Family Plan Management',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addFamilyMember,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Member'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_familyMembers.isEmpty)
              _buildEmptyState(
                icon: Icons.family_restroom,
                title: 'No family members',
                message: 'Add family members to share your subscription benefits!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _familyMembers.length,
                itemBuilder: (context, index) {
                  final member = _familyMembers[index];
                  return _buildFamilyMemberCard(member);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberCard(FamilyMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.colors.primary,
            child: Text(
              member.name[0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  member.role,
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                Text(
                  'Added: ${_formatDate(member.addedDate)}',
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: member.isActive 
                  ? AppTheme.colors.success.withOpacity(0.1)
                  : AppTheme.colors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              member.isActive ? 'Active' : 'Inactive',
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: member.isActive ? AppTheme.colors.success : AppTheme.colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVeterinaryPartnersSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Veterinary Partnerships',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_veterinaryPartners.isEmpty)
              _buildEmptyState(
                icon: Icons.local_hospital,
                title: 'No veterinary partners',
                message: 'Connect with veterinary partners for premium health insights!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _veterinaryPartners.length,
                itemBuilder: (context, index) {
                  final partner = _veterinaryPartners[index];
                  return _buildVeterinaryPartnerCard(partner);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinaryPartnerCard(VeterinaryPartner partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: AppTheme.colors.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: AppTheme.textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      partner.specialization,
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.colors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${partner.rating} (${partner.reviewCount} reviews)',
                          style: AppTheme.textStyles.bodySmall?.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _connectWithPartner(partner),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Connect'),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            partner.description,
            style: AppTheme.textStyles.bodyMedium,
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            children: partner.services.map((service) => Chip(
              label: Text(service),
              backgroundColor: AppTheme.colors.secondary.withOpacity(0.1),
              labelStyle: TextStyle(color: AppTheme.colors.secondary),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insurance Integration',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _getInsuranceQuote,
                  icon: const Icon(Icons.search),
                  label: const Text('Get Quote'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_insuranceProviders.isEmpty)
              _buildEmptyState(
                icon: Icons.security,
                title: 'No insurance providers',
                message: 'Connect with insurance providers for pet health coverage!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _insuranceProviders.length,
                itemBuilder: (context, index) {
                  final provider = _insuranceProviders[index];
                  return _buildInsuranceProviderCard(provider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceProviderCard(InsuranceProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.colors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.security,
                  color: AppTheme.colors.success,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: AppTheme.textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      provider.type,
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.textSecondary,
                      ),
                    ),
                    Text(
                      'Starting at \$${provider.startingPrice.toStringAsFixed(2)}/month',
                      style: AppTheme.textStyles.bodySmall?.copyWith(
                        color: AppTheme.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _getProviderQuote(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Get Quote'),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            provider.description,
            style: AppTheme.textStyles.bodyMedium,
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            children: provider.coverage.map((coverage) => Chip(
              label: Text(coverage),
              backgroundColor: AppTheme.colors.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: AppTheme.colors.primary),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppTheme.colors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Billing & Invoices',
                  style: AppTheme.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_invoices.isEmpty)
              _buildEmptyState(
                icon: Icons.receipt_long,
                title: 'No invoices yet',
                message: 'Your billing history will appear here!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _invoices.length,
                itemBuilder: (context, index) {
                  final invoice = _invoices[index];
                  return _buildInvoiceCard(invoice);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getInvoiceStatusColor(invoice.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getInvoiceStatusIcon(invoice.status),
              color: _getInvoiceStatusColor(invoice.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice #${invoice.invoiceNumber}',
                  style: AppTheme.textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(invoice.issueDate),
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
                Text(
                  'Due: ${_formatDate(invoice.dueDate)}',
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
                '\$${invoice.totalAmount.toStringAsFixed(2)}',
                style: AppTheme.textStyles.titleMedium?.copyWith(
                  color: AppTheme.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getInvoiceStatusColor(invoice.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  invoice.status,
                  style: AppTheme.textStyles.bodySmall?.copyWith(
                    color: _getInvoiceStatusColor(invoice.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.textStyles.bodyLarge?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.textStyles.bodySmall?.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English', '🇺🇸'),
            _buildLanguageOption('es', 'Español', '🇪🇸'),
            _buildLanguageOption('fr', 'Français', '🇫🇷'),
            _buildLanguageOption('de', 'Deutsch', '🇩🇪'),
            _buildLanguageOption('ja', '日本語', '🇯🇵'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: _selectedLanguage == code
          ? Icon(Icons.check, color: AppTheme.colors.primary)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
        Navigator.pop(context);
        _initializeData(); // Reload data with new language
      },
    );
  }

  void _showAddFamilyMemberDialog() {
    _showSnackBar('Add family member feature coming soon!');
  }

  void _showInsuranceQuoteDialog() {
    _showSnackBar('Insurance quote feature coming soon!');
  }

  void _connectWithPartner(VeterinaryPartner partner) {
    _showSnackBar('Connecting with ${partner.name}...');
  }

  void _getProviderQuote(InsuranceProvider provider) {
    _showSnackBar('Getting quote from ${provider.name}...');
  }

  Color _getInvoiceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.colors.success;
      case 'pending':
        return AppTheme.colors.warning;
      case 'overdue':
        return AppTheme.colors.error;
      default:
        return AppTheme.colors.textSecondary;
    }
  }

  IconData _getInvoiceStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'overdue':
        return Icons.warning;
      default:
        return Icons.receipt;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}