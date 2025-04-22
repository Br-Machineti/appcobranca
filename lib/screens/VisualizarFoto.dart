import 'dart:io';

import 'package:droid_foto/Utils.dart' as utils;
import 'package:flutter/material.dart';

class VisualizarFoto extends StatelessWidget {
  const VisualizarFoto({Key? key, required this.imagePath}) : super(key: key);

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// app bar com as cores
      appBar: utils.appBarPadraoCpl(context, 'Visualizar foto'),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,

        /// no duplo clique volta para a tela de onde foi chamado
        child: GestureDetector(
          onDoubleTap: () {
            Navigator.of(context).pop();
          },

          /// image em tela cheia
          child: Image.file(
            File(imagePath),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
