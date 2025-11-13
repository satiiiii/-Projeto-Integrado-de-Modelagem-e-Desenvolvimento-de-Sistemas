import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:esp32_realtime/leitura_sensor.dart';
import 'package:esp32_realtime/motor.dart';
import 'package:esp32_realtime/usuario.dart';
import 'package:esp32_realtime/esteira.dart';
import 'package:esp32_realtime/setor.dart';
import 'package:esp32_realtime/empresa.dart';

class FirebaseService {
  final String baseUrl = 'https://pgrupo8-esp32-default-rtdb.firebaseio.com/';
  final String authToken;

  FirebaseService(this.authToken);

  // Método para ler todas as leituras dos sensores do Firebase.
  Future<List<LeituraSensor>> lerLeituras() async {
    
    final url = Uri.parse('$baseUrl/leituras.json?auth=$authToken');
    try {
      // Faz a requisição GET para o Firebase.
      final response = await http.get(url);
      // Se a requisição foi bem-sucedida e o corpo não é nulo.
      if (response.statusCode == 200 && response.body != 'null') {
        final dynamic decodedData = jsonDecode(response.body);
        // O Firebase retorna um mapa de chaves únicas para cada leitura.
        if (decodedData is Map<String, dynamic>) {
          final List<LeituraSensor> leituras = [];
          // Itera sobre os valores (os objetos de leitura em si).
          for (final item in decodedData.values) {
            if (item is Map<String, dynamic>) {
              // Tenta converter cada item JSON em um objeto LeituraSensor.
              final LeituraSensor? leitura = LeituraSensor.fromJson(item);
              // Se a conversão for bem-sucedida (não nula), adiciona à lista.
              if (leitura != null) {
                leituras.add(leitura);
              }
            }
          }
          return leituras; // Retorna a lista de leituras válidas.
        }
      }
    } catch (e) {
      print('Erro ao ler leituras: $e');
    }
    return []; // Retorna uma lista vazia em caso de erro ou se não houver dados.
  }

  // Envia o comando para girar o motor para o Firebase.
  Future<void> enviarComandoGiroMotor() async {
    
    final empresa = Empresa(idempresa: 1, nome: "Pack Big Bag Industria de Embalagens Ltda", cnpj: "13.478.113/0003-00", endereco: "Av. Francisco Gonçalves, 409 - Vila Braga, Aguaí - SP, 13860-000", website: "https://packbag.com.br/", email: "vendas@packbag.com.br");
    final setor = Setor(idsetor: 1, nome: "Setor de Tecelagem", descricao: "Produção dos tecidos e cordões que irão compor as big bags.", empresa: empresa);
    final esteira = Esteira(idesteira: 1, nome: "Esteira 1", status: true, setor: setor);
    final motor = Motor(idmotor: 1, modelo: "NEMA 17", status: true, direcao: "horario", esteira: esteira);
    final usuario = Usuario(idusuario: 1, nome: "Ricardo Martins", login: "ricardo.martins@gmail.com", perfil: "Operador", senha: '8nM3pL45');

    // O objeto final que será enviado como JSON.
    final comando = {
      'idcomando': DateTime.now().millisecondsSinceEpoch,
      'data': DateTime.now().toIso8601String(),
      'origem': 'Console Dart',
      'motor': motor.toJson(),
      'usuario': usuario.toJson(),
      'acao': 'girar' // O gatilho que o ESP32 irá procurar.
    };

    final url = Uri.parse('$baseUrl/comando.json?auth=$authToken');

    try {
      // Faz uma requisição PUT, que sobrescreve completamente o nó "comando".
      final response = await http.put(
        url,
        body: jsonEncode(comando), // Converte o mapa 'comando' em uma string JSON.
      );

      if (response.statusCode == 200) {
        print('\n✅ Comando para girar o motor enviado com sucesso!');
      } else {
        print('\n❌ Falha ao enviar o comando: ${response.statusCode}');
        print('    Resposta: ${response.body}');
      }
    } catch (e) {
      print('\n❌ Erro ao enviar o comando: $e');
    }
  }
}