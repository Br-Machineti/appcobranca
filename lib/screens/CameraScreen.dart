// A screen that allows users to take a picture using a given camera.
//import 'dart:io';

import 'package:droid_foto/Utils.dart' as utils;
import 'package:droid_foto/screens/FormularioFoto.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:droid_foto/globals.dart' as globals;

class CameraScreen extends StatefulWidget {
  /// recebe a camera como parametro obrigatorio
  const CameraScreen({
    Key? key,
  }) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool flashState = false;

  /// inicia um controller Future para a camera
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    setState(() {
      flashState = false;
    });

    _controller = CameraController(
      /// pega uma camera especifica da lista de cameras disponiveis - a principal
      globals.camera,

      /// Coloca resolucao na media
      ResolutionPreset.medium, //Mudado para teste
      //ResolutionPreset.high,
    );

    /// inicializa o controller, isso retorna o future que precisa
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    /// chamado quando a tela é terminada
    _controller.dispose();
    super.dispose();
  }

  takePicture() async {
    /// abre tela carregamento
    utils.showLoaderDialog(context, texto: 'Aguarde...');

    /// Pega a foto em um try catch pra garantir
    try {
      /// espera a camera iniciar
      await _initializeControllerFuture;

      /// tenta tirar uma foto e pegar a imagem que foi tirada
      /// foto fica em image.path
      final image = await _controller.takePicture();

      /// fecha tela carregamento
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        flashState = false;
      });
      _controller.setFlashMode(FlashMode.off);

      /// quando a foto for tirada leva para outra página
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FormularioFoto(
            // Passa o path gerado automaticamente
            imagePath: image.path, camera: _controller.description,
          ),
        ),
      );
    } catch (e) {
      /// fecha tela carregamento
      Navigator.of(context, rootNavigator: true).pop();
      utils.dialogPadraoCpl(
        context,
        acaoNao: () {},
        acaoSim: () {},
        textoNao: '',
        textoSim: 'Ok',
        titulo: 'Atenção',
        conteudo: 'Houve um erro ao tirar a foto',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        /// app bar, automaticamente já tem o botão de voltar
        appBar: utils.appBarPadraoCpl(context, 'Tirar uma foto'),

        /// é preciso esperar a camera iniciar antes de mostrar ela
        /// usando o FutureBuilder para esperar iniciar e uma CircularProgressIndicator enquanto carrega
        body: Container(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          width: double.infinity,
          height: double.infinity,
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                /// aqui mostra a camera quando estiver pronta
                return CameraPreview(_controller);
              } else {
                /// se não estiver pronta mostra uma tela de loading
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),

        /// botão para tirar a foto
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'camara',
              backgroundColor: utils.cplColorBlue,
              onPressed: () async {
                takePicture();
              },
              child: const Icon(
                Icons.camera_alt,
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'flash',
              backgroundColor: utils.cplColorBlue,
              onPressed: () async {
                if (flashState == true) {
                  setState(() {
                    flashState = false;
                  });
                  _controller.setFlashMode(FlashMode.off);
                } else {
                  setState(() {
                    flashState = true;
                  });
                  _controller.setFlashMode(FlashMode.torch);
                }
              },
              child: const Icon(
                Icons.flash_on,
              ),
            ),
          ],
        ));
  }
}
