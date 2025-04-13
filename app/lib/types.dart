import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/models/transaction.dart';

class DonorTransactions {
  final PublicProfile donor;
  final List<Transaction> transactions;
  final int donationThisMonth;
  final int totalDonations;

  DonorTransactions({
    required this.donor,
    required this.transactions,
    required this.donationThisMonth,
    required this.totalDonations,
  });

  // Optionally, you can add a method to convert it to JSON or other useful methods.
  Map<String, dynamic> toJson() => {
    'donor': donor.toJson(),
    'transactions': transactions.map((t) => t.toJson()).toList(),
    'donationThisMonth': donationThisMonth,
    'totalDonations': totalDonations,
  };
}
