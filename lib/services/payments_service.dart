import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sponsor_karo/models/subscription.dart';
import '../models/transaction.dart' as transaction;

class PaymentsService {
  final FirebaseFunctions functions = FirebaseFunctions.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Create a one-time checkout
  Future<String> createOneTimeCheckout({
    required String beneficiaryId,
    required int amount,
    required String currency,
  }) async {
    final callable = functions.httpsCallable('createOneTimeCheckout');
    final result = await callable.call({
      'beneficiary_id': beneficiaryId,
      'amount': amount,
      'currency': currency,
    });
    return result.data['order_id'];
  }

  // Create a subscription checkout
  Future<String> createSubscriptionCheckout({
    required String beneficiaryId,
    required String planId,
  }) async {
    final callable = functions.httpsCallable('createSubscriptionCheckout');
    final result = await callable.call({
      'beneficiary_id': beneficiaryId,
      'plan_id': planId,
    });
    return result.data['subscription_id'];
  }

  // Cancel a subscription
  Future<void> cancelSubscription(String subscriptionId) async {
    final callable = functions.httpsCallable('cancelSubscription');
    await callable.call({'subscription_id': subscriptionId});
  }

  // Get all transactions
  Future<List<transaction.Transaction>> getAllTransactions() async {
    final snapshot = await firestore.collection('transaction').get();
    return snapshot.docs
        .map((doc) => transaction.Transaction.fromJson(doc.data()))
        .toList();
  }

  // Get all donations made
  Future<List<transaction.Transaction>> getAllDonationsMade() async {
    final donorId = _firebaseAuth.currentUser?.uid ?? "";
    final snapshot =
        await firestore
            .collection('transaction')
            .where('donor_id', isEqualTo: donorId)
            .get();
    return snapshot.docs
        .map((doc) => transaction.Transaction.fromJson(doc.data()))
        .toList();
  }

  // Get all donations received
  Future<List<transaction.Transaction>> getAllDonationsReceived() async {
    final beneficiaryId = _firebaseAuth.currentUser?.uid ?? "";
    final snapshot =
        await firestore
            .collection('transaction')
            .where('beneficiary_id', isEqualTo: beneficiaryId)
            .get();
    return snapshot.docs
        .map((doc) => transaction.Transaction.fromJson(doc.data()))
        .toList();
  }

  // Get subscription status
  Future<String> getSubscriptionStatus(String subscriptionId) async {
    final doc =
        await firestore.collection('subscriptions').doc(subscriptionId).get();
    if (doc.exists) {
      return doc.data()?['status'] ?? 'unknown';
    }
    return 'unknown';
  }

  // Update subscription status
  Future<void> updateSubscriptionStatus({
    required String subscriptionId,
    required String status,
  }) async {
    await firestore.collection('subscriptions').doc(subscriptionId).update({
      'status': status,
    });
  }

  /// Get subscriptions by donor_id
  Future<List<Subscription>> getSubscriptionsByDonor() async {
    final donorId = _firebaseAuth.currentUser?.uid ?? "";
    final snapshot =
        await firestore
            .collection('subscriptions')
            .where('donor_id', isEqualTo: donorId)
            .get();

    return snapshot.docs
        .map((doc) => Subscription.fromJson(doc.data()))
        .toList();
  }

  /// Get subscriptions by beneficiary_id
  Future<List<Subscription>> getSubscriptionsByBeneficiary(
    String beneficiaryId,
  ) async {
    final snapshot =
        await firestore
            .collection('subscriptions')
            .where('beneficiary_id', isEqualTo: beneficiaryId)
            .get();

    return snapshot.docs
        .map((doc) => Subscription.fromJson(doc.data()))
        .toList();
  }
}
