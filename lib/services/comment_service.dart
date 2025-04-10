import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  /// Helper to get comments collection for a post
  CollectionReference _getCommentsCollection(String postId) {
    return _firestore.collection('posts').doc(postId).collection('comments');
  }

  /// Add a comment to a post
  Future<void> addComment(String postId, String commentText) async {
    final userEmail = _firebaseAuth.currentUser?.email;

    if (userEmail == null) {
      throw Exception("User not logged in");
    }

    final postedBy = userEmail.split('@').first.toLowerCase();
    final commentId = _uuid.v4();

    await _getCommentsCollection(postId).doc(commentId).set({
      'id': commentId,
      'postId': postId,
      'comment': commentText,
      'postedBy': postedBy,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a comment from a post
  Future<void> deleteComment(String postId, String commentId) async {
    await _getCommentsCollection(postId).doc(commentId).delete();
  }

  /// Fetch all comments for a post (once)
  Future<List<Comment>> fetchComments(String postId) async {
    final querySnapshot =
        await _getCommentsCollection(postId)
            .orderBy('id') // Optionally, you can use 'timestamp' if you have it
            .get();

    return querySnapshot.docs
        .map((doc) => Comment.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
