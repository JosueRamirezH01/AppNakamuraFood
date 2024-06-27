import 'package:mysql1/mysql1.dart';

class Connection {
    String host = '137.184.54.213';
    String user = 'atonGloR';
    String password = '£4dAGE310N';
    String db = 'elivhu_prueba';
    int port = 3306;

    Connection();


    Future<MySqlConnection> getConnection() async {
        var settings = ConnectionSettings(
            host: host,
            port: port,
            user: user,
            password: password,
            db: db,
        );
        try {
            final conn = await MySqlConnection.connect(settings);
            // print('Conexión establecida correctamente');
            return conn;
        } catch (e) {
            print('Error al establecer la conexión: $e');
            rethrow;
        }
    }
}
