import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  CollectionReference get _posts => _firestore.collection('posts');

  /// Create a new post with generated ID
  Future<void> createPost(Post post) async {
    await _posts.doc(post.id).set(post.toJson());
  }

  /// Delete a post by ID
  Future<void> deletePost(String postId) async {
    await _posts.doc(postId).delete();
  }

  /// Get a single post by ID
  Future<Post?> getPostById(String postId) async {
    final doc = await _posts.doc(postId).get();
    if (doc.exists) {
      return Post.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Post>> getPostByUsername(String username) async {
    final query = await _posts.where('username', isEqualTo: username).get();
    return query.docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Like
  ///
  /// Like a post (increment like count)
  Future<void> likePost(String postId, String username) async {
    final docRef = _posts.doc(postId);

    // Increment like count
    await docRef.update({'likeCount': FieldValue.increment(1)});

    // Add user to likes subcollection
    await docRef.collection('likes').doc(username).set({
      'likedAt': FieldValue.serverTimestamp(),
    });
  }

  // Check if liked
  Future<bool> isPostLiked(String postId, String username) async {
    final likeDoc =
        await _posts.doc(postId).collection('likes').doc(username).get();

    return likeDoc.exists;
  }

  /// Unlike a post (decrement like count)
  Future<void> unlikePost(String postId, String username) async {
    final docRef = _posts.doc(postId);

    // Decrement like count
    await docRef.update({'likeCount': FieldValue.increment(-1)});

    // Remove user from likes subcollection
    await docRef.collection('likes').doc(username).delete();
  }

  /// Fetch all posts (once)
  Future<List<Post>> fetchAllPosts() async {
    final query = await _posts.get();
    return query.docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Upload post images and return list of download URLs
  Future<List<String>> uploadPostImages(
    String username,
    List<File> images,
  ) async {
    List<String> urls = [];

    for (File image in images) {
      final fileId = _uuid.v4();
      final ref = _storage.ref().child('posts/$username/$fileId.jpg');
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }
}
