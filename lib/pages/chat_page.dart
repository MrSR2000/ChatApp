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
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: [
          chatMessages(),
          SizedBox(height: 50),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              height: 78,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      fillColor: Color.fromARGB(255, 58, 58, 58),
                      filled: true,
                      hintText: "Send a message.....",
                      hintStyle: TextStyle(color: Colors.white),
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
                          color: Colors.black,
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
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.green,
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
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: ((context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  print('itemCound: ${snapshot.data.docs.length}');
                  return MessageTile(
                    message: snapshot.data.docs[index]['message'],
                    sender: snapshot.data.docs[index]['sender'],
                    sentByMe:
                        widget.userName == snapshot.data.docs[index]['sender'],
                  );
                },
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

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
