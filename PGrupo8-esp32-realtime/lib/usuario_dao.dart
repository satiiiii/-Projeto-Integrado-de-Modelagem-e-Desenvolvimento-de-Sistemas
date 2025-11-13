import 'package:esp32_realtime/database_connection.dart';
import 'package:esp32_realtime/usuario.dart';

class UsuarioDao {
  final DatabaseConnection db;
  UsuarioDao(this.db);

  // Inserir Usuario (INSERT).
  Future<void> inserirUsuario(Usuario usuario) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        await conn.query(
          'INSERT INTO usuario (idusuario, nome, login, perfil, senha) VALUES (?, ?, ?, ?, ?)',
          [usuario.idusuario, usuario.nome, usuario.login, usuario.perfil, usuario.senha] // Passa a senha
        );
        print('✅ Usuário inserido com sucesso!');
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao inserir usuário: $e');
    }
  }

  // Listar Usuario (SELECT) - NÃO seleciona a senha por segurança.
  Future<List<Usuario>> listarUsuario() async {
    final conn = db.connection;
    List<Usuario> usuarios = [];
    try {
      if (conn != null) {
        // A query NÃO busca a coluna 'senha'
        var results = await conn.query('SELECT idusuario, nome, login, perfil FROM usuario ORDER BY nome');
        for (var row in results) {
          // Cria o objeto Usuario passando uma string vazia como placeholder para a senha,
          // já que o construtor da sua classe a exige, mas não a buscamos do banco.
          usuarios.add(Usuario(
            idusuario: row['idusuario'] ?? 0, // Usar ?? para valores padrão se o campo for nulo no BD
            nome: row['nome'] ?? 'N/A',
            login: row['login'] ?? 'N/A',
            perfil: row['perfil'] ?? 'N/A',
            senha: "" // <-- Passa um placeholder vazio
          ));
        }
      } else {
        print('Conexão inativa.');
        return usuarios;
      }
    } catch (e) {
      print('❌ Erro ao listar usuários: $e');
    }
    return usuarios;
  }

  // Atualizar Usuario (UPDATE).
  Future<void> atualizarUsuario(Usuario usuario) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        await conn.query(
          'UPDATE usuario SET nome = ?, login = ?, perfil = ?, senha = ? WHERE idusuario = ?',
          [usuario.nome, usuario.login, usuario.perfil, usuario.senha, usuario.idusuario] // Passa a nova senha
        );
        print('✅ Usuário atualizado com sucesso!');
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao atualizar usuário: $e');
    }
  }

  // Deletar Usuario (DELETE).
  Future<void> deletarUsuario(int id) async {
    final conn = db.connection;
    try {
      if (conn != null) {
        var result = await conn.query('DELETE FROM usuario WHERE idusuario = ?', [id]);
        if (result.affectedRows! > 0) {
            print('✅ Usuário deletado com sucesso!');
        } else {
            print('❌ Nenhum usuário encontrado com o ID $id para deletar.');
        }
      } else {
        print('Conexão inativa.');
        return;
      }
    } catch (e) {
      print('❌ Erro ao deletar usuário (verifique dependências: Comando): $e');
    }
  }
}