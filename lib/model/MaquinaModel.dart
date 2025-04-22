import 'package:sqflite/sqflite.dart';

class MaquinaModel {
  final int numero;
  final int relogio1atual;
  final int relogio2atual;
  final int relogiosaidaatual;
  final double valorjogada;
  final String mensagem;
  final double valorpelucia;

  MaquinaModel({
    required this.numero,
    required this.relogio1atual,
    required this.relogio2atual,
    required this.relogiosaidaatual,
    required this.valorjogada,
    required this.mensagem,
    required this.valorpelucia,
  });

  factory MaquinaModel.fromJson(Map<String, dynamic> json) {
    return MaquinaModel(
      numero: int.tryParse(json['numero'].toString()) ?? 0,
      relogio1atual: int.tryParse(json['relogio1atual'].toString()) ?? 0,
      relogio2atual: int.tryParse(json['relogio2atual'].toString()) ?? 0,
      relogiosaidaatual: int.tryParse(json['relogiosaidaatual'].toString()) ?? 0,
      valorjogada: double.tryParse(json['valorjogada'].toString()) ?? 0.0,
      mensagem: json['mensagem'] ?? '',
      valorpelucia: double.tryParse(json['valorpelucia'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'relogio1atual': relogio1atual,
      'relogio2atual': relogio2atual,
      'relogiosaidaatual': relogiosaidaatual,
      'valorjogada': valorjogada,
      'mensagem': mensagem,
      'valorpelucia': valorpelucia,
    };
  }

  Future<void> insertOrUpdate(Database db) async {
    final existing = await db.query(
      'maquina',
      where: 'numero = ?',
      whereArgs: [numero],
    );

    if (existing.isEmpty) {
      await db.insert('maquina', toMap());
    } else {
      await db.update(
        'maquina',
        toMap(),
        where: 'numero = ?',
        whereArgs: [numero],
      );
    }
  }
}
