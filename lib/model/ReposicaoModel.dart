import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:droid_foto/classes/Reposicao.dart';

class ReposicaoModel {
  /// retorna todas as fotos
  Future<List<Reposicao>> todasReposicao(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query('reposicao');

    return List.generate(maps.length, (i) {
      return Reposicao(
        id: maps[i]['id'],
        quantidade: maps[i]['quantidade'],
        numero: maps[i]['numero'],
        datai: maps[i]['datai'],
        enviado: maps[i]['enviado']
      );
    });
  }

  Future<List<Reposicao>> todasReposicaoPendentes(Database db) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT id, quantidade, numero, datai, enviado FROM reposicao WHERE enviado = 0');

    //final List<Map<String, dynamic>> maps = await db.query('foto');

    return List.generate(maps.length, (i) {
      return Reposicao(
        id: maps[i]['id'],
        quantidade: maps[i]['quantidade'],
        numero: maps[i]['numero'],
        datai: maps[i]['datai'],
        enviado: maps[i]['enviado']
      );
    });
  }

  /// retorna a foto com o id especificado, se não existir retorna id = 0
  Future<Reposicao> getReposicao(Database db, int id) async {
    final List<Map<String, dynamic>> reposicao = await db.rawQuery(
        'SELECT id, quantidade, numero, datai, enviado FROM reposicao WHERE id = ? LIMIT 1',
        [id]);

    if (reposicao.isEmpty) {
      return Reposicao(
        id: 0,
        quantidade: 0,
        numero: 0,
        datai: '',
        enviado: 0,
      );
    } else {
      return Reposicao(
        id: reposicao[0]['id'],
        quantidade: reposicao[0]['quantidade'],
        numero: reposicao[0]['numero'],
        datai: reposicao[0]['datai'],
        enviado: reposicao[0]['enviado'],
      );
    }
  }

  /// insere a foto passado como parametro
  void inserirReposicao(Database db, Reposicao reposicao) async {
    await db.rawInsert(
      'INSERT INTO reposicao (quantidade, numero, datai, enviado) VALUES (?, ?, ?, ?)',
      [
        reposicao.quantidade,
        reposicao.numero,
        reposicao.datai,
        reposicao.enviado,
        
      ],
    );
  }

  /// atualiza a foto passado como parametro
  void atualizarReposicao(Database db, Reposicao reposicao) async {
    await db.rawUpdate(
        'UPDATE reposicao SET reposicao = ?, numero = ?, datai = ?, enviado=? WHERE id = ?',
        [
          reposicao.quantidade,
          reposicao.numero,
          reposicao.datai,
          reposicao.enviado,

        ]);
  }

  /// insere a foto do id passado como parametro
  Future<bool> deletarReposicao(Database db, int id) async {
   /* final List<Map<String, dynamic>> ReposicaoBanco = await db.rawQuery(
        'SELECT id, reposicao, numero, datai, enviado FROM reposicao WHERE id = ? LIMIT 1',
        [id]);*/
     await db.rawDelete('DELETE FROM reposicao WHERE id = ?', [id]);
     return true;
  }

  /// deleta todas as fotos
  Future<void> deletarTodasReposicao(Database db) async {
    //List<Reposicao> fotoLista = await todasReposicao(db);
    await db.rawDelete('DELETE FROM reposicao');

    /// deleta arquivos fisicamente
    /*for (var foto in fotoLista) {
      File arquivoFisico = File(foto.urlPath);
      if (arquivoFisico.existsSync()) {
        arquivoFisico.delete();
      }
    }*/
  }

  Future<bool> setReposicaoEnviada(Database db, int id) async {
    await db.rawUpdate('update reposicao set enviado=? WHERE id = ?', [1, id]);
    return true;
  }

  /// pega a foto pela reposicao e pelo numero, se não existir retorna id = 0
  /*Future<Foto> getFotoreposicaoNumerio(Database db, Foto foto) async {
    final List<Map<String, dynamic>> fotoBanco = await db.rawQuery(
        'SELECT id, reposicao, numero, dataf, latitude, longitude, urlPath, relogio1, relogio2, saida, enviado, valorteste FROM foto WHERE reposicao = ? AND numero = ? LIMIT 1',
        [foto.reposicao, foto.numero]);

    if (fotoBanco.isEmpty) {
      return Foto(
        id: 0,
        reposicao: 0,
        numero: 0,
        dataf: '',
        latitude: '',
        longitude: '',
        urlPath: '',
        relogio1: 0,
        relogio2: 0,
        saida: 0,
        enviado: 0,
        valorteste: 0,
      );
    } else {
      return Foto(
        id: fotoBanco[0]['id'],
        reposicao: fotoBanco[0]['reposicao'],
        numero: fotoBanco[0]['numero'],
        dataf: fotoBanco[0]['dataf'],
        latitude: fotoBanco[0]['latitude'],
        longitude: fotoBanco[0]['longitude'],
        urlPath: fotoBanco[0]['urlPath'],
        relogio1: fotoBanco[0]['relogio1'],
        relogio2: fotoBanco[0]['relogio2'],
        saida: fotoBanco[0]['saida'],
        enviado: fotoBanco[0]['enviado'],
        valorteste: fotoBanco[0]['valorteste'],
      );
    }
  }*/
}
