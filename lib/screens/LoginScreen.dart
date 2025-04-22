import 'dart:convert';
//import 'dart:io';

import 'package:droid_foto/model/UsuarioModel.dart';
import 'package:droid_foto/model/db.dart';
import 'package:droid_foto/classes/Usuario.dart';
import 'package:droid_foto/screens/TelaInicial.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

/// https://pub.dev/packages/mask_text_input_formatter
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:droid_foto/Utils.dart' as utils;

import '../Utils.dart';
import 'package:droid_foto/globals.dart' as globals;

class LoginScreen extends StatefulWidget {
  /// parametros opcionais da tela de login: cpf e cnpj
  /// parametros obrigatorios da tela de login: camera
  final String cnpj;
  final String cpf;

  const LoginScreen({Key? key, this.cnpj = '', this.cpf = ''})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      _LoginScreenState(cnpj: cnpj, cpf: cpf);
}

class _LoginScreenState extends State<LoginScreen> {
  /// LoginScreenState recebe os 3 parametros
  final String cnpj;
  final String cpf;

  /// Controllers para guardar os valores digitados - https://api.flutter.dev/flutter/widgets/TextEditingController-class.html
  TextEditingController cnpjController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  /// construtor
  _LoginScreenState({required this.cnpj, required this.cpf});

  /// método padrão executado ao iniciar o state da classe
  @override
  void initState() {
    super.initState();

    /// coloca o cnpj e o cpf (não)passados como parametro como valor padrão
    cnpjController = TextEditingController(text: cnpj);
    cpfController = TextEditingController(text: cpf);
  }

