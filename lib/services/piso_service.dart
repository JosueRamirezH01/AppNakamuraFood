import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/piso.dart';
import 'package:restauflutter/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class PisoServicio {
  final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

  final String _url = 'chifalingling.restaupe.com';
  final String _api = '/api/auth';

  Future<List<Piso>?> getAll(String? accessToken) async {
    try {
      Uri url = Uri.https(_url, '$_api/pisosActivos');
      Map<String, String> headers = {
        'Content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      print('Datos recibidos: $data');
      Piso empresa = Piso.fromJsonList(data);
      return empresa.listPiso;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }




  Future<List<Piso>> consultarPisos( int idEstablecimiento, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();
      const query = 'SELECT DISTINCT p.* FROM pisos p WHERE EXISTS ( SELECT 1 FROM mesas m WHERE m.piso_id = p.id AND id_establecimiento = ? AND m.estado_mesa != 0)';
      final results = await conn.query(query, [idEstablecimiento]);
        List<Piso> pisos =
            results.map((row) => Piso.fromJson(row.fields)).toList();
        final jsonPisosData = json.encode(pisos);
        //_sharedPref.save('pisos', jsonPisosData);
        print('Lista de pisos guardada en SharedPreferences: $jsonPisosData');
        return pisos;
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }


}
