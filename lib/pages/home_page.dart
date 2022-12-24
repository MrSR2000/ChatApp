import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/helper/helper_function.dart';
import 'package:flutter_chat_app/pages/auth/login_page.dart';
import 'package:flutter_chat_app/pages/profile_page.dart';
import 'package:flutter_chat_app/pages/search_page.dart';
import 'package:flutter_chat_app/service/auth_service.dart';
import 'package:flutter_chat_app/service/database_service.dart';
import 'package:flutter_chat_app/widgets/widgets.dart';

import '../widgets/group_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  String getId(String res) {
    // print('resko value $res');
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmail().then((value) {
      setState(() {
        email = value!;
      });
    });

    await HelperFunctions.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });

    //getting list of snapshot
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((value) {
      setState(() {
        groups = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chithi',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(context, SearchPage());
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            const Icon(
              Icons.account_circle,
              size: 90,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 2),
                ListTile(
                  onTap: () {},
                  selectedColor: Theme.of(context).primaryColor,
                  selected: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(Icons.group),
                  title: const Text(
                    "Groups",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  onTap: () {
                    nextScreen(
                        context, ProfilePage(userName: userName, email: email));
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(Icons.person),
                  title: const Text(
                    "Profile",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  onTap: () async {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Logout"),
                            content: Text("Are you sure you want to logout?"),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  // nextScreenReplace(context, LoginPage());
                                  authService.signOut().whenComplete(() {
                                    // nextScreen(context, const LoginPage());
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                      (route) => false,
                                    );
                                  });
                                },
                                icon: const Icon(
                                  Icons.done_rounded,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      body: groupList(),
      // body: Text('hello'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Enter Group Name',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          groupName = value;
                        });
                      },
                    )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'CANCEL',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (groupName != "") {
                  setState(
                    () {
                      _isLoading = true;
                    },
                  );
                  DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                      .createGroup(
                    userName,
                    FirebaseAuth.instance.currentUser!.uid,
                    groupName,
                  )
                      .whenComplete(() {
                    _isLoading = false;
                  });
                  Navigator.of(context).pop();
                  showSnackBar(
                      context, Colors.green, "Group Created Succesfully");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // print("this is snapshot ${snapshot.data['groups']}");
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  //get latest created group at top
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                      groupId: getId(snapshot.data['groups'][reverseIndex]),
                      groupName: getName(snapshot.data['groups'][reverseIndex]),
                      userName: snapshot.data['fullName']);
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                popUpDialog(context);
              },
              child: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'You have not joined any group tap the + icon to join the group',
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
