import 'dart:convert';
import 'package:http/http.dart' as http;
class AuthService {
  final String apiKey = 'AIzaSyCbnVKmYqTEqh8aiVnFuHeifrxOcM4T-mU';

  // Método assíncrono para autenticar o usuário anonimamente.
  Future<String?> autenticarAnonimamente() async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');

    final response = await http.post(url, body: jsonEncode({}));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['idToken'];
    } else {
      print('❌ Erro na autenticação: ${response.statusCode}');
      return null;
    }
  }
}