class Empresa{
  final int idempresa;
  final String nome;
  final String cnpj;
  final String endereco;
  final String website;
  final String email;

  // Construtor da classe.
  Empresa({
    required this.idempresa,
    required this.nome, 
    required this.cnpj,
    required this.endereco,
    required this.website,
    required this.email,
  });

  // Método estático (factory) fromJson, converte um mapa JSON em um objeto.
  static Empresa? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // Bloco try-catch para evitar erros se o JSON tiver um formato inesperado.
    try {
      return Empresa(
        idempresa: json['idempresa'],
        nome: json['nome'],
        cnpj: json['cnpj'],
        endereco: json['endereco'],
        website: json['website'],
        email: json['email'],
      );
    } catch (e) {
      print('Erro ao fazer parse de Empresa: $e');
      return null;
    }
  }

  // Método toJson, converte um objeto de volta para um mapa de dados (JSON), como por exemplo, para envio ao Firebase.
  Map<String, dynamic> toJson() => {
    'idempresa' : idempresa,
    'nome' : nome,
    'cnpj' : cnpj,
    'endereco' : endereco,
    'website' : website,
    'email' : email,
  };
}