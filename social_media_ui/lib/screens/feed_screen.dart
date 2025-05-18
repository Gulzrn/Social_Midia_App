// lib/screens/feed_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FeedScreen extends StatelessWidget {
  Future<void> _downloadImage(String imageUrl) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final response = await http.get(Uri.parse(imageUrl));
        final dir = await getExternalStorageDirectory();
        final file = File(
          '${dir!.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await file.writeAsBytes(response.bodyBytes);
        Fluttertoast.showToast(msg: "Image downloaded successfully!");
      } else {
        Fluttertoast.showToast(msg: "Permission denied");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Download failed: $e");
    }
  }

  void _deletePost(BuildContext context, String postId, String imageUrl) async {
    bool confirm = false;
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Delete Post'),
            content: Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  confirm = true;
                  Navigator.pop(context);
                },
                child: Text('Yes'),
              ),
            ],
          ),
    );
    if (confirm) {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      Fluttertoast.showToast(msg: "Post deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Social Feed"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/upload'),
          ),
        ],
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(post['title']),
                  subtitle: Text(post['description']),
                  leading: GestureDetector(
                    onLongPress: () => _downloadImage(post['imageUrl']),
                    child: Image.network(
                      post['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  trailing: Wrap(
                    spacing: 12,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed:
                            () => Navigator.pushNamed(
                              context,
                              '/update',
                              arguments: post,
                            ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed:
                            () => _deletePost(
                              context,
                              post['postId'],
                              post['imageUrl'],
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
