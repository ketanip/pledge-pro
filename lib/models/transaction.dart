import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final bool subscriptionPayment;
  final int amount;
  final String currency;
  final String donorId;
  final String beneficiaryId;
  final Timestamp createdAt;

  Transaction({
    required this.id,
    required this.subscriptionPayment,
    required this.amount,
    required this.currency,
    required this.donorId,
    required this.beneficiaryId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    subscriptionPayment: json['subscription_payment'],
    amount: json['amount'],
    currency: json['currency'],
    donorId: json['donor_id'],
    beneficiaryId: json['beneficiary_id'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subscription_payment': subscriptionPayment,
    'amount': amount,
    'currency': currency,
    'donor_id': donorId,
    'beneficiary_id': beneficiaryId,
    'created_at': createdAt,
  };
}
