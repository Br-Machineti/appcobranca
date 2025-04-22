import 'package:droid_foto/Utils.dart' as utils;
import 'package:droid_foto/model/UsuarioModel.dart';
import 'package:droid_foto/model/db.dart';
import 'package:droid_foto/classes/Usuario.dart';
import 'package:droid_foto/screens/CameraScreen.dart';
import 'package:droid_foto/screens/ListaFoto.dart';
import 'package:droid_foto/screens/ListaReposicao.dart';
import 'package:droid_foto/screens/LoginScreen.dart';
import 'package:droid_foto/service/maquina_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:droid_foto/globals.dart' as globals;

class TelaInicial extends StatelessWidget {
  const TelaInicial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: utils.appBarPadraoCpl(
          context,
          'Cobrança (V:1.7)',
          actions: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 10.0),
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.person_outline_sharp, size: 26.0),
                  Text(globals.usuarioLogado.nome),
                ],
              ),
            ),
          ],
        ),
        body: Container(
          color: utils.cplColorBlue,
          child: const Center(
            child: DashBoard(),
          ),
        ),
      ),
    );
  }
}

class DashBoard extends StatelessWidget {
  const DashBoard({Key? key}) : super(key: key);

  Widget _buildTirarFotoButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15.0),
        primary: utils.cplColorGrey,
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CameraScreen()),
        );
      },
      child: Column(
        children: const [
          Icon(Icons.camera_alt),
          Center(child: Text('Cobrança')),
        ],
      ),
    );
  }

  Widget _buildReposicaoButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15.0),
        primary: utils.cplColorGrey,
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ListaReposicao()),
        );
      },
      child: Column(
        children: const [
          Icon(Icons.table_rows_sharp),
          Center(child: Text('Reposição')),
        ],
      ),
    );
  }

  Widget _buildAcessarListaButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15.0),
        primary: utils.cplColorGrey,
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ListaFoto()),
        );
      },
      child: Column(
        children: const [
          Icon(Icons.table_rows_sharp),
          Center(child: Text('Lista')),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15.0),
        primary: utils.cplColorGrey,
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        utils.dialogPadraoCpl(
          context,
          textoNao: 'Não',
          textoSim: 'Sim',
          acaoNao: () {},
          acaoSim: () async {
            utils.showLoaderDialog(context, texto: 'Saindo...');
            Database db = await getDb();
            UsuarioModel usuarioModel = UsuarioModel();
            usuarioModel.deslogarUsuarios(db);
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false,
            );
          },
          titulo: 'Atenção',
          conteudo: 'Tem certeza que deseja trocar de usuário?',
        );
      },
      child: Column(
        children: const [
          Icon(Icons.logout),
          Center(child: Text('Logout')),
        ],
      ),
    );
  }

  Widget _buildReceberDadosButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(15.0),
        primary: utils.cplColorGrey,
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () async {
        utils.showLoaderDialog(context, texto: 'Recebendo dados...');
        await MaquinaService().fetchAndSaveMaquinas(context);
        Navigator.of(context, rootNavigator: true).pop(); // Fecha o loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados recebidos com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Column(
        children: const [
          Icon(Icons.download),
          Center(child: Text('Receber Dados')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double buttonSize = MediaQuery.of(context).size.width / 2.9;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              width: buttonSize < 134 ? 134 : buttonSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildTirarFotoButton(context),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              width: buttonSize < 134 ? 134 : buttonSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildReposicaoButton(context),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              width: buttonSize < 134 ? 134 : buttonSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildAcessarListaButton(context),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              width: buttonSize < 134 ? 134 : buttonSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildLogoutButton(context),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              width: buttonSize < 134 ? 134 : buttonSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildReceberDadosButton(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}