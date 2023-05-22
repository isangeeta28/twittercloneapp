import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterapp/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import 'addpostscreen.dart';
import 'login_screen.dart';
import 'package:twitterapp/model/users.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    getUserDetails();
    authProvider = context.read<AuthProvider>();

    if(authProvider.getUserFirebaseId()?.isNotEmpty == true){
      currentUserId = authProvider.getUserFirebaseId()!;
    }else{
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> LoginScreen()),
              (Route<dynamic> route) => false);
    }
    // listScrollConttroller.addListener(scrollListener);
  }
  late final FirebaseFirestore firestore;

  late AuthProvider authProvider;
  late String currentUserId;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //function for signout method
  Future<void> handleSignOut() async{
    authProvider.handleSignOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
  }


  Users? userDetails;

  getUserDetails() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    userDetails = await authProvider.getUserDetails();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title:  Text("Twitter",
              style: TextStyle(fontSize: 25, color: Colors.black,
                  fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),

          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser?.photoURL??""
                  //userDetails?.photoUrl??""
              ),
            ),
          ),

          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onPressed: (){
                handleSignOut();
              },
            ),
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPostScreen()),
            );
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add,color: Colors.white,
            size: 30,),
            // child: FittedBox(
            //   child: FloatingActionButton(onPressed: () {}),
            // ),
          ),
        ),
        // FloatingActionButton(
        //   shape: BorderRadius()
        //   onPressed: (){},
        // tooltip: 'Increment',
        //   child: const Icon(Icons.add),
        // ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.
          collection('posts').orderBy("datePublished",descending: true).
          snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) => Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 0.3 ,
                  vertical: 10 ,
                ),
                child: PostCard(
                  snap: snapshot.data!.docs[index].data(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
