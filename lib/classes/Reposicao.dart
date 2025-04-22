class Reposicao {
  final int id;
  int quantidade;
  int numero;
  int enviado;

  /// dataf é string porque o sqlite não tem tipo date
  String datai;
  //String latitude;
  //String longitude;
  //String urlPath;

  Reposicao({
    required this.id,
    required this.quantidade,
    required this.numero,
    required this.datai,
    required this.enviado,
  });

  @override
  String toString() {
    return 'Reposicao{id: $id, quantidade: $quantidade, numero: $numero, datai: $datai, enviado: $enviado}';
  }

  /// método necessário para o jsonDecode
  Reposicao.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        quantidade = json['quantidade'],
        numero = json['numero'],
        datai = json['datai'],
        enviado = json['enviado'];

  /// método necessário para o jsonEncode
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantidade': quantidade,
      'numero': numero,
      'datai': datai,
      'enviado': enviado,
    };
  }
}
