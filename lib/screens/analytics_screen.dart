import 'package:flutter/material.dart';
import 'package:sponsor_karo/components/analytics/charts.dart';
import 'package:sponsor_karo/components/analytics/donor_card.dart';
import 'package:sponsor_karo/components/analytics/top_donors_page.dart';
import 'package:sponsor_karo/types.dart';

// ----- Demo Data ----- //

final List<Donor> demoDonors = [
  Donor(
    username: 'Alice',
    monthlyAmount: 200,
    totalAmount: 1500,
    transactions: [
      DonationTransaction(
        id: 'a1',
        amount: 100,
        date: DateTime.parse("2025-03-01"),
      ),
      DonationTransaction(
        id: 'a2',
        amount: 100,
        date: DateTime.parse("2025-03-15"),
      ),
    ],
  ),
  Donor(
    username: 'Bob',
    monthlyAmount: 150,
    totalAmount: 1200,
    transactions: [
      DonationTransaction(
        id: 'b1',
        amount: 75,
        date: DateTime.parse("2025-03-05"),
      ),
      DonationTransaction(
        id: 'b2',
        amount: 75,
        date: DateTime.parse("2025-03-20"),
      ),
    ],
  ),
  Donor(
    username: 'Charlie',
    monthlyAmount: 300,
    totalAmount: 2500,
    transactions: [
      DonationTransaction(
        id: 'c1',
        amount: 150,
        date: DateTime.parse("2025-03-03"),
      ),
      DonationTransaction(
        id: 'c2',
        amount: 150,
        date: DateTime.parse("2025-03-18"),
      ),
    ],
  ),
  Donor(
    username: 'Diana',
    monthlyAmount: 180,
    totalAmount: 1100,
    transactions: [
      DonationTransaction(
        id: 'd1',
        amount: 90,
        date: DateTime.parse("2025-03-07"),
      ),
      DonationTransaction(
        id: 'd2',
        amount: 90,
        date: DateTime.parse("2025-03-22"),
      ),
    ],
  ),
  Donor(
    username: 'Edward',
    monthlyAmount: 220,
    totalAmount: 1300,
    transactions: [
      DonationTransaction(
        id: 'e1',
        amount: 110,
        date: DateTime.parse("2025-03-09"),
      ),
      DonationTransaction(
        id: 'e2',
        amount: 110,
        date: DateTime.parse("2025-03-24"),
      ),
    ],
  ),
  // More donors can be added...
];

final List<Map<String, String>> kpiList = [
  {
    'title': 'Donations This Month',
    'value': '\$100,000',
    'description': 'Total donations received this month',
  },
  {
    'title': 'Total Pledges',
    'value': '\$1573',
    'description': 'Number of recurring pledges',
  },
  {
    'title': 'Money Expected',
    'value': '\$50,000',
    'description': 'Expected monthly pledge amount',
  },
  {
    'title': 'Followers',
    'value': '95435',
    'description': 'Total followers count',
  },
  {
    'title': 'Views',
    'value': '51653424',
    'description': 'Total page views this month',
  },
];

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {

    // Display only the top 5 donors here.
    final List<Donor> topDonors = demoDonors.take(5).toList();

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
                itemCount: kpiList.length,
                itemBuilder: (context, index) {
                  return _buildKpiCard(
                    kpiList[index]['title']!,
                    kpiList[index]['value']!,
                    kpiList[index]['description']!,
                    Theme.of(context), // Using theme dynamically
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),
          AnalyticsCharts(),
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
            itemBuilder: (context, index) => DonorCard(donor: topDonors[index]),
          ),

          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TopDonorsPage(allDonors: demoDonors),
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
          padding: const EdgeInsets.fromLTRB(6,12,6,6),
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
