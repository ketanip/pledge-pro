import 'package:flutter/material.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/models/subscription.dart';
import 'package:sponsor_karo/models/transaction.dart';
import 'package:sponsor_karo/screens/user_profile.dart';
import 'package:sponsor_karo/services/payments_service.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> _transactions = [];
  List<Subscription> _pledges = [];
  final PaymentsService _paymentsService = PaymentsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void loadData() async {
    final transactions = await _paymentsService.getAllDonationsMade();
    final pledges = await _paymentsService.getSubscriptionsByDonor();

    if (!mounted) return;

    setState(() {
      _transactions = transactions;
      _pledges = pledges;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: SafeArea(
              bottom: false,
              child: TabBar(
                controller: _tabController,
                tabs: const [Tab(text: "One-Time"), Tab(text: "Pledges")],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OneTimeTransactionsTab(transactions: _transactions),
                PledgesTab(pledges: _pledges),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OneTimeTransactionsTab extends StatelessWidget {
  final List<Transaction> transactions;
  const OneTimeTransactionsTab({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text("No one-time donations yet."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final _publicProfileService = PublicProfileService();

        return FutureBuilder<PublicProfile>(
          future: _publicProfileService.getPublicProfileBySub(tx.beneficiaryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                title: Text("Loading..."),
                subtitle: Text("Fetching athlete info"),
              );
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return const ListTile(title: Text("Error loading athlete"));
            }

            final athlete = snapshot.data!;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(athlete.profilePic),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => UserProfileScreen(username: athlete.username),
                    ),
                  );
                },
                title: Text(
                  "₹${(tx.amount / 100).toStringAsFixed(2)} ${tx.currency}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Sent to ${athlete.fullName}"),
                trailing: Text(
                  tx.createdAt.toDate().toString().split(' ')[0],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PledgesTab extends StatelessWidget {
  final List<Subscription> pledges;
  const PledgesTab({super.key, required this.pledges});

  @override
  Widget build(BuildContext context) {
    final _publicProfileService = PublicProfileService();

    if (pledges.isEmpty) {
      return const Center(child: Text("No active pledges."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: pledges.length,
      itemBuilder: (context, index) {
        final pledge = pledges[index];

        return FutureBuilder<PublicProfile>(
          future: _publicProfileService.getPublicProfileBySub(
            pledge.beneficiaryId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(title: Text("Loading beneficiary..."));
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return const ListTile(title: Text("Beneficiary unavailable"));
            }

            return PledgeCard(pledge: pledge, beneficiary: snapshot.data!);
          },
        );
      },
    );
  }
}

final plans = [
  {"id": "plan_QDMGibsikMSB6q", "name": "Platinum", "amount": 2000},
  {"id": "plan_QDMGYPxhlUaYWk", "name": "Gold", "amount": 1000},
  {"id": "plan_QDMGQ1YxILqHvm", "name": "Silver", "amount": 500},
  {"id": "plan_QDMGAvWIpjPRQT", "name": "Bronze", "amount": 100},
];

class PledgeCard extends StatefulWidget {
  final Subscription pledge;
  final PublicProfile beneficiary;

  const PledgeCard({
    super.key,
    required this.pledge,
    required this.beneficiary,
  });

  @override
  _PledgeCardState createState() => _PledgeCardState();
}

class _PledgeCardState extends State<PledgeCard> {
  final _paymentsService = PaymentsService();

  void _handlePledgeAction(String action) async {
    if (action == "Cancel") {
      if (widget.pledge.status == "active") {
        await _paymentsService.cancelSubscription(widget.pledge.id);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pledge cancelled")));
    }
  }

  Map<String, dynamic>? _getPlanDetails(String planId) {
    return plans.firstWhere(
      (plan) => plan['id'] == planId,
      orElse: () => {"name": "Unknown", "amount": 0},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.pledge.status == "active";
    final plan = _getPlanDetails(widget.pledge.planId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.beneficiary.profilePic),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      UserProfileScreen(username: widget.beneficiary.username),
            ),
          );
        },
        title: Text(
          widget.beneficiary.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${plan?['name']}: ₹${plan?['amount']} / month"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIndicator(isActive),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: _handlePledgeAction,
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(
                      value: "Cancel",
                      child: Text("Cancel Pledge"),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isActive ? "Active" : widget.pledge.status,
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }
}
