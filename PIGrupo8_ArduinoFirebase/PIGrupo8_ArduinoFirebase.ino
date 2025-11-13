// Bibliotecas utilizadas
#include <WiFi.h>                 // Biblioteca para conectar o ESP32 a redes Wi-Fi (cliente e AP)
#include <DHT.h>                  // Biblioteca para o sensor DHT 
#include <WebServer.h>            // Biblioteca para criar servidor web no ESP32
#include <ArduinoJson.h>          // Biblioteca para criar o JSON aninhado
#include <Firebase_ESP_Client.h>  // Biblioteca responsável pela comunicação com o Firebase
#include "addons/TokenHelper.h"   // Fornecer informações para o processo de geração do token (autenticação)
#include "addons/RTDBHelper.h"    // Fornecer informações para impressão da carga útil do RTDB e outras funções auxiliares
#include <time.h>                 // Para obter a data e hora (via NTP)

// Configurações Wi-Fi
// Rede para conexão (STA - cliente)
const char* WIFI_SSID = "Angela";                // Nome da rede Wi-Fi
const char* WIFI_PASSWORD = "bibinha14";         // Senha da rede Wi-Fi

// Rede do Access Point (AP - criado pelo ESP32)
const char* AP_SSID = "ESP32-PI";      // Nome da rede Wi-Fi criada pelo ESP32 
const char* AP_PASSWORD = "87654321";  // Senha da rede AP 

// Servidor Web
WebServer server(80);   // Inicializa servidor web na porta 80 (HTTP)

// Configurações do ThingSpeak
const char* THINGSPEAK_HOST = "api.thingspeak.com";  // Endereço do servidor ThingSpeak para envio dos dados
const int THINGSPEAK_PORT = 80;                      // Porta HTTP padrão
const char* THINGSPEAK_API_KEY = "TZM7GSS7KMMNGTW6"; // Chave API do ThingSpeak 

// Configurações do Firebase
#define FIREBASE_API_KEY "AIzaSyCbnVKmYqTEqh8aiVnFuHeifrxOcM4T-mU"                     // Inserir a chave da API do projeto Firebase
#define FIREBASE_DATABASE_URL "https://pgrupo8-esp32-default-rtdb.firebaseio.com/"     // Inserir a URL do banco de dados RTDB

// Pinos dos Sensores e Motor
// DHT11 (Temperatura)
#define DHT_PIN 26           // Pino conectado ao sensor DHT11
#define DHT_TYPE DHT11       // Define o tipo do sensor como DHT11
DHT dht(DHT_PIN, DHT_TYPE);  // Inicializa o objeto DHT com pino e tipo definidos

// KY-025 (Sensor de Efeito Hall para RPM)
#define HALL_SENSOR_PIN 35   // Pino conectado ao sensor KY-025 (sensor efeito Hall)
volatile int pulseCount = 0; // Variável para contar pulsos (declarada volatile pois é usada em interrupção)
float rpm = 0;               // Variável para armazenar o valor calculado de rotações por minuto

// Motor de Passo NEMA 17
#define STEP_PIN 32                    // Pino para sinal de passo do motor
#define DIR_PIN 33                     // Pino para definir direção do motor
#define BUTTON_PIN 14                  // Pino conectado ao botão de controle manual do motor
int stepDelay = 2000;                  // Tempo em microssegundos entre os pulsos do motor (velocidade)
int stepsPer90Deg = 50;                // Quantidade de passos para girar 90 graus 
bool motorState = false;               // Estado atual do motor (direção)
unsigned long lastButtonPressTime = 0; // Último instante que o botão mudou de estado (debounce)
unsigned long debounceDelay = 50;      // Delay para evitar leituras falsas do botão (50 ms)
bool lastButtonState = HIGH;           // Estado anterior do botão
bool buttonState = HIGH;               // Estado atual do botão

// Objetos do Firebase
FirebaseData fbdo;          // Objeto principal para operações com Firebase
FirebaseData stream;        // Objeto para a escuta em tempo real (comandos)
FirebaseAuth auth;          // Para autenticação
FirebaseConfig config;      // Para configuração

// Controle de tempo
unsigned long lastSensorReadTime = 0;     // Armazena o tempo da última leitura/enviada para ThingSpeak
unsigned long sensorReadInterval = 15000; // Intervalo de 15 segundos

