import 'package:droid_foto/Utils.dart' as utils;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:droid_foto/model/UsuarioModel.dart';
import 'package:droid_foto/classes/Usuario.dart';

import 'package:droid_foto/screens/TelaInicial.dart';
import 'package:droid_foto/screens/LoginScreen.dart';

import 'model/db.dart';

import 'package:droid_foto/globals.dart' as globals;

void main() async {
  /// Garante que o app iá iniciar - https://stackoverflow.com/questions/63873338/what-does-widgetsflutterbinding-ensureinitialized-do/63873689#63873689
  WidgetsFlutterBinding.ensureInitialized();

  /// pega/cria o banco de dados
  final db = await getDb();

  /// instancia o Model do usuario
  UsuarioModel usuarioModel = UsuarioModel();

  /// pega o usuario logado, se nenhum estiver logado então id = 0
  Usuario usuarioLogadobanco = await usuarioModel.getUsuarioLogado(db);

  // Pega a lista de câmeras disponíveis no celular - ela é instanciada aqui porque (provavelmente) é o unico jeito
  final List<CameraDescription> cameras = await availableCameras();

  // Pega a princiál câmera do celular
  final CameraDescription firstCamera = cameras.first;

  globals.camera = firstCamera;

  /// coloca a tela inicial como padrão
  Widget selectedScreen = TelaInicial();

  /// se nenhum usuário estiver logado, muda a tela padrão para a tela de login
  if (0 == usuarioLogadobanco.id) {
    selectedScreen = LoginScreen();
  } else {
    globals.usuarioLogado = usuarioLogadobanco;
  }

  /// inicia o app, passando a tela como parametro
  runApp(AplicativoCpl(
    homeScreen: selectedScreen,
  ));
}

class AplicativoCpl extends StatelessWidget {
  /// recebe a tela como parametro - obrigatoria
  final Widget homeScreen;
  const AplicativoCpl({Key? key, required this.homeScreen}) : super(key: key);

  /// constroi o app com a tela passada e o tema carregado
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo CPL Software',
      theme: utils.cplTheme,
      home: homeScreen,
    );
  }
}
