import 'package:esp32_realtime/database_connection.dart';
import 'package:esp32_realtime/setor.dart';
import 'package:esp32_realtime/empresa.dart';

class SetorDao {
  final DatabaseConnection db;
  SetorDao(this.db);

  // Inserir Setor (INSERT).
  Future<void> inserirSetor(Setor setor) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        await conn.query(
          'INSERT INTO setor (idsetor, nome, descricao, empresa_idempresa) VALUES (?, ?, ?, ?)',
          [setor.idsetor, setor.nome, setor.descricao, setor.empresa.idempresa]
        );
        print('✅ Setor inserido com sucesso!');
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao inserir setor (verifique ID empresa): $e');
    }
  }

  // Listar Setor (SELECT com JOIN).
  Future<List<Setor>> listarSetor() async {
    final conn = db.connection;
    List<Setor> setores = [];
    try {
      if (conn != null) {
        var results = await conn.query('''
          SELECT 
            s.idsetor, s.nome, s.descricao,
            e.idempresa, e.nome AS nome_empresa, e.cnpj, e.endereco, e.website, e.email
          FROM setor s
          JOIN empresa e ON s.empresa_idempresa = e.idempresa
          ORDER BY s.nome
        ''');
        for (var row in results) {
          // Mapeia a empresa primeiro
          final empresa = Empresa( 
            idempresa: row['idempresa'], nome: row['nome_empresa'], cnpj: row['cnpj'], 
            endereco: row['endereco'], website: row['website'], email: row['email'] 
          );
          // Mapeia o setor usando a empresa
          setores.add(Setor( 
            idsetor: row['idsetor'], nome: row['nome'], descricao: row['descricao'], 
            empresa: empresa 
          ));
        }
      } else {
        print('Conexão inativa.');
        return setores; 
      }
    } catch (e) {
      print('❌ Erro ao listar setores: $e');
    }
    return setores;
  }

  // Atualizar Setor (UPDATE).
  Future<void> atualizarSetor(Setor setor) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        await conn.query(
          'UPDATE setor SET nome = ?, descricao = ?, empresa_idempresa = ? WHERE idsetor = ?',
          [setor.nome, setor.descricao, setor.empresa.idempresa, setor.idsetor]
        );
        print('✅ Setor atualizado com sucesso!');
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao atualizar setor (verifique ID empresa): $e');
    }
  }

  // Deletar Setor (DELETE).
  Future<void> deletarSetor(int id) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        var result = await conn.query('DELETE FROM setor WHERE idsetor = ?', [id]);
        if (result.affectedRows! > 0) {
            print('✅ Setor deletado com sucesso!');
        } else {
            print('❌ Nenhum setor encontrado com o ID $id para deletar.');
        }
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao deletar setor (verifique dependências): $e');
    }
  }
}