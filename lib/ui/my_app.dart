import 'package:f_firebase_202210/ui/controllers/MyHome_controller.dart';
import 'package:f_firebase_202210/ui/firebase_cental.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/authentication_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/chats_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/MyHome_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(MyHomeController());
    Get.put(AuthenticationController());
    Get.put(ChatController());
    Get.put(ChatSController());
    Get.put(UserController());
    

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TO DO',
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        home: const FirebaseCentral());
  }
}