  @override
  void dispose() {
    /// executa quando termina a tela
    cnpjController.dispose();
    cpfController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  /// criado campo do cnpj
  Widget _buildCnpjTF() {
    /// Máscara para o cnpj - https://pub.dev/packages/mask_text_input_formatter
    ///final cnpjMaskFormatter = MaskTextInputFormatter(
    ///    mask: 'xx.xxx.xxx/xxxx-xx', filter: {"x": RegExp(r'[0-9]')});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// texto de cima
        const Text('Acesso',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            /// aqui vai a máscara, pode ter mais de uma
            ///inputFormatters: [cnpjMaskFormatter],

            /// aqui vai o controller criado para esse campo
            controller: cnpjController,

            /// teclado somente com números
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(Icons.business, color: Colors.white),

              /// isso é o placeholder
              hintText: 'Digite o codigo de acesso',
            ),
          ),
        )
      ],
    );
  }

  /// cria o campo do cpf
  Widget _buildCpfTF() {
    /// Máscara para o cpf - https://pub.dev/packages/mask_text_input_formatter
    ///final cpfMaskFormatter = MaskTextInputFormatter(
    ///  mask: 'xxx.xxx.xxx-xx', filter: {"x": RegExp(r'[0-9]')});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Texto de cima
        const Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OpenSans',
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
            /// aqui vai a máscara criada para esse campo, pode ser mais de uma
            ///inputFormatters: [cpfMaskFormatter],
            // aqui vai o controller
            controller: cpfController,

            /// teclado somente com números
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.assignment_ind,
                color: Colors.white,
              ),

              /// placeholder do campo
              hintText: 'Digite seu login',
            ),
          ),
        )
      ],
    );
  }

  /// cria o campo da senha
  Widget _buildSenhaTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Senha',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 60.0,
          child: TextFormField(
            /// Controller criado para esse campo
            controller: senhaController,
            obscureText: true,

            /// tipo do teclado a ser mostrado
            keyboardType: TextInputType.visiblePassword,
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
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.only(top: 14.0),
              prefixIcon: const Icon(
                Icons.lock,
                color: Colors.white,
              ),

              /// placeholder do campo
              hintText: 'Digite sua senha',
            ),
          ),
        )
      ],
    );
  }

  void postLoginUser(
      String cnpj, String cpf, String senha, BuildContext context) async {
    /// abre dialogo carregamento
    utils.showLoaderDialog(context, texto: 'Entrando...');

    /// Aqui precisa do context porque pra redirecionar para a tela inicial caso o
    /// login seja feito com sucesso
    try {
      /// inicia a request pro login passando os dados digitados
      /*String username = 'gerenciador';
      String password = 'g1e22022';
      String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));*/

      ///print(basicAuth);
      final http.Response response = await http.post(
        Uri.parse(utils.systemBaseConfigs['api_url'] +
            '?m=cobranca_imagem&a=getusuario'),
        headers: <String, String>{
          'authorization': utils.systemBaseConfigs['basicAuth']
        },
        /* headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          "Authorization": basicAuth
        },*/
        body: {'login': cpf, 'acesso': cnpj, 'senha': senha},
      );

      /// pega o body
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['sucesso'] == true) {
        // cria um Usuario com o body response
        Usuario usuarioLogando = Usuario(
            id: 0,
            cpf: cpf,
            cnpj: cnpj,
            nome: responseData['id']['nome'],
            senha: senha,
            logged: 1);

        /// se retornar que o usuário pode logar
        if (usuarioLogando.logged == 1) {
          // instancia o model e o banco de dados
          UsuarioModel usuarioModel = UsuarioModel();
          Database db = await getDb();
          // desloga todos os usuario para ter certeza que só um vai ter logged = 1
          usuarioModel.deslogarUsuarios(db);
          // busca no banco de dados o usuario que está tentando fazer login
          Usuario usuarioLogandoDatabase =
              await usuarioModel.getUsuarioCpfCnpj(db, usuarioLogando);
          // se esse cpf e cnpj não existem juntos no banco retorna o id = 0
          if (usuarioLogandoDatabase.id == 0) {
            // insere se não existe no banco
            usuarioModel.inserirUsuario(db, usuarioLogando);
          } else {
            // se existe atualiza o logged = 1 e o nome = nome que veio da api
            usuarioLogandoDatabase.logged = usuarioLogando.logged;
            usuarioLogandoDatabase.nome = usuarioLogando.nome;
            // atualiza no banco
            usuarioModel.atualizarUsuario(db, usuarioLogandoDatabase);
          }

          /// fecha dialogo carregamento
          Navigator.of(context, rootNavigator: true).pop();

          /// redireciona para a tela inicial
          /// Rediciona para tela de login sem deixar voltar para a tela que estava no troca usuario
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => TelaInicial()),
            (Route<dynamic> route) => false,
          );
        } else {
          /// fecha dialogo carregamento
          Navigator.of(context, rootNavigator: true).pop();

          /// erro padrão
          dialogPadraoCpl(
            context,
            textoNao: '',
            acaoNao: () {},
            acaoSim: () {},
            textoSim: 'Ok',
            titulo: 'Atenção',
            conteudo: 'CPF, CNPJ ou senha incorretos',
          );
        }
      } else {
        /// fecha dialogo carregamento
        Navigator.of(context, rootNavigator: true).pop();

        /// erro padrão
        dialogPadraoCpl(
          context,
          textoNao: '',
          acaoNao: () {},
          acaoSim: () {},
          textoSim: 'Ok',
          titulo: 'Atenção',
          conteudo: 'Dados informados incorretos',
        );
      }
    } catch (e) {
      /// fecha dialogo carregamento
      Navigator.of(context, rootNavigator: true).pop();

      /// erro geral
      dialogPadraoCpl(
        context,
        textoNao: '',
        acaoNao: () {},
        acaoSim: () {},
        textoSim: 'Ok',
        titulo: 'Atenção',
        conteudo: 'Erro ao tentar efetuar login!',
      );
    }
  }

  /// cria o botão de login
  Widget _buildLoginButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: utils.cplColorGrey),
        onPressed: () {
          /// controller.text para pegar o valor digitado
          postLoginUser(cnpjController.text, cpfController.text,
              senhaController.text, context);
        },
        child: Text(
          'Entrar',
          style: TextStyle(color: utils.cplColor, fontSize: 25),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: utils.cplColor,
              ),
            ),
            SizedBox(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 120.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sistema de Cobrança',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'OpenSans',
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    _buildCnpjTF(),
                    _buildCpfTF(),
                    _buildSenhaTF(),
                    _buildLoginButton(context),
                    const Center(
                      child: Image(
                        /// imagem da logo da cpl, setado em pubspec.yaml na parte assets:
                        image: AssetImage('images/cpl_icon.png'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}