import 'package:esp32_realtime/database_connection.dart';
import 'package:esp32_realtime/motor.dart';
import 'package:esp32_realtime/esteira.dart';
import 'package:esp32_realtime/setor.dart';
import 'package:esp32_realtime/empresa.dart';

class MotorDao {
  final DatabaseConnection db;
  MotorDao(this.db);

  // Inserir Motor (INSERT).
  Future<void> inserirMotor(Motor motor) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        // Operador ternário para transformar o status de bool para String, se for verdadeiro 'ativo' senão 'inativo'.
        String statusString = motor.status ? 'ativo' : 'inativo'; 

        await conn.query(
          'INSERT INTO motor (idmotor, modelo, status, direcao, esteira_idesteira) VALUES (?, ?, ?, ?, ?)',
          [motor.idmotor, motor.modelo, statusString, motor.direcao, motor.esteira.idesteira]
        );
        print('✅ Motor inserido com sucesso!');
      } else { 
        print('Conexão inativa.'); 
        return; 
      }
    } catch (e) {
      print('❌ Erro ao inserir motor: $e');
    }
  }

  // Listar Motor (SELECT com JOIN)
  Future<List<Motor>> listarMotor() async {
    final conn = db.connection;
    List<Motor> motores = [];
    try {
      if (conn != null) {
        var results = await conn.query('''
          SELECT 
            m.idmotor, m.modelo, m.status AS status_motor, m.direcao,
            es.idesteira, es.nome AS nome_esteira, es.status AS status_esteira,
            se.idsetor, se.nome AS nome_setor, se.descricao AS descricao_setor,
            em.idempresa, em.nome AS nome_empresa, em.cnpj, em.endereco, em.website, em.email
          FROM motor m
          JOIN esteira es ON m.esteira_idesteira = es.idesteira
          JOIN setor se ON es.setor_idsetor = se.idsetor
          JOIN empresa em ON se.empresa_idempresa = em.idempresa
          ORDER BY m.modelo, es.nome
        ''');
        for (var row in results) {
          final empresa = Empresa( idempresa: row['idempresa'] ?? 0, nome: row['nome_empresa'] ?? 'N/A', cnpj: row['cnpj'] ?? 'N/A', endereco: row['endereco'] ?? 'N/A', website: row['website'] ?? 'N/A', email: row['email'] ?? 'N/A' );
          final setor = Setor( idsetor: row['idsetor'] ?? 0, nome: row['nome_setor'] ?? 'N/A', descricao: row['descricao_setor'] ?? 'N/A', empresa: empresa );
          final esteira = Esteira(
            idesteira: row['idesteira'], nome: row['nome_esteira'],
            status: row['status_esteira'] == 'ativo',
            setor: setor
          );
          motores.add(Motor(
            idmotor: row['idmotor'], modelo: row['modelo'],
            status: row['status_motor'] == 'ativo',
            direcao: row['direcao'], esteira: esteira
          ));
        }
      } else { 
        print('Conexão inativa.'); 
        return motores; 
      }
    } catch (e) { 
      print('❌ Erro ao listar motores: $e');
    }
    return motores;
  }

  // Atualizar Motor (UPDATE).
  Future<void> atualizarMotor(Motor motor) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        // Operador ternário para transformar o status de bool para String, se for verdadeiro 'ativo' senão 'inativo'.
        String statusString = motor.status ? 'ativo' : 'inativo';
        await conn.query(
          'UPDATE motor SET modelo = ?, status = ?, direcao = ?, esteira_idesteira = ? WHERE idmotor = ?',
          [motor.modelo, statusString, motor.direcao, motor.esteira.idesteira, motor.idmotor]
        );
        print('✅ Motor atualizado com sucesso!');
      } else { 
        print('Conexão inativa.'); 
        return; 
      }
    } catch (e) { 
      print('❌ Erro ao atualizar motor: $e');
    }
  }

  // Deletar Motor (DELETE).
  Future<void> deletarMotor(int id) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        var result = await conn.query('DELETE FROM motor WHERE idmotor = ?', [id]);
        if (result.affectedRows! > 0) {
          print('✅ Motor deletado com sucesso!');
        }else {
          print('❌ Nenhum motor encontrado com o ID $id.');
        }
      } else { 
        print('Conexão inativa.');
        return;
      }
    } catch (e) { 
      print('❌ Erro ao deletar motor: $e');
    }
  }
}