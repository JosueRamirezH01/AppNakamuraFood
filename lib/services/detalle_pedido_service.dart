import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/pedido.dart';
import 'package:restauflutter/model/producto.dart';
import 'package:restauflutter/utils/shared_pref.dart';

class DetallePedidoServicio {
  final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

  Future<List<Detalle_Pedido>> crearDetallePedidoPrueba(int idPedido, List<Producto> productos, BuildContext context) async {
    MySqlConnection? conn;
    List<Detalle_Pedido> detallesPedido = [];
    try {
      conn = await _connectionSQL.getConnection();
      print('Id de pedido creado${idPedido}');

      for (Producto producto in productos) {
        final results = await conn.query('''
          INSERT INTO pedido_detalles (
            id_pedido,
            id_producto,
            cantidad_producto,
            cantidad_real,
            precio_producto,
            comentario,
            estado_detalle,
            created_at,
            updated_at ) VALUES (
              ?, ?, ?, ?, ?, ?, ?, ?, ?
            )
        ''',
            [
              idPedido, // id pedido
              producto.id, // id prodcuto
              producto.stock, // cantidad producto
              producto.stock, // cantidad real
              producto.precioproducto, // precio producto
              producto.comentario, // comentario
              1, // estado detalle
              DateTime.now().toUtc(),
              DateTime.now().toUtc()
            ]
        );

        final pedidoDetalleIdResult = await conn.query(
            'SELECT LAST_INSERT_ID()');
        int pedidoDetalleId = pedidoDetalleIdResult.first[0] as int;

        print('SERVICIO DE DETALLE DE PEDIDO $pedidoDetalleId');

        final pedidoDetalleResult = await conn.query(
            'SELECT * FROM pedido_detalles WHERE id_pedido_detalle  = ?',
            [pedidoDetalleId]);

        if (!pedidoDetalleResult.isEmpty) {
          Detalle_Pedido detallePedido = pedidoDetalleResult
              .map((row) => Detalle_Pedido.fromJson(row.fields))
              .first;
          detallesPedido.add(detallePedido);
          print('Detalle insertado correctamente para el producto ${producto
              .nombreproducto}');
        } else {
          print('No se pudo insertar el detalle para el producto ${producto
              .nombreproducto}');
        }
      }
      print('LISTA DE DETALLES DE PEDIDOS AL CREAR ${detallesPedido[0].id_pedido}');
      return detallesPedido;
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<List<Detalle_Pedido>> actualizarCantidadProductoDetallePedido(int? pedidoid,List<Detalle_Pedido> detalle_pedidos, List<Producto> productos, double pedidoTotal, BuildContext context) async {
    MySqlConnection? conn;
    try {
      int? idpedido = 0;

      conn = await _connectionSQL.getConnection();

      if(pedidoid == 0){
        idpedido = detalle_pedidos[0].id_pedido;
        print('PEDIDO REFERSH$idpedido');
      }else{
        idpedido = pedidoid;
      }

      print('PEDIDOID $idpedido');

      Set<int?> idsProductosEnDetalle = detalle_pedidos.map((detalle) => detalle.id_pedido_detalle).toSet();
      final existingDetailCombined = [];
      for (Producto producto in productos) {
        final existingDetail = await conn.query('''
        SELECT id_pedido_detalle
        FROM pedido_detalles
        WHERE id_pedido = ?
        AND id_producto = ?
      ''', [idpedido, producto.id]);
        existingDetailCombined.addAll(existingDetail);

        if (existingDetail.isEmpty) {
          final results = await conn.query('''
          INSERT INTO pedido_detalles (
              id_pedido,
              id_producto,
              cantidad_producto,
              cantidad_real,
              precio_producto,
              comentario,
              estado_detalle,
              created_at,
              updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
            idpedido, // id pedido
            producto.id, // id producto
            producto.stock, // cantidad producto
            producto.stock, // cantidad real
            producto.precioproducto, // precio producto
            producto.comentario, // comentario
            1, // estado detalle
            DateTime.now().toUtc(),
            DateTime.now().toUtc()
          ]);
          idsProductosEnDetalle.add(producto.id);
        } else {
          double precio = (producto.precioproducto! * producto.stock!);
          print('STOCK ${producto.stock}');
          await conn.query('''
          UPDATE pedido_detalles 
          SET cantidad_producto = ?,
              cantidad_real = ?,
              precio_producto = ?,
              comentario = ?,
              updated_at = ?
          WHERE id_pedido = ? AND id_producto = ?
        ''', [
            producto.stock,
            producto.stock,
            precio,
            producto.comentario,
            DateTime.now().toUtc(),
            idpedido,
            producto.id
          ]);
        }

        final existingDetailDespues = await conn.query('''
        SELECT id_pedido_detalle
        FROM pedido_detalles
        WHERE id_pedido = ?
        AND id_producto = ?
      ''', [idpedido, producto.id]);
        existingDetailCombined.addAll(existingDetailDespues);
        print('IDE existingDetailDespues $existingDetailDespues');
        List<int?> existingIds = existingDetailCombined.map((
            row) => row['id_pedido_detalle'] as int?).toList();
        print('LISTA DE ID COMBINADA $existingIds');
        int? missingId;
        for (Detalle_Pedido detalle in detalle_pedidos) {
          print('ID DETALLE DE PEDIDO ${detalle.id_pedido_detalle}');
          if (!existingIds.contains(detalle.id_pedido_detalle)) {
            missingId = detalle.id_pedido_detalle;
            print('IDE QUE FALTA $missingId');
            break;
          }
        }

        if (missingId != null) {
          await conn.query('''
    DELETE FROM pedido_detalles WHERE id_pedido_detalle = ?
  ''', [missingId]);
          print('Se eliminó el registro con ID: $missingId');
        } else {
          print('No hay registros para eliminar');
        }
      }

      await conn.query('''
      UPDATE pedidos SET Monto_total=?  WHERE id_pedido = ?
    ''', [pedidoTotal, idpedido]);

      final results = await conn.query('''
      SELECT * FROM pedido_detalles WHERE id_pedido = ?
      ''', [idpedido]);

      List<Detalle_Pedido> detalle_pedido_actualizado = results.map((row) => Detalle_Pedido.fromJson(row.fields)).toList();

      print('Cantidad actualizada correctamente en los detalles de pedido');
      return detalle_pedido_actualizado;
    } catch (e) {
      print('Error al actualizar la cantidad del producto en los detalles de pedido: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }



}
