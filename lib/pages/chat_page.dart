import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/groupInfo_page.dart';
import 'package:flutter_chat_app/pages/imagePicker_page.dart';
import 'package:flutter_chat_app/service/database_service.dart';
import 'package:flutter_chat_app/widgets/message_tile.dart';
import 'package:flutter_chat_app/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String admin = "";
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  File? _imageFilePath;
  get imageFilePath => _imageFilePath;
  String type = "text";
  String? imgUrl;
  String _imgName = '';
  String get imgName => _imgName;
  PickedFile? _pickedFile;
  get pickedFile => _pickedFile;
  Map<String, dynamic>? _chatMessageMap;
  get chatMessageMap => _chatMessageMap;

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });

    DatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  Future pickImage(String method, BuildContext context) async {
    // print('select image');

    // await Permission.photos.request();

    // if (method == 'camera') {
    //   final image = await ImagePicker().pickImage(source: ImageSource.camera);
    //   if (image == null) return;
    //   // final imageTemporary = File(image.path);
    //   final imagePermanently = await saveImagePermanently(image.path);

    //   setState(() {
    //     this.imageFile = imagePermanently;
    //   });
    // }
    if (method == 'gallery') {
      _pickedFile = await ImagePicker()
          .pickImage(source: ImageSource.gallery)
          .then((XFile) {
        if (XFile != null) {
          _imageFilePath = File(XFile.path);
          // _imgName = _imageFilePath!.uri.path.split('/').last;
          uploadImage();

          // nextScreen(
          //     context,
          //     ImgPicker(
          //       imageFilePath: _imageFilePath,
          //       userName: widget.userName,
          //       imgUrl: imgUrl,
          //       groupId: widget.groupId,
          //     ));
        }
      });
    }
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .doc(fileName)
        .set({
      "sender": widget.userName,
      "message": "",
      "type": "img",
      "time": DateTime.now().millisecondsSinceEpoch,
    });

    var ref =
        FirebaseStorage.instance.ref().child('image').child("$fileName.jpg");
    final TaskSnapshot uploadTask =
        await ref.putFile(imageFilePath!).catchError((error) async {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imgu = await uploadTask.ref.getDownloadURL();

      setState(() {
        type = "text";
      });

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(fileName)
          .update({
        'message': imgu,
      });

      // setState(() {
      //   type = "img";
      //   // print('the image url is $imgu');
      //   imgUrl = imgu;
      // });
    }

    print("imageURL: $imgUrl");
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    final name = basename(imagePath);
    print(name);
    final image = File('${directory.path}/$name');
    print(image);
    return File(imagePath).copy(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 79, 139, 128),
        ),
        title: Text(
          widget.groupName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(
                  context,
                  GroupInfo(
                    adminName: admin,
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                  ));
            },
            icon: const Icon(Icons.info),
            color: const Color.fromARGB(255, 79, 139, 128),
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            chatMessages(type),
            // Container(
            //   child: imageFile != null
            //       ? Image.file(
            //           imageFile!,
            //           width: 160,
            //           height: 160,
            //           fit: BoxFit.cover,
            //         )
            //       : Container(),
            // ),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: Container(
                height: 78,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).primaryColor,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GestureDetector(
                      //   onTap: () {
                      //     pickImage();
                      //   },
                      //   child: Icon(
                      //     Icons.camera_alt,
                      //     size: 25,
                      //     color: const Color.fromARGB(255, 79, 139, 128),
                      //   ),
                      // ),
                      IconButton(
                        onPressed: () {
                          pickImage('camera', context);
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          size: 25,
                          color: const Color.fromARGB(255, 79, 139, 128),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          pickImage('gallery', context);
                        },
                        icon: Icon(
                          Icons.image,
                          size: 25,
                          color: const Color.fromARGB(255, 79, 139, 128),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: messageController,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(12),
                            isDense: true,
                            fillColor: Color.fromARGB(255, 6, 52, 44),
                            filled: true,
                            hintText: "Send a message.....",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 146, 154, 152),
                            ),
                            // border: OutlineInputBorder(
                            //   borderRadius: BorderRadius.circular(50),
                            // ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 6, 52, 44),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.send,
                              color: Color.fromARGB(255, 79, 139, 128),
                              size: 30,
                            ),
                          ),
                        ),
                      )
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  chatMessages(String type) {
    return StreamBuilder(
      stream: chats,
      builder: ((context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data.docs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == snapshot.data.docs.length) {
                      return Container(
                        height: 78,
                      );
                    }
                    // print('itemCound: ${snapshot.data.docs.length}');

                    return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender'],
                      sentTime: DateTime.fromMillisecondsSinceEpoch(
                          snapshot.data.docs[index]['time']),
                      type: snapshot.data.docs[index]['type'],
                      groupId: widget.groupId,
                      // isImg: snapshot.data.docs[index]['isImage'],
                      isImg: true,
                    );
                  },
                ),
              )
            : Container();
      }),
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      print('from here image url is $imgUrl');
      _chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "isImage": false,
        "imgUrl": '$imgUrl',
        "type": "text",
      };
      // print(chatMessageMap);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);

      // _scrollController.jumpTo(chatNo!);

      DatabaseService().sendMessage(widget.groupId, _chatMessageMap!, "text");
      setState(() {
        messageController.clear();
      });
    }
    //  else if (type == "img") {
    //   Map<String, dynamic> _chatMessageMap = {
    //     "sender": widget.userName,
    //     "time": DateTime.now().millisecondsSinceEpoch,
    //     "isImage": true,
    //     // "type": "text",
    //     "imgUrl": imgUrl,
    //   };
    //   // print(chatMessageMap);
    //   _scrollController.animateTo(_scrollController.position.maxScrollExtent,
    //       duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    //   // _scrollController.jumpTo(chatNo!);

    //   DatabaseService().sendMessage(widget.groupId, _chatMessageMap!, type);
    //   setState(() {
    //     messageController.clear();
    //     type = "text";
    //   });
    // }
  }
}
