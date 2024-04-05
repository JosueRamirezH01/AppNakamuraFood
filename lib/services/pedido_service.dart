import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/utils/shared_pref.dart';

class PedidoServicio {
  final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

  Future<int?> consultarMesasDisponibilidad( int? idUsuario, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT id_pedido FROM `pedidos` WHERE id_usuario = ?';
      final results = await conn.query(query, [idUsuario]);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return null;
      } else {
        final idPedido = results.first.fields['id_pedido'] as int;
        print('ID del pedido recuperado: $idPedido');
        return idPedido;
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

  Future<List<Detalle_Pedido>> consultaObtenerDetallePedido( int? idPedido, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT * FROM pedido_detalles WHERE id_pedido = ?';
      final results = await conn.query(query, [idPedido]);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return [];
      } else {
        List<Detalle_Pedido> detallePedido = results.map((row) => Detalle_Pedido.fromJson(row.fields)).toList();
        print('ID del pedido recuperado: $detallePedido');
        return detallePedido;
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
