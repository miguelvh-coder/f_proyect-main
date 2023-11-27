import 'package:f_firebase_202210/data/model/app_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../data/model/message.dart';
import '../controllers/authentication_controller.dart';
import '../controllers/chats_controller.dart';

class ChatSPage extends StatelessWidget {
  const ChatSPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
      ),
      body: ChatSBody(),
    );
  }
}

class ChatSBody extends StatefulWidget {
  const ChatSBody({Key? key}) : super(key: key);

  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatSBody> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  late AppUser person;

  // obtenemos los parámetros del sistema de navegación
  dynamic argumentData = Get.arguments;
  
  
  ChatSController chatController = Get.find();
  AuthenticationController authenticationController = Get.find();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
    person = argumentData[0];
    chatController.subscribeToUpdated(person.uid);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    chatController.unsubscribe();
    super.dispose();
  }

  Widget _item(Message element, int posicion, String uid) {
    logInfo('hola');
    logInfo('Current user? -> ${uid == element.user} msg -> ${element.text}');
    return Card(
      margin: const EdgeInsets.all(4.0),
      color: uid == element.user ? Colors.yellow[200] : Colors.grey[300],
      child: ListTile(
        //onTap: () => chatController._onEntryChanged(),
        //onLongPress: () => chatController.deleteMsg(element, posicion),
        title: Text(
          element.text,
          textAlign: uid == element.user ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }

  Widget _list() {
    String uid = authenticationController.getUid();
    logInfo('Current user $uid');
    return GetX<ChatSController>(builder: (controller) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToEnd());
      return ListView.builder(
        itemCount: chatController.messages.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          var element = chatController.messages[index];
          return _item(element, index, uid);
        },
      );
    });
  }

  Future<void> _sendMsg(String text) async {
    logInfo("Calling _sendMsg with $text");
    await chatController.sendChat(person.uid, text);
  }

  Widget _textInput() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(left: 5.0, top: 5.0),
            child: TextField(
              key: const Key('MsgTextField'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your message',
              ),
              onSubmitted: (value) {
                _sendMsg(_controller.text);
                _controller.clear();
              },
              controller: _controller,
            ),
          ),
        ),
        TextButton(
          key: const Key('sendButton'),
          child: const Text('Send'),
          onPressed: () {
            _sendMsg(_controller.text);
            _controller.clear();
          },
        )
      ],
    );
  }

  _scrollToEnd() async {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 25.0),
      child: Column(
        children: [Expanded(flex: 4, child: _list()), _textInput()],
      ),
    );
  }
}
