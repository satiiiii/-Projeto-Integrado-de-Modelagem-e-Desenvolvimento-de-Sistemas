class Usuario {
  final int idusuario;
  final String nome;
  final String login;
  final String perfil;
  final String senha;

  // Construtor da classe.
  Usuario({
    required this.idusuario,
    required this.nome,
    required this.login,
    required this.perfil,
    required this.senha,
  });

  // Método estático (factory) fromJson, converte um mapa JSON em um objeto.
  static Usuario? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // Bloco try-catch para evitar erros se o JSON tiver um formato inesperado.
    try {
      return Usuario(
        idusuario: json['idusuario'],
        nome: json['nome'],
        login: json['login'],
        perfil: json['perfil'],
        senha: json['senha'],
      );
    } catch (e) {
      print('Erro ao fazer parse de Usuário: $e');
      return null;
    }
  }

  // Método toJson, converte um objeto de volta para um mapa de dados (JSON), como por exemplo, para envio ao Firebase.
  Map<String, dynamic> toJson() => {
    'idusuarior' : idusuario,
    'nome' : nome,
    'login' : login,
    'perfil' : perfil,
    'senha' : senha,
  };
}