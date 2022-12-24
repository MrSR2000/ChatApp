import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/groupInfo_page.dart';
import 'package:flutter_chat_app/service/database_service.dart';
import 'package:flutter_chat_app/widgets/message_tile.dart';
import 'package:flutter_chat_app/widgets/widgets.dart';

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
            color: Color.fromARGB(255, 79, 139, 128),
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                height: 78,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).primaryColor,
                child: Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
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

  chatMessages() {
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
                        height: 70,
                      );
                    }
                    // print('itemCound: ${snapshot.data.docs.length}');
                    return MessageTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender'],
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
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      // print(chatMessageMap);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);

      // _scrollController.jumpTo(chatNo!);

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
