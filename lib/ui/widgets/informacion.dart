import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  final String userEmail;

  ProfilePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.pink,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("users").doc(userEmail).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return Center(child: Text(snapshot.hasError ? 'Error al cargar los datos' : 'No se encontraron datos para este usuario'));
          }

          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

          return Center(
            child: Card(
              color: Colors.pink,
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Perfil del Usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    UserInfoItem(title: 'Correo Electrónico', value: userData['email']),
                    UserInfoItem(title: 'Nombre', value: userData['name']),
                    UserInfoItem(title: 'Cumpleaños', value: userData['birthday']),
                    UserInfoItem(title: 'Número de Teléfono', value: userData['phone']),
                    // Puedes agregar más campos según sea necesario
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserInfoItem extends StatelessWidget {
  final String title;
  final String value;

  UserInfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.pink,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(
              color: Colors.pink,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
