import 'package:SavantGen/pages/admin_to_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final counterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Admin Dashboard'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the total number of users
            Row(
              children: [
                Card(
                  margin: EdgeInsets.all(16.0),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Users',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return RefreshProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              int totalUsers = snapshot.data!.docs.length;
                              return Text(
                                '$totalUsers',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyHomeAdminPage()),
                    );
                  },
                  icon: Icon(Icons.computer_rounded, color: Colors.black),
                  label: const Text(
                    'AI Page',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            // Display user details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'User Details',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('users').get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LinearProgressIndicator(
                      color: Colors.amber,
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var userData = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        String uid = snapshot.data!.docs[index].id;
                        int counter = userData['counter'] ?? 0;
                        String userName = userData['name'] ?? 'None';
                        String message = userData['message'] ?? '';
                        String role = userData['role'] ?? '';

                        bool hasUnreadMessage = false;
                        bool messageSeen = userData['messageSeen'] ?? true;

                        if (message.isNotEmpty && !messageSeen) {
                          hasUnreadMessage = true;
                        }

                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          elevation: 4.0,
                          child: ListTile(
                            title: Text('User Name: $userName'),
                            subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Role: ${userData['role']}'),
                                    Text('Counter: $counter'),
                                  ],
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.message,
                                      color: hasUnreadMessage
                                          ? Colors.red
                                          : null), // Show red dot if there is a new or updated message
                                  onPressed: () {
                                    _showMessageDialog(userName, message, uid);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditCounterDialog(uid, counter);
                                  },
                                ),
                                // Add other user data fields as needed
                              ],
                            ),
                            onLongPress: () {
                              _showDeleteDialog(uid, role);
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String uid, String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: role == 'admin'
              ? Text('Warning: Cannot delete an admin account.')
              : Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            if (role != 'admin')
              TextButton(
                onPressed: () {
                  _deleteUser(uid);
                  Navigator.of(context).pop();
                },
                child: Text('Delete'),
              ),
          ],
        );
      },
    );
  }

  void _deleteUser(String uid) {
    FirebaseFirestore.instance.collection('users').doc(uid).delete().then((_) {
      // Trigger a rebuild of the ListView.builder after deleting the user
      setState(() {});
    });
  }

  void _showMessageDialog(String userName, String message, String uid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message from $userName'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                // Mark the message as seen when the dialog is closed
                FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'messageSeen': true,
                }).then((_) {
                  // Trigger a rebuild of the ListView.builder after updating the messageSeen flag
                  setState(() {});
                });

                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCounterDialog(String uid, int currentCounter) {
    counterController.text = currentCounter.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('UID: $uid'),
          content: Column(
            children: [
              TextField(
                controller: counterController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'New Counter Value'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateCounter(uid);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateCounter(String uid) {
    int newCounter = int.tryParse(counterController.text) ?? 0;
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'counter': newCounter,
      'messageSeen': true,
    }).then((_) {
      // Trigger a rebuild of the ListView.builder after updating the counter
      setState(() {});
    });
  }

  @override
  void dispose() {
    counterController.dispose();
    super.dispose();
  }
}
