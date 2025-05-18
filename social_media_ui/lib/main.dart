// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:social_media_ui/screens/feed_screen.dart';
// // import 'package:social_media_ui/screens/upload_screen.dart';
// // import 'package:social_media_ui/screens/update_screen.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Social App',
// //       theme: ThemeData(primarySwatch: Colors.blue),
// //       initialRoute: '/',
// //       routes: {
// //         '/': (context) => FeedScreen(),
// //         '/upload': (context) => UploadScreen(),
// //         '/update': (context) => UpdateScreen(),
// //       },
// //     );
// //   }
// // }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Social Media App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: HomeTabBar(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class HomeTabBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Social Media App"),
//           bottom: TabBar(tabs: [Tab(text: "Feed"), Tab(text: "Upload")]),
//         ),
//         body: TabBarView(children: [FeedScreen(), UploadScreen()]),
//       ),
//     );
//   }
// }

// // Upload Screen
// class UploadScreen extends StatefulWidget {
//   @override
//   _UploadScreenState createState() => _UploadScreenState();
// }

// class _UploadScreenState extends State<UploadScreen> {
//   final titleController = TextEditingController();
//   final descController = TextEditingController();
//   File? _image;
//   final picker = ImagePicker();

//   Future pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _image = File(pickedFile.path));
//     }
//   }

//   Future uploadPost() async {
//     if (_image == null) return;

//     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//     final ref = FirebaseStorage.instance.ref('posts/$fileName');
//     await ref.putFile(_image!);
//     final imageUrl = await ref.getDownloadURL();

//     await FirebaseFirestore.instance.collection('posts').add({
//       'title': titleController.text,
//       'desc': descController.text,
//       'image': imageUrl,
//       'timestamp': Timestamp.now(),
//     });

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text("Post uploaded!")));
//     titleController.clear();
//     descController.clear();
//     setState(() => _image = null);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           TextField(
//             controller: titleController,
//             decoration: InputDecoration(labelText: "Title"),
//           ),
//           TextField(
//             controller: descController,
//             decoration: InputDecoration(labelText: "Description"),
//           ),
//           SizedBox(height: 10),
//           ElevatedButton(onPressed: pickImage, child: Text("Pick Image")),
//           if (_image != null) Image.file(_image!, height: 150),
//           ElevatedButton(onPressed: uploadPost, child: Text("Upload")),
//         ],
//       ),
//     );
//   }
// }

// // Feed Screen
// class FeedScreen extends StatelessWidget {
//   Future<void> downloadImage(String imageUrl) async {
//     final status = await Permission.storage.request();
//     if (!status.isGranted) return;

//     final response = await http.get(Uri.parse(imageUrl));
//     final dir = await getExternalStorageDirectory();
//     final file = File(
//       '${dir!.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
//     );
//     await file.writeAsBytes(response.bodyBytes);
//   }

//   void showDeleteDialog(BuildContext context, String docId) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             content: Text("Are you sure you want to delete this post?"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text("No"),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   await FirebaseFirestore.instance
//                       .collection('posts')
//                       .doc(docId)
//                       .delete();
//                   Navigator.pop(context);
//                 },
//                 child: Text("Yes"),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream:
//           FirebaseFirestore.instance
//               .collection('posts')
//               .orderBy('timestamp', descending: true)
//               .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData)
//           return Center(child: CircularProgressIndicator());
//         final posts = snapshot.data!.docs;
//         return ListView.builder(
//           itemCount: posts.length,
//           itemBuilder: (_, i) {
//             final post = posts[i];
//             return Card(
//               child: ListTile(
//                 title: Text(post['title']),
//                 subtitle: Text(post['desc']),
//                 leading: GestureDetector(
//                   onLongPress: () async {
//                     await downloadImage(post['image']);
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Image downloaded!")),
//                     );
//                   },
//                   child: Image.network(
//                     post['image'],
//                     width: 60,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 trailing: Wrap(
//                   spacing: 8,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit),
//                       onPressed:
//                           () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder:
//                                   (_) => UpdateScreen(
//                                     post.id,
//                                     post['title'],
//                                     post['desc'],
//                                     post['image'],
//                                   ),
//                             ),
//                           ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete),
//                       onPressed: () => showDeleteDialog(context, post.id),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// // Update Screen
// class UpdateScreen extends StatefulWidget {
//   final String docId, title, desc, imageUrl;
//   UpdateScreen(this.docId, this.title, this.desc, this.imageUrl);

