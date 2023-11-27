import 'package:f_firebase_202210/ui/controllers/chat_controller.dart';
import 'package:f_firebase_202210/ui/widgets/maps_page.dart';
import 'package:f_firebase_202210/ui/widgets/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loggy/loggy.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List todos = List.empty();
  String titles = "";
  String _description = "";

  @override
  void initState() {
    super.initState();
    todos = ["Hello", "Hey There"];
  }

  createToDo() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(titles);

    Map<String, dynamic> todoList = {
      "todoTitle": titles,
      "todoDesc": _description,
    };

    documentReference
        .set(todoList)
        .whenComplete(() => print("Data stored successfully"));
  }

  deleteTodo(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(item);

    documentReference.delete().whenComplete(() => print("Deleted successfully"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("MyTodos").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else if (snapshot.hasData || snapshot.data != null) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (BuildContext context, int index) {
                QueryDocumentSnapshot<Object?>? documentSnapshot =
                    snapshot.data?.docs[index];
                return Dismissible(
                  key: Key(index.toString()),
                  child: Card(
                    elevation: 4,
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((documentSnapshot != null) ? (documentSnapshot["todoTitle"]) : ""),
                        ],
                      ),
                      subtitle: Text((documentSnapshot != null)
                          ? ((documentSnapshot["todoDesc"] != null)
                              ? documentSnapshot["todoDesc"]
                              : "")
                          : ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                deleteTodo((documentSnapshot != null) ? (documentSnapshot["todoTitle"]) : "");
                              });
                            },
                          ),
                          //llevar al mapa
                          IconButton(
                            icon: const Icon(Icons.location_on),
                            onPressed: () {
                              Get.to(() => MapScreen());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat),
                            onPressed: () {
                              ChatController chatController = Get.find();
                              Navigator.push(
                                context,
                                
                                MaterialPageRoute(builder: (context) => ChatPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: const Text("Add Todo"),
                content: SingleChildScrollView(
                  child: Container(
                    width: 400,
                    height: 120,
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (String value) {
                            setState(() {
                              titles = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Título',
                            hintText: 'Ingrese título de la tarea',
                          ),
                        ),
                        TextField(
                          onChanged: (String value) {
                            setState(() {
                              _description = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            hintText: 'Ingrese descripción de la tarea',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        createToDo();
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text("Add"),
                  )
                ],
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
