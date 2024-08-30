import 'package:flutter/cupertino.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';

class EntornoService {
  // final Connection _connectionSQL = Connection();

  // Future<int> consultarEntorno( BuildContext context) async {
  //   MySqlConnection? conn;
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //     const query = 'SELECT id_entorno FROM `empresas` WHERE 1';
  //     final results = await conn.query(query);
  //     final entorno = results.first['id_entorno'];
  //     print('entorno ${entorno} tipo ${entorno.runtimeType}');
  //
  //     return entorno;
  //   } catch (e) {
  //     print('Error al realizar la consulta: $e');
  //     return 0;
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }
}