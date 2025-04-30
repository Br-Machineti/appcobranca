import 'dart:async';
import 'dart:io';
import 'package:droid_foto/Utils.dart' as utils;
import 'package:droid_foto/classes/Foto.dart';
import 'package:droid_foto/model/FotoModel.dart';
import 'package:droid_foto/model/db.dart';
import 'package:droid_foto/screens/VisualizarFoto.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/scheduler.dart';
import 'package:droid_foto/screens/ListaFoto.dart';
import 'package:droid_foto/screens/TelaInicial.dart';

class FormularioFoto extends StatefulWidget {
  final String imagePath;
  final CameraDescription camera;

  const FormularioFoto({
    Key? key,
    required this.imagePath,
    required this.camera,
  }) : super(key: key);

  @override
  State<FormularioFoto> createState() => _FormularioFotoState();
}

class _FormularioFotoState extends State<FormularioFoto> {
  final numeroController = TextEditingController();
  final clienteController = TextEditingController();
  final reposicaoController = TextEditingController();
  final relogio1Controller = TextEditingController();
  final relogio2Controller = TextEditingController();
  final saidaController = TextEditingController();
  final valortesteController = TextEditingController();
  final quantidadeEquipamentoController = TextEditingController();

  int? relogio1Antigo;
  int? relogio2Antigo;
  int? saidaAntiga;
  double? valorJogadaAntigo;
  double? valorPeluciaAntigo;
  String? mensagemAntiga;
  String? cliente;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    numeroController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 900), () {
        if (mounted) {
          _buscarMaquina(this.context);
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    numeroController.dispose();
    reposicaoController.dispose();
    relogio1Controller.dispose();
    relogio2Controller.dispose();
    saidaController.dispose();
    valortesteController.dispose();
    quantidadeEquipamentoController.dispose();
    super.dispose();
  }

  Future<Position> _determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      utils.dialogPadraoCpl(
        context,
        titulo: 'Atenção',
        conteudo: 'Ative a localização do seu celular.',
        textoSim: 'Ok',
        acaoSim: () {},
        textoNao: '',
        acaoNao: () {},
      );
      return Future.error('Localização desativada. Ative-a nas configurações.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        utils.dialogPadraoCpl(
          context,
          titulo: 'Atenção',
          conteudo: 'É necessária a localização para salvar a foto.',
          textoSim: 'Ok',
          acaoSim: () {},
          textoNao: '',
          acaoNao: () {},
        );
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      utils.dialogPadraoCpl(
        context,
        titulo: 'Atenção',
        conteudo:
            'As permissões de localização foram negadas permanentemente. Altere-as nas configurações do celular.',
        textoSim: 'Ok',
        acaoSim: () {},
        textoNao: '',
        acaoNao: () {},
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _buscarMaquina(BuildContext context) async {
    final numero = int.tryParse(numeroController.text);
    if (numero != null) {
      final db = await getDb();
      final result =
          await db.query('maquina', where: 'numero = ?', whereArgs: [numero]);

      if (result.isNotEmpty) {
        final data = result.first;
        setState(() {
          relogio1Antigo = data['relogio1atual'] as int?;
          relogio2Antigo = data['relogio2atual'] as int?;
          saidaAntiga = data['relogiosaidaatual'] as int?;
          valorJogadaAntigo = (data['valorjogada'] as num?)?.toDouble();
          valorPeluciaAntigo = (data['valorpelucia'] as num?)?.toDouble();
          mensagemAntiga = data['mensagem'] as String?;
          cliente = data['cliente'] as String?; // adicionei o cliente aqui
        });

        if (mensagemAntiga != null && mensagemAntiga!.isNotEmpty) {
          _exibirDialogo(
            context: context,
            titulo: 'Mensagem da Máquina',
            conteudo: mensagemAntiga!,
          );
        }
      } else {
        _exibirDialogo(
          context: context,
          titulo: 'Atenção',
          conteudo: 'Máquina não cadastrada. Deseja continuar?',
        );
      }
    }
  }

  Widget _buildResultadoCalculos() {
    final rel1 = int.tryParse(relogio1Controller.text) ?? 0;
    final rel2 = int.tryParse(relogio2Controller.text) ?? 0;
    final saida = int.tryParse(saidaController.text) ?? 0;
    final saidaAnt = saidaAntiga ?? 0;
    final pelucia = valorPeluciaAntigo ?? 1.0;

    final diferenca1 = relogio1Antigo != null ? rel1 - relogio1Antigo! : 0;
    final diferenca2 = relogio2Antigo != null ? rel2 - relogio2Antigo! : 0;
    final totalEntrada = diferenca1 + diferenca2;
    final diferencaSaida = saida - saidaAnt;
    final jogadasPorPelucia = diferencaSaida > 0
        ? (totalEntrada / diferencaSaida).toStringAsFixed(2)
        : '0';
    final mediaSaida = diferencaSaida > 0
        ? ((totalEntrada * pelucia) / diferencaSaida).toStringAsFixed(2)
        : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Soma das diferenças dos relógios de entrada: $totalEntrada',
            style: TextStyle(color: Colors.white)),
        SizedBox(height: 5),
        Text('Jogadas por pelúcia: $jogadasPorPelucia',
            style: TextStyle(color: Colors.white)),
        SizedBox(height: 5),
        Text('Média de saída: $mediaSaida',
            style: TextStyle(color: Colors.white)),
        SizedBox(height: 20),
      ],
    );
  }

  void _exibirDialogo({
    required BuildContext context,
    required String titulo,
    required String conteudo,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(conteudo),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void saveFoto(BuildContext context) async {
    // Exibe o diálogo de carregamento
    utils.showLoaderDialog(context, texto: 'Salvando e enviando foto(s)...');

    if (reposicaoController.text.isEmpty || numeroController.text.isEmpty) {
      Navigator.of(context, rootNavigator: true).pop();
      utils.dialogPadraoCpl(
        context,
        titulo: 'Atenção',
        conteudo: 'Reposição e número são obrigatórios.',
        textoSim: 'Ok',
        acaoSim: () {},
        textoNao: '',
        acaoNao: () {},
      );
      return;
    }

    try {
      // Obtém os dados dos campos
      final int reposicao = int.parse(reposicaoController.text);
      final int numero = int.parse(numeroController.text);
      final int relogio1 = int.tryParse(relogio1Controller.text) ?? 0;
      final int relogio2 = int.tryParse(relogio2Controller.text) ?? 0;
      final int saida = int.tryParse(saidaController.text) ?? 0;
      final int valorteste = int.tryParse(valortesteController.text) ?? 0;
      final int quantidadeEquipamento =
          int.tryParse(quantidadeEquipamentoController.text) ?? 0;

      final String imagePath = widget.imagePath;
      DateTime dataAtual = DateTime.now();
      String dataFormatada = dataAtual.toString().split('.')[0];
      Position position = await _determinePosition(context);

      // Copia a imagem para o diretório de armazenamento
      final String path =
          (await path_provider.getApplicationDocumentsDirectory()).path;
      Directory(path + '/images/').createSync();
      final String fileName = basename(File(imagePath).path);
      final File newImage =
          await File(imagePath).copy('$path/images/$fileName');

      // Cria o objeto Foto
      Foto foto = Foto(
        id: 0,
        reposicao: reposicao,
        numero: numero,
        dataf: dataFormatada,
        urlPath: newImage.path,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
        relogio1: relogio1,
        relogio2: relogio2,
        saida: saida,
        enviado: 0,
        valorteste: valorteste,
        quantidade_equipamento: quantidadeEquipamento,
      );

      // Salva a foto no banco de dados
      Database db = await getDb();
      FotoModel fotoModel = FotoModel();
      await fotoModel.inserirFoto(db, foto);

      // Tenta enviar a foto para a API
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          List<Foto> listaFotos = await fotoModel.todasFotosPendentes(db);
          await utils.enviarFotos(context, listaFotos, fotoModel, db);
        }
      } on SocketException catch (_) {
        // Caso não tenha conexão, exibe um aviso
        utils.dialogPadraoCpl(
          context,
          titulo: 'Atenção',
          conteudo:
              'Não foi possível conectar-se ao servidor. A foto será enviada posteriormente.',
          textoSim: 'Ok',
          acaoSim: () {},
          textoNao: '',
          acaoNao: () {},
        );
      }

      // Fecha o diálogo de carregamento
      Navigator.of(context, rootNavigator: true).pop();

      // Redireciona para a tela de lista de fotos
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TelaInicial()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Fecha o diálogo de carregamento em caso de erro
      Navigator.of(context, rootNavigator: true).pop();
      utils.dialogPadraoCpl(
        context,
        titulo: 'Erro',
        conteudo: 'Ocorreu um erro ao salvar a foto: $e',
        textoSim: 'Ok',
        acaoSim: () {},
        textoNao: '',
        acaoNao: () {},
      );
    }
  }

