class DatabaseConfig {
  final String host;
  final int port;
  final String user;
  final String password;
  final String dbName;

  // Encapsulamento (junção dos atributos no método construtor --> envia ao instanciar/criar)
  // Construtor da classe.
  DatabaseConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.dbName
  });
}