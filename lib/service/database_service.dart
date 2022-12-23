import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  //reference for collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  //saving the userdata
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  //getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  //creating Group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference documentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    await documentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": documentReference.id,
    });

    DocumentReference userDocumentreference = userCollection.doc(uid);
    return await userDocumentreference.update({
      "groups": FieldValue.arrayUnion(["${documentReference.id}_$groupName"])
    });
  }

  //gettng the chats
  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupid) async {
    DocumentReference d = groupCollection.doc(groupid);
    print('document location of groupid is $d');
    DocumentSnapshot documentSnapshot = await d.get();
    print('document snpashot is $documentSnapshot');
    return documentSnapshot['admin'];
  }

  //get group members
  Future getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //search
  Future searchByName(String groupName) async {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  //joind group or not
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];

    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  //toggling group join or exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    //if user in group then remove else join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  //send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    print('added to messages');
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
