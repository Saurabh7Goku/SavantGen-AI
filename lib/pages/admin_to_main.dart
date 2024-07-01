import 'package:SavantGen/api/gemini_api.dart';
import 'package:SavantGen/components/my_button.dart';
import 'package:SavantGen/components/my_textfield.dart';
import 'package:SavantGen/components/square_tile.dart';
import 'package:SavantGen/pages/admin_page.dart';
import 'package:SavantGen/pages/login_page.dart';
import 'package:SavantGen/pages/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_switch/sliding_switch.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyHomeAdminPage());
}

Future<bool> _getUserGuidanceFlag() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('userGuidanceShown') ?? false;
}

class MyHomeAdminPage extends StatefulWidget {
  const MyHomeAdminPage({
    super.key,
  });

  @override
  State<MyHomeAdminPage> createState() => _MyHomeAdminPageState();
}

class _MyHomeAdminPageState extends State<MyHomeAdminPage> {
  final textController = TextEditingController();
  final focusNode = FocusNode();
  bool isSidebarOpen = true;
  List<String> responses = [];
  bool showImage = true;
  bool bePrecise = true;
  bool isLoading = false;
  int textFieldUsageCount = 0;
  bool isTrialOver = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _updateRemainingCount();
  }

  Future<void> _updateRemainingCount() async {
    UserCredential? userCredential = await _signInWithGoogle();
    if (userCredential != null) {
      String? uid = userCredential.user!.email;

      // Retrieve the counter value from Firestore
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      int lastCounterValue = documentSnapshot['counter'];

      setState(() {
        textFieldUsageCount = 0; // Reset the textFieldUsageCount
        isTrialOver = lastCounterValue <= 0; // Check if trial is over
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  setState(() {
                    _scaffoldKey.currentState!.openDrawer();
                  });
                },
              ),
              const Text(
                'At your Service',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Image.asset(
                'assets/images/chatbot2.png',
                height: 70,
                width: 70,
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple.shade800,
          elevation: 10,
        ),
        body: GestureDetector(
          onTap: () {
            setState(() {
              isSidebarOpen = false;
            });
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.deepPurple.shade800,
                  Colors.deepPurple.shade700,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                if (showImage)
                  Positioned.fill(
                    bottom: MediaQuery.of(context).size.height * 0.3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/chatbot2.png',
                            height: 150,
                            width: 200,
                            fit: BoxFit.contain,
                          ),
                          Column(
                            children: [
                              const Text(
                                "Welcome to SavantGen",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.black38),
                                child: Center(
                                  child: TyperAnimatedTextKit(
                                    speed: const Duration(milliseconds: 100),
                                    isRepeatingAnimation: false,
                                    text: [
                                      'SavantGen can make mistakes. Consider checking important information.'
                                    ],
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned.fill(
                  top: showImage ? 110 : 10,
                  bottom: MediaQuery.of(context).size.height * 0.3,
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: responses.asMap().entries.map((entry) {
                        int index = entry.key;
                        String response = entry.value;
                        String userText =
                            index % 2 == 0 ? responses[index + 1] : '';

                        return _buildResponseBubble(response, userText);
                      }).toList(),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: showImage ? -30 : 0,
                  child: isTrialOver
                      ? _buildTrialOverMessage()
                      : Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              SlidingSwitch(
                                width: 270,
                                value: bePrecise,
                                onChanged: (value) {
                                  setState(() {
                                    bePrecise = value;
                                  });
                                },
                                height: 40,
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                onDoubleTap: () {},
                                onSwipe: () {},
                                onTap: () {},
                                textOff: "Be Creative",
                                textOn: "Be Precise",
                                colorOn: Colors.green,
                                colorOff: Colors.red,
                                background: Colors.grey,
                                buttonColor: Colors.white,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextField(
                                keyboardType: TextInputType.text,
                                controller: textController,
                                focusNode: focusNode,
                                onEditingComplete: () {
                                  _handleSendButtonPress();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Ask me anything',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[300],
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      _handleSendButtonPress();
                                      textController.clear();
                                      focusNode.unfocus();
                                    },
                                    icon: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.black),
                                            ),
                                          )
                                        : Icon(Icons.send, color: Colors.black),
                                    label: const Text(
                                      'Send',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AdminPage()),
                                      );
                                    },
                                    icon: Icon(Icons.dashboard,
                                        color: Colors.black),
                                    label: const Text(
                                      'Dashboard',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
                // SideBar(remainingCount: 10 - textFieldUsageCount),
                if (!showImage)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/chatbot2.png',
                            height: 60,
                            width: 60,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        drawer: isSidebarOpen
            ? Drawer(
                child: FutureBuilder<DocumentSnapshot>(
                  future: _getCounterFromFirebase(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      int remainingCount = snapshot.data!['counter'];
                      return SideBar(remainingCount: remainingCount);
                    } else {
                      //  handle the loading of the remaining count when opening the sidebar...
                      return Drawer(
                        child: SideBar(remainingCount: 0),
                      );
                    }
                  },
                ),
              )
            : null,
      ),
    );
  }

  Future<DocumentSnapshot> _getCounterFromFirebase() async {
    UserCredential? userCredential = await _signInWithGoogle();

    String? uid = userCredential?.user?.email;

    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Widget _buildResponseBubble(String response, String userText) {
    return GestureDetector(
      onLongPress: () {
        _showCopyContextMenu(response);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 5, right: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: Image.asset(
                'assets/images/chatbot2.png',
                height: 40,
                width: 30,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCopyContextMenu(String text) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    LongPressDraggable(
      data: text,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            text,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      childWhenDragging: Container(),
      onDragEnd: (details) {
        Clipboard.setData(ClipboardData(text: text));
      },
      child: PopupMenuButton(
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: text));
                Navigator.pop(context);
              },
              child: const Text("Copy"),
            ),
          ),
        ],
        offset: Offset(position.dx, position.dy),
      ),
    );
  }

  Widget _buildTrialOverMessage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Trial Limit Exceeded',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            'Thank you for trying the app. To continue using, please purchase the full version.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

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
    } catch (error) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Error signing in with Google: $error"),
      //     duration: Duration(seconds: 5),
      //   ),
      // );
      return null;
    }
  }

  Future<void> _saveChatHistory(
      String? uid, String date, String userText, String response) async {
    // DateTime now = DateTime.now();
    // String date = now.toLocal().toString().split(' ')[0];
    String time =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_history')
        .doc(date)
        .collection('messages')
        .doc(time)
        .set({
      'userText': userText,
      'response': response,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _handleSendButtonPress() async {
    String userText = textController.text.trim();

    if (userText.isNotEmpty) {
      setState(() {
        isLoading = true; // Show loading indicator
      });

      String response = await GeminiAPI.getGeminiData(
        context,
        userText,
      );

      setState(() {
        responses.add(userText);
        responses.add(response);
        showImage = false;
        isLoading = false;
      });

      // Save the chat history
      UserCredential? userCredential = await _signInWithGoogle();
      if (userCredential != null) {
        String? uid = userCredential.user!.email;
        String date = DateTime.now()
            .toLocal()
            .toString()
            .split(' ')[0]; // Get current date

        await _saveChatHistory(uid, date, userText, response);
      }

      textController.clear();
      focusNode.unfocus();

      if (!isTrialOver) {
        // Update counter in Firebase based on the number of messages sent
        UserCredential? userCredential = await _signInWithGoogle();
        if (userCredential != null) {
          String? uid = userCredential.user!.email;

          // Increment textFieldUsageCount by 1 for each message
          textFieldUsageCount = 1;

          // Retrieve the last counter value from Firestore
          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          int lastCounterValue = documentSnapshot['counter'];

          int newCounterValue = lastCounterValue - textFieldUsageCount;

          // Update the counter in Firestore
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({'counter': newCounterValue});

          if (textFieldUsageCount >= 10) {
            setState(() {
              isTrialOver = true;
            });
          }
          _updateRemainingCount();
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade800,
          content: const Center(
            child: Text(
              'Ask Your Question First.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // Future<DocumentSnapshot> _getCounterFromFirebase() async {
  //   UserCredential? userCredential = await _signInWithGoogle();
  //   if (userCredential != null) {
  //     String? uid = userCredential.user!.email;

  //     return FirebaseFirestore.instance.collection('users').doc(uid).get();
  //   }

  //   // Return a dummy snapshot in case of an error
  //   return FirebaseFirestore.instance.collection('users').doc('dummy').get();
  // }
}
