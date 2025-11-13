import 'package:esp32_realtime/esteira.dart';

class Sensor {
  final int idsensor;
  final String tipo;
  final bool status;
  final String unidade;
  final Esteira esteira;

  // Construtor da classe.
  Sensor({
    required this.idsensor,
    required this.tipo,
    required this.status,
    required this.unidade,
    required this.esteira,

  });

  // Método estático (factory) fromJson, converte um mapa JSON em um objeto.
  static Sensor? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // Bloco try-catch para evitar erros se o JSON tiver um formato inesperado.
    try {
      // Chama o 'fromJson' da classe Esteira para converter o objeto aninhado 'esteira'.
      final Esteira? esteira = Esteira.fromJson(json['esteira']);
      if (esteira == null) return null;

      return Sensor(
        idsensor: json['idsensor'],
        tipo: json['tipo'],
        status: json['status'],
        unidade: json['unidade'],
        esteira: esteira,
      );
    } catch (e) {
      print('Erro ao fazer parse de Sensor: $e');
      return null;
    }
  }

  // Método toJson, converte um objeto de volta para um mapa de dados (JSON), como por exemplo, para envio ao Firebase.
  Map<String, dynamic> toJson() => {
    'idsensor' : idsensor,
    'tipo' : tipo,
    'status' : status,
    'unidade' : unidade,
    'esteira' : esteira.toJson(), // Aninha os dados da esteira.
  };
}