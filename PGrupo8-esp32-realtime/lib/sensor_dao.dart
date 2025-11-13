import 'package:esp32_realtime/database_connection.dart';
import 'package:esp32_realtime/sensor.dart';
import 'package:esp32_realtime/esteira.dart';
import 'package:esp32_realtime/setor.dart';
import 'package:esp32_realtime/empresa.dart';

class SensorDao {
  final DatabaseConnection db;
  SensorDao(this.db);

  // Inserir Sensor (INSERT).
  Future<void> inserirSensor(Sensor sensor) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        // Operador ternário para transformar o status de bool para String, se for verdadeiro 'ativo' senão 'inativo'.
        String statusString = sensor.status ? 'ativo' : 'inativo';
        await conn.query(
          'INSERT INTO sensor (idsensor, tipo, status, unidade, esteira_idesteira) VALUES (?, ?, ?, ?, ?)',
          [sensor.idsensor, sensor.tipo, statusString, sensor.unidade, sensor.esteira.idesteira]
        );
        print('✅ Sensor inserido com sucesso!');
      } else { 
        print('Conexão inativa.'); 
        return; 
      }
    } catch (e) { 
      print('❌ Erro ao inserir sensor: $e'); 
    }
  }

  // Listar Sensor (SELECT com JOIN)
  Future<List<Sensor>> listarSensor() async {
    final conn = db.connection;
    List<Sensor> sensores = [];
    try {
      if (conn != null) {
        var results = await conn.query('''
          SELECT 
            s.idsensor, s.tipo, s.status AS status_sensor, s.unidade,
            es.idesteira, es.nome AS nome_esteira, es.status AS status_esteira,
            se.idsetor, se.nome AS nome_setor, se.descricao AS descricao_setor,
            em.idempresa, em.nome AS nome_empresa, em.cnpj, em.endereco, em.website, em.email
          FROM sensor s
          JOIN esteira es ON s.esteira_idesteira = es.idesteira
          JOIN setor se ON es.setor_idsetor = se.idsetor
          JOIN empresa em ON se.empresa_idempresa = em.idempresa
          ORDER BY s.tipo, es.nome
        ''');
        for (var row in results) {
          final empresa = Empresa( idempresa: row['idempresa'] ?? 0, nome: row['nome_empresa'] ?? 'N/A', cnpj: row['cnpj'] ?? 'N/A', endereco: row['endereco'] ?? 'N/A', website: row['website'] ?? 'N/A', email: row['email'] ?? 'N/A' );
          final setor = Setor( idsetor: row['idsetor'] ?? 0, nome: row['nome_setor'] ?? 'N/A', descricao: row['descricao_setor'] ?? 'N/A', empresa: empresa );
          final esteira = Esteira(
              idesteira: row['idesteira'], nome: row['nome_esteira'],
              status: row['status_esteira'] == 'ativo',
              setor: setor
          );
          sensores.add(Sensor(
            idsensor: row['idsensor'], tipo: row['tipo'],
            status: row['status_sensor'] == 'ativo',
            unidade: row['unidade'], esteira: esteira
          ));
        }
      } else { 
        print('Conexão inativa.'); 
        return sensores;
      }
    } catch (e) { 
      print('❌ Erro ao listar sensores: $e'); 
    }
    return sensores;
  }

  // Atualizar Sensor (UPDATE).
  Future<void> atualizarSensor(Sensor sensor) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        // Operador ternário para transformar o status de bool para String, se for verdadeiro 'ativo' senão 'inativo'.
        String statusString = sensor.status ? 'ativo' : 'inativo';
        await conn.query(
          'UPDATE sensor SET tipo = ?, status = ?, unidade = ?, esteira_idesteira = ? WHERE idsensor = ?',
          [sensor.tipo, statusString, sensor.unidade, sensor.esteira.idesteira, sensor.idsensor]
        );
        print('✅ Sensor atualizado com sucesso!');
      } else {
        print('Conexão inativa.');
        return; 
      }
    } catch (e) { 
      print('❌ Erro ao atualizar sensor: $e');
    }
  }

  // Deletar Sensor (DELETE).
  Future<void> deletarSensor(int id) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        var result = await conn.query('DELETE FROM sensor WHERE idsensor = ?', [id]);
        if (result.affectedRows! > 0) {
          print('✅ Sensor deletado com sucesso!');
        }else{
          print('❌ Nenhum sensor encontrado com o ID $id.');
        } 
      } else { 
        print('Conexão inativa.'); 
        return; 
      }
    } catch (e) { 
      print('❌ Erro ao deletar sensor: $e'); 
    }
  }
}