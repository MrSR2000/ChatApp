import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/service/database_service.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final DateTime sentTime;
  final String type;
  final String groupId;
  final bool isImg;

  MessageTile({
    Key? key,
    required this.message,
    required this.sender,
    required this.sentByMe,
    required this.sentTime,
    required this.type,
    required this.groupId,
    required this.isImg,
  }) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  String? imgUrl;

  @override
  void initState() {
    // TODO: implement initState
    // getImgUrl();
    // dislayText();
    super.initState();
  }

  // getImgUrl() async {
  //   // DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
  //   //     .getImageUrl(widget.groupId)
  //   //     .then((value) {});

  //   DocumentReference documentReference =
  //       FirebaseFirestore.instance.collection('groups').doc(widget.groupId).then(());
  //   print('The document ref $documentReference');
  //   DocumentSnapshot documentSnapshot = await documentReference.get();
  //   print('The document snapshot is $documentSnapshot');

  //   // List<dynamic> imgUrl = await documentSnapshot['imgUrl'];

  //   print(imgUrl);
  // }

  dislayText() async {
    // await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
    //     .isImg(widget.groupId)
    //     .then((value) {
    //   setState(() {
    //     print('the value is $value');
    //     isImg = value;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    print(widget.type);

    return widget.type == "text"
        ? Container(
            padding: EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: widget.sentByMe ? 0 : 24,
                right: widget.sentByMe ? 24 : 0),
            alignment:
                widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
                margin: widget.sentByMe
                    ? const EdgeInsets.only(left: 30)
                    : const EdgeInsets.only(right: 30),
                padding: const EdgeInsets.only(
                    top: 17, bottom: 17, left: 20, right: 20),
                decoration: BoxDecoration(
                    borderRadius: widget.sentByMe
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                    color: widget.sentByMe
                        ? Color.fromARGB(255, 79, 139, 128)
                        : Color.fromARGB(255, 3, 41, 32)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sender.toUpperCase(),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.message,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    // : Container(
                    //     height: MediaQuery.of(context).size.height / 2.5,
                    //     width: MediaQuery.of(context).size.width / 2,
                    //     child: Image.network(imgUrl ?? ""),
                    //   ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      ("${widget.sentTime.year.toString()}/${widget.sentTime.month.toString()}/${widget.sentTime.day.toString()}")
                          .toString(),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ("${widget.sentTime.hour.toString()}:${widget.sentTime.minute.toString()}")
                          .toString(),
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                )),
          )
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment:
                widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: widget.message,
                  ),
                ),
              ),
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration(border: Border.all()),
                alignment: widget.message != "" ? null : Alignment.center,
                child: widget.message != ""
                    ? Image.network(
                        widget.message,
                        fit: BoxFit.cover,
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
