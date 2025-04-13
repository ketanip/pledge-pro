import 'package:flutter/material.dart';
import 'package:sponsor_karo/types.dart';

class DonorCard extends StatefulWidget {
  final DonorTransactions data;
  const DonorCard({super.key, required this.data});

  @override
  _DonorCardState createState() => _DonorCardState();
}

class _DonorCardState extends State<DonorCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Image.network(widget.data.donor.profilePic),
            ),
            title: Text(
              widget.data.donor.fullName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "This Month: ₹ ${widget.data.donationThisMonth} \nTotal: ₹ ${widget.data.totalDonations}",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () {
              setState(() => _expanded = !_expanded);
            },
          ),
          if (_expanded) _buildTransactionList(textTheme),
        ],
      ),
    );
  }

  Widget _buildTransactionList(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children:
            widget.data.transactions.map((tx) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${tx.createdAt.toDate().toLocal().toString().split(' ')[0]}",
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      "₹ ${tx.amount}",
                      style: textTheme.bodyMedium?.copyWith(
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
