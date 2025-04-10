import 'package:flutter/material.dart';

// Assuming the following types and demo data are defined somewhere in your project:

class DonationTransaction {
  final String id;
  final double amount;
  final String currency;
  final String sentTo; // recipient userId
  final String sentBy; // donor userId
  final DateTime timestamp;

  DonationTransaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.sentTo,
    required this.sentBy,
    required this.timestamp,
  });
}

class Pledge {
  final String id;
  final double amount;
  final String currency;
  final DateTime startedOn;
  final double totalAmountSentTillDate;
  final bool active;
  final String sentTo; // recipient athlete userId
  final String sentBy; // donor userId
  final List<DonationTransaction> transactions;

  Pledge({
    required this.id,
    required this.amount,
    required this.currency,
    required this.startedOn,
    required this.totalAmountSentTillDate,
    required this.active,
    required this.sentTo,
    required this.sentBy,
    this.transactions = const [],
  });
}

// Demo data for one-time transactions.
final List<DonationTransaction> demoTransactions = [
  DonationTransaction(
    id: 't1',
    amount: 50.0,
    currency: 'USD',
    sentTo: 'athlete1',
    sentBy: 'donor1',
    timestamp: DateTime.parse("2025-03-01T12:34:56Z"),
  ),
  DonationTransaction(
    id: 't2',
    amount: 75.0,
    currency: 'USD',
    sentTo: 'athlete2',
    sentBy: 'donor1',
    timestamp: DateTime.parse("2025-03-05T12:34:56Z"),
  ),
  DonationTransaction(
    id: 't3',
    amount: 100.0,
    currency: 'USD',
    sentTo: 'athlete3',
    sentBy: 'donor2',
    timestamp: DateTime.parse("2025-03-10T12:34:56Z"),
  ),
];

// Demo data for recurring pledges.
final List<Pledge> demoPledges = [
  Pledge(
    id: 'p1',
    amount: 20.0,
    currency: 'USD',
    startedOn: DateTime.parse("2025-01-01T00:00:00Z"),
    totalAmountSentTillDate: 40.0,
    active: true,
    sentTo: 'athlete1',
    sentBy: 'donor1',
    transactions: [
      DonationTransaction(
        id: 'pt1',
        amount: 20.0,
        currency: 'USD',
        sentTo: 'athlete1',
        sentBy: 'donor1',
        timestamp: DateTime.parse("2025-01-01T12:00:00Z"),
      ),
      DonationTransaction(
        id: 'pt2',
        amount: 20.0,
        currency: 'USD',
        sentTo: 'athlete1',
        sentBy: 'donor1',
        timestamp: DateTime.parse("2025-02-01T12:00:00Z"),
      ),
    ],
  ),
  Pledge(
    id: 'p2',
    amount: 30.0,
    currency: 'USD',
    startedOn: DateTime.parse("2025-01-15T00:00:00Z"),
    totalAmountSentTillDate: 90.0,
    active: false,
    sentTo: 'athlete2',
    sentBy: 'donor2',
    transactions: [
      DonationTransaction(
        id: 'pt3',
        amount: 30.0,
        currency: 'USD',
        sentTo: 'athlete2',
        sentBy: 'donor2',
        timestamp: DateTime.parse("2025-01-15T12:00:00Z"),
      ),
      DonationTransaction(
        id: 'pt4',
        amount: 30.0,
        currency: 'USD',
        sentTo: 'athlete2',
        sentBy: 'donor2',
        timestamp: DateTime.parse("2025-02-15T12:00:00Z"),
      ),
      DonationTransaction(
        id: 'pt5',
        amount: 30.0,
        currency: 'USD',
        sentTo: 'athlete2',
        sentBy: 'donor2',
        timestamp: DateTime.parse("2025-03-15T12:00:00Z"),
      ),
    ],
  ),
];

// Main Donations Screen
class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  _DonationsScreenState createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<DonationTransaction> transactions = demoTransactions;
  final List<Pledge> pledges = demoPledges;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DonationAppBar(tabController: _tabController),
      body: TabBarView(
        controller: _tabController,
        children: [
          OneTimeTransactionsTab(transactions: transactions),
          PledgesTab(pledges: pledges),
        ],
      ),
    );
  }
}

// Custom AppBar with Tabs
class DonationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  const DonationAppBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      indicatorColor: Theme.of(context).primaryColor,
      tabs: const [Tab(text: "One-Time"), Tab(text: "Pledges")],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

// One-Time Donations Tab
class OneTimeTransactionsTab extends StatelessWidget {
  final List<DonationTransaction> transactions;
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
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          elevation: 2,
          child: ListTile(
            leading: Icon(
              Icons.monetization_on,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              "\$${tx.amount.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Sent by ${tx.sentBy} to ${tx.sentTo}"),
            trailing: Text(
              tx.timestamp.toLocal().toString().split(' ')[0],
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}

// Pledges Tab
class PledgesTab extends StatelessWidget {
  final List<Pledge> pledges;
  const PledgesTab({super.key, required this.pledges});

  @override
  Widget build(BuildContext context) {
    if (pledges.isEmpty) {
      return const Center(child: Text("No active pledges."));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: pledges.length,
      itemBuilder: (context, index) {
        return PledgeCard(pledge: pledges[index]);
      },
    );
  }
}

// Pledge Card with Expandable Transactions
class PledgeCard extends StatefulWidget {
  final Pledge pledge;
  const PledgeCard({super.key, required this.pledge});

  @override
  _PledgeCardState createState() => _PledgeCardState();
}

class _PledgeCardState extends State<PledgeCard> {
  bool _showTransactions = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              widget.pledge.sentTo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Pledge: \$${widget.pledge.amount.toStringAsFixed(2)} per month",
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIndicator(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // Handle Stop or Modify pledge actions
                  },
                  itemBuilder:
                      (context) => const [
                        PopupMenuItem(
                          value: "Stop",
                          child: Text("Stop Pledge"),
                        ),
                        PopupMenuItem(
                          value: "Modify",
                          child: Text("Modify Pledge"),
                        ),
                      ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          TextButton(
            onPressed:
                () => setState(() => _showTransactions = !_showTransactions),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Show Transactions", style: TextStyle(fontSize: 14)),
                Icon(_showTransactions ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          if (_showTransactions) _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.pledge.active ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.pledge.active ? "Active" : "Inactive",
        style: TextStyle(
          color: widget.pledge.active ? Colors.green : Colors.red,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children:
            widget.pledge.transactions.map((tx) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx.timestamp.toLocal().toString().split(' ')[0],
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    Text(
                      "\$${tx.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}
