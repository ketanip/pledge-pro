import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sponsor_karo/components/analytics/charts.dart';
import 'package:sponsor_karo/components/analytics/donor_card.dart';
import 'package:sponsor_karo/components/analytics/top_donors_page.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/models/transaction.dart';
import 'package:sponsor_karo/services/follow_service.dart';
import 'package:sponsor_karo/services/payments_service.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';
import 'package:sponsor_karo/state/user_provider.dart';
import 'package:sponsor_karo/types.dart';

final plansData = {
  "plan_QDMGibsikMSB6q": 2000,
  "plan_QDMGYPxhlUaYWk": 1000,
  "plan_QDMGQ1YxILqHvm": 500,
  "plan_QDMGAvWIpjPRQT": 100,
};

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final PublicProfileService _publicProfileService = PublicProfileService();
  final PaymentsService _paymentsService = PaymentsService();
  final FollowService _followService = FollowService();

  List<DonorTransactions> _donors = [];
  List<Map<String, String>> _kpiList = [];
  Map<DateTime, int> _donationsChartsData = HashMap();
  Map<DateTime, int> _subscriptionChartData = HashMap();
  bool isAthlete = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<List<DonorTransactions>> _groupTransactionsWithDonor(
    List<Transaction> transactions,
  ) async {
    final Map<String, List<Transaction>> grouped = {};

    // Group transactions by donorId
    for (var transaction in transactions) {
      grouped.putIfAbsent(transaction.donorId, () => []);
      grouped[transaction.donorId]!.add(transaction);
    }

    List<DonorTransactions> result = [];

    for (var entry in grouped.entries) {
      // Fetch the PublicProfile for the donor asynchronously
      PublicProfile donorProfile = await _publicProfileService
          .getPublicProfileBySub(entry.key);

      int donationThisMonth = 0;
      int totalDonations = 0;

      // Calculate donations
      DateTime currentMonth = DateTime.now();
      for (var transaction in entry.value) {
        totalDonations += transaction.amount;

        // Check if the transaction was made in the current month
        if (transaction.createdAt.toDate().year == currentMonth.year &&
            transaction.createdAt.toDate().month == currentMonth.month) {
          donationThisMonth += transaction.amount;
        }
      }

      // Create a DonorTransactions instance and add it to the result
      result.add(
        DonorTransactions(
          donor: donorProfile,
          transactions: entry.value,
          donationThisMonth: donationThisMonth,
          totalDonations: totalDonations,
        ),
      );
    }

    return result;
  }

  void loadData() async {
    // CURRENT USER
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user == null) return;

    // DONATIONS
    final donations = await _paymentsService.getAllDonationsReceived();

    // Donors Data
    final donors = await _groupTransactionsWithDonor(donations);

    int totalDonationsValue = 0;
    int totalDonationThisMonth = 0;
    final DateTime now = DateTime.now();

    final Map<DateTime, int> donationsChartData = HashMap();

    for (final item in donations) {
      totalDonationsValue += item.amount;

      if (item.createdAt.toDate().month == now.month) {
        totalDonationThisMonth += item.amount;
      }

      donationsChartData.update(
        item.createdAt.toDate(),
        (val) => val += item.amount,
        ifAbsent: () => item.amount,
      );
    }

    // PLEDGES
    final subscriptions =
        await _paymentsService.getSubscriptionsByBeneficiary();

    int totalActiveSubscriptions = 0;
    int totalExpectedRevenue = 0;
    final Map<DateTime, int> subscriptionChartData = HashMap();

    for (final item in subscriptions) {
      if (item.status != "active") continue;
      totalActiveSubscriptions++;
      totalExpectedRevenue += plansData[item.planId] ?? 0;

      subscriptionChartData.update(
        item.createdAt.toDate(),
        (val) => val += 1,
        ifAbsent: () => 1,
      );
    }

    // FOLLOWERS
    int totalFollowers = 0;
    final followers = await _followService.getFollowers(user.username);
    totalFollowers = followers.length;

    final List<Map<String, String>> kpiList = [
      {
        'title': 'Donations This Month',
        'value': '₹$totalDonationThisMonth',
        'description': 'Total donations received this month',
      },
      {
        'title': 'Total Donations',
        'value': '₹$totalDonationsValue',
        'description': 'Total donations till date.',
      },
      {
        'title': 'Total Pledges',
        'value': '$totalActiveSubscriptions',
        'description': 'Number of recurring pledges',
      },
      {
        'title': 'Pledge Revenue',
        'value': '₹$totalExpectedRevenue',
        'description': 'Expected monthly pledge amount',
      },
      {
        'title': 'Followers',
        'value': '$totalFollowers',
        'description': 'Total followers count',
      },
    ];

    setState(() {
      _kpiList = kpiList;
      _donors = donors;
      _donationsChartsData = donationsChartData;
      _subscriptionChartData = subscriptionChartData;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Display only the top 5 donors here.
    final List<DonorTransactions> topDonors = _donors.take(5).toList();

    if (_donors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                "No donations yet",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "This page will activate once you receive a donation.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(90),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Section with Overflow Handling
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              double aspectRatio = constraints.maxWidth > 400 ? 1.8 : 1.5;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: aspectRatio,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _kpiList.length,
                itemBuilder: (context, index) {
                  return _buildKpiCard(
                    _kpiList[index]['title']!,
                    _kpiList[index]['value']!,
                    _kpiList[index]['description']!,
                    Theme.of(context), // Using theme dynamically
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),

          AnalyticsCharts(
            donationsChartData: _donationsChartsData,
            subscriptionChartData: _subscriptionChartData,
          ),

          const SizedBox(height: 32),

          // Top Donors Section
          Text(
            "Top Donors",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topDonors.length,
            itemBuilder: (context, index) => DonorCard(data: topDonors[index]),
          ),

          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TopDonorsPage(allDonors: _donors),
                  ),
                );
              },
              child: Text(
                "Show More",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    String description,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 6),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Allows dynamic height based on content
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // KPI Value - Handle potential long text with ellipsis
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Limit to one line
                overflow: TextOverflow.ellipsis, // Show ... if too long
                softWrap:
                    false, // Prevent wrapping if using ellipsis on single line
              ),
              const SizedBox(height: 4),

              // KPI Title - Handle potential long text with ellipsis
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Allow wrapping up to 2 lines, then ellipsis
                overflow: TextOverflow.ellipsis, // Show ... if too long
                softWrap: true, // Allow wrapping up to maxLines
              ),
            ],
          ),
        ),
      ),
    );
  }
}
