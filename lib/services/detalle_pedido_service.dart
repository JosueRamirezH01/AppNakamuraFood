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

  Future<List<Detalle_Pedido>> eliminarCantidadProductoDetallePedidoImprimir(
      int? pedidoid,
      List<Producto> productos,
      double pedidoTotal,
      BuildContext context
      ) async {
    MySqlConnection? conn;
    List<Detalle_Pedido> detallesPedido = [];
    try {
      conn = await _connectionSQL.getConnection();

      final resultst = await conn.query('''
      SELECT * FROM pedido_detalles WHERE id_pedido = ?
      ''', [pedidoid]);

      List<Detalle_Pedido> listaBD = resultst.map((row) =>
          Detalle_Pedido.fromJson(row.fields)).toList();


      for (var detalle in listaBD) {
        bool found = false;
        for (var product in productos) {
          if (product.id == detalle.id_producto) {
            found = true;
            break;
          }

        }
        if (!found) {

          print('ID OBTENIDO PARA ELIMINAR IMPRESORA----------------------------: ${detalle.id_pedido_detalle}');
          detalle.cantidad_real = 0;
          detalle.cantidad_producto = 0;
          detallesPedido.add(detalle);
        }

      }

      print('---- Productos para la otraq lista -----');
      detallesPedido.forEach((element) {

        print(element.id_producto);
        print(element.cantidad_producto);
      });
      return detallesPedido;
    }catch (e) {
      print('Error al realizar la consulta: $e');
      return []; // Retorna 0 si ocurre algún error
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }



  Future<List<Detalle_Pedido>> actualizarCantidadProductoDetallePedidoPrueba(
      int? pedidoid,
      List<Producto> productos,
      double pedidoTotal,
      BuildContext context
      ) async {
    MySqlConnection? conn;
    List<Detalle_Pedido> detallesPedido = [];
    detallesPedido.clear();
    print('-------------- ID PEDIDO ${pedidoid}');
    print('-------------- PRODUCTOS ${productos}');
    print('-------------- PRECIO TOTAL ${pedidoTotal}');

    try {

      conn = await _connectionSQL.getConnection();

      final resultst = await conn.query('''
      SELECT * FROM pedido_detalles WHERE id_pedido = ?
      ''', [pedidoid]);

      List<Detalle_Pedido> listaBD = resultst.map((row) =>
          Detalle_Pedido.fromJson(row.fields)).toList();

      print('LISTADO OBTENIDO POR LA CONSULTA $listaBD');


      for (var detalle in listaBD) {
        bool found = false;
        for (var product in productos) {
          if (product.id == detalle.id_producto) {
            found = true;
            break;
          }
        }
        if (!found) {
          print('ID OBTENIDO PARA ELIMINAR: ${detalle.id_pedido_detalle}');
          await conn.query(
              'DELETE FROM pedido_detalles WHERE id_pedido_detalle = ?',
              [detalle.id_pedido_detalle]);
        }
      }

      for (final producto in productos) {
        var existingDetail = await conn.query(
            'SELECT id_pedido_detalle, cantidad_producto, comentario FROM pedido_detalles WHERE id_pedido = ? AND id_producto = ?',
            [pedidoid, producto.id]);
        print('LISTA $existingDetail');
        producto.comentario = producto.comentario == 'null'? null : producto.comentario;
        if (existingDetail.isEmpty) {
          Detalle_Pedido nuevoDetalle = Detalle_Pedido(
            id_pedido: pedidoid,
            id_producto: producto.id,
            cantidad_producto: producto.stock,
            cantidad_real: producto.stock,
            precio_producto: producto.precioproducto,
            comentario: producto.comentario,
            estado_detalle: 1,

          );

          await conn.query(
              'INSERT INTO pedido_detalles (id_pedido, id_producto, cantidad_producto, cantidad_real, precio_producto, comentario, estado_detalle, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
              [
                nuevoDetalle.id_pedido,
                nuevoDetalle.id_producto,
                nuevoDetalle.cantidad_producto,
                nuevoDetalle.cantidad_producto,
                nuevoDetalle.precio_producto,
                nuevoDetalle.comentario,
                nuevoDetalle.estado_detalle,
                DateTime.now().toUtc(),
                DateTime.now().toUtc()
              ]);
          detallesPedido.add(nuevoDetalle);
        } else {
          var detailRow = existingDetail.first;
          int cantidadProductoExistente = detailRow['cantidad_producto'];
          String? nomComent = detailRow['comentario']?.toString();
          int productoRestado = producto.stock! - cantidadProductoExistente;
          print('Cantidad Restado $productoRestado');
          print(' COMENTARIO ACTUALZIADO ${producto.comentario}');
          if(productoRestado < 0 ){
            Detalle_Pedido nuevoDetalle2 = Detalle_Pedido(
              id_pedido: pedidoid,
              id_producto: producto.id,
              cantidad_producto: productoRestado,
              cantidad_real: producto.stock,
              precio_producto: producto.precioproducto,
              comentario: producto.comentario,
              estado_detalle: 1,
            );
            detallesPedido.add(nuevoDetalle2);
          }else if(productoRestado>0){
            Detalle_Pedido nuevoDetalle2 = Detalle_Pedido(
              id_pedido: pedidoid,
              id_producto: producto.id,
              cantidad_producto: productoRestado,
              cantidad_real: producto.stock,
              precio_producto: producto.precioproducto,
              comentario: producto.comentario,
              estado_detalle: 1,
            );
            detallesPedido.add(nuevoDetalle2);
          }else if(nomComent != producto.comentario){
            Detalle_Pedido nuevoDetalle2 = Detalle_Pedido(
              id_pedido: pedidoid,
              id_producto: producto.id,
              cantidad_producto: producto.stock,
              cantidad_real: producto.stock,
              precio_producto: producto.precioproducto,
              comentario: producto.comentario,
              estado_detalle: 1,
            );
            detallesPedido.add(nuevoDetalle2);
          }




          double precio = producto.precioproducto! * producto.stock!;
          await conn.query(
              'UPDATE pedido_detalles SET cantidad_producto = ?, cantidad_real = ?, precio_producto = ?, comentario = ?, updated_at = ? WHERE id_pedido = ? AND id_producto = ?',
              [
                producto.stock,
                producto.stock,
                precio,
                producto.comentario,
                DateTime.now().toUtc(),
                pedidoid,
                producto.id
              ]);
        }

      }

      await conn.query('UPDATE pedidos SET Monto_total = ?, updated_at= ? WHERE id_pedido = ?',
          [pedidoTotal, DateTime.now().toUtc(),pedidoid]);
      print('LISTA DE INSERTAR AL ACTUALIZAR EL PEDIDO $detallesPedido');
      return detallesPedido;
    }catch (e) {
      print('Error al realizar la consulta: $e');
      return []; // Retorna 0 si ocurre algún error
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }




  Future<int> consultaObtenerDetallePedido(int? idMesa,  BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = '''
      SELECT p.id_pedido 
      FROM pedidos AS p 
      JOIN mesas AS m ON p.id_mesa = m.id 
      WHERE m.id = ?
      ORDER BY p.fecha_pedido DESC 
      LIMIT 1
    ''';

      final results = await conn.query(query, [idMesa]);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return 0; // Retorna 0 si no se encuentra ningún dato
      } else {
        // Obtén el valor del campo id_pedido de la primera fila y conviértelo a entero
        int detallePedido = results.first.fields['id_pedido'] as int;
        print('ID del pedido recuperado: $detallePedido');
        return detallePedido;
      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return 0; // Retorna 0 si ocurre algún error
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }



  Future<List<Detalle_Pedido>> obtenerDetallePedidoLastCreate(int? idPedido,  BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      final results = await conn.query('''
      SELECT * FROM pedido_detalles WHERE id_pedido = ?
      ''', [idPedido]);

      List<Detalle_Pedido> detallePedidoActualizado = results.map((row) => Detalle_Pedido.fromJson(row.fields)).toList();

      print('Cantidad actualizada correctamente en los detalles de pedido');
      return detallePedidoActualizado;
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return []; // Retorna 0 si ocurre algún error
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }



}
