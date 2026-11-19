import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'produtor_screen.dart';
import 'perfil_screen.dart';
import 'vendedor_screen.dart';
import 'gerente_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  Widget? tela;

  @override
  void initState() {
    super.initState();
    verificarLogin();
  }

  Future<void> verificarLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final perfil = prefs.getString('perfil');

    Widget destino;

    if (perfil == null) {
      destino = const LoginScreen();
    } else {
      final usuario = {
        'id': prefs.getInt('id'),
        'nome': prefs.getString('nome'),
        'email': prefs.getString('email'),
        'perfil': perfil,
      };

      if (perfil == 'produtor') {
        destino = ProdutorScreen(usuario: usuario);
      } else if (perfil == 'vendedor') {
        destino = VendedorScreen(usuario: usuario);
      } else if (perfil == 'gerente') {
        destino = GerenteScreen(usuario: usuario);
      } else {
        destino = PerfilScreen(usuario: usuario);
      }
    }

    if (mounted) {
      setState(() {
        tela = destino;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tela == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return tela!;
  }
}
