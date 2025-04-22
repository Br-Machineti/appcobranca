import 'dart:io';

import 'package:droid_foto/Utils.dart' as utils;
import 'package:droid_foto/model/FotoModel.dart';
import 'package:droid_foto/model/ReposicaoModel.dart';
import 'package:droid_foto/model/db.dart';
import 'package:droid_foto/classes/Foto.dart';
import 'package:droid_foto/classes/Reposicao.dart';
import 'package:droid_foto/screens/VisualizarFoto.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class ListaFoto extends StatefulWidget {
  const ListaFoto({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListaFotoState();
}

class _ListaFotoState extends State<ListaFoto> {
  _ListaFotoState({Key? key});

  List<Foto> fotos = [];
  List<Foto> fotosFiltradas = [];
  TextEditingController searchController = TextEditingController();

  getFotos() async {
    Database db = await getDb();
    FotoModel fotoModel = FotoModel();
    fotos = await fotoModel.todasFotos(db);
    fotosFiltradas = List.from(fotos);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFotos();
  }

  confirmaDeletarFoto(int id) {
    utils.dialogPadraoCpl(
      context,
      acaoNao: () {},
      acaoSim: () async {
        utils.showLoaderDialog(context, texto: 'Enviando foto(s)...');
        Database db = await getDb();
        FotoModel fotoModel = FotoModel();
        await fotoModel.setFotoEnviada(db, id);
        Navigator.of(context, rootNavigator: true).pop();
        getFotos();
      },
      titulo: 'Atenção',
      conteudo: 'Tem certeza que deseja deletar esta foto?',
    );
  }

  confirmaReenviarFoto(int id) {
    utils.dialogPadraoCpl(
      context,
      acaoNao: () {},
      acaoSim: () async {
        utils.showLoaderDialog(context, texto: 'Enviando foto(s)...');
        Database db = await getDb();
        FotoModel fotoModel = FotoModel();
        await fotoModel.setFotoReenviar(db, id);
        Navigator.of(context, rootNavigator: true).pop();
        getFotos();
      },
      titulo: 'Atenção',
      conteudo: 'Tem certeza que deseja reenviar a foto?',
    );
  }

  Widget _buildExpandableTile(Foto foto) {
    DateTime dataTemp = DateTime.parse(foto.dataf);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm:ss');

    return ExpansionTile(
      leading: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: utils.cplColorGrey,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(10),
        ),
        child: const Icon(Icons.delete),
        onPressed: () {
          confirmaReenviarFoto(foto.id);
        },
      ),
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      subtitle: Text(
        'Data: ' + formatter.format(dataTemp),
        style: const TextStyle(color: Colors.white),
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      title: Text(
        'Reposição: ${foto.reposicao} Número: ${foto.numero} Env.: ${foto.enviado}',
        style: const TextStyle(color: Colors.white),
      ),
      children: <Widget>[
        GestureDetector(
          onDoubleTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VisualizarFoto(imagePath: foto.urlPath),
              ),
            );
          },
          child: Image.file(
            File(foto.urlPath),
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  Widget _listContent(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: fotosFiltradas.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildExpandableTile(fotosFiltradas[index]);
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  void buscarPorNumero(String texto) {
    if (texto.isEmpty) return;
    setState(() {
      fotosFiltradas =
          fotos.where((f) => f.numero.toString().contains(texto)).toList();
    });
  }

  void fecharBusca() {
    setState(() {
      searchController.clear();
      fotosFiltradas = List.from(fotos);
    });
  }

  void abrirDialogBusca() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buscar Foto'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Número da máquina',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                fecharBusca();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Pesquisar'),
              onPressed: () {
                buscarPorNumero(searchController.text.trim());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> enviarListaFotos(BuildContext context) async {
    utils.showLoaderDialog(context, texto: 'Enviando foto(s)...');
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Database db = await getDb();
        FotoModel fotoModel = FotoModel();
        List<Foto> listaFotos = await fotoModel.todasFotosPendentes(db);
        await utils.enviarFotos(context, listaFotos, fotoModel, db);

        ReposicaoModel reposicaoModel = ReposicaoModel();
        List<Reposicao> listaReposicao =
            await reposicaoModel.todasReposicaoPendentes(db);
        await utils.enviarReposicao(
            context, listaReposicao, reposicaoModel, db);

        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pop(context);
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        utils.dialogPadraoCpl(
          context,
          textoNao: '',
          acaoNao: () {},
          textoSim: 'Ok',
          acaoSim: () {},
          titulo: 'Atenção',
          conteudo: 'Não foi possível conectar-se ao servidor.',
        );
      }
    } on SocketException catch (_) {
      Navigator.of(context, rootNavigator: true).pop();
      utils.dialogPadraoCpl(
        context,
        textoNao: '',
        acaoNao: () {},
        textoSim: 'Ok',
        acaoSim: () {},
        titulo: 'Atenção',
        conteudo: 'Não foi possível conectar-se ao servidor.',
      );
    }
  }

  confirmaEnvio(BuildContext context) {
    utils.dialogPadraoCpl(
      context,
      acaoNao: () {},
      acaoSim: () async {
        await enviarListaFotos(context);
      },
      titulo: 'Atenção',
      conteudo: 'Tem certeza que deseja enviar as fotos?',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarPadraoCpl(context, 'Fotos no dispositivo'),
      body: Container(
        color: utils.cplColorBlue,
        child: _listContent(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: utils.cplColorGrey,
            heroTag: null,
            child: Icon(Icons.search, color: utils.cplColorBlue),
            onPressed: abrirDialogBusca,
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: utils.cplColorGrey,
            heroTag: null,
            child: Icon(Icons.picture_as_pdf, color: utils.cplColorBlue),
            onPressed: () async {
              Database db = await getDb();
              FotoModel fotoModel = FotoModel();
              List<Foto> listFoto = await fotoModel.todasFotos(db);
              utils.generatePdf(listFoto);
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: utils.cplColorGrey,
            child: Icon(Icons.send, color: utils.cplColorBlue),
            onPressed: (fotos.isEmpty)
                ? null
                : () {
                    confirmaEnvio(context);
                  },
          ),
        ],
      ),
    );
  }
}
