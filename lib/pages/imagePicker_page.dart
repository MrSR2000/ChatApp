import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/service/database_service.dart';

class ImgPicker extends StatefulWidget {
  File? imageFilePath;
  String? userName;
  String? imgUrl;
  String? groupId;

  ImgPicker({
    required this.imageFilePath,
    required this.userName,
    required this.imgUrl,
    required this.groupId,
  });

  @override
  State<ImgPicker> createState() => _ImgPickerState();
}

class _ImgPickerState extends State<ImgPicker> {
  @override
  void initState() {
    // TODO: implement initState
    print('reached to next page');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              height: size.height,
              width: size.width,
              child: Image.file(widget.imageFilePath!),
            ),
            IconButton(
              iconSize: size.height * .035,
              onPressed: () {
                // print('back');
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 79, 139, 128),
              ),
            ),
            // SizedBox(width: size.width * .05),
            Positioned(
              bottom: 20,
              right: 15,
              child: IconButton(
                iconSize: 40,
                icon: const Icon(
                  Icons.send,
                  color: Color.fromARGB(255, 79, 139, 128),
                ),
                onPressed: () {
                  print('send pressed');
                  sendMessage();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendMessage() {
    // if (type == "text") {
    //   if (messageController.text.isNotEmpty) {
    //     _chatMessageMap = {
    //       "message": messageController.text,
    //       "sender": widget.userName,
    //       "time": DateTime.now().millisecondsSinceEpoch,
    //       "isImage": false,
    //     };
    //     // print(chatMessageMap);
    //     _scrollController.animateTo(_scrollController.position.maxScrollExtent,
    //         duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    //     // _scrollController.jumpTo(chatNo!);

    //     DatabaseService().sendMessage(widget.groupId, _chatMessageMap!, type);
    //     setState(() {
    //       messageController.clear();
    //     });
    //   }

    print('tero bau ko imgUrl ${widget.imgUrl}');

    Map<String, dynamic> _chatMessageMap = {
      "sender": widget.userName,
      "time": DateTime.now().millisecondsSinceEpoch,
      "isImage": true,
      // "type": "text",
      "imgUrl": widget.imgUrl,
      "message": 'imgaUrl is ${widget.imgUrl}',
    };
    // print(chatMessageMap);
    // _scrollController.animateTo(_scrollController.position.maxScrollExtent,
    // duration: Duration(milliseconds: 300), curve: Curves.easeOut);

    // _scrollController.jumpTo(chatNo!);

    DatabaseService().sendMessage(widget.groupId!, _chatMessageMap, 'img');
  }
}