//   @override
//   _UpdateScreenState createState() => _UpdateScreenState();
// }

// class _UpdateScreenState extends State<UpdateScreen> {
//   late TextEditingController titleController, descController;
//   File? _newImage;
//   final picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     titleController = TextEditingController(text: widget.title);
//     descController = TextEditingController(text: widget.desc);
//   }

//   Future pickImage() async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) setState(() => _newImage = File(picked.path));
//   }

//   Future updatePost() async {
//     String imageUrl = widget.imageUrl;

//     if (_newImage != null) {
//       final ref = FirebaseStorage.instance.ref(
//         'posts/${DateTime.now().millisecondsSinceEpoch}',
//       );
//       await ref.putFile(_newImage!);
//       imageUrl = await ref.getDownloadURL();
//     }

//     await FirebaseFirestore.instance
//         .collection('posts')
//         .doc(widget.docId)
//         .update({
//           'title': titleController.text,
//           'desc': descController.text,
//           'image': imageUrl,
//         });

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Update Post")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(labelText: "Title"),
//             ),
//             TextField(
//               controller: descController,
//               decoration: InputDecoration(labelText: "Description"),
//             ),
//             ElevatedButton(onPressed: pickImage, child: Text("Change Image")),
//             (_newImage != null)
//                 ? Image.file(_newImage!, height: 100)
//                 : Image.network(widget.imageUrl, height: 100),
//             ElevatedButton(onPressed: updatePost, child: Text("Update")),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

void main() {
  runApp(SocialMediaApp());
}

class SocialMediaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: LoginScreen(),
    );
  }
}

/// -------- Login Screen ---------
class LoginScreen extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Login to continue',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock),
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 100.0,
                  vertical: 15.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // For demo, just navigate to HomeScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('Login', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------- Home Screen with Bottom Navigation ---------

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = [FeedPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(selectedIndex == 0 ? 'Feed' : 'Profile')),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// -------- Feed Page ---------

class FeedPage extends StatelessWidget {
  final List<Post> posts = [
    Post(
      username: 'alice',
      userImg: 'https://randomuser.me/api/portraits/women/65.jpg',
      postImg:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      caption: 'Enjoying the beautiful sunset!',
      likes: 120,
      comments: 12,
    ),
    Post(
      username: 'bob',
      userImg: 'https://randomuser.me/api/portraits/men/32.jpg',
      postImg:
          'https://images.unsplash.com/photo-1517816428104-7b37f3d28807?auto=format&fit=crop&w=800&q=80',
      caption: 'Hiking adventures.',
      likes: 230,
      comments: 45,
    ),
    Post(
      username: 'carol',
      userImg: 'https://randomuser.me/api/portraits/women/44.jpg',
      postImg:
          'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=800&q=80',
      caption: 'City lights at night.',
      likes: 340,
      comments: 30,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostWidget(post: post);
      },
    );
  }
}

class Post {
  final String username;
  final String userImg;
  final String postImg;
  final String caption;
  final int likes;
  final int comments;

  Post({
    required this.username,
    required this.userImg,
    required this.postImg,
    required this.caption,
    required this.likes,
    required this.comments,
  });
}

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.userImg),
                  radius: 20,
                ),
                SizedBox(width: 12),
                Text(
                  post.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),

          // Post image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              post.postImg,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),

          // Caption and actions
          Padding(padding: EdgeInsets.all(12), child: Text(post.caption)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.grey),
                SizedBox(width: 6),
                Text(post.likes.toString()),
                SizedBox(width: 20),
                Icon(Icons.comment_outlined, color: Colors.grey),
                SizedBox(width: 6),
                Text(post.comments.toString()),
              ],
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// -------- Profile Page ---------

class ProfilePage extends StatelessWidget {
  final String profilePic = 'https://randomuser.me/api/portraits/women/65.jpg';
  final String username = 'alice';
  final String bio = 'Travel lover | Foodie | Photographer';
  final int followers = 1240;
  final int following = 300;
  final int posts = 58;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(radius: 60, backgroundImage: NetworkImage(profilePic)),
          SizedBox(height: 16),
          Text(
            username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 8),
          Text(
            bio,
            style: TextStyle(color: Colors.grey[700], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Posts', posts),
              _buildStat('Followers', followers),
              _buildStat('Following', following),
            ],
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.deepPurple,
            ),
            child: Text('Edit Profile', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int number) {
    return Column(
      children: [
        Text(
          number.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}
