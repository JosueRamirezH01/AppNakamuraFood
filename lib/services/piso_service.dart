
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

  Future<List<Piso>> consultarPisos( int idEstablecimiento, BuildContext context ) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT * FROM pisos where id_establecimiento = ? ';
      final results = await conn.query(query, [idEstablecimiento]);
      if (results.isEmpty) {
        Fluttertoast.showToast(
          msg: "No se encontraron datos en las tablas.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('No se encontraron datos en las tablas.');
        return [];
      } else {
        List<Piso> pisos = results.map((row) => Piso.fromJson(row.fields)).toList();
        final jsonPisosData = json.encode(pisos);
        _sharedPref.save('pisos', jsonPisosData);
        print('Lista de pisos guardada en SharedPreferences:');
        print(pisos);
        return pisos;
      }
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