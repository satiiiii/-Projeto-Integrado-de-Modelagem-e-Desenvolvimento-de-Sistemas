import 'dart:io';
import 'package:esp32_realtime/esteira_dao.dart';
import 'package:esp32_realtime/esteira.dart';
import 'package:esp32_realtime/setor.dart';
import 'package:esp32_realtime/setor_dao.dart';

class MenuEsteira {
  final EsteiraDao dao;
  final SetorDao setorDao; 
  MenuEsteira(this.dao, this.setorDao);

  // Função para exibir o menu.
  Future<void> exibir() async {
    while(true) {
      print('\n--- Gerenciar Esteiras ---');
      print('1 - Inserir Nova');
      print('2 - Listar Todas');
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

  // Função para selecionar o setor.
  Future<Setor?> _selecionarSetor(String acao) async {
    print('\nSetores disponíveis para $acao:');
    var setores = await setorDao.listarSetor();
    if (setores.isEmpty) {
      print('❌ Nenhum setor cadastrado. Crie um setor primeiro.');
      return null;
    }
    for (var s in setores) {
      print('[ID: ${s.idsetor}] ${s.nome} (Empresa: ${s.empresa.nome})');
    }
    stdout.write('Digite o ID do Setor: ');
    int? idSetor = int.tryParse(stdin.readLineSync() ?? '');
    if (idSetor == null) { 
      print('❌ ID inválido.'); 
      return null; 
    }
    try {
      return setores.firstWhere((s) => s.idsetor == idSetor);
    } catch (e) {
      print('❌ ID do setor não encontrado na lista.');
      return null;
    }
  }

  // Função para inserir.
  Future<void> _inserir() async {
    print('\n--- Inserir Nova Esteira ---');
    try {
      stdout.write('ID da Esteira: '); int id = int.parse(stdin.readLineSync()!);
      stdout.write('Nome: '); String nome = stdin.readLineSync()!;
      stdout.write('Status (ativo/inativo): '); String statusStr = stdin.readLineSync()!.toLowerCase();
      bool status = (statusStr == 'ativo');

      final setorEscolhido = await _selecionarSetor('vincular');
      if (setorEscolhido == null) return;

      await dao.inserirEsteira(Esteira(idesteira: id, nome: nome, status: status, setor: setorEscolhido));
    } catch (e) {
      print('❌ Erro nos dados de entrada: $e'); 
    }
  }

  // Função para listar.
  Future<void> _listar() async {
    print('\n--- Lista de Esteiras ---');
    var lista = await dao.listarEsteira();
    if (lista.isEmpty){
      print('❌ Nenhuma esteira cadastrada.');
    }else{
      for (var e in lista) {
         print('[ID: ${e.idesteira}] Nome: ${e.nome}, Status: ${e.status ? "Ativo" : "Inativo"}, Setor: ${e.setor.nome}');
      }
    }
  }

  // Função para atualizar.
  Future<void> _atualizar() async {
    print('\n--- Atualizar Esteira ---');
    await _listar();
    try {
      stdout.write('Digite o ID da esteira a atualizar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) {
        print('❌ ID inválido.'); 
        return;
      }

      stdout.write('Novo Nome: '); String nome = stdin.readLineSync()!;
      stdout.write('Novo Status (ativo/inativo): '); 
      String statusStr = stdin.readLineSync()!.toLowerCase();
      bool status = (statusStr == 'ativo');
      final setorEscolhido = await _selecionarSetor('vincular (novo)');
      if (setorEscolhido == null) return;

      await dao.atualizarEsteira(Esteira(idesteira: id, nome: nome, status: status, setor: setorEscolhido));
    } catch (e) { 
      print('❌ Erro ao ler dados para atualizar: $e');
    }
  }

  // Função para deletar.
  Future<void> _deletar() async {
    print('\n--- Deletar Esteira ---');
    await _listar();
    try {
      stdout.write('Digite o ID da esteira a deletar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) {
        print('❌ ID inválido.');
        return;
      }
      stdout.write('Tem certeza? (s/N): ');
      String? conf = stdin.readLineSync()?.toLowerCase();
      if (conf == 's'){
        await dao.deletarEsteira(id);
      }else{
        print('❌ Operação cancelada.');
      } 
    } catch (e) {
      print('❌ Erro ao ler ID para deletar: $e');
    }
  }
}