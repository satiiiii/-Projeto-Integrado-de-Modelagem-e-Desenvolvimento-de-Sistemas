import 'dart:io';
import 'package:esp32_realtime/comando_dao.dart';
import 'package:esp32_realtime/motor_dao.dart';
import 'package:esp32_realtime/usuario_dao.dart';

class MenuComando {
  final ComandoDao dao;
  final MotorDao motorDao;
  final UsuarioDao usuarioDao;
  MenuComando(this.dao, this.motorDao, this.usuarioDao);

  // Função para exibir o menu.
  Future<void> exibir() async {
     while(true) {
      print('\n--- Gerenciar Comandos Registrados ---');
      print('1 - Inserir Novo Comando (Simulação)');
      print('2 - Listar Últimos 10 Comandos');
      print('3 - Deletar Comando por ID');
      print('4 - Voltar');
      stdout.write('Escolha: ');
      String? op = stdin.readLineSync();
      switch(op) {
        case '1': 
          await _inserir();
          break;
        case '2': 
          await _listarRecentes(); 
          break;
        case '3': 
          await _deletarPorId(); 
          break;
        case '4': 
          return;
        default: 
          print('❌ Opção inválida! Tente novamente.');
      }
    }
  }

  // Função para inserir.
  Future<void> _inserir() async {
    print('\n--- Inserir Novo Comando (Simulação) ---');
    // Esta função apenas insere o registro no banco, não aciona o motor.
    try {
      print('\nMotores disponíveis:');
      var motores = await motorDao.listarMotor();
      if (motores.isEmpty) {
        print('❌ Nenhum motor cadastrado.');
        return;
      }
      for (var m in motores) {
        print('[ID: ${m.idmotor}] ${m.modelo} (Esteira: ${m.esteira.nome})');
      }
      stdout.write('Digite o ID do Motor alvo do comando: ');
      int? idMotor = int.tryParse(stdin.readLineSync() ?? '');
      if (idMotor == null) {
        print('❌ ID inválido.');
        return;
      }
      print('\nUsuários disponíveis:');
      var usuarios = await usuarioDao.listarUsuario();
      if (usuarios.isEmpty) {
        print('❌ Nenhum usuário cadastrado.');
        return;
      }
      for (var u in usuarios) {
        print('[ID: ${u.idusuario}] ${u.nome} (${u.login})');
      }
      stdout.write('Digite o ID do Usuário que está registrando o comando: ');
      int? idUsuario = int.tryParse(stdin.readLineSync() ?? '');
      if (idUsuario == null) {
        print('❌ ID inválido.');
        return;
      }
      stdout.write('Origem do comando (ex: Teste Manual): ');
      String origem = stdin.readLineSync() ?? 'Console MySQL';
      // Usa o ComandoDao para inserir (converte DateTime para UTC).
      await dao.inserirComando(DateTime.now().toUtc(), origem, idMotor, idUsuario);
    } catch (e) {
      print('❌ Erro nos dados de entrada: $e');
    }
  }

  // Função para listar os últimos 10 comandos.
   Future<void> _listarRecentes() async {
    print('\n--- Últimos 10 Comandos Registrados ---');
    var lista = await dao.listarComando(limite: 10);
    if (lista.isEmpty) {
      print('❌ Nenhum comando encontrado.');
    } else {
      for (var c in lista) {
        print('\n[ID: ${c.idcomando}] Origem: ${c.origem} | Data: ${c.data}');
        print('  Usuário: ${c.usuario.nome} (ID: ${c.usuario.idusuario})');
        print('  Motor: ${c.motor.modelo} (ID: ${c.motor.idmotor}) na Esteira: ${c.motor.esteira.nome}');
      }
    }
  }

  // Função para deletar.
  Future<void> _deletarPorId() async {
    print('\n--- Deletar Registro de Comando por ID ---');
    try {
      stdout.write('Digite o ID do comando a deletar: ');
      int? id = int.tryParse(stdin.readLineSync() ?? '');
      if (id == null) { print('ID inválido.'); return; }
      // Confirmação para o usuário, se deseja 
      stdout.write('Tem certeza? (s/N): '); String? conf = stdin.readLineSync()?.toLowerCase();
      if (conf == 's'){
        await dao.deletarComando(id);
      } else{
         print('Operação cancelada.');
      }
    } catch (e) { 
      print('❌ Erro ao ler ID para deletar: $e');
    }
  }
}