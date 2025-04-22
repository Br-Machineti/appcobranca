import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:droid_foto/model/maquinaModel.dart';
import 'package:droid_foto/model/db.dart';
import 'package:droid_foto/globals.dart';
import 'package:sqflite/sqflite.dart';

class MaquinaService {
  Future<void> fetchAndSaveMaquinas(BuildContext context) async {
    final uri = Uri.parse(
        'https://brmachinepag.com.br/gerenciadornovo/api/indexapi.php?a=getdadosalocacao&m=cobranca_imagem');

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization':
          'Basic Z2VyZW5jaWFkb3I6ZzFlMjIwMjI=', // Substitua pelo valor correto, se necessário
      'Cookie':
          'PHPSESSID=9lt95d23ng4c0ebo9if23ko0g4', // Substitua pelo valor correto, se necessário
    };

    final body = {
      'login': usuarioLogado.cpf,
      'senha': usuarioLogado.senha,
      'acesso': usuarioLogado.cnpj,
    };

    try {
      print('Iniciando requisição para $uri');
      final response = await http.post(uri, headers: headers, body: body);

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body);
          print('JSON decodificado: $json');

          if (json['sucesso'] == true &&
              json['id'] != null &&
              json['id'] is List) {
            final db = await getDb();
            await db.execute(
                'DELETE FROM maquina'); // Limpa a tabela antes de inserir novos dados

            print('Conteúdo de json["id"]: ${json['id']}');

            for (final item in json['id']) {
              if (item is Map<String, dynamic>) {
                try {
                  final maquina = MaquinaModel.fromJson(item);
                  await maquina.insertOrUpdate(db);
                } catch (e) {
                  print('Erro ao processar item: $item. Erro: $e');
                }
              } else {
                print('Item inválido: $item');
              }
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dados atualizados com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            final msg = json['mensagem'] ?? 'Resposta inválida da API.';
            print(msg);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro: $msg'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          print('Erro ao processar resposta da API: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao processar dados da API.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Erro na resposta da API. Código: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ${response.statusCode} na resposta da API.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao fazer requisição: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão ao buscar dados.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}