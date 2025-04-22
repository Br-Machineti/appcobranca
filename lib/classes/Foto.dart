class Foto {
  final int id;
  int reposicao;
  int numero;
  int relogio1;
  int relogio2;
  int saida;
  int enviado;
  int valorteste;
  int quantidade_equipamento;

  /// dataf é string porque o sqlite não tem tipo date
  String dataf;
  String latitude;
  String longitude;
  String urlPath;

  Foto({
    required this.id,
    required this.reposicao,
    required this.numero,
    required this.dataf,
    required this.latitude,
    required this.longitude,
    required this.urlPath,
    required this.relogio1,
    required this.relogio2,
    required this.saida,
    required this.enviado,
    required this.valorteste,
    required this.quantidade_equipamento,
  });

  @override
  String toString() {
    return 'Foto{id: $id, reposicao: $reposicao, numero: $numero, dataf: $dataf, latitude: $latitude, longitude: $longitude, urlPath: $urlPath,' +
        ' relogio1: $relogio1, relogio2: relogio2, saida: $saida, enviado: $enviado, valorteste: $valorteste, quantidade_equipamento: $quantidade_equipamento}';
  }

  /// método necessário para o jsonDecode
  Foto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        reposicao = json['reposicao'],
        numero = json['numero'],
        dataf = json['dataf'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        urlPath = json['urlPath'],
        relogio1 = json['relogio1'],
        relogio2 = json['relogio2'],
        saida = json['saida'],
        enviado = json['enviado'],
        valorteste = json['valorteste'],
        quantidade_equipamento = json['quantidade_equipamento'];

  /// método necessário para o jsonEncode
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reposicao': reposicao,
      'numero': numero,
      'dataf': dataf,
      'latitude': latitude,
      'longitude': longitude,
      'urlPath': urlPath,
      'relogio1': relogio1,
      'relogio2': relogio2,
      'saida': saida,
      'enviado': enviado,
      'valorteste': valorteste,
      'quantidade_equipamento': quantidade_equipamento,
    };
  }
}
