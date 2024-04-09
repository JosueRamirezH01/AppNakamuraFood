import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/utils/shared_pref.dart';


//SELECT * FROM `mesas` WHERE piso_id = 14

class MesaServicio {
  final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

  Future<List<Mesa>> consultarMesas( int idPiso, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT * FROM mesas WHERE piso_id = ?';
      final results = await conn.query(query, [idPiso]);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return [];
      } else {
        List<Mesa> mesas = results.map((row) => Mesa.fromJson(row.fields)).toList();
        final jsonMesasData = json.encode(mesas);
        //_sharedPref.save('pisos', jsonPisosData);
        print('Lista de pisos guardada en SharedPreferences: $jsonMesasData');
        return mesas;
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

  Future<Mesa?> actualizarMesa(int? idMesa, int estadoMesa, BuildContext context) async {
    MySqlConnection? conn;
    String estDisMesa = 'Disponible';

    try {
      conn = await _connectionSQL.getConnection();

      if (estadoMesa == 2){
        estDisMesa = 'Ocupado';
      }
      if(estadoMesa == 3){
        estDisMesa = 'Precuenta';
      }
      const query = 'UPDATE mesas SET est_dis_mesa=?, estado_mesa=? WHERE id = ?';
      final results = await conn.query(query, [estDisMesa, estadoMesa, idMesa]);
      if (results.affectedRows == 0) {
        print('No se encontró ninguna mesa con el ID proporcionado.');
        return null;
      } else {
        print('Mesa actualizada correctamente.');
        return Mesa(
          id: idMesa,
          estDisMesa: estDisMesa,
          estadoMesa: estadoMesa,
        );
      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return null;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
