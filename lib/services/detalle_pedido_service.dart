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
            cantidad_actualizada ,
            cantidad_exacta,
            cantidad_real,
            precio_producto,
            comentario,
            estado_detalle,
            created_at,
            updated_at ) VALUES (
              ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
            )
        ''',
            [
              idPedido, // id pedido
              producto.id, // id prodcuto
              producto.stock, // cantidad producto
              producto.stock, // cantidad actualizada
              null, // cantidad exacta
              producto.stock, // cantidad real
              producto.precioproducto, // precio producto
              producto.comentario, // comentario
              1, // estado detalle
              DateTime.now().toUtc(),
              DateTime.now().toUtc()
            ]
        );

        final pedidoDetalleIdResult = await conn.query('SELECT LAST_INSERT_ID()');
        int pedidoDetalleId = pedidoDetalleIdResult.first[0] as int;

        final pedidoDetalleResult = await conn.query('SELECT * FROM pedido_detalles WHERE id_pedido_detalle  = ?', [pedidoDetalleId]);

        if (!pedidoDetalleResult.isEmpty) {
          Detalle_Pedido detallePedido = pedidoDetalleResult.map((row) => Detalle_Pedido.fromJson(row.fields)).first;
          detallesPedido.add(detallePedido);
          print('Detalle insertado correctamente para el producto ${producto.nombreproducto}');
        } else {
          print('No se pudo insertar el detalle para el producto ${producto.nombreproducto}');
        }
      }
      return [];
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
