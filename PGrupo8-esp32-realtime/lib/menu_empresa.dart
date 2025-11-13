import 'dart:io';
import 'package:esp32_realtime/empresa_dao.dart';
import 'package:esp32_realtime/empresa.dart';

class MenuEmpresa {
  final EmpresaDao dao;
  MenuEmpresa(this.dao);

  // Função para exibir o menu.
  Future<void> exibir() async {
    while(true) {
      print('\n--- Gerenciar Empresas ---');
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

  // Função para inserir.
  Future<void> _inserir() async {
    print('\n--- Inserir Nova Empresa ---');
    try {
      stdout.write('ID da Empresa: ');
      int id = int.parse(stdin.readLineSync()!);
      stdout.write('Nome: ');
      String nome = stdin.readLineSync()!;
      stdout.write('CNPJ: ');
      String cnpj = stdin.readLineSync()!;
      stdout.write('Endereço: ');
      String end = stdin.readLineSync()!;
      stdout.write('Website: ');
      String web = stdin.readLineSync()!;
      stdout.write('Email: ');
      String email = stdin.readLineSync()!;
      await dao.inserirEmpresa(
        Empresa(idempresa: id, nome: nome, cnpj: cnpj, endereco: end, website: web, email: email)
      );
    } catch (e) { 
      print('❌ Erro nos dados de entrada: $e'); 
    }
  }

  // Função para listar.
  Future<void> _listar() async {
    print('\n--- Lista de Empresas ---');
    var lista = await dao.listarEmpresa();
    if (lista.isEmpty) {
      print('❌ Nenhuma empresa cadastrada.');
    } else {
      for (var e in lista) {
         print('[ID: ${e.idempresa}] Nome: ${e.nome}, CNPJ: ${e.cnpj}, Endereço: ${e.endereco}, Website: ${e.website}, Email: ${e.email}');
      }
    }
  }

  // Função para atualizar.
  Future<void> _atualizar() async {
    print('\n--- Atualizar Empresa ---');
    await _listar();
    try {
      stdout.write('Digite o ID da empresa a atualizar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) { 
        print('❌ ID inválido.'); 
        return;
      }
      stdout.write('Novo Nome: '); String nome = stdin.readLineSync()!;
      stdout.write('Novo CNPJ: '); String cnpj = stdin.readLineSync()!;
      stdout.write('Novo Endereço: '); String end = stdin.readLineSync()!;
      stdout.write('Novo Website: '); String web = stdin.readLineSync()!;
      stdout.write('Novo Email: '); String email = stdin.readLineSync()!;
      final empresaAtualizada = Empresa(idempresa: id, nome: nome, cnpj: cnpj, endereco: end, website: web, email: email);
      await dao.atualizarEmpresa(empresaAtualizada);
    } catch (e) {
      print('❌ Erro ao ler dados para atualizar: $e'); 
    }
  }

  // Função para deletar.
  Future<void> _deletar() async {
    print('\n--- Deletar Empresa ---');
    await _listar();
    try {
      stdout.write('Digite o ID da empresa a deletar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
       if (id == null) { 
        print('❌ ID inválido.'); 
        return; 
      }
      stdout.write('Tem certeza que deseja deletar a empresa ID $id? (s/N): ');
      String? confirm = stdin.readLineSync()?.toLowerCase();
      if (confirm == 's') {
        await dao.deletarEmpresa(id);
      } else {
        print('❌ Operação cancelada.');
      }
    } catch (e) { 
      print('❌ Erro ao ler ID para deletar: $e');
    }
  }
}