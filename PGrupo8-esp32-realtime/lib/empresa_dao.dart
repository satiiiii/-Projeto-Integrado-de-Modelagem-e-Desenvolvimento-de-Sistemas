import 'package:esp32_realtime/database_connection.dart';
import 'package:esp32_realtime/empresa.dart';

class EmpresaDao {
  final DatabaseConnection db;
  EmpresaDao(this.db);

  // Inserir Empresa (INSERT).
  Future<void> inserirEmpresa(Empresa empresa) async {
    final conn = db.connection;
    try{
      if (conn != null){
        await conn.query(
          'INSERT INTO empresa (idempresa, nome, cnpj, endereco, website, email) VALUES (?, ?, ?, ?, ?, ?)',
          [empresa.idempresa, empresa.nome, empresa.cnpj, empresa.endereco, empresa.website, empresa.email]
        );
        print('✅ Empresa inserida com sucesso!');
      }else{
        print('Conexão inativa.'); 
        return;
      }
    } catch (e) {
      print('❌ Erro ao inserir empresa: $e'); 
    } 
  }

  // Listar Empresa (SELECT).
  Future<List<Empresa>> listarEmpresa() async {
    final conn = db.connection;
    List<Empresa> empresas = [];
    try {
      if (conn != null) {
        var results = await conn.query('SELECT idempresa, nome, cnpj, endereco, website, email FROM empresa ORDER BY nome');
        for (var row in results) {
          empresas.add(Empresa(
            idempresa: row['idempresa'], nome: row['nome'], cnpj: row['cnpj'],
            endereco: row['endereco'], website: row['website'], email: row['email'],
          ));
        }
      } else {
        print('Conexão inativa.');
        return empresas; 
      }
    } catch (e) {
      print('❌ Erro ao listar empresas: $e');
    }
    return empresas;
  }

  // Atualizar Empresa (UPDATE).
  Future<void> atualizarEmpresa(Empresa empresa) async {
      final conn = db.connection;
      try {
        if (conn != null) {
          await conn.query(
            'UPDATE empresa SET nome = ?, cnpj = ?, endereco = ?, website = ?, email = ? WHERE idempresa = ?',
            [empresa.nome, empresa.cnpj, empresa.endereco, empresa.website, empresa.email, empresa.idempresa]
          );
          print('✅ Empresa atualizada com sucesso!');
        } else {
          print('Conexão inativa.');
          return;
        }
      } catch (e) {
        print('❌ Erro ao atualizar empresa: $e');
      }
    }

  // Deletar Empresa (DELETE).
  Future<void> deletarEmpresa(int id) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        var result = await conn.query('DELETE FROM empresa WHERE idempresa = ?', [id]);
        if (result.affectedRows! > 0) {
            print('✅ Empresa deletada com sucesso!');
        } else {
          print('❌ Nenhuma empresa encontrada com o ID $id para deletar.');
        }
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao deletar empresa (verifique dependências): $e');
    }
  }
}