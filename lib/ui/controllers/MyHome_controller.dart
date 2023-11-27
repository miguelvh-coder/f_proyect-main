import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomeController extends GetxController {
  var _todos = <Todo>[].obs;

  get todos => _todos;

  @override
  void onInit() {
    // Inicializa el controlador
    super.onInit();
    // Suscribe a las actualizaciones de Firestore
    subscribeUpdates();
  }

  void subscribeUpdates() {
    FirebaseFirestore.instance.collection("MyTodos").snapshots().listen((snapshot) {
      _todos.value = snapshot.docs.map((doc) => Todo.fromMap(doc.data())).toList();
    });
  }

  void createTodo(String title, String description) {
    DocumentReference documentReference = FirebaseFirestore.instance.collection("MyTodos").doc(title);

    Map<String, String> todoList = {
      "todoTitle": title,
      "todoDesc": description,
    };

    documentReference.set(todoList).whenComplete(() => print("Data stored successfully"));
  }

  void deleteTodo(String title) {
    DocumentReference documentReference = FirebaseFirestore.instance.collection("MyTodos").doc(title);

    documentReference.delete().whenComplete(() => print("Deleted successfully"));
  }
}

class Todo {
  String title;
  String description;

  Todo({
    required this.title,
    required this.description,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      title: map['todoTitle'] ?? '',
      description: map['todoDesc'] ?? '',
    );
  }
}