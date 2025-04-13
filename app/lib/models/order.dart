import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String donorId;
  final String beneficiaryId;
  final Timestamp createdAt;

  Order({
    required this.id,
    required this.donorId,
    required this.beneficiaryId,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        donorId: json['donor_id'],
        beneficiaryId: json['beneficiary_id'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'donor_id': donorId,
        'beneficiary_id': beneficiaryId,
        'created_at': createdAt,
      };
}
