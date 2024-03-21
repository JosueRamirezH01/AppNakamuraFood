


import 'package:mysql1/mysql1.dart';

class Connection{


    Connection();

    void getConnetion() async {
      var settings = ConnectionSettings(
        host: '127.0.0.1',
        port: 3306,
        user: 'root',
        password: '',
        db: 'bd_restau',
      );

      var conn = await MySqlConnection.connect(settings);

      var results = await conn.query('SELECT email FROM usuarios WHERE id = 42');

      if (results.isNotEmpty) {
        var email = results.first[0]['email'];
        print('Correo obtenido: $email');
      } else {
        print('No se encontró ningún correo para el ID proporcionado.');
      }

      await conn.close();
    }
}