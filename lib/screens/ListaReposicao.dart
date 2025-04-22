import 'dart:io';
import 'package:droid_foto/Utils.dart' as utils;
import 'package:droid_foto/model/ReposicaoModel.dart';
import 'package:droid_foto/model/UsuarioModel.dart';
import 'package:droid_foto/model/db.dart';
import 'package:droid_foto/classes/Reposicao.dart';
import 'package:droid_foto/classes/Usuario.dart';
import 'package:droid_foto/screens/TelaInicial.dart';
//import 'package:droid_foto/screens/ListaReposicao.dart';
//import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


class ListaReposicao extends StatefulWidget {
  /// recebe o imgPath e a camera da tela da camera
  /*final String imagePath;
  final CameraDescription camera;*/
  const ListaReposicao({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FormularioReposicaoState();
  /*State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      _FormularioFotoState();*/
}

class _FormularioReposicaoState extends State<ListaReposicao> {
  _FormularioReposicaoState({Key? key});

  /// cria as variaveis e os controllers necessarios
  final TextEditingController reposicaoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  /// Determina a localização atual do dispositivo
  /*Future<Position> _determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      /// fecha dialogo carregamento
      Navigator.of(context, rootNavigator: true).pop();

      /// Localização está desativada
      utils.dialogPadraoCpl(
        context,
        acaoNao: () {},
        acaoSim: () {},
        textoNao: '',
        textoSim: 'Ok',
        titulo: 'Atenção',
        conteudo: 'Ative a localização do seu celular.',
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        /// fecha dialogo carregamento
        Navigator.of(context, rootNavigator: true).pop();

        /// permissão foi negada
        utils.dialogPadraoCpl(
          context,
          acaoNao: () {},
          acaoSim: () {},
          textoNao: '',
          textoSim: 'Ok',
          titulo: 'Atenção',
          conteudo: 'É necessária a localização para salvar a foto.',
        );
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      /// fecha dialogo carregamento
      Navigator.of(context, rootNavigator: true).pop();

      /// Permissões foram negadas permanentemente
      utils.dialogPadraoCpl(
        context,
        acaoNao: () {},
        acaoSim: () {},
        textoNao: '',
        textoSim: 'Ok',
        titulo: 'Atenção',
        conteudo:
            'As permissões de localização foram negadas permanentemente, altere-as nas configurações do celular.',
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    /// funcionou
    return await Geolocator.getCurrentPosition();
  }*/

  void saveReposicao(BuildContext context) async {
    /// abre dialogo de carregamento
    utils.showLoaderDialog(context, texto: 'Enviando Reposição(s)...');

    if (reposicaoController.text == '' || numeroController.text == '') {
      /// fecha dialogo de carregamento
      Navigator.of(context, rootNavigator: true).pop();

      utils.dialogPadraoCpl(
        context,
        acaoNao: () {},
        acaoSim: () {},
        textoNao: '',
        textoSim: 'Ok',
        titulo: 'Atenção',
        conteudo: 'Reposição e número são obrigatórios.',
      );
      return;
    }

    /// pega a reposicao e numero dos controllers
    final int reposicaoc = int.parse(reposicaoController.text);
    final int numero = int.parse(numeroController.text);
    /// a data atual formatada
    DateTime dataAtual = DateTime.now();
    String dataFormatada = dataAtual.toString().split('.')[0];

    /// a localizacao
 //   Position position = await _determinePosition(context);

    // pegando o path da imagem - ela ainda está no temp
    //final String path =
    //    (await path_provider.getApplicationDocumentsDirectory()).path;
    //Directory(path + '/images/').createSync();
    //final String fileName = basename(File(imagePath).path);
    // copiando para um diretorio
    //final File newImage = await File(imagePath).copy('$path/images/$fileName');

    /// instancia a foto
    Reposicao reposicao = Reposicao(
        id: 0,
        quantidade: reposicaoc,
        numero: numero,
        datai: dataFormatada,
        enviado: 0);

    /// pega o db e instancia o model
    Database db = await getDb();
    ReposicaoModel reposicaoModel = ReposicaoModel();

    /// insere a foto
    reposicaoModel.inserirReposicao(db, reposicao);

    /// pega o usuario logado
    UsuarioModel usuarioModel = UsuarioModel();
    Usuario usuarioLogado = await usuarioModel.getUsuarioLogado(db);

    /// valida a conexao com a internet e tenta enviar elas se tiver internet
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        List<Reposicao> listaReposicao = await reposicaoModel.todasReposicao(db);

        utils.enviarReposicao(context, listaReposicao, reposicaoModel, db);
      }
    } on SocketException catch (_) {}

    /// fecha dialogo de carregamento
    Navigator.of(context, rootNavigator: true).pop();

    /// move pra tela inicial
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => TelaInicial()),
      (Route<dynamic> route) => false,
    );
  }

  /// botao de salvar
  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: utils.cplColorGrey,
          padding: const EdgeInsets.all(5.0),
          elevation: 2.0,
          minimumSize: const Size(100, 50),
        ),
        onPressed: () async {
          /// remove o foco dos inputs
          FocusScope.of(context).requestFocus(FocusNode());
          utils.dialogPadraoCpl(
            context,
            acaoNao: () {},
            acaoSim: () async {
              saveReposicao(context);
              //saveFoto(context);
            },
            titulo: 'Atenção',
            conteudo: 'Tem certeza que deseja gravar a reposição?',
          );
        },
        child: Text(
          'Salvar',
          style: TextStyle(color: utils.cplColor, fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildNumeroTF() {
    /// mascara para o numero - https://pub.dev/packages/mask_text_input_formatter
    final numeroFormatter = MaskTextInputFormatter(
        mask: 'xxxxxxxxxx', filter: {"x": RegExp(r'[0-9]')});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Número',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'ComicSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            /// mascara
            inputFormatters: [numeroFormatter],

            /// controller
            controller: numeroController,

            /// tipo de teclado
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintText: 'Digite o número',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.keyboard,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildReposicaoTF() {
    /// mascara para a reposicao - https://pub.dev/packages/mask_text_input_formatter
    final reposicaoFormatter = MaskTextInputFormatter(
        mask: 'xxxxxxxxxxxxxxxxxxx', filter: {"x": RegExp(r'[0-9]')});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reposição: ',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OpenSans',
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            /// mascaras
            inputFormatters: [reposicaoFormatter],

            /// controller
            controller: reposicaoController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              hintText: 'Digite a reposição',
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.keyboard,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

 /* Widget _buildOpenPhotoButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.all(5),
      ),
      onPressed: () {
        //print(imagePath);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VisualizarFoto(
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Icon(
        Icons.zoom_in,
        color: utils.cplColor,
        size: 30,
      ),
    );
  }*/

 /* Widget _buildRelogio1TF() {
    /// mascara para o numero - https://pub.dev/packages/mask_text_input_formatter
    final numeroFormatter = MaskTextInputFormatter(
        mask: 'xxxxxxxxxxxxxxxxxxx', filter: {"x": RegExp(r'[0-9]')});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Número Relógio Entrada 1',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'ComicSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            /// mascara
            inputFormatters: [numeroFormatter],

            /// controller
            controller: relogio1Controller,

            /// tipo de teclado
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintText: 'Relógio de Entrada',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.keyboard,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRelogio2TF() {
    /// mascara para o numero - https://pub.dev/packages/mask_text_input_formatter
    final numeroFormatter = MaskTextInputFormatter(
        mask: 'xxxxxxxxxxxxxxxxxxx', filter: {"x": RegExp(r'[0-9]')});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Número Relógio Entrada 2',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'ComicSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            /// mascara
            inputFormatters: [numeroFormatter],

            /// controller
            controller: relogio2Controller,

            /// tipo de teclado
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintText: 'Relógio de Entrada 2',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.keyboard,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSaidaTF() {
    /// mascara para o numero - https://pub.dev/packages/mask_text_input_formatter
    final numeroFormatter = MaskTextInputFormatter(
        mask: 'xxxxxxxxxxxxxxxxxxx', filter: {"x": RegExp(r'[0-9]')});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Número Relógio Saída',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'ComicSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            /// mascara
            inputFormatters: [numeroFormatter],

            /// controller
            controller: saidaController,

            /// tipo de teclado
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintText: 'Relógio de Saída Pelucias',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.keyboard,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildValortesteTF() {
    /// mascara para o numero - https://pub.dev/packages/mask_text_input_formatter
    final numeroFormatter = MaskTextInputFormatter(
        mask: 'xxxxxxxxxxxxxxxxxxx', filter: {"x": RegExp(r'[0-9]')});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valor de teste na máquina',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'ComicSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            /// mascara
            inputFormatters: [numeroFormatter],

            /// controller
            controller: valortesteController,

            /// tipo de teclado
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintText: 'Informe o valor de teste na máquina',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.keyboard,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: utils.appBarPadraoCpl(context, 'Reposição'),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            color: utils.cplColorBlue,

            /// detecta o onTap fora dos inputs e botoes e remove o foco deles
            child: GestureDetector(
              onTap: () => {FocusScope.of(context).requestFocus(FocusNode())},
              child: Form(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildNumeroTF(),
                        _buildReposicaoTF(),
                        _buildSaveButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}
