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

  Future<List<Mesa>> consultarTodasMesas(List<Piso> pisos, BuildContext context) async {
    MySqlConnection? conn;
    List<Mesa> allMesas = [];

    try {
      conn = await _connectionSQL.getConnection();

      for (Piso piso in pisos) {
        const query = 'SELECT * FROM mesas WHERE piso_id = ?';
        final results = await conn.query(query, [piso.id]);
        List<Mesa> mesas = results.map((row) => Mesa.fromJson(row.fields)).toList();
        if (mesas.isNotEmpty) {
          allMesas.addAll(mesas);
        } else {
          print('No hay mesas en el piso ${piso.id}, pasando al siguiente piso.');
        }
      }

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
  Future<bool> consultarMesa( int idMesa, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT * FROM mesas WHERE id = ?';
      final results = await conn.query(query, [idMesa]);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return false;
      } else {
        Mesa mesa = Mesa.fromJson(results.first.fields);
        print('---------${mesa.estadoMesa}');
        final jsonMesasData = json.encode(mesa);
        print('Lista de pisos guardada en SharedPreferences: $jsonMesasData');
        if(mesa.estadoMesa == 1){
          return true;
        }else{
          return false;
        }

      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return false;
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
