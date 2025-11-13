import 'dart:io';
import 'package:esp32_realtime/esteira_dao.dart';
import 'package:esp32_realtime/esteira.dart';
import 'package:esp32_realtime/sensor.dart';
import 'package:esp32_realtime/sensor_dao.dart';

class MenuSensor {
  final SensorDao dao;
  final EsteiraDao esteiraDao; 
  MenuSensor(this.dao, this.esteiraDao);

  // Função para exibir o menu
  Future<void> exibir() async {
    while(true) {
      print('\n--- Gerenciar Sensores ---');
      print('1 - Inserir Novo');
      print('2 - Listar Todos');
      print('3 - Atualizar');
      print('4 - Deletar');
      print('5 - Voltar');
      stdout.write('Escolha: ');
      String? op = stdin.readLineSync();
      switch(op) {
        case '1': 
          await _inserir(); 
          break;
        case '2': 
          await _listar(); 
          break;
        case '3': 
          await _atualizar(); 
          break;
        case '4': 
          await _deletar(); 
          break;
        case '5': 
          return;
        default: 
          print('❌ Opção inválida! Tente novamente.');
      }
    }
  }

  // Função para selecionar a esteira
  Future<Esteira?> _selecionarEsteira(String acao) async {
    print('\nEsteiras disponíveis para $acao:');
    var esteiras = await esteiraDao.listarEsteira();
    if (esteiras.isEmpty) {
      print('❌ Nenhuma esteira cadastrada. Crie uma esteira primeiro.');
      return null;
    }
    for (var e in esteiras) {
      print('[ID: ${e.idesteira}] ${e.nome} (Setor: ${e.setor.nome})');
    }
    stdout.write('Digite o ID da Esteira: ');
    int? idEsteira = int.tryParse(stdin.readLineSync() ?? '');
    if (idEsteira == null) {
      print('❌ ID inválido.');
      return null;
    }
    try {
      return esteiras.firstWhere((e) => e.idesteira == idEsteira);
    } catch (e) {
      print('❌ ID da esteira não encontrado na lista.');
      return null;
    }
  }

  // Função para inserir
  Future<void> _inserir() async {
    print('\n--- Inserir Novo Sensor ---');
    try {
      stdout.write('ID do Sensor: ');
      int id = int.parse(stdin.readLineSync()!);
      stdout.write('Tipo (ex: Temperatura, Velocidade): '); 
      String tipo = stdin.readLineSync()!;
      stdout.write('Unidade (ex: °C, RPM): '); 
      String unidade = stdin.readLineSync()!;
      stdout.write('Status (ativo/inativo): '); 
      String statusStr = stdin.readLineSync()!.toLowerCase();
      bool status = (statusStr == 'ativo');

      final esteiraEscolhida = await _selecionarEsteira('vincular');
      if (esteiraEscolhida == null) return;

      await dao.inserirSensor(Sensor(idsensor: id, tipo: tipo, status: status, unidade: unidade, esteira: esteiraEscolhida));
    } catch (e) { 
      print('❌ Erro nos dados de entrada: $e'); 
    }
  }

  // Função para listar
  Future<void> _listar() async {
    print('\n--- Lista de Sensores ---');
    var lista = await dao.listarSensor();
    if (lista.isEmpty){
      print('❌ Nenhum sensor cadastrado.');
    } else{
      for (var s in lista) {
        print('[ID: ${s.idsensor}] Tipo: ${s.tipo}, Unid: ${s.unidade}, Status: ${s.status ? "Ativo" : "Inativo"}, Esteira: ${s.esteira.nome}');
      }
    } 
  }

  // Função para atualizar
  Future<void> _atualizar() async {
    print('\n--- Atualizar Sensor ---');
    await _listar();
    try {
      stdout.write('Digite o ID do sensor a atualizar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) { 
        print('❌ ID inválido.'); 
        return; 
      }
      stdout.write('Novo Tipo: '); 
      String tipo = stdin.readLineSync()!;
      stdout.write('Nova Unidade: ');
      String unidade = stdin.readLineSync()!;
      stdout.write('Novo Status (ativo/inativo): '); 
      String statusStr = stdin.readLineSync()!.toLowerCase();
      bool status = (statusStr == 'ativo');
      final esteiraEscolhida = await _selecionarEsteira('vincular (nova)');
      if (esteiraEscolhida == null) return;
      await dao.atualizarSensor(Sensor(idsensor: id, tipo: tipo, status: status, unidade: unidade, esteira: esteiraEscolhida));
    } catch (e) {
      print('❌ Erro ao ler dados para atualizar: $e'); 
    }
  }

  // Função para deletar
   Future<void> _deletar() async {
    print('\n--- Deletar Sensor ---');
    await _listar();
    try {
      stdout.write('Digite o ID do sensor a deletar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) { 
        print('❌ ID inválido.');
        return;
      }
      stdout.write('Tem certeza? (s/N): '); 
      String? conf = stdin.readLineSync()?.toLowerCase();
      if (conf == 's') {
        await dao.deletarSensor(id); 
      }else{
        print('❌ Operação cancelada.');
      } 
    } catch (e) {
      print('❌ Erro ao ler ID para deletar: $e');
    }
  }
}