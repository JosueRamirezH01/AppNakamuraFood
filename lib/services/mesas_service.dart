import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/model/piso.dart';
import 'package:restauflutter/utils/shared_pref.dart';


//SELECT * FROM `mesas` WHERE piso_id = 14

class MesaServicio {
  final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

  Future<List<Mesa>> consultarTodasMesas( List<Piso> pisos, BuildContext context) async {
    print('-------------------------');
    print('Todas mesas');
    MySqlConnection? conn;
    List<Mesa> allMesas = [];

    try {
      conn = await _connectionSQL.getConnection();


      for (Piso piso in pisos) {
        print('Sooloooooooooooooooooo ---------- ${piso.id}');
        const query = 'SELECT * FROM mesas WHERE piso_id = ?';
        final results = await conn.query(query, [piso.id]);
        print('aui muere ${results}');

        if (results.isEmpty) {
          print('No se encontraron mesas para el piso ${piso.id}.');
        } else {
          List<Mesa> mesas = results.map((row) => Mesa.fromJson(row.fields)).toList();
          allMesas.addAll(mesas);
        }
      }
      if (allMesas.isEmpty) {
        print('No se encontraron mesas en ningún piso.');
      } else {
        final jsonMesasData = json.encode(allMesas);
        print('Lista de mesas guardada en SharedPreferences: $jsonMesasData');
      }

      allMesas.forEach((element) {
        print('NOMBRE : ${element.nombreMesa}, PISO ${element.pisoId}');
      });

      return allMesas;
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }


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

  Future<List<Mesa>> consultarMesasDisponibles( int? idPiso,  BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT * FROM mesas WHERE piso_id = ? AND estado_mesa = 1';
      final results = await conn.query(query, [idPiso]);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return [];
      } else {
        List<Mesa> mesas = results.map((row) => Mesa.fromJson(row.fields)).toList();
        final jsonMesasData = json.encode(mesas);
        //_sharedPref.save('pisos', jsonPisosData);
        print('Lista de mesas Disponibles en SharedPreferences: $jsonMesasData');
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

    try {
      conn = await _connectionSQL.getConnection();
      const query = 'UPDATE mesas SET estado_mesa=? WHERE id = ?';
      final results = await conn.query(query, [estadoMesa, idMesa]);
      if (results.affectedRows == 0) {
        print('No se encontró ninguna mesa con el ID proporcionado.');
        return null;
      } else {
        print('Mesa actualizada correctamente.');
        return Mesa(
          id: idMesa,
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
