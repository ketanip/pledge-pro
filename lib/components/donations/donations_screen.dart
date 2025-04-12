import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:sponsor_karo/services/payments_service.dart';

class DonationScreen extends StatefulWidget {
  final String beneficiaryId;
  const DonationScreen({super.key, required this.beneficiaryId});

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen>
    with SingleTickerProviderStateMixin {
  late Razorpay _razorpay;
  late TabController _tabController;

  int _selectedAmount = 100; // Default amount for one-time donation
  String _selectedPlanId = "plan_QDMGAvWIpjPRQT"; // Default: Bronze Plan

  final PaymentsService _paymentsService = PaymentsService();

  final List<Map<String, dynamic>> _plans = [
    {"id": "plan_QDMGibsikMSB6q", "name": "Platinum", "amount": 2000},
    {"id": "plan_QDMGYPxhlUaYWk", "name": "Gold", "amount": 1000},
    {"id": "plan_QDMGQ1YxILqHvm", "name": "Silver", "amount": 500},
    {"id": "plan_QDMGAvWIpjPRQT", "name": "Bronze", "amount": 100},
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _tabController.dispose();
    super.dispose();
  }

  void _makeOneTimeDonation() async {
    final orderId = await _paymentsService.createOneTimeCheckout(
      beneficiaryId: widget.beneficiaryId,
      amount: _selectedAmount * 100,
      currency: "INR",
    );

    var options = {'key': 'rzp_test_whDqyjdOCKuOGt', 'order_id': orderId};

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _subscribeToPlan() async {
    final subscriptionId = await _paymentsService.createSubscriptionCheckout(
      beneficiaryId: widget.beneficiaryId,
      planId: _selectedPlanId,
    );

    var options = {
      'key': 'rzp_test_whDqyjdOCKuOGt',
      'subscription_id': subscriptionId,
      'customer_notify': 1,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment successful: ${response.paymentId}")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet Selected: ${response.walletName}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Support the Cause"),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withAlpha(179),
          indicatorColor: theme.colorScheme.primary,
          tabs: [Tab(text: "Subscription"), Tab(text: "One-Time Donation")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPlanSelection(theme), _buildOneTimeDonation(theme)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            _tabController.index == 0 ? _subscribeToPlan : _makeOneTimeDonation,
        backgroundColor: theme.colorScheme.primary,
        label: Text(
          _tabController.index == 0
              ? "Subscribe ₹$_selectedAmount"
              : "Donate ₹$_selectedAmount",
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(Icons.payment, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPlanSelection(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(20),
      children:
          _plans.map((plan) {
            bool isSelected = _selectedPlanId == plan["id"];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlanId = plan["id"];
                  _selectedAmount = plan["amount"];
                });
              },
              child: Card(
                color:
                    isSelected
                        ? theme.colorScheme.primary.withAlpha(50)
                        : theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(50),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    plan["name"] + " Plan",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    "₹${plan["amount"]}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildOneTimeDonation(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter Donation Amount",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: "Amount in ₹",
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _selectedAmount = int.tryParse(value) ?? _selectedAmount;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
