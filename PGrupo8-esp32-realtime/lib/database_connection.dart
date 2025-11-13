import 'package:mysql1/mysql1.dart';
import './database_config.dart';

class DatabaseConnection {
  // Herda da classe DatabaseConfig e cria instância.
  final DatabaseConfig config;

  // Atributos restritos (somente acessa com get e set).
  MySqlConnection? _connection;

  // Herda do método construtor do DatabaseConfig.
  DatabaseConnection(this.config);

  // Método de conexão async --> async await espera algo externo (requisição do banco).
  Future<bool> connect() async {
    try {
      _connection = await MySqlConnection.connect(ConnectionSettings(
        host: config.host,
        port: config.port,
        user: config.user,
        password: config.password,
        db: config.dbName
      ));

      // Testa a conexão com um query simples.
      try{
        await _connection!.query('SELECT 1');
        print('✅ Conexão estabelecida com Sucesso!');
        return true;
      }catch(queryError){
        print('❌ Erro ao executar query de teste: $queryError');
        return false;
      }
      
    } catch (e) {
      print('❌ Erro ao conectar: $e');
      return false;
    }
  }

  // Método assíncrono para encerrar a conexão.
  Future<void> close() async{
    await _connection?.close();
    print('Conexão encerrada');
  }
  
  // Para ler um dado privado na classe (método de leitura = get).
  MySqlConnection? get connection => _connection;
}
