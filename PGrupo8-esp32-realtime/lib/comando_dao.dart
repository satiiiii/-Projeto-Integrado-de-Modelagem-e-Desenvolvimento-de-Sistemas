import 'package:esp32_realtime/database_connection.dart';
import 'package:esp32_realtime/comando.dart';
import 'package:esp32_realtime/motor.dart';
import 'package:esp32_realtime/usuario.dart';
import 'package:esp32_realtime/esteira.dart';
import 'package:esp32_realtime/setor.dart';
import 'package:esp32_realtime/empresa.dart';

class ComandoDao {
  final DatabaseConnection db;
  ComandoDao(this.db);

  // Inserir Comando (INSERT).
  Future<void> inserirComando(DateTime data, String origem, int motorId, int usuarioId) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        await conn.query(
          'INSERT INTO comando (data, origem, motor_idmotor, usuario_idusuario) VALUES (?, ?, ?, ?)',
          [ data, origem, motorId, usuarioId ] 
        );
        print('✅ Registro de comando inserido com sucesso.');
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao inserir comando (verifique IDs motor/usuario): $e');
    }
  }

  // Listar Comando (SELECT com JOINs e Mapeamento Seguro para senha do Usuário).
  Future<List<Comando>> listarComando({int limite = 10}) async {
    final conn = db.connection;
    List<Comando> comandos = [];
    try {
      if (conn != null) {
        // Query NÃO seleciona u.senha
        var results = await conn.query('''
          SELECT 
            c.idcomando, c.data, c.origem,
            m.idmotor, m.modelo, m.status AS status_motor, m.direcao,
            u.idusuario, u.nome AS nome_usuario, u.login, u.perfil, 
            es.idesteira, es.nome AS nome_esteira, es.status AS status_esteira,
            se.idsetor, se.nome AS nome_setor, se.descricao AS descricao_setor,
            em.idempresa, em.nome AS nome_empresa, em.cnpj, em.endereco, em.website, em.email
          FROM comando c
          JOIN motor m ON c.motor_idmotor = m.idmotor
          JOIN usuario u ON c.usuario_idusuario = u.idusuario
          JOIN esteira es ON m.esteira_idesteira = es.idesteira
          JOIN setor se ON es.setor_idsetor = se.idsetor
          JOIN empresa em ON se.empresa_idempresa = em.idempresa
          ORDER BY c.data DESC 
          LIMIT ?
        ''', [limite]);

        for (var row in results) {
          try {
            // Mapeia Empresa, Setor, Esteira, Motor.
            final empresa = Empresa(idempresa: row['idempresa'] ?? 0, nome: row['nome_empresa'] ?? 'N/A', cnpj: row['cnpj'] ?? 'N/A', endereco: row['endereco'] ?? 'N/A', website: row['website'] ?? 'N/A', email: row['email'] ?? 'N/A');
            final setor = Setor(idsetor: row['idsetor'] ?? 0, nome: row['nome_setor'] ?? 'N/A', descricao: row['descricao_setor'] ?? 'N/A', empresa: empresa);
            final esteira = Esteira(idesteira: row['idesteira'] ?? 0, nome: row['nome_esteira'] ?? 'N/A', status: row['status_esteira'] == 1, setor: setor);
            final motor = Motor(idmotor: row['idmotor'] ?? 0, modelo: row['modelo'] ?? 'N/A', status: row['status_motor'] == 1, direcao: row['direcao'] ?? 'N/A', esteira: esteira);

            // Mapeia Usuário (verificando nulidade e passando senha vazia).
            final idUsuario = row['idusuario'];
            final nomeUsuario = row['nome_usuario'];
            final loginUsuario = row['login'];
            final perfilUsuario = row['perfil'];

            if (idUsuario == null || nomeUsuario == null || loginUsuario == null || perfilUsuario == null) {
              print("AVISO: Dados do usuário incompletos no JOIN para comando ID ${row['idcomando']}. Pulando.");
              continue;
            }

            // Cria o objeto Usuario passando a senha vazia
            final usuario = Usuario(
              idusuario: idUsuario,
              nome: nomeUsuario,
              login: loginUsuario,
              perfil: perfilUsuario,
              senha: "" // <-- Passa senha vazia
            );

            // Cria o Comando
            comandos.add(Comando(
              idcomando: row['idcomando'] ?? 0,
              data: row['data'] as DateTime,
              origem: row['origem'] ?? 'N/A',
              motor: motor,
              usuario: usuario,
              acao: null
            ));

          } catch (mappingError) {
             print("❌ Erro ao mapear linha do comando ID ${row['idcomando']}: $mappingError. Pulando.");
             continue;
          }
        }
      } else {
        print('Conexão inativa.');
        return comandos;
      }
    } catch (e) {
      print('❌ Erro ao listar comandos: $e');
    }
    return comandos;
  }

  // Deletar Comando (DELETE).
  Future<void> deletarComando(int id) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        var result = await conn.query('DELETE FROM comando WHERE idcomando = ?', [id]);
        if (result.affectedRows! > 0) {
            print('✅ Comando deletado com sucesso!');
        } else {
            print('❌ Nenhum comando encontrado com o ID $id para deletar.');
        }
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao deletar comando: $e');
    }
  }
}