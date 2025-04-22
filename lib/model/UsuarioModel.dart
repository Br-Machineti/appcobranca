import 'package:droid_foto/classes/Usuario.dart';
import 'package:sqflite/sqflite.dart';

class UsuarioModel {
  /// retorna todos os usuarios
  Future<List<Usuario>> todosUsuarios(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query('usuario');

    return List.generate(maps.length, (i) {
      return Usuario(
          id: maps[i]['id'],
          cpf: maps[i]['cpf'],
          cnpj: maps[i]['cnpj'],
          nome: maps[i]['nome'],
          senha: maps[i]['senha'],
          logged: maps[i]['logged']);
    });
  }

  /// insere o usuario passado como parametro
  void inserirUsuario(Database db, Usuario user) async {
    await db.rawInsert(
      'INSERT INTO usuario (cpf, cnpj, nome, senha, logged) VALUES (?, ?, ?, ?, ?)',
      [user.cpf, user.cnpj, user.nome, user.senha, user.logged],
    );
  }

  /// atualiza o usuario
  void atualizarUsuario(Database db, Usuario user) async {
    await db.rawUpdate(
        'UPDATE usuario SET cpf = ?, cnpj = ?, nome = ?, logged = ?, senha=? WHERE id = ?',
        [user.cpf, user.cnpj, user.nome, user.logged, user.senha, user.id]);
  }

  /// desloga todos os usuario, porque só pode ter um logado por vez
  void deslogarUsuarios(Database db) async {
    await db.rawUpdate('UPDATE usuario SET logged = ?', [0]);
  }

  /// deleta o usuario
  void deletarUsuario(Database db, Usuario user) async {
    await db.rawDelete('DELETE FROM usuario WHERE id = ?', [user.id]);
  }

  /// retorna o usuario logado, se ninguém estiver logado retorna id = 0
  Future<Usuario> getUsuarioLogado(Database db) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT id, cpf, cnpj, nome, senha, logged FROM usuario WHERE logged = ? LIMIT 1',
        [1]);
    if (maps.isEmpty) {
      return Usuario(id: 0, cpf: '', cnpj: '', nome: '', senha: '', logged: 0);
    } else {
      return Usuario(
          id: maps[0]['id'],
          cpf: maps[0]['cpf'],
          cnpj: maps[0]['cnpj'],
          nome: maps[0]['nome'],
          senha: maps[0]['senha'],
          logged: maps[0]['logged']);
    }
  }

  /// pega o usuario pelo cpf e cnpj
  Future<Usuario> getUsuarioCpfCnpj(Database db, Usuario user) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT id, cpf, cnpj, nome, senha, logged FROM usuario WHERE cpf = ? AND cnpj = ? LIMIT 1',
        [user.cpf, user.cnpj]);
    if (maps.isEmpty) {
      return Usuario(id: 0, cpf: '', cnpj: '', nome: '', senha: '', logged: 0);
    } else {
      return Usuario(
          id: maps[0]['id'],
          cpf: maps[0]['cpf'],
          cnpj: maps[0]['cnpj'],
          nome: maps[0]['nome'],
          senha: maps[0]['senha'],
          logged: maps[0]['logged']);
    }
  }
}
