


import 'package:mysql1/mysql1.dart';

class Connection{

    String host = 'chifalingling.restaupe.com',
    //chifalingling.restaupe.com
    user = 'atonGloR',
    password = '£4dAGE310N',
    db = 'bd_restaurant';
     int port = 3306;

    Connection();

    Future<MySqlConnection> getConnection() async {
        var settings =  ConnectionSettings(
            host: host,
            port: port,
            user: user,
            password: password,
            db: db,
        );

        try {
            final conn = await MySqlConnection.connect(settings);
            print('Conexión establecida correctamente');
            return conn;
        } catch (e) {
            print('Error al establecer la conexión: $e');
            rethrow; // Relanza la excepción para manejarla en el código que llama a este método
        }
    }
}
