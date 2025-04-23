// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:droid_foto/Utils.dart' as utils;
import 'package:droid_foto/model/FotoModel.dart';
import 'package:droid_foto/model/db.dart';
import 'package:droid_foto/classes/Foto.dart';
import 'package:droid_foto/screens/VisualizarFoto.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    numeroController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 900), () {
        if (mounted) {
          _buscarMaquina(context);
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

  void _buscarMaquina(BuildContext context) async {
    final numero = int.tryParse(numeroController.text);
    if (numero != null) {
      final db = await getDb();
      final result = await db.query('maquina', where: 'numero = ?', whereArgs: [numero]);

      if (result.isNotEmpty) {
        final data = result.first;
        setState(() {
          relogio1Antigo = data['relogio1atual'] as int?;
          relogio2Antigo = data['relogio2atual'] as int?;
          saidaAntiga = data['relogiosaidaatual'] as int?;
          valorJogadaAntigo = (data['valorjogada'] as num?)?.toDouble();
          valorPeluciaAntigo = (data['valorpelucia'] as num?)?.toDouble();
          mensagemAntiga = data['mensagem'] as String?;
        });

        if (mensagemAntiga != null && mensagemAntiga!.isNotEmpty) {
          utils.dialogPadraoCpl(
            context,
            titulo: 'Mensagem da Máquina',
            conteudo: mensagemAntiga!,
            textoSim: 'Ok',
            acaoSim: () {},
            textoNao: '',
            acaoNao: () {},
          );
        }
      } else {
        utils.dialogPadraoCpl(
          context,
          titulo: 'Atenção',
          conteudo: 'Máquina não cadastrada. Deseja continuar?',
          textoSim: 'Sim',
          acaoSim: () {},
          textoNao: 'Não',
          acaoNao: () {},
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
    final jogadasPorPelucia = diferencaSaida > 0 ? (totalEntrada / diferencaSaida).toStringAsFixed(2) : '0';
    final mediaSaida = diferencaSaida > 0 ? ((totalEntrada * pelucia) / diferencaSaida).toStringAsFixed(2) : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Soma das diferenças dos relógios de entrada: $totalEntrada', style: TextStyle(color: Colors.white)),
        SizedBox(height: 5),
        Text('Jogadas por pelúcia: $jogadasPorPelucia', style: TextStyle(color: Colors.white)),
        SizedBox(height: 5),
        Text('Média de saída: $mediaSaida', style: TextStyle(color: Colors.white)),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.appBarPadraoCpl(context, 'Foto tirada'),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        color: utils.cplColorBlue,
        child: Form(
          child: Center(
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
                          builder: (context) => VisualizarFoto(imagePath: widget.imagePath),
                        ),
                      );
                    },
                    child: Icon(Icons.zoom_in, color: utils.cplColor, size: 30),
                  ),
                  _buildCampoComTitulo(titulo: 'Número', valorAntigo: null, controller: numeroController, hintText: 'Digite o número'),
                  _buildCampoComTitulo(titulo: 'Reposição', valorAntigo: null, controller: reposicaoController, hintText: 'Digite a reposição'),
                  _buildCampoComTitulo(titulo: 'Relógio Entrada 1', valorAntigo: relogio1Antigo?.toString(), controller: relogio1Controller, hintText: 'Entrada 1'),
                  _buildCampoComTitulo(titulo: 'Relógio Entrada 2', valorAntigo: relogio2Antigo?.toString(), controller: relogio2Controller, hintText: 'Entrada 2'),
                  _buildCampoComTitulo(titulo: 'Relógio Saída', valorAntigo: saidaAntiga?.toString(), controller: saidaController, hintText: 'Saída'),
                  _buildCampoComTitulo(titulo: 'Valor Teste', valorAntigo: valorJogadaAntigo?.toString(), controller: valortesteController, hintText: 'Valor de teste'),
                  _buildCampoComTitulo(titulo: 'Qtd Produtos', valorAntigo: quantidadeEquipamentoController.text, controller: quantidadeEquipamentoController, hintText: 'Qtd produtos'),

                  // CÁLCULOS EXTRAS AQUI 👇
                  _buildResultadoCalculos(),

                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: utils.cplColorGrey),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _validarCampos(context);
                      utils.dialogPadraoCpl(
                        context,
                        titulo: 'Atenção',
                        conteudo: 'Tem certeza que deseja gravar a foto?',
                        textoSim: 'Sim',
                        acaoSim: () {
                          // salvar lógica aqui
                        },
                        textoNao: 'Não',
                        acaoNao: () {},
                      );
                    },
                    child: Text('Salvar', style: TextStyle(color: utils.cplColor, fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validarCampos(BuildContext context) {
    final relogio1Atual = int.tryParse(relogio1Controller.text) ?? 0;
    final relogio2Atual = int.tryParse(relogio2Controller.text) ?? 0;

    if (relogio1Antigo != null && relogio1Atual <= relogio1Antigo!) {
      utils.dialogPadraoCpl(
        context,
        titulo: 'Erro',
        conteudo: 'O valor do Relógio Entrada 1 deve ser maior que o anterior.',
        textoSim: 'Ok',
        acaoSim: () {},
        textoNao: '',
        acaoNao: () {},
      );
      return;
    }

    if (relogio2Antigo != null && relogio2Atual <= relogio2Antigo!) {
      utils.dialogPadraoCpl(
        context,
        titulo: 'Erro',
        conteudo: 'O valor do Relógio Entrada 2 deve ser maior que o anterior.',
        textoSim: 'Ok',
        acaoSim: () {},
        textoNao: '',
        acaoNao: () {},
      );
      return;
    }
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
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
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ),
        SizedBox(height: 20),
      ],
    );
  }
}
