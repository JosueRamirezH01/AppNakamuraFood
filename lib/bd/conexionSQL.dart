
import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';

class ConnectionSQL {
  late PostgreSQLConnection _connection;

  Future<void> getConnectionSQL() async {
    _connection = PostgreSQLConnection(
      'dpg-cnjq7kfjbltc73cgbgvg-a.oregon-postgres.render.com',
      5432,
      'bd_mecanico',
      queryTimeoutInSeconds: 3600,
      timeoutInSeconds: 3600,
      username: 'mecanica',
      password: 'yYWjhrMqCN8Sez8pTX0ncubFHuTxjmRc',
      useSSL: true,
    );

    try {
      await _connection.open();
      if (kDebugMode) {
        print('Conexión a PostgreSQL establecida');
      }
    } catch (e) {
      // Si ocurre un error al establecer la conexión, imprime el mensaje de error
      if (kDebugMode) {
        print('Error al establecer la conexión: $e');
      }
    }
  }

  PostgreSQLConnection get connection => _connection;

  Future<void> closeConnection() async {
    await _connection.close();
  }
}
