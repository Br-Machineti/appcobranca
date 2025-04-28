import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:droid_foto/classes/Foto.dart';

class FotoModel {
  /// retorna todas as fotos
  Future<List<Foto>> todasFotos(Database db) async {
    //final List<Map<String, dynamic>> maps = await db.query('foto');
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM foto order by id desc');

    return List.generate(maps.length, (i) {
      return Foto(
        id: maps[i]['id'],
        reposicao: maps[i]['reposicao'],
        numero: maps[i]['numero'],
        dataf: maps[i]['dataf'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        urlPath: maps[i]['urlPath'],
        relogio1: maps[i]['relogio1'],
        relogio2: maps[i]['relogio2'],
        saida: maps[i]['saida'],
        enviado: maps[i]['enviado'],
        valorteste: maps[i]['valorteste'],
        quantidade_equipamento: maps[i]['quantidade_equipamento'],
      );
    });
  }

  Future<List<Foto>> todasFotosPendentes(Database db) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT id, reposicao, numero, dataf, latitude, longitude, urlPath, relogio1, relogio2, saida, enviado, valorteste, quantidade_equipamento FROM foto WHERE enviado = 0');

    //final List<Map<String, dynamic>> maps = await db.query('foto');

    return List.generate(maps.length, (i) {
      return Foto(
        id: maps[i]['id'],
        reposicao: maps[i]['reposicao'],
        numero: maps[i]['numero'],
        dataf: maps[i]['dataf'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        urlPath: maps[i]['urlPath'],
        relogio1: maps[i]['relogio1'],
        relogio2: maps[i]['relogio2'],
        saida: maps[i]['saida'],
        enviado: maps[i]['enviado'],
        valorteste: maps[i]['valorteste'],
        quantidade_equipamento: maps[i]['quantidade_equipamento'],
      );
    });
  }

  /// retorna a foto com o id especificado, se não existir retorna id = 0
  Future<Foto> getFoto(Database db, int id) async {
    final List<Map<String, dynamic>> foto = await db.rawQuery(
        'SELECT id, reposicao, numero, dataf, latitude, longitude, urlPath, relogio1, relogio2, saida, enviado, valorteste, quantidade_equipamento FROM foto WHERE id = ? LIMIT 1',
        [id]);

    if (foto.isEmpty) {
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
        quantidade_equipamento:0,
      );
    } else {
      return Foto(
        id: foto[0]['id'],
        reposicao: foto[0]['reposicao'],
        numero: foto[0]['numero'],
        dataf: foto[0]['dataf'],
        latitude: foto[0]['latitude'],
        longitude: foto[0]['longitude'],
        urlPath: foto[0]['urlPath'],
        relogio1: foto[0]['relogio1'],
        relogio2: foto[0]['relogio2'],
        saida: foto[0]['saida'],
        enviado: foto[0]['enviado'],
        valorteste: foto[0]['valorteste'],
        quantidade_equipamento:foto[0]['quantidade_equipamento'],
      );
    }
  }

  /// insere a foto passado como parametro
Future<void> inserirFoto(Database db, Foto foto) async {
    await db.rawInsert(
      'INSERT INTO foto (reposicao, numero, dataf, latitude, longitude, urlPath, relogio1, relogio2, saida, enviado, valorteste, quantidade_equipamento) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        foto.reposicao,
        foto.numero,
        foto.dataf,
        foto.latitude,
        foto.longitude,
        foto.urlPath,
        foto.relogio1,
        foto.relogio2,
        foto.saida,
        foto.enviado,
        foto.valorteste,
        foto.quantidade_equipamento
      ],
    );
  }

  /// atualiza a foto passado como parametro
  void atualizarFoto(Database db, Foto foto) async {
    await db.rawUpdate(
        'UPDATE foto SET reposicao = ?, numero = ?, dataf = ?, latitude = ?, longitude = ?, urlPath = ?, relogio1 = ?, relogio2= ?, saida= ?, enviado=?, valoteste=?, quantidade_equipamento=? WHERE id = ?',
        [
          foto.reposicao,
          foto.numero,
          foto.dataf,
          foto.latitude,
          foto.longitude,
          foto.urlPath,
          foto.relogio1,
          foto.relogio2,
          foto.saida,
          foto.enviado,
          foto.valorteste,
          foto.quantidade_equipamento
        ]);
  }

  /// insere a foto do id passado como parametro
  Future<bool> deletarFoto(Database db, int id) async {
    final List<Map<String, dynamic>> fotoBanco = await db.rawQuery(
        'SELECT id, reposicao, numero, dataf, latitude, longitude, urlPath, relogio1, relogio2, saida, enviado, valorteste, quantidade_equipamento FROM foto WHERE id = ? LIMIT 1',
        [id]);
    int i = await db.rawDelete('DELETE FROM foto WHERE id = ?', [id]);

    /// deleta arquivo fisicamente
    if (fotoBanco[0]['urPath'] != null && i > 0) {
      File arquivoFisico = File(fotoBanco[0]['urPath']);
      if (arquivoFisico.existsSync()) {
        arquivoFisico.delete();
      }
    }

    return true;
  }

  /// deleta todas as fotos
  Future<void> deletarTodasFotos(Database db) async {
    List<Foto> fotoLista = await todasFotos(db);
    await db.rawDelete('DELETE FROM foto');

    /// deleta arquivos fisicamente
    for (var foto in fotoLista) {
      File arquivoFisico = File(foto.urlPath);
      if (arquivoFisico.existsSync()) {
        arquivoFisico.delete();
      }
    }
  }

  Future<bool> setFotoEnviada(Database db, int id) async {
    await db.rawUpdate('update foto set enviado=? WHERE id = ?', [1, id]);
    return true;
  }

  Future<bool> setFotoReenviar(Database db, int id) async {
    await db.rawUpdate('update foto set enviado=? WHERE id = ?', [0, id]);
    return true;
  }

  /// pega a foto pela reposicao e pelo numero, se não existir retorna id = 0
  Future<Foto> getFotoreposicaoNumerio(Database db, Foto foto) async {
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
        quantidade_equipamento: 0
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
        quantidade_equipamento: fotoBanco[0]['quantidade_equipamento'],

      );
    }
  }
}
