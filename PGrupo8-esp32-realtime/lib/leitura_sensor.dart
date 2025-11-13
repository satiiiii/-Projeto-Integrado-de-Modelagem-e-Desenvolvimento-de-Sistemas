import 'package:esp32_realtime/sensor.dart';

class LeituraSensor {
  final int idleitura;
  final DateTime data;
  final double valor;
  final bool alerta;
  final String? descricaoAlerta;
  final Sensor sensor;

  // Construtor da classe.
  LeituraSensor({
    required this.idleitura,
    required this.data,
    required this.valor,
    required this.alerta,
    this.descricaoAlerta,
    required this.sensor,
  });

  // Sobrescita do toString() para exibição no console.
  @override
  String toString() {
    String output = '\n---- 🔄 LEITURA DOS DADOS DOS SENSORES ----\n'
        'Sensor: ${sensor.tipo} | Valor: $valor ${sensor.unidade} | Hora: $data | Alerta: ${alerta ? 'SIM' : 'NÃO'}';
    // Adiciona a descrição do alerta se existir.
    if (descricaoAlerta != null && descricaoAlerta!.isNotEmpty) {
      output += ' | Descrição: $descricaoAlerta';
    }
    return output;
  }

  // Método estático (factory) fromJson, converte um mapa JSON em um objeto.
  static LeituraSensor? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    // Bloco try-catch para evitar erros se o JSON tiver um formato inesperado.
    try {
      // Chama o 'fromJson' da classe Sensor para converter o objeto aninhado 'sensor'.
      final Sensor? sensor = Sensor.fromJson(json['sensor']);
      if (sensor == null) return null;

      return LeituraSensor(
        idleitura: json['idleitura'],
        data: DateTime.parse(json['data']),
        valor: (json['valor'] as num).toDouble(),
        alerta: json['alerta'],
        descricaoAlerta: json['descricaoAlerta'],
        sensor: sensor,
      );
    } catch (e) {
      print('Erro ao fazer parse de LeituraSensor: $e');
      return null;
    }
  }
}