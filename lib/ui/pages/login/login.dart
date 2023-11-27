import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/authentication_controller.dart';
import 'register.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final AuthenticationController authenticationController = Get.find();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void signIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Verificar el formato del correo electrónico
    if (!isValidEmail(email)) {
      Get.snackbar('Error', 'Por favor, ingresa un correo electrónico válido.');
      return;
    }

    // Verificar el formato de la contraseña
    if (!isValidPassword(password)) {
      Get.snackbar('Error', 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    try {
      await authenticationController.login(email, password);
      // Manejar el resultado del inicio de sesión aquí (puedes redirigir a otra pantalla si es exitoso)
    } catch (e) {
      // Manejar el error de credenciales incorrectas
      Get.snackbar('Error', 'Credenciales incorrectas. Por favor, inténtalo de nuevo.');
    }
  }

  void goToRegisterPage() {
    Get.to(() => RegisterPage());
  }

  bool isValidEmail(String email) {
    // Verificar el formato del correo electrónico utilizando una expresión regular
    return RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(email);
  }

  bool isValidPassword(String password) {
    // Verificar el formato de la contraseña (mínimo 6 caracteres)
    return password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/logos.png',
                  width: 100,
                  height: 100,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => signIn(),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("Iniciar Sesión"),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => goToRegisterPage(),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text("Registrarse"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
