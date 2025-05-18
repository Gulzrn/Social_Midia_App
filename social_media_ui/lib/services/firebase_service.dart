// lib/services/firebase_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage, returns download URL
  Future<String> uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('posts').child(fileName);
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Create a new post
  Future<void> createPost({
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    await _firestore.collection('posts').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Read posts as a stream (ordered by timestamp descending)
  Stream<QuerySnapshot> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Update a post by document ID
  Future<void> updatePost({
    required String postId,
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    await _firestore.collection('posts').doc(postId).update({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    });
  }

  // Delete a post by document ID
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }
}
