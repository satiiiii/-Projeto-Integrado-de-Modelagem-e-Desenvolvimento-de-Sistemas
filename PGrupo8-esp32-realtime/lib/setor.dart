import 'package:esp32_realtime/empresa.dart';

class Setor {
  final int idsetor;
  final String nome;
  final String descricao;
  final Empresa empresa;

  // Construtor da classe.
  Setor({
    required this.idsetor,
    required this.nome,
    required this.descricao,
    required this.empresa,
  });

  // Método estático (factory) fromJson, converte um mapa JSON em um objeto.
  static Setor? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // Bloco try-catch para evitar erros se o JSON tiver um formato inesperado.
    try {
      // Chama o 'fromJson' da classe Empresa para converter o objeto aninhado 'empresa'.
      final Empresa? empresa = Empresa.fromJson(json['empresa']);
      // Se a empresa aninhada for inválida, o Setor inteiro é considerado inválido.
      if (empresa == null) return null;

      return Setor(
        idsetor: json['idsetor'],
        nome: json['nome'],
        descricao: json['descricao'],
        empresa: empresa, // Atribui o objeto Empresa já convertido.
      );
    } catch (e) {
      print('Erro ao fazer parse de Setor: $e');
      return null;
    }
  }

  // Método toJson, converte um objeto de volta para um mapa de dados (JSON), como por exemplo, para envio ao Firebase.
  Map<String, dynamic> toJson() => {
    'idsetor' : idsetor,
    'nome' : nome,
    'descricao' : descricao,
    'empresa' : empresa.toJson(), // Aninha os dados da empresa.
  };
}