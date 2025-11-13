import 'dart:io';
import 'package:esp32_realtime/leitura_dao.dart';

class MenuLeitura {
  final LeituraDao dao;
  MenuLeitura(this.dao);

  // Função para exibir o menu
  Future<void> exibir() async {
     while(true) {
      print('\n--- Gerenciar Leituras ---');
      print('1 - Listar Últimas 10 Leituras');
      print('2 - Deletar Leitura por ID');
      print('3 - Voltar');
      stdout.write('Escolha: '); 
      String? op = stdin.readLineSync();
      switch(op) {
        case '1': 
          await _listarRecentes(); 
          break;
        case '2': 
          await _deletarPorId(); 
          break;
        case '3': 
          return;
        default: 
          print('❌ Opção inválida! Tente novamente.');
      }
    }
  }

  // Função para listar as últimas 10 leituras.
  Future<void> _listarRecentes() async {
    print('\n--- Últimas 10 Leituras Registradas ---');
    var lista = await dao.listarLeitura(limite: 10);
    if (lista.isEmpty){
      print('❌ Nenhuma leitura encontrada.');
    }else{
      lista.forEach(print); // Usa o toString() detalhado da LeituraSensor.
    } 
  }

  // Função para deletar.
  Future<void> _deletarPorId() async {
    print('\n--- Deletar Leitura por ID ---');
    try {
      stdout.write('Digite o ID da leitura a deletar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) { 
        print('❌ ID inválido.');
        return;
      }
      stdout.write('Tem certeza? (s/N): '); 
      String? conf = stdin.readLineSync()?.toLowerCase();
      if (conf == 's'){
        await dao.deletarLeitura(id);
      }else{
        print('❌ Operação cancelada.');
      } 
    } catch (e) {
      print('❌ Erro ao ler ID para deletar: $e'); 
    }
   }
}