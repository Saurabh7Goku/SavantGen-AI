import 'package:SavantGen/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatHistoryPage extends StatefulWidget {
  final String uid;

  ChatHistoryPage({Key? key, required this.uid}) : super(key: key);

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade700,
        title: Text(
          'Chat History',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade800,
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .collection('chat_history')
              .doc(selectedDate.toLocal().toString().split(' ')[0])
              .collection('messages')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              var formattedSelectedDate =
                  DateFormat('yyyy-MM-dd').format(selectedDate.toLocal());
              return Center(
                child: Text(
                  "No history at : $formattedSelectedDate",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              );
            }

            var messages = snapshot.data!.docs;

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];
                var userText = message['userText'];
                var response = message['response'];
                var timestamp =
                    message['timestamp']?.toDate() ?? DateTime.now();
                var messageDate = timestamp.toLocal().toString().split(' ')[0];

                if (index > 0 &&
                    messageDate ==
                        (messages[index - 1]['timestamp']?.toDate() ??
                                DateTime.now())
                            .toLocal()
                            .toString()
                            .split(' ')[0]) {
                  return ListTile();
                } else {
                  var groupedMessages = messages
                      .where((msg) =>
                          (msg['timestamp']?.toDate() ?? DateTime.now())
                              .toLocal()
                              .toString()
                              .split(' ')[0] ==
                          messageDate)
                      .toList();

                  groupedMessages.sort((a, b) => (b['timestamp']?.toDate() ??
                          DateTime.now())
                      .compareTo(a['timestamp']?.toDate() ?? DateTime.now()));

                  return Card(
                    color: Colors.white,
                    child: ExpansionTile(
                      title: ListTile(
                        title: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 20),
                              Text(
                                'Date: $messageDate',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      shape: const ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(23)),
                        side: BorderSide(width: 2, color: Colors.black),
                      ),
                      children: groupedMessages.map((groupedMessage) {
                        var groupedTimestamp =
                            groupedMessage['timestamp']?.toDate() ??
                                DateTime.now();
                        var formattedTime =
                            DateFormat.Hms().format(groupedTimestamp.toLocal());
                        return Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time: ${formattedTime}'),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'User: ${groupedMessage['userText']}',
                                style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Bot: ${groupedMessage['response']}',
                                style: TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontWeight: FontWeight.bold),
                              ),
                              Divider(
                                color: Colors.grey,
                                thickness: 1.0,
                                height: 20,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );

          if (pickedDate != null && pickedDate != selectedDate) {
            setState(() {
              selectedDate = pickedDate;
            });
          }
        },
        child: Icon(Icons.calendar_today_rounded),
        backgroundColor: Colors.white,
      ),
    );
  }
}
