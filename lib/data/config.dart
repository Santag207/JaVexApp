// ============================================================
// CONFIGURACIÓN DEL MOCK SERVER
// ============================================================
// IMPORTANTE: Para correr con el mock server:
// 1. Abre una terminal y ejecuta:
//    cd mock-server
//    json-server --watch db.json --port 3000 --host 0.0.0.0
// 2. Cambia la IP de abajo por la IP de tu PC
//    (ejecuta 'ipconfig' en la terminal para verla, busca la IPv4 de WiFi)
// 3. Tu celular y tu PC deben estar en la misma red WiFi
// 4. Si usas emulador de Android Studio, usa: http://10.0.2.2:3000
// ============================================================

class ApiConfig {
  static const String baseUrl = 'http://192.168.2.51:3000';
}