//Acho que tem que ser aqui o _buildResultadoCalculos, mas não sei onde
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarPadraoCpl(context, 'Foto tirada'),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        color: utils.cplColorBlue,
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.file(File(widget.imagePath), width: 200),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VisualizarFoto(imagePath: widget.imagePath),
                      ),
                    );
                  },
                  child: Icon(Icons.zoom_in, color: utils.cplColor, size: 30),
                ),
                _buildCampoComTitulo(
                  titulo: 'Número',
                  valorAntigo: null,
                  controller: numeroController,
                  hintText: 'Digite o número',
                ),
                if (cliente != null && cliente!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Text(
                          'Cliente:',
                          style: TextStyle(
                            color: Colors.white, // Cor do rótulo
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5), // Espaço entre "Cliente:" e o nome
                        Expanded(
                          child: Text(
                            cliente!,
                            style: TextStyle(
                              color: Colors.amber, // Cor do nome do cliente
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Trunca o texto se for muito longo
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                    height: 20), // Espaço entre o cliente e o próximo campo

                _buildCampoComTitulo(
                  titulo: 'Reposição',
                  valorAntigo: null,
                  controller: reposicaoController,
                  hintText: 'Digite a reposição',
                ),
                _buildCampoComTitulo(
                  titulo: 'Relógio Entrada 1',
                  valorAntigo: relogio1Antigo?.toString(),
                  controller: relogio1Controller,
                  hintText: 'Entrada 1',
                ),
                _buildCampoComTitulo(
                  titulo: 'Relógio Entrada 2',
                  valorAntigo: relogio2Antigo?.toString(),
                  controller: relogio2Controller,
                  hintText: 'Entrada 2',
                ),
                _buildCampoComTitulo(
                  titulo: 'Relógio Saída',
                  valorAntigo: saidaAntiga?.toString(),
                  controller: saidaController,
                  hintText: 'Saída',
                ),
                _buildCampoComTitulo(
                  titulo: 'Valor Teste',
                  valorAntigo: valorJogadaAntigo?.toString(),
                  controller: valortesteController,
                  hintText: 'Valor de teste',
                ),
                _buildCampoComTitulo(
                  titulo: 'Qtd Produtos',
                  valorAntigo: quantidadeEquipamentoController.text,
                  controller: quantidadeEquipamentoController,
                  hintText: 'Qtd produtos',
                ),
                _buildResultadoCalculos(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: utils.cplColorGrey),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    saveFoto(context);
                  },
                  child: Text(
                    'Salvar',
                    style: TextStyle(color: utils.cplColor, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampoComTitulo({
    required String titulo,
    required String? valorAntigo,
    required TextEditingController controller,
    required String hintText,
  }) {
    int? diferenca;
    bool exibirDiferenca = false;

    if (valorAntigo != null && int.tryParse(valorAntigo) != null) {
      final valorAntigoInt = int.parse(valorAntigo);
      final valorAtual = int.tryParse(controller.text) ?? 0;
      diferenca = valorAtual - valorAntigoInt;
      exibirDiferenca = controller.text.isNotEmpty;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              titulo,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (valorAntigo != null)
              Text(
                ' (anterior: $valorAntigo)',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.keyboard, color: Colors.white),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (exibirDiferenca && diferenca != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Diferença: $diferenca',
              style:
                  TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ),
        SizedBox(height: 20),
      ],
    );
  }
}
