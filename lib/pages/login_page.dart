import 'package:SavantGen/pages/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:SavantGen/components/my_button.dart';
import 'package:SavantGen/components/my_textfield.dart';
import 'package:SavantGen/components/square_tile.dart';
import 'package:SavantGen/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserGuidancePage extends StatefulWidget {
  @override
  _UserGuidancePageState createState() => _UserGuidancePageState();
}

class _UserGuidancePageState extends State<UserGuidancePage> {
  bool _userAgreed = false;
  final ScrollController _scrollController = ScrollController();

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('\u2022', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('User Guidance')),
      ),
      body: Container(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to SavantGen!\n\n'
                  'SavantGen is your personal AI companion, ready to engage in creative conversation, '
                  'answer your questions, and offer thoughtful insights.\n\n'
                  'Getting Started:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                bulletPoint('Register Yourself by using google account.'),
                bulletPoint(
                    'This is just a free Trail Version where you will get free 10 queries to ask.'),
                bulletPoint(
                    'You can request the admin to increase you free trails. Note this process can take times so just bear with us...'),
                SizedBox(height: 10),
                Text(
                  'What SavantGen Can Do:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                bulletPoint(
                    'Ask anything: SavantGen has a vast knowledge base and can answer your questions on diverse topics.'),
                bulletPoint(
                    'Creative prompts: Spark your imagination with writing prompts, brainstorm ideas, or explore new perspectives.'),
                bulletPoint(
                    'Engage in conversation: Chat with SavantGen about your day, share your thoughts and feelings, or simply enjoy engaging discourse.'),
                bulletPoint(
                    'Get advice: Seek guidance on personal dilemmas, creative projects, or any situation needing a fresh perspective.'),
                SizedBox(height: 10),
                Text(
                  'Remember:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                bulletPoint(
                    'Respect: Treat SavantGen and other users with courtesy and kindness.'),
                bulletPoint(
                    'Keep it clean: Avoid hateful, discriminatory, or offensive language.'),
                bulletPoint(
                    'No spamming: Focus on meaningful conversations, not repetitive or irrelevant messages.'),
                bulletPoint(
                    'Report: If you encounter any inappropriate behavior, please report it immediately.'),
                SizedBox(height: 10),
                Text(
                  'Stay Connected:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                bulletPoint(
                    'Feedback: We value your thoughts! Share your feedback and suggestions through the in-app feedback button.'),
                bulletPoint(
                    'Support: Need help or have questions? Contact us at [saurabhgk7@gmail.com].'),
                SizedBox(height: 10),
                Text(
                  'Terms and Conditions:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                bulletPoint('By using SavantGen, you agree to the following:'),
                bulletPoint(
                    'You must be at least 13 years old to use this app.'),
                bulletPoint(
                    'You are responsible for your actions and interactions within SavantGen.'),
                bulletPoint(
                    'You will not violate any laws or regulations while using the app.'),
                bulletPoint(
                    'You will not share or transmit any content that violates our guidelines (see "Remember" section).'),
                bulletPoint(
                    'You will not attempt to hack into or disrupt the operation of the app.'),
                bulletPoint(
                    'We reserve the right to moderate content and terminate accounts for violations of these terms.'),
                SizedBox(height: 10),
                Text(
                  'Remember, SavantGen is here to enhance your interactions and spark your creativity. '
                  'Let\'s make our conversations informative, respectful, and fun!',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),

                // Checkbox for user agreement
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _userAgreed,
                        onChanged: (value) {
                          setState(() {
                            _userAgreed = value ?? false;
                            if (_userAgreed) {
                              scrollToLast();
                            }
                          });
                        },
                      ),
                      Text('I agree to the T&C'),
                      Spacer(),
                      if (_userAgreed)
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.deepPurpleAccent.shade400)),
                          onPressed: () {
                            // Save the flag to SharedPreferences
                            _saveUserGuidanceFlag();

                            // Navigate to the login page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          },
                          child: Text(
                            'Next',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void scrollToLast() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Function to save the user guidance flag to SharedPreferences
  Future<void> _saveUserGuidanceFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('userGuidanceShown', true);
  }
}

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

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
      // print(e.toString());
      return null;
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user is already signed in
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // If the user is signed in, navigate directly to MyHomePage
      return MyHomePage();
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text('Login to SavantGen')),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.lock,
                size: 100,
              ),

              // const SizedBox(height: 50),

              // welcome back, you've been missed!
              // Text(
              //   'Welcome back you\'ve been missed!',
              //   style: TextStyle(
              //     color: Colors.grey[700],
              //     fontSize: 16,
              //   ),
              // ),

              const SizedBox(height: 25),

              // username textfield
              MyTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // sign in button
              MyButton(
                onTap: signUserIn,
              ),

              const SizedBox(height: 50),

              // or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // google sign in buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // google button
                  SquareTile(
                      imagePath: 'assets/images/google.png',
                      onTap: () async {
                        UserCredential? userCredential =
                            await _signInWithGoogle();
                        if (userCredential != null) {
                          // User is signed in, proceed to check the counter value
                          String? uid = userCredential.user!.email;
                          String? uname = userCredential.user!.displayName;
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .get()
                              .then(
                            (DocumentSnapshot documentSnapshot) {
                              if (documentSnapshot.exists) {
                                // User data exists, retrieve and check counter value
                                int counterValue = documentSnapshot['counter'];
                                String role = documentSnapshot['role'];

                                if (counterValue <= 10 && counterValue != 0) {
                                  // Check the user's role
                                  if (role == 'admin') {
                                    // Navigate to the admin page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AdminPage()),
                                    );
                                  } else {
                                    // Allow user to use the app
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyHomePage()),
                                    );
                                  }
                                } else {
                                  // Show message that the trial is over
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Trial Limit Exceeded'),
                                        content: Text(
                                          'Thank you for trying the app. To continue using, please purchase the full version.',
                                        ),
                                        actions: [
                                          TextButton(
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
                              } else {
                                // User data doesn't exist, initialize counter value and store it
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .set(
                                  {
                                    'counter': 10,
                                    'role': 'user',
                                    'name': uname,
                                    'message': '',
                                    'messageSeen': false,
                                  },
                                );
                                // Allow user to use the app
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyHomePage()),
                                );
                              }
                            },
                          );
                        }
                      }),

                  // SizedBox(width: 25),

                  // apple button
                  // SquareTile(
                  //     imagePath: 'assets/images/apple.png',
                  //     onTap: () async {
                  //       UserCredential? userCredential =
                  //           await _signInWithGoogle();
                  //       if (userCredential != null) {
                  //         // User is signed in, proceed to check the counter value
                  //         String? uid = userCredential.user!.email;
                  //         String? uname = userCredential.user!.displayName;
                  //         FirebaseFirestore.instance
                  //             .collection('users')
                  //             .doc(uid)
                  //             .get()
                  //             .then(
                  //           (DocumentSnapshot documentSnapshot) {
                  //             if (documentSnapshot.exists) {
                  //               // User data exists, retrieve and check counter value
                  //               int counterValue = documentSnapshot['counter'];
                  //               String role = documentSnapshot['role'];

                  //               if (counterValue <= 10 && counterValue != 0) {
                  //                 // Check the user's role
                  //                 if (role == 'admin') {
                  //                   // Navigate to the admin page
                  //                   Navigator.push(
                  //                     context,
                  //                     MaterialPageRoute(
                  //                         builder: (context) => AdminPage()),
                  //                   );
                  //                 } else {
                  //                   // Allow user to use the app
                  //                   Navigator.push(
                  //                     context,
                  //                     MaterialPageRoute(
                  //                         builder: (context) => MyHomePage()),
                  //                   );
                  //                 }
                  //               } else {
                  //                 // Show message that the trial is over
                  //                 showDialog(
                  //                   context: context,
                  //                   builder: (BuildContext context) {
                  //                     return AlertDialog(
                  //                       title: Text('Trial Limit Exceeded'),
                  //                       content: Text(
                  //                         'Thank you for trying the app. To continue using, please purchase the full version.',
                  //                       ),
                  //                       actions: [
                  //                         TextButton(
                  //                           onPressed: () {
                  //                             Navigator.of(context).pop();
                  //                           },
                  //                           child: Text('OK'),
                  //                         ),
                  //                       ],
                  //                     );
                  //                   },
                  //                 );
                  //               }
                  //             } else {
                  //               // User data doesn't exist, initialize counter value and store it
                  //               FirebaseFirestore.instance
                  //                   .collection('users')
                  //                   .doc(uid)
                  //                   .set(
                  //                 {
                  //                   'counter': 10,
                  //                   'role': 'user',
                  //                   'name': uname,
                  // 'message': '',
                  // 'messageSeen': false,
                  //                 },
                  //               );
                  //               // Allow user to use the app
                  //               Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                     builder: (context) => const MyHomePage()),
                  //               );
                  //             }
                  //           },
                  //         );
                  //       }
                  //     }),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Sign out the current user
                  await _signOut();

                  // Show a message or navigate to a different screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.black,
                      shape: CircleBorder(),
                      content: Center(
                        child: Icon(Icons.done,
                            color: Colors.purpleAccent, fill: 1.0),
                      ),
                    ),
                  );
                  UserCredential? userCredential = await _signInWithGoogle();
                  if (userCredential != null) {
                    // User is signed in, proceed to check the counter value
                    String? uid = userCredential.user!.email;
                    String? uname = userCredential.user!.displayName;
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get()
                        .then(
                      (DocumentSnapshot documentSnapshot) {
                        if (documentSnapshot.exists) {
                          // User data exists, retrieve and check counter value
                          int counterValue = documentSnapshot['counter'];
                          String role = documentSnapshot['role'];

                          if (counterValue <= 10 && counterValue != 0) {
                            // Check the user's role
                            if (role == 'admin') {
                              // Navigate to the admin page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminPage()),
                              );
                            } else {
                              // Allow user to use the app
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyHomePage()),
                              );
                            }
                          } else {
                            // Show message that the trial is over
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Trial Limit Exceeded'),
                                  content: Text(
                                    'Thank you for trying the app. To continue using, please purchase the full version.',
                                  ),
                                  actions: [
                                    TextButton(
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
                        } else {
                          // User data doesn't exist, initialize counter value and store it
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .set(
                            {
                              'counter': 10,
                              'role': 'user',
                              'name': uname,
                              'message': '',
                              'messageSeen': false,
                            },
                          );
                          // Allow user to use the app
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHomePage()),
                          );
                        }
                      },
                    );
                  }
                },
                child: Text('Sign in with a different Google account'),
              ),

              const SizedBox(height: 50),

              // not a member? register now
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       'Not a member?',
              //       style: TextStyle(color: Colors.grey[700]),
              //     ),
              //     const SizedBox(width: 4),
              //     const Text(
              //       'Register now',
              //       style: TextStyle(
              //         color: Colors.blue,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void signUserIn(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign In with Google'),
          content: Text(
              'Please sign in using your Google account or Apple account.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Center(child: Text('OK')),
            ),
          ],
        );
      },
    );
  }
}
