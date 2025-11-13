
import 'package:esp32_realtime/esteira.dart';

class Motor {
  final int idmotor;
  final String modelo;
  final bool status;
  final String direcao;
  final Esteira esteira; 

  // Construtor da classe.
  Motor({
    required this.idmotor,
    required this.modelo,
    required this.status,
    required this.direcao,
    required this.esteira,
  });

  // Método estático (factory) fromJson, converte um mapa JSON em um objeto.
  static Motor? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // Bloco try-catch para evitar erros se o JSON tiver um formato inesperado.
    try {
      // Chama o 'fromJson' da classe Esteira para converter o objeto aninhado 'esteira'.
      final Esteira? esteira = Esteira.fromJson(json['esteira']);
      if (esteira == null) return null;

      return Motor(
        idmotor: json['idmotor'] as int,
        modelo: json['modelo'] as String,
        status: json['status'] as bool,
        direcao: json['direcao'] as String,
        esteira: esteira,
      );
    } catch (e) {
      print('Erro ao fazer parse de Motor: $e');
      return null;
    }
  }

  // Método toJson, converte um objeto de volta para um mapa de dados (JSON), como por exemplo, para envio ao Firebase.
  Map<String, dynamic> toJson() => {
    'idmotor' : idmotor,
    'modelo' : modelo,
    'status' : status,
    'direcao' : direcao,
    'esteira' : esteira.toJson(), // Aninha os dados da esteira.
  };
}