// lib/screens/upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String postId = Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref().child(
        'posts/$postId.jpg',
      );
      await storageRef.putFile(_image!);
      String imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'title': _titleController.text,
        'description': _descController.text,
        'imageUrl': imageUrl,
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Post Title'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            _image == null
                ? Text('No Image Selected')
                : Image.file(_image!, height: 200),
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text('Select Image'),
              onPressed: _pickImage,
            ),
            SizedBox(height: 20),
            _isUploading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _uploadPost, child: Text('Upload')),
          ],
        ),
      ),
    );
  }
}
