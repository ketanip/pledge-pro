import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sponsor_karo/models/detail.dart';
import 'package:uuid/uuid.dart';
import '../models/public_profile.dart';

class PublicProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  CollectionReference get _profiles => _firestore.collection('public-profiles');

  Future<void> createPublicProfile() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null || firebaseUser.email == null) {
      throw Exception("No logged-in user with valid email found.");
    }

    final email = firebaseUser.email!;
    final username = email.split('@').first.toLowerCase();
    final profileDoc = _profiles.doc(username);
    final docSnapshot = await profileDoc.get();

    if (docSnapshot.exists) {
      // If profile exists but UID is missing, update it
      final data = docSnapshot.data() as Map<String, dynamic>;
      if (data['uid'] == null || data['uid'].toString().isEmpty) {
        await profileDoc.update({'uid': firebaseUser.uid});
      }
      return;
    }

    final newProfile = PublicProfile(
      uid: firebaseUser.uid,
      username: username,
      fullName: firebaseUser.displayName ?? '',
      profilePic: firebaseUser.photoURL ?? '',
      bio: '',
      details: [],
      followerCount: 0,
      followingCount: 0,
    );

    await profileDoc.set(newProfile.toJson());
  }

  /// Update a public profile
  Future<void> updatePublicProfile(PublicProfile profile) async {
    await _profiles.doc(profile.username).update(profile.toJson());
  }

  /// Get public profile by username
  Future<PublicProfile> getPublicProfile(String username) async {
    final doc = await _profiles.doc(username).get();
    if (doc.exists) {
      return PublicProfile.fromJson(doc.data() as Map<String, dynamic>);
    }
    throw Exception("Invalid username");
  }

  /// Get public profile by Firebase UID (sub)
  Future<PublicProfile> getPublicProfileBySub(String uid) async {
    final query = await _profiles.where('uid', isEqualTo: uid).limit(1).get();

    if (query.docs.isEmpty) {
      throw Exception("No profile found for UID: $uid");
    }

    return PublicProfile.fromJson(
      query.docs.first.data() as Map<String, dynamic>,
    );
  }

  /// Get all public profiles
  Future<List<PublicProfile>> getAllPublicProfiles() async {
    final snapshot = await _profiles.get();

    return snapshot.docs.map((doc) {
      return PublicProfile.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Upload profile image and return download URL
  Future<String> uploadProfileImage(String username, File imageFile) async {
    final ref = _storage.ref().child(
      'public-profiles/$username/profilePic_${_uuid.v4()}.jpg',
    );
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  /// Add a detail to user's profile
  Future<void> addDetailToProfile(String username, Detail detail) async {
    final profileDoc = _profiles.doc(username);
    final snapshot = await profileDoc.get();

    if (!snapshot.exists) throw Exception("Profile not found");

    final profile = PublicProfile.fromJson(
      snapshot.data() as Map<String, dynamic>,
    );
    final updatedDetails = [...profile.details, detail];

    await profileDoc.update({
      'details': updatedDetails.map((e) => e.toJson()).toList(),
    });
  }

  /// Update a specific detail in the user's profile
  Future<void> updateDetailInProfile(
    String username,
    Detail updatedDetail,
  ) async {
    final profileDoc = _profiles.doc(username);
    final snapshot = await profileDoc.get();

    if (!snapshot.exists) throw Exception("Profile not found");

    final profile = PublicProfile.fromJson(
      snapshot.data() as Map<String, dynamic>,
    );
    final updatedDetails =
        profile.details.map((d) {
          return d.id == updatedDetail.id ? updatedDetail : d;
        }).toList();

    await profileDoc.update({
      'details': updatedDetails.map((e) => e.toJson()).toList(),
    });
  }

  /// Delete a specific detail from the profile
  Future<void> deleteDetailFromProfile(String username, String detailId) async {
    final profileDoc = _profiles.doc(username);
    final snapshot = await profileDoc.get();

    if (!snapshot.exists) throw Exception("Profile not found");

    final profile = PublicProfile.fromJson(
      snapshot.data() as Map<String, dynamic>,
    );
    final filteredDetails =
        profile.details.where((d) => d.id != detailId).toList();

    await profileDoc.update({
      'details': filteredDetails.map((e) => e.toJson()).toList(),
    });
  }
}
