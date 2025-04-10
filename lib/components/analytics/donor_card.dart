import 'package:flutter/material.dart';
import 'package:sponsor_karo/types.dart';

class DonorCard extends StatefulWidget {
  final Donor donor;
  const DonorCard({super.key, required this.donor});

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
            title: Text(
              widget.donor.username,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "This Month: \$${widget.donor.monthlyAmount} | Total: \$${widget.donor.totalAmount}",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.message, color: colorScheme.primary),
              onPressed: () {
                // Trigger message action
              },
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
            widget.donor.transactions.map((tx) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${tx.date.toLocal().toString().split(' ')[0]}",
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      "\$${tx.amount}",
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
