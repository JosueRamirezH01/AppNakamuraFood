import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/home/home_page.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/pedido.dart';
import 'package:restauflutter/utils/shared_pref.dart';

import '../model/pedido.dart';

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
   Future<int> crearPedidoPrueba( Pedido pedido, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();
      const query = 'INSERT INTO pedidos ( id_entorno, id_cliente,id_usuario, id_tipo_ped, id_mesa, id_establecimiento, id_serie_pedido, Monto_total, fecha_pedido, estado_pedido) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
      final results = await conn.query( query, [
          pedido.idEntorno,
          pedido.idCliente,
          pedido.idUsuario,
          pedido.idTipoPedido,
          pedido.idMesa,
          pedido.idEstablecimiento,
          pedido.idSeriePedido,
          pedido.montoTotal,
          pedido.fechaPedido,
          pedido.estadoPedido,
        ]
      );
      if (results.affectedRows == 0) {
        print('No se pudo insertar el pedido.');
        return 0;
      } else {
        final idResult = await conn.query('SELECT LAST_INSERT_ID()');
        int lastInsertId = idResult.first[0] as int;
        return lastInsertId;
      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return 0;
    } finally {
      if (conn != null) {
        conn.close();
      }
    }
  }

  Future<List<Pedido>> obtenerPedidos( int id_establecimiento, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT * FROM pedidos where id_establecimiento = ? ';
      final results = await conn.query(query,[id_establecimiento] );
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return [];
      } else {
        List<Pedido> detallePedido = results.map((row) => Pedido.fromJson(row.fields)).toList();
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


  Future<List<Pedido>> obtenerListasPedidos( SubOptTypes variable, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();
      int id_tipo_ped = 1;
     if(variable == SubOptTypes.llevar){
        id_tipo_ped = 2;
      }else if(variable == SubOptTypes.delivery){
        id_tipo_ped = 3;
      }
      const query = 'SELECT * FROM pedidos where id_tipo_ped = ? ORDER BY correlativo_pedido DESC ';
      final results = await conn.query(query,[id_tipo_ped] );
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return [];
      } else {
        List<Pedido> listaPedido = results.map((row) => Pedido.fromJson(row.fields)).toList();
        print('ID del pedido recuperado: $listaPedido');
        return listaPedido;
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
