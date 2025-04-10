class DonationTransaction {
  final String id;
  final double amount;
  final DateTime date;

  DonationTransaction({
    required this.id,
    required this.amount,
    required this.date,
  });
}

class Donor {
  final String username;
  final double monthlyAmount;
  final double totalAmount;
  final List<DonationTransaction> transactions;
  // You can add additional fields (e.g., userId, profileImage, etc.) as needed.

  Donor({
    required this.username,
    required this.monthlyAmount,
    required this.totalAmount,
    required this.transactions,
  });
}