// Assinatura dos procedimentos
void IRAM_ATTR handlePulse();                                                                       // Procedimento para contar pulsos do sensor (interrupção)
void handleRoot();                                                                                  // Procedimento para tratar página raiz "/"
void handleGira();                                                                                  // Procedimento para tratar ação de girar motor via web
void streamCallback(FirebaseStream data);                                                           // Procedimento chamado quando chega um dado do Firebase (comando do motor)
void streamTimeoutCallback(bool timeout);                                                           // Procedimento chamado se o stream do Firebase expirar
void enviarLeituraParaFirebase(float valor, String tipoSensor, String unidadeSensor, int idSensor); // Procedimento para enviar uma leitura completa para o Firebase
void girarMotorFirebase();                                                                          // Procedimento dedicado para o comando do Firebase


void setup() {
  Serial.begin(115200);  // Inicializa comunicação serial com taxa 115200 baud

  // Configura o pino do sensor KY-025 como entrada com resistor pull-up interno
  pinMode(HALL_SENSOR_PIN, INPUT_PULLUP);
  // Configura interrupção para detectar borda de subida no pino do sensor, chamando handlePulse
  attachInterrupt(digitalPinToInterrupt(HALL_SENSOR_PIN), handlePulse, RISING);

  pinMode(DHT_PIN, INPUT);  // Configura pino do DHT11 como entrada
  dht.begin();             // Inicializa sensor DHT

  // Configura pinos do motor e botão
  pinMode(STEP_PIN, OUTPUT);          // Configura STEP_PIN como saída
  pinMode(DIR_PIN, OUTPUT);           // Configura DIR_PIN como saída
  pinMode(BUTTON_PIN, INPUT_PULLUP);  // Botão com resistor pull-up interno
  digitalWrite(STEP_PIN, LOW);        // Inicializa pino STEP em nível baixo
  digitalWrite(DIR_PIN, LOW);         // Inicializa pino DIR em nível baixo

  // Configuração do Wi-Fi
  // Conecta o ESP32 à rede Wi-Fi definida (modo STA)
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Conectando ao Wi-Fi");
  // Aguarda conexão Wi-Fi, mostrando ponto a cada 500ms até conectar
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Conectado! IP: ");
  Serial.println(WiFi.localIP());  // Mostra o IP obtido na rede Wi-Fi

  // Configuração do Servidor Web Local
  // Inicializa o Access Point local para página web do ESP32
  WiFi.softAP(AP_SSID, AP_PASSWORD);
  IPAddress IP = WiFi.softAPIP();  // Obtém IP do Access Point
  Serial.print("AP ativo no IP: ");
  Serial.println(IP);
  // Configura as rotas da página web:
  server.on("/", handleRoot);                // Página inicial "/"
  server.on("/gira", handleGira);            // Endpoint para girar motor "/gira"
  server.begin();                            // Inicia o servidor web
  Serial.println("Servidor web iniciado.");

  // Configuração do Firebase
  Serial.println("Configurando Firebase...");
  config.api_key = FIREBASE_API_KEY;
  config.database_url = FIREBASE_DATABASE_URL;

  // Autenticação Anônima
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("Autenticação anônima com Firebase OK");
  } else {
    Serial.printf("Falha na autenticação: %s\n", config.signer.signupError.message.c_str());
  }
  
  // Atribuir a função de callback para o estado do token
  config.token_status_callback = tokenStatusCallback; 
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Sincroniza a hora do ESP32 com um servidor NTP para ter o timestamp correto
  configTime(-3 * 3600, 0, "pool.ntp.org", "time.nist.gov"); // UTC-3 para horário de Brasília
  
  // Inicia a escuta por comandos do motor
  if (!Firebase.RTDB.beginStream(&stream, "/comando")) {
      Serial.printf("Erro ao iniciar stream: %s\n", stream.errorReason().c_str());
  }
  Firebase.RTDB.setStreamCallback(&stream, streamCallback, streamTimeoutCallback);
  Serial.println("Escutando por comandos do Firebase em /comando");
}


