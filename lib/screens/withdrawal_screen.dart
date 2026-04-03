// File: lib/screens/withdrawal_screen.dart
// Kaam: Coins withdraw karna — payment method save/delete, history tabs
// Pehle withdrawal pe referrer ko 500 coins milte hain (Firebase mein handle hota hai)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class WithdrawalScreen extends StatefulWidget {
  final UserModel user;
  const WithdrawalScreen({super.key, required this.user});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen>
    with SingleTickerProviderStateMixin {
  final _firebase = FirebaseService();
  late TabController _tabController;

  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _withdrawals = [];
  bool _loading = false;
  bool _dataLoaded = false;

  final _coinsCtrl = TextEditingController();
  String _selectedMethod = '';
  String _selectedMethodId = '';
  String _selectedTab = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _coinsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final methods = await _firebase.getPaymentMethods(widget.user.uid);
    final withdrawals = await _firebase.getWithdrawals(widget.user.uid);
    setState(() {
      _paymentMethods = methods;
      _withdrawals = withdrawals;
      _dataLoaded = true;
    });
  }

  List<Map<String, dynamic>> get _filteredWithdrawals {
    if (_selectedTab == 'All') return _withdrawals;
    return _withdrawals
        .where((w) => (w['status'] ?? '').toString().toLowerCase() ==
            _selectedTab.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Withdrawal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Payment Method',
            onPressed: _showAddPaymentDialog,
          ),
        ],
      ),
      body: !_dataLoaded
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _buildWithdrawForm(),
                const SizedBox(height: 24),
                _buildHistorySection(),
              ],
            ),
    );
  }

  // ─── Balance Card ──────────────────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF5b21b6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    color: Colors.white24, shape: BoxShape.circle),
                child: const Center(
                  child: Text('₵',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                Helpers.formatCoins(widget.user.coins),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 34),
              ),
              const Text(' coins',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.user.coins >= CoinValues.minWithdrawal
                  ? '✓ Eligible for withdrawal'
                  : '⚠ Need ${CoinValues.minWithdrawal - widget.user.coins} more coins',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Withdraw Form ─────────────────────────────────────────────────────────
  Widget _buildWithdrawForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Request Withdrawal',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'Minimum: ${CoinValues.minWithdrawal} coins',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Coins input
          TextField(
            controller: _coinsCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Coins to withdraw',
              prefixIcon: const Icon(Icons.monetization_on_outlined,
                  color: AppColors.gold),
              suffix: TextButton(
                onPressed: () =>
                    _coinsCtrl.text = widget.user.coins.toString(),
                child: const Text('MAX',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Payment method selection
          const Text('Select Payment Method',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          _paymentMethods.isEmpty
              ? GestureDetector(
                  onTap: _showAddPaymentDialog,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.4),
                          style: BorderStyle.solid),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline,
                            color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Add Payment Method',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    ..._paymentMethods.map((m) => _paymentMethodTile(m)),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add another method'),
                      onPressed: _showAddPaymentDialog,
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent),
                    ),
                  ],
                ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submitWithdrawal,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Withdrawal Request'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodTile(Map<String, dynamic> method) {
    final isSelected = _selectedMethodId == method['id'];
    final icon = _methodIcon(method['type'] ?? '');

    return GestureDetector(
      onTap: () => setState(() {
        _selectedMethodId = method['id'] ?? '';
        _selectedMethod = method['type'] ?? '';
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method['type'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(method['value'] ?? '',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 18),
              onPressed: () => _deleteMethod(method['id'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  // ─── History Section ───────────────────────────────────────────────────────
  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Withdrawal History',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
        const SizedBox(height: 12),

        // Filter tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Pending', 'Successful', 'Cancelled']
                .map((tab) => GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == tab
                              ? AppColors.primary
                              : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedTab == tab
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: _selectedTab == tab
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: _selectedTab == tab
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: 12),

        _filteredWithdrawals.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Text('💳', style: TextStyle(fontSize: 36)),
                      SizedBox(height: 8),
                      Text('No withdrawals yet',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Your withdrawal history will appear here',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13)),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredWithdrawals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) =>
                    _withdrawalRow(_filteredWithdrawals[i]),
              ),
      ],
    );
  }

  Widget _withdrawalRow(Map<String, dynamic> w) {
    final status = w['status'] ?? 'pending';
    Color statusColor;
    switch (status) {
      case 'successful':
        statusColor = AppColors.success;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    final date = w['created_at'] != null
        ? DateTime.tryParse(w['created_at'])
        : null;
    final dateStr = date != null ? Helpers.timeAgo(date) : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(_methodIcon(w['payment_type'] ?? ''),
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Helpers.formatCoins(w['coins'] ?? 0)} coins',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
                Text(
                  '${w['payment_type'] ?? ''} • $dateStr',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Add Payment Dialog ────────────────────────────────────────────────────
  void _showAddPaymentDialog() {
    String selectedType = AppStrings.upi;
    final valueCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text('Add Payment Method',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment Type',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppStrings.upi,
                    AppStrings.paytm,
                    AppStrings.bankTransfer,
                    AppStrings.amazonPay,
                  ]
                      .map((type) => GestureDetector(
                            onTap: () => setS(() => selectedType = type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selectedType == type
                                    ? AppColors.primary
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selectedType == type
                                      ? AppColors.primary
                                      : AppColors.divider,
                                ),
                              ),
                              child: Text(
                                '${_methodIcon(type)} $type',
                                style: TextStyle(
                                  color: selectedType == type
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Account Holder Name',
                    prefixIcon: Icon(Icons.person_outline,
                        color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: selectedType == AppStrings.bankTransfer
                        ? 'Account Number / IFSC'
                        : 'UPI ID / Mobile Number',
                    prefixIcon: const Icon(Icons.payment_outlined,
                        color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (valueCtrl.text.trim().isEmpty) return;
                await _firebase.savePaymentMethod(widget.user.uid, {
                  'type': selectedType,
                  'value': valueCtrl.text.trim(),
                  'name': nameCtrl.text.trim(),
                });
                Navigator.pop(ctx);
                _loadData();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ───────────────────────────────────────────────────────────────
  Future<void> _submitWithdrawal() async {
    final coinsText = _coinsCtrl.text.trim();
    if (coinsText.isEmpty) {
      Helpers.showSnackBar(context, 'Enter coins amount', isError: true);
      return;
    }

    final coins = int.tryParse(coinsText) ?? 0;
    if (coins < CoinValues.minWithdrawal) {
      Helpers.showSnackBar(context, AppStrings.minWithdrawal, isError: true);
      return;
    }

    if (coins > widget.user.coins) {
      Helpers.showSnackBar(context, 'Insufficient coins!', isError: true);
      return;
    }

    if (_selectedMethodId.isEmpty) {
      Helpers.showSnackBar(context, 'Select a payment method', isError: true);
      return;
    }

    setState(() => _loading = true);

    final method = _paymentMethods.firstWhere(
        (m) => m['id'] == _selectedMethodId,
        orElse: () => {});

    final id = await _firebase.submitWithdrawal(widget.user.uid, {
      'coins': coins,
      'payment_type': _selectedMethod,
      'payment_value': method['value'] ?? '',
      'payment_name': method['name'] ?? '',
    });

    setState(() => _loading = false);

    if (!mounted) return;

    if (id != null) {
      _coinsCtrl.clear();
      setState(() => _selectedMethodId = '');
      _loadData();
      Helpers.showSnackBar(
          context, '✅ Withdrawal request submitted! Processing in 24-48h');
    } else {
      Helpers.showSnackBar(context, AppStrings.genericError, isError: true);
    }
  }

  Future<void> _deleteMethod(String id) async {
    await _firebase.deletePaymentMethod(widget.user.uid, id);
    _loadData();
    Helpers.showSnackBar(context, 'Payment method removed');
  }

  String _methodIcon(String type) {
    switch (type) {
      case AppStrings.upi:
        return '💳';
      case AppStrings.paytm:
        return '🔵';
      case AppStrings.bankTransfer:
        return '🏦';
      case AppStrings.amazonPay:
        return '🛒';
      default:
        return '💰';
    }
  }
}
