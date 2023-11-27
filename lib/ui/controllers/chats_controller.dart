import 'dart:async';
import 'package:f_firebase_202210/data/model/app_user.dart';
import 'package:f_firebase_202210/ui/controllers/authentication_controller.dart';
import 'package:f_firebase_202210/ui/controllers/user_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:loggy/loggy.dart';

import '../../data/model/message.dart';

class ChatSController extends GetxController {
  var messages = <Message>[].obs;
  final databaseReference = FirebaseDatabase.instance.ref();
  late StreamSubscription<DatabaseEvent> newEntryStreamSubscription;
  late StreamSubscription<DatabaseEvent> updateEntryStreamSubscription;

  void subscribeToUpdated(uidUser) {
    messages.clear();
    AuthenticationController authenticationController = Get.find();
    logInfo('Current user? -> ${authenticationController.getUid()} msg -> $uidUser');
    String chatKey = getChatKey(authenticationController.getUid(), uidUser);

    newEntryStreamSubscription =
        databaseReference.child("msg").child(chatKey).onChildAdded.listen((event) => _onEntryAdded(event));

    updateEntryStreamSubscription =
        databaseReference.child("msg").child(chatKey).onChildChanged.listen((event) => _onEntryChanged(event));
  }

  void unsubscribe() {
    newEntryStreamSubscription.cancel();
    updateEntryStreamSubscription.cancel();
  }

  _onEntryAdded(DatabaseEvent event) {
    final json = event.snapshot.value as Map<dynamic, dynamic>;
    messages.add(Message.fromJson(event.snapshot, json));
  }

  _onEntryChanged(DatabaseEvent event) {
    var oldEntry = messages.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    final json = event.snapshot.value as Map<dynamic, dynamic>;
    messages[messages.indexOf(oldEntry)] =
        Message.fromJson(event.snapshot, json);
  }

  String getChatKey(uidUser1, uidUser2) {
    List<String> uidList = [uidUser1, uidUser2];
    uidList.sort();
    return uidList[0] + "--" + uidList[1];
  }

  Future<void> createChat(uidUser1, uidUser2, senderUid, msg) async {
    String key = getChatKey(uidUser1, uidUser2);
    try {
      // Save the message for the sender
      databaseReference
          .child('msg')
          .child(key)
          .push()
          .set({'senderUid': senderUid, 'msg': msg});

      // Save the message for the receiver
      databaseReference
          .child('msg')
          .child(getChatKey(uidUser2, uidUser1)) // Swap the order for the receiver
          .push()
          .set({'senderUid': senderUid, 'msg': msg});
    } catch (error) {
      logError(error);
      return Future.error(error);
    }
  }

  Future<void> sendChat(remoteUserUid, msg) async {
    AuthenticationController authenticationController = Get.find();
    String key = getChatKey(authenticationController.getUid(), remoteUserUid);
    String senderUid = authenticationController.getUid();

    try {
      databaseReference.child('msg').child(key).push().set({'text': msg, 'uid': senderUid});
    } catch (error) {
      logError(error);
      return Future.error(error);
    }
  }

  void initializeChats() {
    UserController userController = Get.find();
    List<AppUser> users = userController.allUsers();
    createChat(users[0].uid, users[1].uid, users[0].uid, "Hola B, soy A");
    createChat(users[1].uid, users[0].uid, users[1].uid, "Hola A, cómo estás?");
    createChat(users[0].uid, users[2].uid, users[0].uid, "Hola C, soy A");
    createChat(users[0].uid, users[2].uid, users[2].uid, "Hola A, Cómo estás?");
    createChat(users[1].uid, users[2].uid, users[1].uid, "Hola C, soy B");
    createChat(users[2].uid, users[1].uid, users[2].uid, "Todo bien B");
  }
}