void loop() {
  unsigned long currentMillis = millis();  // Tempo atual desde o boot do ESP

  // Verifica se já passou o intervalo para enviar os dados dos sensores
  if (currentMillis - lastSensorReadTime >= sensorReadInterval) {
    lastSensorReadTime = currentMillis;   // Atualiza o tempo da última leitura

    // Leitura da Velocidade em RPM 
    noInterrupts();                                         // Desativa interrupções para acessar pulseCount com segurança
    int pulses = pulseCount;                                // Lê quantidade de pulsos do sensor KY-025
    pulseCount = 0;                                         // Reseta contagem de pulsos para próxima janela
    interrupts();                                           // Reativa interrupções
    // Calcula RPM com base nos pulsos e intervalo de tempo
    rpm = (pulses * 60.0) / (sensorReadInterval / 1000.0);
    
    // Leitura da Temperatura
    float temperatura = dht.readTemperature();
    // Se a leitura falhar, retorna NaN (não é número)
    if (isnan(temperatura)) {
      Serial.println("Falha na leitura do DHT11!");
      temperatura = 0; // Define temperatura como zero para evitar erros
    }

    Serial.printf("Leitura: Temperatura = %.2f °C | Velocidade = %.2f RPM\n", temperatura, rpm);

    // Caso temperatura alta, exibe alerta
    if (temperatura > 50) {
      Serial.println("ALERTA: Motor está superaquecido!");
    }

    // Envio para o ThingSpeak (Cria cliente Wi-Fi para conexão TCP)
    WiFiClient client;
    // Tenta conectar ao host e porta HTTP
    if (client.connect(THINGSPEAK_HOST, THINGSPEAK_PORT)) {
      // Monta a URL GET com API Key e campos field1 (temperatura) e field2 (rpm)
      String url = String("/update?api_key=") + THINGSPEAK_API_KEY +
                   "&field1=" + String(temperatura) +
                   "&field2=" + String(rpm);
      // Envia requisição HTTP GET para ThingSpeak
      client.print(String("GET ") + url + " HTTP/1.1\r\n" +
                   "Host: " + THINGSPEAK_HOST + "\r\n" +
                   "Connection: close\r\n\r\n");
      Serial.println("Dados enviados para ThingSpeak!");
    } else {
      Serial.println("Falha na conexão com ThingSpeak");
    }

    // Envio para o Firebase
    // Envia a temperatura como uma leitura completa, para o sensor 1
    enviarLeituraParaFirebase(temperatura, "Sensor de Temperatura DHT11", "°C", 1);

    // Envia o RPM como outra leitura completa, para o sensor 2
    enviarLeituraParaFirebase(rpm, "Sensor de Velocidade KY-025", "RPM", 2);
  }
  
  // Leitura do estado do botão para controle manual do motor
  bool reading = digitalRead(BUTTON_PIN);
  if (reading != lastButtonState) {      // Se o estado mudou, atualiza tempo para debounce
    lastButtonPressTime = currentMillis;
  }

  // Verifica se o estado está estável (tempo debounce) para registrar mudança efetiva
  if ((currentMillis - lastButtonPressTime) > debounceDelay) {
    if (reading != buttonState) {
      buttonState = reading;
      if (buttonState == LOW) {  // Botão pressionado (ativo em LOW)
        girarMotorFirebase(); // Reutiliza a mesma função de girar o motor
        Serial.println(motorState ? "Girou 90 graus (botão)" : "Voltou 90 graus (botão)");
      }
    }
  }
  lastButtonState = reading;  // Atualiza estado anterior do botão

  // Aguarda e responde requisições HTTP da página web
  server.handleClient();

}

