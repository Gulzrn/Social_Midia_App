// lib/screens/update_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpdateScreen extends StatefulWidget {
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _image;
  String? _postId;
  String? _oldImageUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final post =
        ModalRoute.of(context)!.settings.arguments as QueryDocumentSnapshot;
    _postId = post['postId'];
    _titleController.text = post['title'];
    _descController.text = post['description'];
    _oldImageUrl = post['imageUrl'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<String> _uploadNewImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child(fileName);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _updatePost() async {
    String title = _titleController.text.trim();
    String description = _descController.text.trim();
    String imageUrl = _oldImageUrl ?? '';

    if (_image != null) {
      imageUrl = await _uploadNewImage(_image!);
    }

    await FirebaseFirestore.instance.collection('posts').doc(_postId).update({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Post updated!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Post")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              SizedBox(height: 10),
              _image != null
                  ? Image.file(_image!, height: 200)
                  : _oldImageUrl != null
                  ? Image.network(_oldImageUrl!, height: 200)
                  : Container(),
              ElevatedButton.icon(
                icon: Icon(Icons.image),
                label: Text("Change Image"),
                onPressed: _pickImage,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _updatePost, child: Text("Update")),
            ],
          ),
        ),
      ),
    );
  }
}
