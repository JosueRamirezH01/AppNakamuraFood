import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/piso.dart';
import 'package:restauflutter/utils/shared_pref.dart';

class PisoServicio {
  final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

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

  Future<Piso> consultarPiso( int idmesapiso, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();
      const query = 'SELECT * FROM `pisos` WHERE id = ? ';
      final results = await conn.query(query, [idmesapiso]);
        Map<String, dynamic> pisoData = results.first.fields;
        Piso piso = Piso.fromJson(pisoData);
        return piso;
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return Piso();
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
