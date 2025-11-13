import 'dart:io';
import 'package:esp32_realtime/usuario_dao.dart';
import 'package:esp32_realtime/usuario.dart';

class MenuUsuario {
  final UsuarioDao dao;
  MenuUsuario(this.dao);

  // Função para exibir o menu.
  Future<void> exibir() async {
    while(true) {
      print('\n--- Gerenciar Usuários ---');
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

  // Função para inserir.
  Future<void> _inserir() async {
    print('\n--- Inserir Novo Usuário ---');
    try {
      stdout.write('ID do Usuário: '); 
      int id = int.parse(stdin.readLineSync()!);
      stdout.write('Nome: ');
      String nome = stdin.readLineSync()!;
      stdout.write('Login: '); 
      String login = stdin.readLineSync()!;
      stdout.write('Perfil (ex: Operador, Supervisor): ');
      String perfil = stdin.readLineSync()!;
      stdout.write('Senha: '); 
      String senha = stdin.readLineSync()!;
      await dao.inserirUsuario(Usuario(idusuario: id, nome: nome, login: login, perfil: perfil, senha: senha));
    } catch (e) { 
      print('❌ Erro nos dados de entrada: $e');
    }
  }

  // Função para listar.
  Future<void> _listar() async {
    print('\n--- Lista de Usuários ---');
    var lista = await dao.listarUsuario();
    if (lista.isEmpty){
      print('❌ Nenhum usuário cadastrado.');
    }else{
      for (var u in lista) {
        print('[ID: ${u.idusuario}] Nome: ${u.nome}, Login: ${u.login}, Perfil: ${u.perfil}');
      }
    } 
  }

  // Função para atualizar.
  Future<void> _atualizar() async {
    print('\n--- Atualizar Usuário ---');
    await _listar();
    try {
      stdout.write('Digite o ID do usuário a atualizar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) {
        print('❌ ID inválido.'); 
        return; 
      }
      stdout.write('Novo Nome: ');
      String nome = stdin.readLineSync()!;
      stdout.write('Novo Login: '); 
      String login = stdin.readLineSync()!;
      stdout.write('Novo Perfil: ');
      String perfil = stdin.readLineSync()!;
      stdout.write('Nova Senha: '); 
      String senha = stdin.readLineSync()!;
      await dao.atualizarUsuario(Usuario(idusuario: id, nome: nome, login: login, perfil: perfil, senha: senha));
    } catch (e) { 
      print('❌ Erro ao ler dados para atualizar: $e'); 
    }
  }

  // Função para deletar.
   Future<void> _deletar() async {
    print('\n--- Deletar Usuário ---');
    await _listar();
    try {
      stdout.write('Digite o ID do usuário a deletar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) { 
        print('❌ ID inválido.'); 
        return;
      }
      stdout.write('Tem certeza? (s/N): '); 
      String? conf = stdin.readLineSync()?.toLowerCase();
      if (conf == 's') {
        await dao.deletarUsuario(id);
      } else {
        print('❌ Operação cancelada.');
      }
    } catch (e) { 
      print('❌ Erro ao ler ID para deletar: $e');
    }
   }
}