import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/utils/shared_pref.dart';

class PedidoServicio {
  final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

  Future<int?> consultarMesasDisponibilidad( int? idUsuario, int? idMesa ,BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT id_pedido FROM `pedidos` WHERE id_usuario = ?   AND id_mesa = ?';
      final results = await conn.query(query, [idUsuario, idMesa]);
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

  Future<int?> actualizarPedido(int? idPedido, int? idMesa, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'UPDATE pedidos SET id_mesa = ? WHERE id_pedido = ?';
      final results = await conn.query(query, [idMesa, idPedido]);
      if (results.affectedRows == 1) {
        print('Pedido actualizado correctamente.');
        return idPedido;
      } else {
        print('No se pudo actualizar el pedido.');
        return null;
      }
    } catch (e) {
      print('Error al realizar la consulta de actualización: $e');
      return null;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

//UPDATE pedidos  SET  id_pedido = 57 WHERE   p.id_pedido = 818;

}
