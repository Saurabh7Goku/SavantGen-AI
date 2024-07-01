// ignore_for_file: prefer_const_constructors

import 'package:SavantGen/pages/admin_chat_history.dart';
import 'package:SavantGen/pages/chat_history.dart';
import 'package:SavantGen/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class SideBar extends StatefulWidget {
  final int remainingCount;

  SideBar({Key? key, required this.remainingCount}) : super(key: key);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String _pressedButton = ''; // Track the pressed button

  void _onButtonPressed(String buttonName) {
    setState(() {
      _pressedButton = buttonName;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        maxRadius: 25,
                        backgroundColor: Colors.deepPurpleAccent,
                        child: Image.asset('assets/images/chatbot2.png'),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'SavantGen-AI',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.deepPurpleAccent,
                    endIndent: 20,
                    indent: 20,
                    thickness: 2,
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.deepPurpleAccent),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Trail Remaining: ',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        widget.remainingCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildButton('Chat History', () async {
                _onButtonPressed('Chat History');
                UserCredential? userCredential = await _signInWithGoogle();
                User? user = _auth.currentUser;
                String? uid = userCredential?.user!.email;

                if (user != null) {
                  uid = uid;
                } else {
                  return;
                }
                _navigateToChatHistoryPage(context, uid!);
              },
                  Icon(
                    Icons.chat,
                    color: Colors.indigoAccent,
                    size: 38,
                  )),
              _buildButton(
                'Request Trail',
                () {
                  _showRequestDialog(context);
                },
                Icon(
                  Icons.request_quote_outlined,
                  color: Colors.redAccent,
                  size: 38,
                ),
              ),
              _buildButton(
                'Portfolio',
                () {
                  launch(
                      'https://portfolio-saurabh-singh-18.vercel.app/#portfolio');
                },
                Icon(
                  Icons.contact_mail,
                  color: Colors.blueAccent,
                  size: 38,
                ),
              ),
              _buildButton('LogOut', () {
                _showLogoutConfirmationDialog(context);
              },
                  Icon(
                    Icons.logout_outlined,
                    color: Colors.green,
                    size: 38,
                  )),
            ],
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.31,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  top: 30,
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurpleAccent,
                    radius: 50,
                    child: Image.asset(
                      'assets/images/pro.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.21,
                  margin: EdgeInsets.only(left: 15, right: 15),
                  padding: EdgeInsets.only(top: 50, bottom: 5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Upgrade to Pro',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('Get 1 month FREE and'),
                      Text('unlock all Pro Features'),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.deepPurpleAccent)),
                        onPressed: () {
                          _showUpgradeDialog(context);
                        },
                        child: Text(
                          'Upgrade Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(_auth.currentUser?.photoURL ??
                        'assets/images/chatbot2.png'),
                  ),
                  Column(
                    children: [
                      Text(
                        _auth.currentUser?.displayName ?? '',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        _auth.currentUser?.email ?? '',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Icon icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        color: _pressedButton == text
            ? Colors.deepPurpleAccent.withOpacity(0.4)
            : null,
      ),
      width: double.infinity,
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 15),
      margin: EdgeInsets.only(left: 10, right: 10),
      child: TextButton.icon(
        icon: icon,
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          alignment: Alignment.centerLeft,
          shape: MaterialStateProperty.all(
            ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
        ),
        onPressed: () {
          _onButtonPressed(text);
          onPressed();
        },
      ),
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                confirmed = true;
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      _signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _navigateToChatHistoryPage(BuildContext context, String uid) async {
    String? userRole = await _getUserRole(uid);

    if (userRole != null) {
      if (userRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AdminChatHistoryPage(uid: uid)),
        );
      } else if (userRole == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatHistoryPage(uid: uid)),
        );
      } else {
        print('Unknown user role');
      }
    } else {
      print('Failed to retrieve user role');
    }
  }

  Future<String?> _getUserRole(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      if (userDoc.data() != null && userDoc.data()!['role'] != null) {
        return userDoc.data()!['role'];
      }
    }

    return null;
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  Future<void> _showUpgradeDialog(BuildContext context) async {
    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Coming Soon'),
          content: Text('This feature is coming soon! Stay tuned.'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRequestDialog(BuildContext context) async {
    String? message = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Message'),
          content: TextField(
            onChanged: (value) {
              message = value;
            },
            decoration: InputDecoration(hintText: 'Enter your message'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                UserCredential? userCredential = await _signInWithGoogle();

                if (userCredential != null) {
                  String? uid = userCredential.user!.email;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                    'message': message,
                    'messageSeen': false,
                  });

                  Navigator.of(context).pop();
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }
}
