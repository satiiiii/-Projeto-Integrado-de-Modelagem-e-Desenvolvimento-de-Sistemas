import 'package:esp32_realtime/setor.dart';

class Esteira{
  final int idesteira;
  final String nome;
  final bool status;
  final Setor setor;

  // Construtor da classe.
  Esteira({
    required this.idesteira,
    required this.nome, 
    required this.status,
    required this.setor,
  });

  // Método estático (factory) fromJson, converte um mapa JSON em um objeto.
  static Esteira? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // Bloco try-catch para evitar erros se o JSON tiver um formato inesperado.
    try {
      // Chama o 'fromJson' da classe Setor para converter o objeto aninhado 'setor'.
      final Setor? setor = Setor.fromJson(json['setor']);
      if (setor == null) return null;

      return Esteira(
        idesteira: json['idesteira'],
        nome: json['nome'],
        status: json['status'],
        setor: setor, // Atribui o objeto Setor já convertido.
      );
    } catch (e) {
      print('Erro ao fazer parse de Esteira: $e');
      return null;
    }
  }

  // Método toJson, converte um objeto de volta para um mapa de dados (JSON), como por exemplo, para envio ao Firebase.
  Map<String, dynamic> toJson() => {
    'idesteira' : idesteira,
    'nome' : nome,
    'status' : status,
    'setor' : setor.toJson(), // Aninha os dados do setor.
  };
}