import 'package:flutter/material.dart';
import 'package:qr_reader/pages/home_page.dart';
import 'package:qr_reader/utils/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final supabaseService = SupabaseService();
  bool _obscurePassword = true;

  void loginFunction(String email, String password) async {
    final isDataOk = await supabaseService.userLogin(email, password);

    // Evitar problemas de contexto entre espacios asíncronos
    if (!mounted) return;

    // Si los datos están correctos
    if (isDataOk == true) {
      // Mensaje saliente
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sesión iniciada correctamente')));
      // Cambiar de página
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
    // Si los datos no están correctos
    else {
      // Mensaje saliente
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Datos incorrectos')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 32),

                // CAMPO EMAIL
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa un correo';
                    }
                    if (!value.contains('@')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // CAMPO PASSWORD
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa la contraseña';
                    }
                    if (value.length < 6) {
                      return 'Debe tener mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // BOTÓN LOGIN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        // Función con lógica de login
                        loginFunction(email, password);
                      }
                    },
                    child: const Text('Ingresar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
