import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String id;
  final String planId;
  final String donorId;
  final String beneficiaryId;
  final String status;
  final Timestamp createdAt;

  Subscription({
    required this.id,
    required this.planId,
    required this.donorId,
    required this.beneficiaryId,
    required this.status,
    required this.createdAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'],
        planId: json['plan_id'],
        donorId: json['donor_id'],
        beneficiaryId: json['beneficiary_id'],
        status: json['status'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_id': planId,
        'donor_id': donorId,
        'beneficiary_id': beneficiaryId,
        'status': status,
        'created_at': createdAt,
      };
}
