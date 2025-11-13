import 'dart:io';
import 'package:esp32_realtime/setor_dao.dart';
import 'package:esp32_realtime/setor.dart';
import 'package:esp32_realtime/empresa.dart';
import 'package:esp32_realtime/empresa_dao.dart';

class MenuSetor {
  final SetorDao dao;
  final EmpresaDao empresaDao;
  MenuSetor(this.dao, this.empresaDao);

  // Função para exibir o menu.
   Future<void> exibir() async {
    while(true) {
      print('\n--- Gerenciar Setores ---');
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

  // Função para selecionar uma empresa.
  Future<Empresa?> _selecionarEmpresa(String acao) async {
    print('\nEmpresas disponíveis para $acao:');
    var empresas = await empresaDao.listarEmpresa();
    if (empresas.isEmpty) {
      print('❌ Nenhuma empresa cadastrada. Crie uma empresa primeiro.');
      return null;
    }
    for (var e in empresas) {
      print('[ID: ${e.idempresa}] ${e.nome}');
    }
    stdout.write('Digite o ID da Empresa: ');
    int? idEmpresa = int.tryParse(stdin.readLineSync() ?? '');
     if (idEmpresa == null) { 
      print('❌ ID inválido.');
      return null;
    }
    try {
      // Busca na lista já carregada.
      return empresas.firstWhere((e) => e.idempresa == idEmpresa);
    } catch (e) {
      print('❌ ID da empresa não encontrado na lista.');
      return null;
    }
  }

  // Função para inserir.
  Future<void> _inserir() async {
    print('\n--- Inserir Novo Setor ---');
    try {
      stdout.write('ID do Setor: '); 
      int id = int.parse(stdin.readLineSync()!);
      stdout.write('Nome: '); 
      String nome = stdin.readLineSync()!;
      stdout.write('Descrição: '); 
      String desc = stdin.readLineSync()!;
      final empresaEscolhida = await _selecionarEmpresa('vincular');
      if (empresaEscolhida == null) return; 
      await dao.inserirSetor(Setor(idsetor: id, nome: nome, descricao: desc, empresa: empresaEscolhida));
    } catch (e) {
      print('❌ Erro nos dados de entrada: $e'); 
    }
  }

  // Função para listar.
  Future<void> _listar() async {
    print('\n--- Lista de Setores ---');
    var lista = await dao.listarSetor();
    if (lista.isEmpty) {
      print('❌ Nenhum setor cadastrado.');
    }else{
      for (var s in lista) {
        print('[ID: ${s.idsetor}] Nome: ${s.nome}\nDescrição: ${s.descricao}\nEmpresa: ${s.empresa.nome} (ID: ${s.empresa.idempresa})');
      }
    } 
  }

  // Função para atualizar.
  Future<void> _atualizar() async {
    print('\n--- Atualizar Setor ---');
    await _listar();
    try {
      stdout.write('Digite o ID do setor a atualizar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) {
        print('❌ ID inválido.'); 
        return;
      }

      stdout.write('Novo Nome: '); 
      String nome = stdin.readLineSync()!;
      stdout.write('Nova Descrição: ');
      String desc = stdin.readLineSync()!;
      final empresaEscolhida = await _selecionarEmpresa('vincular (nova)');
      if (empresaEscolhida == null) return;
      await dao.atualizarSetor(Setor(idsetor: id, nome: nome, descricao: desc, empresa: empresaEscolhida));
    } catch (e) { 
      print('❌ Erro ao ler dados para atualizar: $e'); 
    }
  }

  // Função para deletar.
   Future<void> _deletar() async {
    print('\n--- Deletar Setor ---');
    await _listar();
    try {
      stdout.write('Digite o ID do setor a deletar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) { 
        print('❌ ID inválido.');
        return; 
      }
      stdout.write('Tem certeza? (s/N): ');
      String? conf = stdin.readLineSync()?.toLowerCase();
      if (conf == 's') {
        await dao.deletarSetor(id); 
      }else{
        print('❌ Operação cancelada.');
      } 
    } catch (e) {
      print('❌ Erro ao ler ID para deletar: $e');
    }
  }
}