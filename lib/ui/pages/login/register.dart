import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:date_format/date_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/authentication_controller.dart';
import '../login/login.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  final AuthenticationController authenticationController = Get.find();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final phoneFormatter = FilteringTextInputFormatter.digitsOnly;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      String formattedDate = formatDate(pickedDate, [yyyy, '-', mm, '-', dd]);
      birthdayController.text = formattedDate;
    }
  }

  void register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String birthday = birthdayController.text.trim();
    String phone = phoneController.text.trim();
    String name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || birthday.isEmpty || phone.isEmpty) {
      Get.snackbar('Error', 'Por favor, completa todos los campos.');
      return;
    }

    if (!isValidEmail(email)) {
      Get.snackbar('Error', 'Por favor, ingresa un correo electrónico válido.');
      return;
    }

    if (password.length < 6) {
      Get.snackbar('Error', 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    try {
      // Registro en Firebase Authentication
      await authenticationController.signup(email, password);

      // Guardar datos en Firestore
      DocumentReference documentReference = FirebaseFirestore.instance.collection("users").doc(email);

      Map<String, String> userData = {
        "email": email,
        "birthday": birthday,
        "phone": phone,
        "name": name,
      };

      await documentReference.set(userData);

      Get.off(() => LoginPage());
    } catch (e) {
      Get.snackbar('Error', 'El correo electrónico ya está en uso. Por favor, elige otro.');
    }
  }

  bool isValidEmail(String email) {
    return email.contains('@');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'), 
        backgroundColor: Colors.pink, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField('Correo Electrónico', emailController),
              _buildTextField('Nombre', nameController),
              _buildTextField('Contraseña', passwordController, obscureText: true),
              _buildDateField('Cumpleaños', birthdayController, context),
              _buildTextField('Número de Teléfono', phoneController,
                  keyboardType: TextInputType.phone, inputFormatters: [phoneFormatter]),
              SizedBox(height: 20),
              _buildElevatedButton('Registrarse', register),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(fontSize: 16.0),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      child: InkWell(
        onTap: () => _selectDate(context),
        child: IgnorePointer(
          child: _buildTextField(label, controller),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 248, 138, 175),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(label),
      ),
    );
  }
}
