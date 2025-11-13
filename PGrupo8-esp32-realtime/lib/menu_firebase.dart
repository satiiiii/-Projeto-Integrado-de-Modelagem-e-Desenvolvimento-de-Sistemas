import 'dart:io';
import 'package:esp32_realtime/firebase_service.dart';
import 'package:esp32_realtime/leitura_sensor.dart';

class MenuFirebase {
  final FirebaseService firebaseService;
  MenuFirebase(this.firebaseService);

  // Função para exibir o menu.
  Future<void> exibir() async {
    while (true) {
      print('\n📊 Menu de Monitoramento e Controle do ESP32:');
      print('1 - 🌡️    Leitura dos sensores');
      print('2 - ⚙️    Controle do Motor');
      print('3 - 🚪   Voltar ao Menu Principal');
      stdout.write('Escolha: ');
      String? op = stdin.readLineSync();
      switch (op) {
        case '1':
          print('\nBuscando leituras no Firebase...');
          List<LeituraSensor> leituras = await firebaseService.lerLeituras();
          if (leituras.isNotEmpty) {
            for (var leitura in leituras) {
              print(leitura);
            }
          } else {
            print('❌ Nenhuma leitura encontrada ou dados inválidos.');
          }
          break;
        case '2':
          //Chama o método para enviar o comando ao Firebase.
          await firebaseService.enviarComandoGiroMotor();
          break;
        case '3':
          return; 
        default:
          print('\n❌ Opção inválida! Tente novamente.');
      }
    }
  }
}