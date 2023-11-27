import 'package:f_firebase_202210/data/model/app_user.dart';
import 'package:f_firebase_202210/ui/controllers/user_controller.dart';
import 'package:f_firebase_202210/ui/widgets/chats_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  UserController userController = Get.find();

  @override
  void initState() {
    userController.start();
    super.initState();
  }

  @override
  void dispose() {
    userController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _list();
  }

  Widget _item(AppUser element) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: ListTile(
        title: Text(
          element.email,
        ),
        subtitle: Text(element.uid),
        // Agrega un botón para iniciar el chat con el usuario
        trailing: ElevatedButton(
          onPressed: () => _startChatWithUser(element),
          child: const Text('Chat'),
        ),
      ),
    );
  }

  Widget _list() {
    return GetX<UserController>(builder: (controller) {
      if (userController.users.length == 0) {
        return const Center(
          child: Text('No users'),
        );
      }
      return ListView.builder(
        itemCount: userController.users.length,
        itemBuilder: (context, index) {
          var element = userController.users[index];
          return _item(element);
        },
      );
    });
  }

  // Método para iniciar el chat con un usuario específico
  void _startChatWithUser(AppUser user) {
    
    Get.to(() => ChatSPage(), arguments: [ user]);
}
  }