// Procedimento para enviar uma leitura completa para o Firebase
void enviarLeituraParaFirebase(float valor, String tipoSensor, String unidadeSensor, int idSensor) {
  
  // Cria um objeto JSON para construir a estrutura de dados
  FirebaseJson json;

  // Obtém a data e hora atual
  time_t now = time(nullptr);
  char dataISO[30];
  strftime(dataISO, sizeof(dataISO), "%Y-%m-%dT%H:%M:%SZ", gmtime(&now));

  bool emAlerta = false;
  String descricaoAlerta = "Normal";

  //Alerta para Temperatura acima de 50°C
  if (tipoSensor.indexOf("Temperatura") != -1 && valor > 50.0){
    emAlerta = true;
    descricaoAlerta = "ALERTA: Motor está superaquecido!";
  }

  // Preenche o objeto JSON com todos os dados, incluindo os aninhados.
  json.set("idleitura", (int)now); // Usa o timestamp como ID único simples
  json.set("data", dataISO);
  json.set("valor", valor);
  json.set("alerta", emAlerta); 
  json.set("descricaoAlerta", descricaoAlerta);

  // Objeto Sensor
  json.set("sensor/idsensor", idSensor);
  json.set("sensor/tipo", tipoSensor);
  json.set("sensor/status", true);
  json.set("sensor/unidade", unidadeSensor);

  // Objeto Esteira (aninhado dentro de Sensor)
  json.set("sensor/esteira/idesteira", 1);
  json.set("sensor/esteira/nome", "Esteira 1");
  json.set("sensor/esteira/status", true);

  // Objeto Setor (aninhado dentro de Esteira)
  json.set("sensor/esteira/setor/idsetor", 1);
  json.set("sensor/esteira/setor/nome", "Setor de Tecelagem");
  json.set("sensor/esteira/setor/descricao", "Produção dos tecidos e cordões que irão compor as big bags.");

  // Objeto Empresa (aninhado dentro de Setor)
  json.set("sensor/esteira/setor/empresa/idempresa", 1);
  json.set("sensor/esteira/setor/empresa/nome", "Pack Big Bag Industria de Embalagens Ltda");
  json.set("sensor/esteira/setor/empresa/cnpj", "13.478.113/0003-00");
  json.set("sensor/esteira/setor/empresa/endereco", "Av. Francisco Gonçalves, 409 - Vila Braga, Aguaí - SP, 13860-000");
  json.set("sensor/esteira/setor/empresa/website", "https://packbag.com.br/");
  json.set("sensor/esteira/setor/empresa/email", "vendas@packbag.com.br");

  // Envia o JSON para o Firebase
  // Usa pushJSON para criar uma chave única (-NqMxyz...) dentro de /leituras
  String path = "/leituras";
  if (Firebase.RTDB.pushJSON(&fbdo, path.c_str(), &json)) {
    Serial.printf("Leitura de %s enviada para Firebase com sucesso.\n", tipoSensor.c_str());
  } else {
    Serial.printf("Erro ao enviar leitura de %s: %s\n", tipoSensor.c_str(), fbdo.errorReason().c_str());
  }
}

// Procedimento chamado quando chega um dado do Firebase (comando do motor)
void streamCallback(FirebaseStream data) {
  // Verifica se o evento é uma atualização (put) e se o dado é um JSON.
  if (data.eventType() == "put" && data.dataTypeEnum() == fb_esp_rtdb_data_type_json) {
    Serial.println("\n[FIREBASE] Comando JSON recebido!");
    FirebaseJson *json = data.to<FirebaseJson *>(); // Converte o dado para um objeto JSON.
    FirebaseJsonData result;
    String acao = "";
    // Tenta ler a chave "acao" do JSON.
    if (json->get(result, "acao") && result.type == "string") {
      acao = result.to<String>();
    }
    // Se a ação for "girar", executa a função do motor.
    if (acao == "girar") {
      Serial.println(">>> Ação 'girar' identificada. Acionando motor! <<<");
      girarMotorFirebase();
      // Medida de segurança: reseta a ação no Firebase para não executar de novo.
      Firebase.RTDB.setString(&fbdo, "/comando/acao", "nenhuma");
      Serial.println("[FIREBASE] Ação do comando resetada.");
    } else {
      Serial.printf("[FIREBEASE] Ação recebida ('%s') não é 'girar'.\n", acao.c_str());
    }
    delete json; // Libera a memória do JSON.
  }
}

// Procedimento chamado se o stream do Firebase expirar
void streamTimeoutCallback(bool timeout) {
  if (timeout) {
    Serial.println("Stream do Firebase expirou, tentando reconectar...");
  }
}

// Procedimento de interrupção para contar pulsos do sensor KY-025
void IRAM_ATTR handlePulse() {
  pulseCount++;  // Incrementa contador a cada pulso detectado
}

// Procedimento que monta e envia a página web inicial
void handleRoot() {
  String html = "<!DOCTYPE html><html><head><title>Controle Motor</title></head><body>"
                "<h2>Controle Remoto</h2><form action='/gira'><button type='submit'>Girar 90°</button></form>"
                "</body></html>";
  server.send(200, "text/html", html);  // Envia a página com código HTML ao cliente
}

// Procedimento que gira o motor quando botão da página web é pressionado
void handleGira() {
  girarMotorFirebase();
  Serial.println(motorState ? "Motor girou 90 graus (web)" : "Motor voltou 90 graus (web)");

  // Redireciona o cliente para a página inicial após a ação
  server.sendHeader("Location", "/");
  server.send(303);
}

//Procedimento dedicado para girar o motor
void girarMotorFirebase(){
  motorState = !motorState;       // Alterna direção do motor
  digitalWrite(DIR_PIN, motorState);
  // Envia pulsos STEP para girar 90 graus
  for (int i = 0; i < stepsPer90Deg; i++) {
    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(stepDelay);
    digitalWrite(STEP_PIN, LOW);
    delayMicroseconds(stepDelay);
  }
}