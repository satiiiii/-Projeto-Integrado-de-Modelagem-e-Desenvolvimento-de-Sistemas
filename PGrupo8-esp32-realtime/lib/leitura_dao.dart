import 'package:esp32_realtime/database_connection.dart';
import 'package:esp32_realtime/leitura_sensor.dart';
import 'package:esp32_realtime/sensor.dart';
import 'package:esp32_realtime/esteira.dart';
import 'package:esp32_realtime/setor.dart';
import 'package:esp32_realtime/empresa.dart';

class LeituraDao {
  final DatabaseConnection db;
  LeituraDao(this.db);

  // Listar Leitura (SELECT com JOINs).
  Future<List<LeituraSensor>> listarLeitura({int limite = 10}) async {
    final conn = db.connection;
    List<LeituraSensor> leituras = [];
    try {
      if (conn != null) {
        String sql = """
          SELECT 
            l.idleitura, l.data, l.valor, l.alerta, l.descricaoAlerta,
            s.idsensor, s.tipo, s.status AS status_sensor, s.unidade,
            es.idesteira, es.nome AS nome_esteira, es.status AS status_esteira,
            se.idsetor, se.nome AS nome_setor, se.descricao AS descricao_setor,
            em.idempresa, em.nome AS nome_empresa, em.cnpj, em.endereco, em.website, em.email
          FROM leitura l
          JOIN sensor s ON l.sensor_idsensor = s.idsensor
          JOIN esteira es ON s.esteira_idesteira = es.idesteira
          JOIN setor se ON es.setor_idsetor = se.idsetor
          JOIN empresa em ON se.empresa_idempresa = em.idempresa
          ORDER BY l.data DESC 
          LIMIT ? 
        """;
        var results = await conn.query(sql, [limite]);
        for (var row in results) {
           final empresa = Empresa(idempresa: row['idempresa'], nome: row['nome_empresa'], cnpj: row['cnpj'], endereco: row['endereco'], website: row['website'], email: row['email']);
           final setor = Setor(idsetor: row['idsetor'], nome: row['nome_setor'], descricao: row['descricao_setor'], empresa: empresa);
           final esteira = Esteira(idesteira: row['idesteira'], nome: row['nome_esteira'], status: row['status_esteira'] == 1, setor: setor);
           final sensor = Sensor(idsensor: row['idsensor'], tipo: row['tipo'], status: row['status_sensor'] == 1, unidade: row['unidade'], esteira: esteira);
           final leitura = LeituraSensor(idleitura: row['idleitura'], data: row['data'] as DateTime, valor: (row['valor'] as num).toDouble(), alerta: row['alerta'] == 1, descricaoAlerta: row['descricaoAlerta'], sensor: sensor);
           leituras.add(leitura);
        }
      } else {
        print('Conexão inativa.');
        return leituras;
      }
    } catch (e) {
      print('❌ Erro ao listar leituras: $e');
    }
    return leituras;
  }

  // Deletar Leitura (DELETE).
  Future<void> deletarLeitura(int id) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        var result = await conn.query('DELETE FROM leitura WHERE idleitura = ?', [id]);
        if (result.affectedRows! > 0) {
            print('✅ Leitura deletada com sucesso!');
        } else {
            print('❌ Nenhuma leitura encontrada com o ID $id para deletar.');
        }
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao deletar leitura: $e');
    }
  }
}