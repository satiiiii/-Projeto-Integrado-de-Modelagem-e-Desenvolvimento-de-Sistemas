import 'package:esp32_realtime/motor.dart';
import 'package:esp32_realtime/usuario.dart';

class Comando {
  final int idcomando;
  final DateTime data;
  final String origem;
  final Motor motor;
  final Usuario usuario;
  final String? acao; // 'acao':'girar' instrução de controle do motor para o ESP32 

  // Construtor da classe.
  Comando({
    required this.idcomando,
    required this.data,
    required this.origem,
    required this.motor,
    required this.usuario,
    this.acao 
  });

  // Método estático (factory) fromJson, converte um mapa JSON em um objeto.
  static Comando? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // Bloco try-catch para evitar erros se o JSON tiver um formato inesperado.
    try {
      // Chama o 'fromJson' da classe Motor e Usuario para converter o objeto aninhado 'motor' e 'usuario'.
      final Motor? motor = Motor.fromJson(json['motor']);
      final Usuario? usuario = Usuario.fromJson(json['usuario']);
      if (motor == null || usuario == null) return null;

      return Comando(
        idcomando: json['idcomando'],
        data: DateTime.parse(json['data']),
        origem: json['origem'],
        motor: motor,
        usuario: usuario,
        acao: json['acao'] as String? // Lê 'acao' se existir, senão será null
      );
    } catch (e) { 
      print('❌ Erro parse Comando: $e'); 
      return null; 
    }
  }

  // Método toJson, converte um objeto de volta para um mapa de dados (JSON), como por exemplo, para envio ao Firebase.
  Map<String, dynamic> toJson() => {
    'idcomando': idcomando,
    'data': data.toIso8601String(),
    'origem': origem,
    'motor': motor.toJson(),
    'usuario': usuario.toJson(),
    if (acao != null) 'acao': acao // Só inclui se 'acao' tiver valor
  };
}