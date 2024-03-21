


import 'package:mysql1/mysql1.dart';

class Connection{

    static String host = '10.0.2.2',
    user = 'root',
    password = '',
    db = 'bd_restau';
    static int port = 3306;

    Connection();

    Future<MySqlConnection> getConnection() async {
    var settings =  ConnectionSettings(
    host: host,
    port: port,
    user: user,
    password: password,
    db: db
    );
    return await MySqlConnection.connect(settings);
    }
}
