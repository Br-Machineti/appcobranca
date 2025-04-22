class Usuario {
  final int id;
  String cpf;
  String cnpj;
  String nome;
  String senha;

  /// aqui é int porque não tem tipo bool no
  int logged;

  Usuario(
      {required this.id,
      required this.cpf,
      required this.cnpj,
      required this.nome,
      required this.senha,
      required this.logged});

  @override
  String toString() {
    return 'Usuario{id: $id, cpf: $cpf, cnpj: $cnpj, nome: $nome, senha: $senha, logged: $logged}';
  }

  /// método necessário para o jsonDecode
  Usuario.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        cpf = json['cpf'],
        cnpj = json['cnpj'],
        nome = json['nome'],
        senha = json['senha'],
        logged = json['logged'];

  /// método necessário para o jsonEncode
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cpf': cpf,
      'cnpj': cnpj,
      'nome': nome,
      'senha': senha,
      'logged': logged,
    };
  }
}
