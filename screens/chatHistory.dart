import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'chatHistory_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import 'store.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    Future<List<ChatModel>> load_chathistory(int index) async{
      List<ChatModel> chatList = [];

      final snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userProvider.myProfile.email)
          .collection('chatHistory')
          .doc(userProvider.chatHistoryList[index].dateTime.toString())
          .collection('chat').get();

      for (final doc in snapshot.docs) {
        print(doc.id);
        chatList.add(ChatModel(
          role: doc.get('role'),
          msg: doc.get('msg'),
          chatIndex:  doc.get('chatIndex'),
        ));
      }

      return chatList;
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Chat room',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () async{
                  await userProvider.loadDeployed();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StorePage()),
                  );
                },
                icon: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.green,
                )
            )
          ],
        ),
        body: Container(
            child: Column(children: [
          SizedBox(height: 30),
          Container(
            height: MediaQuery.of(context).size.height - 180,
            // width: MediaQuery.of(context).size.width - 20,
            child: ListView.builder(
              itemCount: userProvider.chatHistoryList.length,
              itemBuilder: (BuildContext context, int index) => Card(
                child: ListTile(
                  onTap: () async{
                    List<ChatModel> chatList = [];
                    chatList = await load_chathistory(index);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatHisoryScreen(
                          chatList: chatList,
                          title: userProvider.chatHistoryList[index].title),
                      ),
                    );
                  }, title: Container(
                      child: Column(
                        children: [
                          Text(userProvider.chatHistoryList[index].title),
                          Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMicrosecondsSinceEpoch(userProvider.chatHistoryList[index].dateTime)).toString()
                              // userProvider.chatHistoryList[index].dateTime.toString()
                          ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                      child: Text("Delete"),
                              value: "delete",
                            ),
                          ],
                      onSelected: (value) {
                        if (value == "delete") {
                          // 삭제 기능 실행
                          userProvider.deleteChatHistory(
                              userProvider.chatHistoryList[index].dateTime.toString());
                          userProvider.loadChatHistory();
                          const snackBar = SnackBar(
                            content: Text('삭제 완료!'),
                            duration: Duration(seconds: 2),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }),
                ),
              ),
            ),
          )
        ])));
  }
}
