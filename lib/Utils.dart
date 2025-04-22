import 'dart:convert';
import 'dart:io';

import 'package:droid_foto/classes/Usuario.dart';
import 'package:droid_foto/model/UsuarioModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'classes/Foto.dart';
import 'model/FotoModel.dart';

import 'classes/Reposicao.dart';
import 'model/ReposicaoModel.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Configurações base do app
const Map<String, dynamic> systemBaseConfigs = {
  // api da url
  //'api_url':   'http://192.168.1.168/Projetos/brmachine/gerenciadornovo_us/api/indexapi.php',
  'api_url': 'https://brmachinepag.com.br/gerenciadornovo/api/indexapi.php',
  'basicAuth': 'Basic Z2VyZW5jaWFkb3I6ZzFlMjIwMjI=',
};

/// Cores usadas no app
int cplColorInt = 0xFF2D3F4A;
Color cplColor = Color(cplColorInt);

int cplColorIntBlue = 0xFF1A4C63;
Color cplColorBlue = Color(cplColorIntBlue);

int cplColorIntGrey = 0xFF9AAEBB;
Color cplColorGrey = Color(cplColorIntGrey);

/// Tema base do app
ThemeData cplTheme = ThemeData(
  brightness: Brightness.dark,
  backgroundColor: cplColor,
  primaryTextTheme: TextTheme(
    headline6: TextStyle(
      color: cplColor,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        Colors.white,
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    iconTheme: const IconThemeData(color: Colors.white, size: 25),
    backgroundColor: cplColor,
  ),
);

/// App bar padrão
appBarPadraoCpl(BuildContext context, String title,
    {List<Widget> actions = const []}) {
  return AppBar(
    title: Text(title),
    backgroundColor: cplColor,
    actions: actions,
  );
}

/// dialogo padrão
/*
  Exemplos: Dialogo só com botão Ok, titulo e mensagem
  dialogPadrapCpl(
    context,{
      titulo: 'Título',
      conteudo: 'Conteúdo',
      acaoNao: (){},
      acaoSim: (){},
      textoSim: 'Ok'
      textoNao: ''
      }
    )

 */
dialogPadraoCpl(BuildContext context,
    {titulo = const Text(''),
    conteudo = const Text(''),
    required acaoNao,
    required acaoSim,
    textoSim = 'Sim',
    textoNao = 'Não'}) {
  /// showDialog do flutter - https://api.flutter.dev/flutter/material/showDialog.html
  showDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(titulo),
      content: Text(conteudo),
      backgroundColor: cplColor,
      titleTextStyle: const TextStyle(color: Colors.white),
      contentTextStyle: const TextStyle(color: Colors.white),
      actions: <Widget>[
        TextButton(
          key: const Key('btnNao'),
          onPressed: () async {
            //acaoNao();
            Navigator.of(context).pop('N');
          },
          child: Text(textoNao, style: const TextStyle(color: Colors.white)),
        ),
        TextButton(
          key: const Key('btnSim'),
          onPressed: () async {
            //acaoSim();
            Navigator.of(context).pop('S');
          },
          child: Text(textoSim, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  ).then((value) {
    if (value == null) return;

    if (value == 'S') {
      acaoSim();
    } else if (value == 'N') {
      acaoNao();
    }
  });
}

/// Enviar dados para a api
enviarFotos(BuildContext context, List<Foto> listaFotos, FotoModel fotoModel,
    Database db) async {
  try {
    ///Inicializa o model
    UsuarioModel usuarioModel = UsuarioModel();

    ///Pega o usuário logado
    Usuario usuarioLogado = await usuarioModel.getUsuarioLogado(db);
    for (Foto foto in listaFotos) {
      File arquivoFisico = File(foto.urlPath);
      if (arquivoFisico.existsSync() == true) {
        /// para cada foto da lista de fotos gera uma nova request
        Uri uri = Uri.parse(systemBaseConfigs['api_url'] +
            '?m=cobranca_imagem&a=execCobrancaImagem');

        /// coloca a request como psot
        http.MultipartRequest request = http.MultipartRequest('POST', uri);
        request.headers['authorization'] = systemBaseConfigs['basicAuth'];

        /// inclui o usuario na request
        request.fields['login'] = usuarioLogado.cpf;
        request.fields['senha'] = usuarioLogado.senha;
        request.fields['acesso'] = usuarioLogado.cnpj;
        //request.fields['usuario'] = jsonEncode(usuarioLogado);
        /// os dados da imagem
        request.fields['img_data'] = jsonEncode(foto);

        /// inclui a imagem enquanto blob na request
        List<String> fileName = foto.urlPath.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
              fileName[(fileName.length - 1)], foto.urlPath,
              filename: fileName[(fileName.length - 1)]),
        );

        /// envia a request

        StreamedResponse responseData =
            await request.send().timeout(const Duration(seconds: 20));
        var resposta2 = await responseData.stream.bytesToString();
        var resposta = jsonDecode(resposta2);
        /*await responseData.stream.transform(utf8.decoder).listen((value) {
          // print(value);
          resposta = jsonEncode(value);
        });*/
        //print(resposta);

        /// se retornar 200 então deleta a foto do banco sqlite
        ///
        if (resposta['sucesso'] == true) {
          if (responseData.statusCode == 200) {
            fotoModel.setFotoEnviada(db, foto.id);
            //fotoModel.deletarFoto(db, foto.id);
          }

          /// exclui a foto fisica
          //arquivoFisico.delete();
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          dialogPadraoCpl(
            context,
            acaoNao: () {},
            acaoSim: () {},
            textoNao: '',
            textoSim: 'Ok',
            titulo: 'Atenção',
            conteudo: 'Erro.' + resposta['sucesso'],
          );
          throw ('Erro ao enviar foto(s), Parando execução.');
        }
      }
    }
  } catch (e) {
    // qualquer erro mostra essa mensagem
    Navigator.of(context, rootNavigator: true).pop();
    dialogPadraoCpl(
      context,
      acaoNao: () {},
      acaoSim: () {},
      textoNao: '',
      textoSim: 'Ok',
      titulo: 'Atenção',
      conteudo: 'Erro grave ao enviar foto(s), parando execução.',
    );
  }
}

enviarReposicao(BuildContext context, List<Reposicao> listaReposicao, ReposicaoModel reposicaoModel,
    Database db) async {
  try {
    ///Inicializa o model
    UsuarioModel usuarioModel = UsuarioModel();

    ///Pega o usuário logado
    Usuario usuarioLogado = await usuarioModel.getUsuarioLogado(db);
    for (Reposicao reposicao in listaReposicao) {
        /// para cada foto da lista de fotos gera uma nova request
        Uri uri = Uri.parse(systemBaseConfigs['api_url'] +
            '?m=cobranca_imagem&a=execReposicaoImagem');

        /// coloca a request como psot
        http.MultipartRequest request = http.MultipartRequest('POST', uri);
        request.headers['authorization'] = systemBaseConfigs['basicAuth'];

        /// inclui o usuario na request
        request.fields['login'] = usuarioLogado.cpf;
        request.fields['senha'] = usuarioLogado.senha;
        request.fields['acesso'] = usuarioLogado.cnpj;
        //request.fields['usuario'] = jsonEncode(usuarioLogado);
        /// os dados da imagem
        request.fields['img_data'] = jsonEncode(reposicao);

        /// inclui a imagem enquanto blob na request
        /*List<String> fileName = foto.urlPath.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
              fileName[(fileName.length - 1)], foto.urlPath,
              filename: fileName[(fileName.length - 1)]),
        );*/

        /// envia a request

        StreamedResponse responseData =  await request.send().timeout(const Duration(seconds: 20));
        var resposta2 = await responseData.stream.bytesToString();
        var resposta = jsonDecode(resposta2);
        /*await responseData.stream.transform(utf8.decoder).listen((value) {
          // print(value);
          resposta = jsonEncode(value);
        });*/
        //print(resposta);

        /// se retornar 200 então deleta a foto do banco sqlite
        ///
        if (resposta['sucesso'] == true) {
          if (responseData.statusCode == 200) {
            reposicaoModel.setReposicaoEnviada(db, reposicao.id);
          }

          /// exclui a foto fisica
          //arquivoFisico.delete();
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          dialogPadraoCpl(
            context,
            acaoNao: () {},
            acaoSim: () {},
            textoNao: '',
            textoSim: 'Ok',
            titulo: 'Atenção',
            conteudo: 'Erro.' + resposta['sucesso'],
          );
          throw ('Erro ao enviar as reposições(s), Parando execução.');
        }
      
    }
  } catch (e) {
    // qualquer erro mostra essa mensagem
    Navigator.of(context, rootNavigator: true).pop();
    dialogPadraoCpl(
      context,
      acaoNao: () {},
      acaoSim: () {},
      textoNao: '',
      textoSim: 'Ok',
      titulo: 'Atenção',
      conteudo: 'Erro grave ao enviar reposições(s), parando execução.',
    );
  }
}

/// para fechar use
/// Navigator.of(context, rootNavigator: true).pop();
showLoaderDialog(BuildContext context, {required String texto}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: cplColorBlue,
          content: Container(
            color: cplColorBlue,
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                Container(
                  margin: const EdgeInsets.fromLTRB(5, 3, 3, 3),
                  child: Text(
                    texto,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

generatePdf(List<Foto> fotos) async {
  final pdf = pw.Document();

  /// para cada foto uma pagina
  for (Foto foto in fotos) {
    /// formata data
    DateTime dataTemp = DateTime.parse(foto.dataf);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm:ss');

    /// imagem
    pw.MemoryImage image = pw.MemoryImage(
      File(foto.urlPath).readAsBytesSync(),
    );

    /// add page
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Text('Reposição: ' +
                    foto.reposicao.toString() +
                    ' - Número:' +
                    foto.numero.toString()),
                pw.Text('Data: ' + formatter.format(dataTemp)),
                pw.Image(image, width: 400),
              ],
            ),
          );
        },
      ),
    ); //
  }

  final String path = (await getApplicationDocumentsDirectory()).path;
  Directory(path + '/images/').createSync();

  final file = File('$path/images/cpl_imagens.pdf');

  //print('$path/images/cpl_imagens.pdf');

  await file.writeAsBytes(await pdf.save());

  Share.shareFiles(['$path/images/cpl_imagens.pdf'], text: 'Imagens CPL');
}
