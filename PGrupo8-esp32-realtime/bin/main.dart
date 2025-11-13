import 'dart:io';
import 'package:esp32_realtime/auth_service.dart';
import 'package:esp32_realtime/firebase_service.dart';
import 'package:esp32_realtime/database_config.dart';
import 'package:esp32_realtime/database_connection.dart';
import 'package:esp32_realtime/empresa_dao.dart';
import 'package:esp32_realtime/setor_dao.dart';
import 'package:esp32_realtime/esteira_dao.dart';
import 'package:esp32_realtime/sensor_dao.dart';
import 'package:esp32_realtime/motor_dao.dart';
import 'package:esp32_realtime/leitura_dao.dart';
import 'package:esp32_realtime/comando_dao.dart';
import 'package:esp32_realtime/usuario_dao.dart';
import 'package:esp32_realtime/menu_firebase.dart';
import 'package:esp32_realtime/menu_empresa.dart';
import 'package:esp32_realtime/menu_setor.dart';
import 'package:esp32_realtime/menu_esteira.dart';
import 'package:esp32_realtime/menu_sensor.dart';
import 'package:esp32_realtime/menu_motor.dart';
import 'package:esp32_realtime/menu_leitura.dart';
import 'package:esp32_realtime/menu_comando.dart';
import 'package:esp32_realtime/menu_usuario.dart';

void main() async {
  print('\n---- 📈 Console de Monitoramento e Controle de Motores e Esteiras Transportadoras  ----');

  // Conexão MySQL.
  final config = DatabaseConfig(
    host: 'localhost',
    port: 3306, 
    user: 'root', 
    password: 'B_moonlit25', 
    dbName: 'bancoPI'
  ); 

  final db = DatabaseConnection(config);
  bool conectadoMySQL = await db.connect();

  if (!conectadoMySQL) {
    print('❌ Falha ao conectar ao MySQL. Encerrando...'); 
    return; 
  }

  // Autenticação no Firebase.
  // Cria uma instância do serviço de autenticação.
  AuthService authService = AuthService();

  // Chama o método para autenticar e aguarda o token.
  String? token = await authService.autenticarAnonimamente();
  FirebaseService? firebaseService;

  if (token != null) { 
    // Cria uma instância do serviço do Firebase, passando o token obtido.
    firebaseService = FirebaseService(token); 
    print('✅ Autenticação no Firebase com sucesso!');
  }else{ 
    print('❌ Não foi possível autenticar.'); 
  }

  // Instanciar DAOs (operações com o banco MySQL).
  final empresaDao = EmpresaDao(db);
  final setorDao = SetorDao(db);
  final esteiraDao = EsteiraDao(db);
  final sensorDao = SensorDao(db);
  final motorDao = MotorDao(db);
  final leituraDao = LeituraDao(db);
  final comandoDao = ComandoDao(db);
  final usuarioDao = UsuarioDao(db);

  // Instanciar Menus.
  MenuFirebase? menuFirebase; // ?null se a autenticação com o Firebase falha
  if (firebaseService != null) menuFirebase = MenuFirebase(firebaseService); // Cria o obj da classe MenuFirebase passando o firebaseService para o construtor da classe.
  final menuEmpresa = MenuEmpresa(empresaDao); // Passa o obj empresaDao para o construtor da classe MenuEmpresa para as operações com o banco.
  final menuSetor = MenuSetor(setorDao, empresaDao); // Passa dao de empresa para FK.
  final menuEsteira = MenuEsteira(esteiraDao, setorDao); // Passa dao de setor para FK.
  final menuSensor = MenuSensor(sensorDao, esteiraDao);   // Passa dao de esteira para FK.
  final menuMotor = MenuMotor(motorDao, esteiraDao);     // Passa dao de esteira para FK.
  final menuLeitura = MenuLeitura(leituraDao); // Passa o obj leituraDao para o construtor da classe MenuLeitura para as operações com o banco.
  final menuComando = MenuComando(comandoDao, motorDao, usuarioDao); // Passa daos para FKs.
  final menuUsuario = MenuUsuario(usuarioDao); // Passa o obj usuarioDao para o construtor da classe MenuUsuario para as operações com o banco.

  // Loop do Menu Principal
  while (true) {
    print('\n====== MENU PRINCIPAL ======');
    print('1  - Monitoramento das Leituras e Motor no Firebase');
    print('2  - Empresas');
    print('3  - Setores');
    print('4  - Esteiras');
    print('5  - Sensores');
    print('6  - Motores');
    print('7  - Leituras');
    print('8  - Comandos');
    print('9  - Usuários');
    print('10 - Sair');
    stdout.write('Escolha: '); 
    String? op = stdin.readLineSync();

    try {
      switch (op) {
        case '1':
          if (menuFirebase != null){
            await menuFirebase.exibir();
          }else{
            print('❌ Monitoramento no Firebase indisponível.');
          } 
          break;
        case '2': 
          await menuEmpresa.exibir(); 
          break;
        case '3': 
          await menuSetor.exibir(); 
          break;
        case '4': 
          await menuEsteira.exibir(); 
          break;
        case '5': 
          await menuSensor.exibir(); 
          break;
        case '6': 
          await menuMotor.exibir(); 
          break;
        case '7': 
          await menuLeitura.exibir(); 
          break;
        case '8': 
          await menuComando.exibir(); 
          break;
        case '9': 
          await menuUsuario.exibir(); 
          break;
        case '10':
          await db.close();
          print('\nEncerrando...');
          return;
        default: 
          print('❌ Opção inválida.');
      }
    } catch (e) {
       print("\n❌ Ocorreu um erro inesperado no menu principal: $e");
    }
  }
}
