import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:twitterapp/model/users.dart';
import 'package:twitterapp/provider/auth_provider.dart';
import 'package:twitterapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../resources/firestore_methods.dart';
import '../utilis/utils.dart';
import 'dart:typed_data';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  @override
  Uint8List? _file;
  File? videoFile;
  String videoUrl = '';
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  Users? userDetails;

  getUserDetails() async {
    AuthProvider authProvider = context.read<AuthProvider>();
     userDetails = await authProvider.getUserDetails();
  }


  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            // SimpleDialogOption(
            //     padding: const EdgeInsets.all(20),
            //     child: const Text('Choose Video from Gallery'),
            //     onPressed: () async {
            //       Navigator.of(context).pop();
            //       File? file = await uploadVideoPost(videoFile!);
            //       setState(() {
            //         videoFile = file;
            //       });
            //     }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void postImage({required String datauid, required String datausername, required String dataphotourl}) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _file!,
        datauid,
        datausername,
        dataphotourl,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close,
                color: Colors.black,),
                onPressed: (){
                  Navigator.pop(context);
                  clearImage;
                  _descriptionController.clear();
                },
              ),
              // title: const Text(
              //   'New Post ',
              //   style: TextStyle(color: Colors.black),
              // ),
              centerTitle: false,
              actions: <Widget>[
               Padding(
                 padding:  EdgeInsets.only(right: 10),
                 child: GestureDetector(
                   onTap: () {
                     postImage(
                       datauid: userDetails?.id??"",
                       datausername : userDetails?.nickname??"",
                       dataphotourl :userDetails?.photoUrl??"",
                     );
                     Future.delayed(const Duration(seconds: 4), () {
                       Navigator.pop(context);
                       clearImage;
                       _descriptionController.clear();
                     });

                   } ,

                   child: Container(
                    width: 70,
                     margin: EdgeInsets.all(10),
                     decoration: BoxDecoration(
                       color: Colors.blue,
                       borderRadius: BorderRadius.all(Radius.circular(20))
                     ),
                     child: Center(
                         child: Text("Tweet",
                         style: TextStyle(color: Colors.white, fontSize: 17,
                             fontWeight: FontWeight.w900),)
                     ),
                   ),
                 ),
               )
              ],
            ),
           bottomSheet: Container(
             width: 400,
             decoration: BoxDecoration(
               border: Border(
                 top: BorderSide( //                    <--- top side
                   color: Colors.grey,
                   width: 1.0,
                 ),
               ),
               color: Colors.white,
             ),

             child: Row(
               children: [
                 IconButton(
                     onPressed:() => _selectImage(context),
                     icon: Icon(Icons.image_outlined, color: Colors.blue,))
               ],
             ),
           ),
            // POST FORM
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                Padding(
                  padding:  EdgeInsets.only(left: 10),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              userDetails?.photoUrl??"",
                            ),
                          ),
                          SizedBox(width: 10,),
                          Padding(
                            padding:  EdgeInsets.only(right: 10),
                            child: Container(
                              width: 90,
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  //color: Colors.blue,
                                border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                              child: Center(
                                  child: Text("Public",
                                    style: TextStyle(color: Colors.blue, fontSize: 17,
                                        fontWeight: FontWeight.w900),)
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                              hintText: "What's happening?",
                              hintStyle: TextStyle(fontSize: 18),
                              border: InputBorder.none),
                          maxLines: 20,
                          minLines: 2,
                        ),
                      ),
                      _file == null
                          ?SizedBox()
                      :SizedBox(
                        // height: 50.0,
                        // width: 50.0,
                        child: Container(
                          height: 270.0,
                          width: 260.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                alignment: FractionalOffset.topCenter,
                                image: MemoryImage(_file!),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
