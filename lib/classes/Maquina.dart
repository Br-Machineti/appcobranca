class Maquina {
  final int numero;
  final int relogio1atual;
  final int relogio2atual;
  final int relogiosaidaatual;
  final double valorjogada;
  final String mensagem;
  final double valorpelucia;

  Maquina({
    required this.numero,
    required this.relogio1atual,
    required this.relogio2atual,
    required this.relogiosaidaatual,
    required this.valorjogada,
    required this.mensagem,
    required this.valorpelucia,
  });

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

  factory Maquina.fromMap(Map<String, dynamic> map) {
    return Maquina(
      numero: map['numero'],
      relogio1atual: map['relogio1atual'],
      relogio2atual: map['relogio2atual'],
      relogiosaidaatual: map['relogiosaidaatual'],
      valorjogada: map['valorjogada'],
      mensagem: map['mensagem'],
      valorpelucia: map['valorpelucia'],
    );
  }
}
