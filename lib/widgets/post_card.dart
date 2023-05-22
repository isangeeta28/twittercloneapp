import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twitterapp/utilis/utils.dart';
import 'package:twitterapp/widgets/like_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitterapp/model/users.dart' as model;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/users.dart';
import '../provider/auth_provider.dart';
import '../resources/firestore_methods.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({Key? key, required this.snap,}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    getUserDetails();
  }

  Users? userDetails;

  getUserDetails() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    userDetails = await authProvider.getUserDetails();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final Users? user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 0,
      ),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    //  userDetails?.photoUrl??""
                    widget.snap['profImage'].toString(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                         // userDetails?.nickname??"",
                          widget.snap['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17
                          ),
                        ),
                        SizedBox(
                          width: 300,
                            child: Text(widget.snap['description']))
                      ],
                    ),
                  ),
                ),
                widget.snap['uid'].toString() == userDetails?.id
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: SizedBox(
                                  height: 60,
                                  child: Column(
                                    children: [
                                      ListView(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          shrinkWrap: true,
                                          children: [
                                            'Delete',
                                          ]
                                              .map(
                                                (e) => InkWell(
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                                  child: Text(e),
                                                ),
                                                onTap: () {
                                                  deletePost(
                                                    widget.snap['postId']
                                                        .toString(),
                                                  );
                                                  // remove the dialog box
                                                  Navigator.of(context).pop();
                                                }),
                                          )
                                              .toList()),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert, color: Colors.grey,),
                      )
                    : Container(),
              ],
            ),
          ),
          // IMAGE SECTION OF THE POST
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding:  EdgeInsets.only(left: 62, right: 15),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage( widget.snap['postUrl'].toString())
                    )
                  ),
                  // child: Image.network(
                  //   widget.snap['postUrl'].toString(),
                  //   fit: BoxFit.cover,
                  // ),
                ),
              ),
            ],
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Padding(
            padding:  EdgeInsets.only(left: 62, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                     Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(width: 3,),
                    Text("23",
                    style: TextStyle( color: Colors.grey.shade700,),)
                  ],
                ),
                Row(
                  children: [
                     Icon(
                      Icons.reset_tv,
                       color: Colors.grey.shade700,
                    ),
                    SizedBox(width: 4,),
                    Text("83",
                    style: TextStyle(color: Colors.grey.shade700,),)
                  ],
                ),
                Row(
                  children: [
                    LikeAnimation(
                      isAnimating: widget.snap['likes'].contains(userDetails?.id),
                      smallLike: true,
                      child: IconButton(
                        icon: widget.snap['likes'].contains(userDetails?.id)
                            ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                            :  Icon(
                          Icons.favorite_border,
                          color: Colors.grey.shade700,
                        ),
                        onPressed: () => FireStoreMethods().likePost(
                          widget.snap['postId'].toString(),
                          userDetails?.id??"",
                          widget.snap['likes'],
                        ),
                      ),
                    ),
                    Text("${widget.snap['likes'].length}",
                    style: TextStyle(color: Colors.grey.shade700,),)
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.stacked_bar_chart,
                      color: Colors.grey.shade700,),
                    SizedBox(width: 3,),
                    Text("34",
                    style: TextStyle(fontSize: 16,color: Colors.grey.shade700,),)
                  ],
                ),

                IconButton(
                    icon: const Icon(
                      Icons.share_outlined,
                    ),
                    onPressed: () {}),
              ],
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
