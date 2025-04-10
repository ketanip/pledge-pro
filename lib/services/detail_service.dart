import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/detail.dart';
import '../models/public_profile.dart';

class DetailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  DocumentReference getProfileRef(String username) =>
      _firestore.collection('public-profiles').doc(username);

  /// Add a new detail to a user's public profile
  Future<void> addDetail(String username, Detail detail) async {
    final profileRef = getProfileRef(username);
    final snapshot = await profileRef.get();

    if (!snapshot.exists) {
      throw Exception("User profile does not exist");
    }

    final profile = PublicProfile.fromJson(
      snapshot.data() as Map<String, dynamic>,
    );
    final newDetail = detail.copyWith(id: _uuid.v4());
    final updatedDetails = [...profile.details, newDetail];

    await profileRef.update({
      'details': updatedDetails.map((e) => e.toJson()).toList(),
    });
  }

  /// Update a specific detail by ID
  Future<void> updateDetail(String username, Detail updatedDetail) async {
    final profileRef = getProfileRef(username);
    final snapshot = await profileRef.get();

    if (!snapshot.exists) throw Exception("Profile not found");

    final profile = PublicProfile.fromJson(
      snapshot.data() as Map<String, dynamic>,
    );
    final updatedDetails =
        profile.details.map((d) {
          return d.id == updatedDetail.id ? updatedDetail : d;
        }).toList();

    await profileRef.update({
      'details': updatedDetails.map((e) => e.toJson()).toList(),
    });
  }

  /// Delete a detail by ID
  Future<void> deleteDetail(String username, String detailId) async {
    final profileRef = getProfileRef(username);
    final snapshot = await profileRef.get();

    if (!snapshot.exists) throw Exception("Profile not found");

    final profile = PublicProfile.fromJson(
      snapshot.data() as Map<String, dynamic>,
    );
    final updatedDetails =
        profile.details.where((d) => d.id != detailId).toList();

    await profileRef.update({
      'details': updatedDetails.map((e) => e.toJson()).toList(),
    });
  }

  /// Get all details from a user profile
  Future<List<Detail>> getDetails(String username) async {
    final snapshot = await getProfileRef(username).get();
    if (!snapshot.exists) return [];

    final profile = PublicProfile.fromJson(
      snapshot.data() as Map<String, dynamic>,
    );
    return profile.details;
  }
}
