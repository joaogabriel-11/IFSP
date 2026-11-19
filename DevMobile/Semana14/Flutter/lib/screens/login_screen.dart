import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'cadastro_screen.dart';
import 'produtor_screen.dart';
import 'perfil_screen.dart';
import 'vendedor_screen.dart';
import 'gerente_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool carregando = false;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty || senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe e-mail e senha')),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      final resultado = await ApiService.post(
        'usuarios/login.php',
        {
          'email': emailController.text.trim(),
          'senha': senhaController.text,
        },
      );

      final usuario = Map<String, dynamic>.from(
        resultado['usuario'],
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('id', int.parse(usuario['id'].toString()));
      await prefs.setString('nome', usuario['nome']);
      await prefs.setString('email', usuario['email']);
      await prefs.setString('perfil', usuario['perfil']);

      if (!mounted) return;

      Widget tela;

      if (usuario['perfil'] == 'produtor') {
        tela = ProdutorScreen(usuario: usuario);
      } else if (usuario['perfil'] == 'vendedor') {
        tela = VendedorScreen(usuario: usuario);
      } else if (usuario['perfil'] == 'gerente') {
        tela = GerenteScreen(usuario: usuario);
      } else {
        tela = PerfilScreen(usuario: usuario);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => tela),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Trufas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cookie,
              size: 80,
              color: Colors.brown,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bem-vindo!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : login,
                child: carregando
                    ? const CircularProgressIndicator()
                    : const Text('Entrar'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CadastroScreen(),
                  ),
                );
              },
              child: const Text('Não possui conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}
