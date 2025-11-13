import 'package:esp32_realtime/database_connection.dart';
import 'package:esp32_realtime/esteira.dart';
import 'package:esp32_realtime/setor.dart';
import 'package:esp32_realtime/empresa.dart';


class EsteiraDao {
  final DatabaseConnection db;
  EsteiraDao(this.db);

  // Inserir Esteira (INSERT).
  Future<void> inserirEsteira(Esteira esteira) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        // Operador ternário para transformar o status de bool para String, se for verdadeiro 'ativo' senão 'inativo'. 
        String statusString = esteira.status ? 'ativo' : 'inativo';
        await conn.query(
          'INSERT INTO esteira (idesteira, nome, status, setor_idsetor) VALUES (?, ?, ?, ?)',
          [esteira.idesteira, esteira.nome, statusString, esteira.setor.idsetor]
        );
        print('✅ Esteira inserida com sucesso!');
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao inserir esteira: $e');
    }
  }

  // Listar Esteira (SELECT com JOIN)
  Future<List<Esteira>> listarEsteira() async {
    final conn = db.connection;
    List<Esteira> esteiras = [];
    try {
      if (conn != null) {
        var results = await conn.query('''
          SELECT 
            es.idesteira, es.nome, es.status,
            se.idsetor, se.nome AS nome_setor, se.descricao AS descricao_setor,
            em.idempresa, em.nome AS nome_empresa, em.cnpj, em.endereco, em.website, em.email
          FROM esteira es
          JOIN setor se ON es.setor_idsetor = se.idsetor
          JOIN empresa em ON se.empresa_idempresa = em.idempresa
          ORDER BY es.nome
        ''');
        for (var row in results) {
          final empresa = Empresa( idempresa: row['idempresa'] ?? 0, nome: row['nome_empresa'] ?? 'N/A', cnpj: row['cnpj'] ?? 'N/A', endereco: row['endereco'] ?? 'N/A', website: row['website'] ?? 'N/A', email: row['email'] ?? 'N/A' );
          final setor = Setor( idsetor: row['idsetor'] ?? 0, nome: row['nome_setor'] ?? 'N/A', descricao: row['descricao_setor'] ?? 'N/A', empresa: empresa );
          esteiras.add(Esteira(
            idesteira: row['idesteira'],
            nome: row['nome'],
            status: row['status'] == 'ativo',
            setor: setor
          ));
        }
      } else {
        print('Conexão inativa.'); 
        return esteiras;
      }
    } catch (e) {
      print('❌ Erro ao listar esteiras: $e');
    }
    return esteiras;
  }

  // Atualizar Esteira (UPDATE).
  Future<void> atualizarEsteira(Esteira esteira) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        // Operador ternário para transformar o status de bool para String, se for verdadeiro 'ativo' senão 'inativo'.
        String statusString = esteira.status ? 'ativo' : 'inativo';
        await conn.query(
          'UPDATE esteira SET nome = ?, status = ?, setor_idsetor = ? WHERE idesteira = ?',
          [esteira.nome, statusString, esteira.setor.idsetor, esteira.idesteira]
        );
        print('✅ Esteira atualizada com sucesso!');
      } else { 
        print('Conexão inativa.'); 
        return; 
      }
    } catch (e) { 
      print('❌ Erro ao atualizar esteira: $e'); 
    }
  }

  // Deletar Esteira (DELETE).
  Future<void> deletarEsteira(int id) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        var result = await conn.query('DELETE FROM esteira WHERE idesteira = ?', [id]);
        if (result.affectedRows! > 0) {
          print('✅ Esteira deletada com sucesso!');
        }else {
          print('❌ Nenhuma esteira encontrada com o ID $id.');
        }
      } else { 
        print('Conexão inativa.'); 
        return; 
      }
    } catch (e) { 
      print('❌ Erro ao deletar esteira: $e'); 
    }
  }
}