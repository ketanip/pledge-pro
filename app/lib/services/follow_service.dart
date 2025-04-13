import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  CollectionReference get _followers => _firestore.collection('followers');
  CollectionReference get _following => _firestore.collection('following');
  CollectionReference get _profiles => _firestore.collection('public-profiles');

  /// Follow a user and update follower/following counts
  Future<void> followUser(String targetUsername) async {
    final userEmail = _firebaseAuth.currentUser?.email;

    if (userEmail == null) {
      throw Exception("User not logged in");
    }
    final currentUsername = userEmail.split('@').first.toLowerCase();

    final batch = _firestore.batch();

    final followerRef = _followers
        .doc(targetUsername)
        .collection('userFollowers')
        .doc(currentUsername);
    final followingRef = _following
        .doc(currentUsername)
        .collection('userFollowing')
        .doc(targetUsername);

    final targetProfileRef = _profiles.doc(targetUsername);
    final currentProfileRef = _profiles.doc(currentUsername);

    batch.set(followerRef, {'username': currentUsername});
    batch.set(followingRef, {'username': targetUsername});

    batch.update(targetProfileRef, {'followerCount': FieldValue.increment(1)});
    batch.update(currentProfileRef, {
      'followingCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Unfollow a user and update follower/following counts
  Future<void> unfollowUser(String targetUsername) async {
    final userEmail = _firebaseAuth.currentUser?.email;

    if (userEmail == null) {
      throw Exception("User not logged in");
    }
    final currentUsername = userEmail.split('@').first.toLowerCase();

    final batch = _firestore.batch();

    final followerRef = _followers
        .doc(targetUsername)
        .collection('userFollowers')
        .doc(currentUsername);
    final followingRef = _following
        .doc(currentUsername)
        .collection('userFollowing')
        .doc(targetUsername);

    final targetProfileRef = _profiles.doc(targetUsername);
    final currentProfileRef = _profiles.doc(currentUsername);

    batch.delete(followerRef);
    batch.delete(followingRef);

    batch.update(targetProfileRef, {'followerCount': FieldValue.increment(-1)});
    batch.update(currentProfileRef, {
      'followingCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// Get followers of a user
  Future<List<String>> getFollowers(String username) async {
    final query =
        await _followers.doc(username).collection('userFollowers').get();
    return query.docs.map((doc) => doc.id).toList();
  }

  /// Get following of a user
  Future<List<String>> getFollowing(String username) async {
    final query =
        await _following.doc(username).collection('userFollowing').get();
    return query.docs.map((doc) => doc.id).toList();
  }

  /// Check if current user is following target user
  Future<bool> isFollowing(String targetUsername) async {
    final userEmail = _firebaseAuth.currentUser?.email;

    if (userEmail == null) {
      throw Exception("User not logged in");
    }
    final currentUsername = userEmail.split('@').first.toLowerCase();

    final doc =
        await _following
            .doc(currentUsername)
            .collection('userFollowing')
            .doc(targetUsername)
            .get();

    return doc.exists;
  }
}
