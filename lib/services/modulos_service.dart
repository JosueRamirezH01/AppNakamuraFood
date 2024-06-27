import 'package:flutter/cupertino.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';

class ModuloServicio {
  final Connection _connectionSQL = Connection();

  Future<bool> consultarRestriccion(BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT rs.estado_restriccion_stock FROM restriccion_stocks as rs WHERE 1';
      final results = await conn.query(query);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return false;
      } else {
        var detailRow = results.first;
        int isEnable = detailRow['estado_restriccion_stock'];
        if(isEnable == 1){
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

  Future<bool> consultarItemsIndependientes(BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();
      const query = 'SELECT ti.estado_item_independiente FROM items_independientes as ti WHERE 1';
      final results = await conn.query(query);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return false;
      } else {
        var detailRow = results.first;
        int isEnable = detailRow['estado_item_independiente'];
        if(isEnable == 1){
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
}