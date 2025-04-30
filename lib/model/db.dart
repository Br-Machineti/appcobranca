import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDb() async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'cpldb.db'),
    onCreate: (db, version) async {
      await db.execute(
        '''CREATE TABLE IF NOT EXISTS foto(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reposicao INTEGER,
            numero INTEGER,
            dataf TEXT,
            urlPath TEXT,
            latitude TEXT,
            longitude TEXT,
            relogio1 INTEGER,
            relogio2 INTEGER,
            saida INTEGER,
            enviado INTEGER,
            valorteste INTEGER,
            quantidade_equipamento INTEGER
        )''',
      );
      await db.execute(
        '''CREATE TABLE IF NOT EXISTS usuario(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cpf TEXT,
            cnpj TEXT,
            nome TEXT,
            senha TEXT,
            logged INTEGER,
            UNIQUE(cpf, cnpj)
        )''',
      );
      await db.execute(
        '''CREATE TABLE IF NOT EXISTS reposicao(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            datai TEXT,
            numero INTEGER,
            quantidade INTEGER,
            enviado INTEGER
        )''',
      );
      //Adicionar o campo cliente.
      await db.execute(
        '''CREATE TABLE IF NOT EXISTS maquina(
            numero INTEGER PRIMARY KEY,
            cliente TEXT,
            relogio1atual INTEGER,
            relogio2atual INTEGER,
            relogiosaidaatual INTEGER,
            valorjogada REAL,
            mensagem TEXT,
            valorpelucia REAL
        )''',
      );
    },
    version: 3,

    // Alterar a tabela existente para adicionar o campo cliente
    // e garantir que o banco de dados seja atualizado corretamente.
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 3) {
        await db.execute('ALTER TABLE maquina ADD COLUMN cliente TEXT');
      }
    },
  );
  return await database;
}
