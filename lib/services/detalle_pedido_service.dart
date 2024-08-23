import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/PedidoResponse.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/model/nota.dart';
import 'package:restauflutter/model/pedido.dart';
import 'package:restauflutter/model/producto.dart';
import 'package:restauflutter/services/pedido_service.dart';
import 'package:restauflutter/utils/shared_pref.dart';

class DetallePedidoServicio {
  // final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

  final String _url = 'chifalingling.restaupe.com';
  final String _api = '/api/auth';

  Future<Map<String, dynamic>> fetchPedidoDetalle(String? accessToken,int? idMesa) async {

    Uri url = Uri.https(_url, '$_api/obtener_pedidos_pormesa/$idMesa');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    final res = await http.get(url, headers: headers);
    
    if (res.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(res.body);

      // Procesa el JSON y devuelve el Map
      bool status = jsonResponse['status'];
      Pedido pedido = Pedido.fromJson(jsonResponse['pedido_detalle']);
      print('Pedido Detalle: ${pedido.detalle!.first.comentario.runtimeType}');
      return {
        'status': status,
        'pedido_detalle': pedido,
      };
    } else {
      throw Exception('Failed to load pedido detalle');
    }
  }

  // Future<Map<String, dynamic>> fetchPedidoDetalleRespuesta(String? accessToken,int? idMesa) async {
  //
  //   Uri url = Uri.https(_url, '$_api/obtener_pedidos_pormesa/$idMesa');
  //   Map<String, String> headers = {
  //     'Content-type': 'application/json',
  //     'Authorization': 'Bearer $accessToken'
  //   };
  //   final res = await http.get(url, headers: headers);
  //   if (res.statusCode == 200) {
  //     Map<String, dynamic> jsonResponse = json.decode(res.body);
  //
  //     return jsonResponse;
  //   } else {
  //     throw Exception('Failed to load pedido detalle');
  //   }
  // }

  Future<void> actualizarPedidoApi(String? accessToken, Map<String, dynamic> pedidoDetalle, int? idMesa) async {
    Uri uri = Uri.https(_url, '$_api/actualizarPedido/$idMesa');
    // pedidoDetalle['detalle'];
    String body = json.encode(pedidoDetalle);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    print('-Body- ${body}');

    // Realizar la solicitud PUT
    final response = await http.put(
      uri,
      headers: headers,
      body: body,
    );

    print(response.body);
    // Verificar el estado de la respuesta
    if (response.statusCode == 200) {
      print('Pedido actualizado con éxito.');
    } else {
      throw Exception('Error al actualizar el pedido: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> actualizarPedidoConRespuestaApi(String? accessToken, Map<String, dynamic> pedidoDetalle, int? idMesa) async {
    Uri uri = Uri.https(_url, '$_api/actualizarPedido/$idMesa');
    print('Datos del pedido enviados ->: ${json.encode(pedidoDetalle)}');
    String body = json.encode(pedidoDetalle);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    //print('-Body- ${body} :end');

    // Realizar la solicitud PUT
    final response = await http.put(
      uri,
      headers: headers,
      body: body,
    );

    print('✔️✔️✔️✔️');

    // Verificar el estado de la respuesta
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      // if
      print('jsonResponse :a ${jsonResponse}');
      // List<dynamic> detalleActualizadoJson = jsonResponse['detalle_actualizado'];
      // print('detalleActualizadoJson : ${detalleActualizadoJson}');
      // List<Detalle_Pedido> detalleActualizado = detalleActualizadoJson.map((json) => Detalle_Pedido.fromJson(json)).toList();
      return jsonResponse;
    } else {
      throw Exception('Error al actualizar el pedido: ${response.statusCode}');
    }
  }

  Future<PedidoResponse> eliminarDetallePedido(int id, String? accessToken) async {

    Uri uri = Uri.https(_url, '$_api/eliminar_detallepedido/$id');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    // Realizar la solicitud DELETE
    final response = await http.delete(uri, headers: headers);
    final data = json.decode(response.body);
    // Verificar el estado de la respuesta
    if (response.statusCode == 200) {
      PedidoResponse responseData = PedidoResponse.fromJson(data);
      return responseData;
    } else {
      throw Exception('Error al eliminar el detalle del pedido: ${response.statusCode}');
    }


  }













  // Future<List<Detalle_Pedido>> crearDetallePedidoPrueba(int idPedido, List<Producto> productos, BuildContext context) async {
  //   MySqlConnection? conn;
  //   List<Detalle_Pedido> detallesPedido = [];
  //   List<Nota> listaNota = [];
  //   late  Mozo? mozo = Mozo();
  //   var bdPedido = PedidoServicio();
  //
  //   final dynamic userData = await _sharedPref.read('user_data');
  //   if (userData != null) {
  //     final Map<String, dynamic> userDataMap = json.decode(userData);
  //     mozo = Mozo.fromJson(userDataMap);
  //   }
  //
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //     print('Id de pedido creado${idPedido}');
  //     listaNota = await bdPedido.obtenerListasNota(mozo.id_establecimiento!, context);
  //
  //     for (Producto producto in productos) {
  //       String? comentarioHTML = limpiarPuntoComa(listaNota,producto,'');
  //
  //       final results = await conn.query('''
  //         INSERT INTO pedido_detalles (
  //           id_pedido,
  //           id_producto,
  //           cantidad_producto,
  //           cantidad_real,
  //           precio_unitario,
  //           precio_producto,
  //           comentario,
  //           estado_detalle,
  //           created_at,
  //           updated_at ) VALUES (
  //             ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
  //           )
  //       ''',
  //           [
  //             idPedido, // id pedido
  //             producto.id, // id prodcuto
  //             producto.stock, // cantidad producto
  //             producto.stock, // cantidad real
  //             producto.precioproducto!,
  //             producto.precioproducto! * producto.stock!, // precio producto
  //             comentarioHTML,//producto.comentario, // comentario
  //             1, // estado detalle
  //             DateTime.now().toUtc(),
  //             DateTime.now().toUtc()
  //           ]
  //       );
  //
  //       final pedidoDetalleIdResult = await conn.query(
  //           'SELECT LAST_INSERT_ID()');
  //       int pedidoDetalleId = pedidoDetalleIdResult.first[0] as int;
  //
  //       print('SERVICIO DE DETALLE DE PEDIDO $pedidoDetalleId');
  //
  //       final pedidoDetalleResult = await conn.query(
  //           'SELECT * FROM pedido_detalles WHERE id_pedido_detalle  = ?',
  //           [pedidoDetalleId]);
  //
  //       if (!pedidoDetalleResult.isEmpty) {
  //         Detalle_Pedido detallePedido = pedidoDetalleResult
  //             .map((row) => Detalle_Pedido.fromJson(row.fields))
  //             .first;
  //         print('COmentario bd = ${detallePedido.comentario} tipo: ${detallePedido.comentario.runtimeType}');
  //         detallePedido.comentario = detallePedido.comentario == null ? null : _extraerTextoComentario(detallePedido.comentario);
  //         detallesPedido.add(detallePedido);
  //         print('Detalle insertado correctamente para el producto ${producto
  //             .nombreproducto}');
  //       } else {
  //         print('No se pudo insertar el detalle para el producto ${producto
  //             .nombreproducto}');
  //       }
  //     }
  //
  //     detallesPedido.forEach((element) {
  //       print('Los cbdl ${element.comentario} tipo : ${element.comentario.runtimeType}');
  //     });
  //     print('LISTA DE DETALLES DE PEDIDOS AL CREAR ${detallesPedido[0].id_pedido}');
  //     return detallesPedido;
  //   } catch (e) {
  //     print('Error al realizar la consulta: $e');
  //     return [];
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

  // Future<List<Detalle_Pedido>> eliminarCantidadProductoDetallePedidoImprimir( int? pedidoid,List<Producto> productos,double pedidoTotal, BuildContext context) async {
  //   MySqlConnection? conn;
  //   List<Detalle_Pedido> detallesPedido = [];
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //
  //     final resultst = await conn.query('''
  //     SELECT * FROM pedido_detalles WHERE id_pedido = ?
  //     ''', [pedidoid]);
  //
  //     List<Detalle_Pedido> listaBD = resultst.map((row) {
  //       Detalle_Pedido detalle = Detalle_Pedido.fromJson(row.fields);
  //       detalle.comentario = detalle.comentario == null ? null : _extraerTextoComentario(detalle.comentario);
  //       return detalle;
  //     }).toList();
  //
  //
  //     for (var detalle in listaBD) {
  //       bool found = false;
  //       for (var product in productos) {
  //         if (product.id == detalle.id_producto) {
  //           found = true;
  //           break;
  //         }
  //
  //       }
  //       if (!found) {
  //
  //         print('ID OBTENIDO PARA ELIMINAR IMPRESORA----------------------------: ${detalle.id_pedido_detalle}');
  //         detalle.cantidad_real = 0;
  //         detalle.cantidad_producto = 0;
  //         detallesPedido.add(detalle);
  //       }
  //
  //     }
  //
  //     print('---- Productos para la otraq lista -----');
  //     detallesPedido.forEach((element) {
  //
  //       print(element.id_producto);
  //       print(element.cantidad_producto);
  //     });
  //     return detallesPedido;
  //   }catch (e) {
  //     print('Error al realizar la consulta: $e');
  //     return []; // Retorna 0 si ocurre algún error
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

  // bingo 1
  // Future<List<Detalle_Pedido>>  actualizarCantidadProductoDetallePedidoPrueba(int? pedidoid, List<Producto> productos, double pedidoTotal, BuildContext context) async {
  //   MySqlConnection? conn;
  //   List<Detalle_Pedido> detallesPedido = [];
  //
  //   List<Nota> listaNota = [];
  //   listaNota.clear();
  //   late  Mozo? mozo = Mozo();
  //   var bdPedido = PedidoServicio();
  //
  //   final dynamic userData = await _sharedPref.read('user_data');
  //   if (userData != null) {
  //     final Map<String, dynamic> userDataMap = json.decode(userData);
  //     mozo = Mozo.fromJson(userDataMap);
  //   }
  //
  //   detallesPedido.clear();
  //   print('-------------- ID PEDIDO ${pedidoid}');
  //   print('-------------- PRODUCTOS ${productos}');
  //   print('-------------- PRECIO TOTAL ${pedidoTotal}');
  //
  //   try {
  //
  //     conn = await _connectionSQL.getConnection();
  //     listaNota = await bdPedido.obtenerListasNota();
  //     final resultst = await conn.query('''
  //     SELECT * FROM pedido_detalles WHERE id_pedido = ?
  //     ''', [pedidoid]);
  //
  //     // List<Detalle_Pedido> listaBD = resultst.map((row) =>
  //     //     Detalle_Pedido.fromJson(row.fields)).toList();
  //
  //     List<Detalle_Pedido> listaBD = resultst.map((row) {
  //       Detalle_Pedido detalle = Detalle_Pedido.fromJson(row.fields);
  //       detalle.comentario = detalle.comentario == null ? null : _extraerTextoComentario(detalle.comentario);
  //       return detalle;
  //     }).toList();
  //
  //     print('LISTADO OBTENIDO POR LA CONSULTA $listaBD');
  //
  //     for (var detalle in listaBD) {
  //
  //       print('P-Comentario ${detalle.comentario} Tipo :${detalle.comentario.runtimeType }');
  //       bool found = false;
  //       for (var product in productos) {
  //           if (product.id == detalle.id_producto && product.precioproducto == detalle.precio_unitario && product.stock == detalle.cantidad_producto) {
  //           found = true;
  //           break;
  //         }
  //       }
  //
  //       if (!found) {
  //         print('ID OBTENIDO PARA ELIMINAR: ${detalle.id_pedido_detalle}');
  //         await conn.query(
  //             'DELETE FROM pedido_detalles WHERE id_pedido_detalle = ?',
  //             [detalle.id_pedido_detalle]);
  //       }
  //     }
  //
  //     for (final producto in productos) {
  //       var existingDetail = await conn.query(
  //           'SELECT id_pedido_detalle, cantidad_producto, comentario FROM pedido_detalles WHERE id_pedido = ? AND id_producto = ? AND precio_unitario = ?',
  //           [pedidoid, producto.id, producto.precioproducto]);
  //
  //       print('LISTA $existingDetail');
  //
  //       print('Comentario cero ${producto.comentario} ${producto.comentario.runtimeType}');
  //
  //       // producto.comentario = producto.comentario == 'null' ? null : producto.comentario;
  //       producto.comentario = (producto.comentario == 'null' || producto.comentario?.length == 0) ? null : producto.comentario;
  //
  //       print('Comentario inicio ${producto.comentario} ${producto.comentario.runtimeType}');
  //
  //       print('Comentario medio ${producto.comentario} ${producto.comentario.runtimeType}');
  //       // si existingDetail
  //       if (existingDetail.isEmpty) {
  //
  //         String? comentarioHTML = limpiarPuntoComa(listaNota,producto,'');
  //
  //         Detalle_Pedido nuevoDetalle = Detalle_Pedido(
  //           id_pedido: pedidoid,
  //           id_producto: producto.id,
  //           cantidad_producto: producto.stock,
  //           cantidad_real: producto.stock,
  //           precio_unitario: producto.precioproducto!,
  //           precio_producto: producto.precioproducto! * producto.stock!,
  //           comentario: comentarioHTML,
  //           estado_detalle: 1,
  //
  //         );
  //
  //         await conn.query(
  //             'INSERT INTO pedido_detalles (id_pedido, id_producto, cantidad_producto, cantidad_real, precio_unitario,precio_producto, comentario, estado_detalle, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?,?)',
  //             [
  //               nuevoDetalle.id_pedido,
  //               nuevoDetalle.id_producto,
  //               nuevoDetalle.cantidad_producto,
  //               nuevoDetalle.cantidad_producto,
  //               nuevoDetalle.precio_unitario,
  //               nuevoDetalle.precio_producto,
  //               nuevoDetalle.comentario,
  //               nuevoDetalle.estado_detalle,
  //               DateTime.now().toUtc(),
  //               DateTime.now().toUtc()
  //             ]);
  //         nuevoDetalle.comentario = nuevoDetalle.comentario == null ? null : _extraerTextoComentario(nuevoDetalle.comentario);
  //         detallesPedido.add(nuevoDetalle);
  //       } else {
  //
  //         var detailRow = existingDetail.first;
  //         int cantidadProductoExistente = detailRow['cantidad_producto'];
  //         String? nomComent = _extraerTextoComentario(detailRow['comentario']?.toString());
  //
  //         print('nomComent : ${nomComent} ${nomComent.runtimeType} ');
  //
  //         int productoRestado = producto.stock! - cantidadProductoExistente;
  //         print('Cantidad Restado $productoRestado');
  //         print(' COMENTARIO ACTUALZIADO ${producto.comentario}');
  //         if(productoRestado < 0 ){
  //           Detalle_Pedido nuevoDetalle2 = Detalle_Pedido(
  //             id_pedido: pedidoid,
  //             id_producto: producto.id,
  //             cantidad_producto: productoRestado,
  //             cantidad_real: producto.stock,
  //             precio_producto: producto.precioproducto,
  //             comentario: producto.comentario,
  //             estado_detalle: 1,
  //           );
  //           detallesPedido.add(nuevoDetalle2);
  //         }else if(productoRestado>0){
  //           Detalle_Pedido nuevoDetalle2 = Detalle_Pedido(
  //             id_pedido: pedidoid,
  //             id_producto: producto.id,
  //             cantidad_producto: productoRestado,
  //             cantidad_real: producto.stock,
  //             precio_producto: producto.precioproducto,
  //             comentario: producto.comentario,
  //             estado_detalle: 1,
  //           );
  //           detallesPedido.add(nuevoDetalle2);
  //         }else if(nomComent != producto.comentario){
  //
  //           print('Comparacion --C');
  //           print('Com Base : ${nomComent} - ${nomComent.runtimeType}');
  //           print('Com Sist : ${producto.comentario} - ${producto.comentario.runtimeType}');
  //
  //           String? comentarioHTML = limpiarPuntoComa(listaNota,producto,'');
  //
  //           Detalle_Pedido nuevoDetalle2 = Detalle_Pedido(
  //             id_pedido: pedidoid,
  //             id_producto: producto.id,
  //             cantidad_producto: producto.stock,
  //             cantidad_real: producto.stock,
  //             precio_producto: producto.precioproducto,
  //             // comentario: producto.comentario,
  //             comentario: comentarioHTML,
  //             estado_detalle: 1,
  //           );
  //
  //           nuevoDetalle2.comentario = nuevoDetalle2.comentario == null ? null : _extraerTextoComentario(nuevoDetalle2.comentario);
  //           detallesPedido.add(nuevoDetalle2);
  //         }
  //
  //         String? comentarioHTML = limpiarPuntoComa(listaNota,producto,'');
  //
  //         double precio = producto.precioproducto! * producto.stock!;
  //         await conn.query(
  //             'UPDATE pedido_detalles SET cantidad_producto = ?, cantidad_real = ?, precio_producto = ?, comentario = ?, updated_at = ? WHERE id_pedido = ? AND id_producto = ?',
  //             [
  //               producto.stock,
  //               producto.stock,
  //               precio,
  //               comentarioHTML,
  //               DateTime.now().toUtc(),
  //               pedidoid,
  //               producto.id
  //             ]
  //         );
  //       }
  //     }
  //     await conn.query('UPDATE pedidos SET Monto_total = ?, updated_at= ? WHERE id_pedido = ?',
  //         [pedidoTotal, DateTime.now().toUtc(),pedidoid]);
  //     print('LISTA DE INSERTAR AL ACTUALIZAR EL PEDIDO $detallesPedido');
  //     return detallesPedido;
  //   }catch (e) {
  //     print('Error al realizar la consulta: $e');
  //     return [];
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

  // Future<void> eliminarProductoPorItem(int id_pedido_detalle) async {
  //   MySqlConnection? conn;
  //
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //     await conn.query(
  //         'DELETE FROM pedido_detalles WHERE id_pedido_detalle = ?',
  //         [id_pedido_detalle]
  //     );
  //   } catch (e) {
  //     print('Error al realizar la eliminación: $e');
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

  //tp2
  // Future<void> notaProductoPorItem(String comentario, int id_pedido_detalle, BuildContext context) async {
  //   MySqlConnection? conn;
  //   List<Nota> listaNota = [];
  //   late Mozo? mozo = Mozo();
  //   var bdPedido = PedidoServicio();
  //
  //   final dynamic userData = await _sharedPref.read('user_data');
  //   if (userData != null) {
  //     final Map<String, dynamic> userDataMap = json.decode(userData);
  //     mozo = Mozo.fromJson(userDataMap);
  //   }
  //   try {
  //     listaNota = await bdPedido.obtenerListasNota(mozo.id_establecimiento!, context);
  //     conn = await _connectionSQL.getConnection();
  //     // String? nomComent = _extraerTextoComentario(comentario..toString());
  //     print('COMENTARIO LLEGADA 1${comentario}');
  //     String? formaComent = limpiarPuntoComa(listaNota, Producto() , comentario);
  //
  //     await conn.query(
  //         'UPDATE pedido_detalles SET comentario = ?, updated_at = ? WHERE id_pedido_detalle = ?',
  //         [
  //           formaComent,
  //           DateTime.now().toUtc(),
  //           id_pedido_detalle
  //         ]
  //     );
  //   } catch (e) {
  //     print('Error al realizar la eliminación: $e');
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

  // tp5
  // Future<void> actualizarAgregarProductoDetallePedidoItem(int? pedidoid, double pedidoTotal, BuildContext context) async {
  //
  //   MySqlConnection? conn;
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //     await conn.query('UPDATE pedidos SET Monto_total = ?, updated_at = ? WHERE id_pedido = ?', [pedidoTotal, DateTime.now().toUtc(), pedidoid]);
  //
  //   } catch (e) {
  //     print('Error al realizar la consulta: $e');
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

  // Future<Detalle_Pedido> AgregarProductoDetallePedidoItem(int? pedidoid, Producto producto, BuildContext context) async {
  //   MySqlConnection? conn;
  //   Detalle_Pedido detallePedidocreado = Detalle_Pedido();
  //   List<Nota> listaNota = [];
  //   late Mozo? mozo = Mozo();
  //   var bdPedido = PedidoServicio();
  //
  //   final dynamic userData = await _sharedPref.read('user_data');
  //   if (userData != null) {
  //     final Map<String, dynamic> userDataMap = json.decode(userData);
  //     mozo = Mozo.fromJson(userDataMap);
  //   }
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //
  //     // Obtener lista de notas
  //     listaNota =
  //     await bdPedido.obtenerListasNota(mozo.id_establecimiento!, context);
  //
  //
  //     await conn.query(
  //       'INSERT INTO pedido_detalles (id_pedido, id_producto, cantidad_producto, cantidad_real, precio_unitario, precio_producto, comentario, estado_detalle, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
  //       [
  //         pedidoid, // id pedido
  //         producto.id, // id prodcuto
  //         producto.stock, // cantidad producto
  //         producto.stock, // cantidad real
  //         producto.precioproducto!,
  //         producto.precioproducto! * producto.stock!, // precio producto
  //         producto.comentario, //producto.comentario, // comentario
  //         1, // estado detalle
  //         DateTime.now().toUtc(),
  //         DateTime.now().toUtc()
  //       ],
  //     );
  //
  //     final pedidoDetalleIdResult = await conn.query('SELECT LAST_INSERT_ID()');
  //     int pedidoDetalleId = pedidoDetalleIdResult.first[0] as int;
  //
  //     final pedidoDetalleResult = await conn.query(
  //         'SELECT * FROM pedido_detalles WHERE id_pedido_detalle  = ?',
  //         [pedidoDetalleId]);
  //
  //     if (!pedidoDetalleResult.isEmpty) {
  //       Detalle_Pedido detallePedido = pedidoDetalleResult
  //           .map((row) => Detalle_Pedido.fromJson(row.fields))
  //           .first;
  //       print('COmentario bd = ${detallePedido.comentario} tipo: ${detallePedido
  //           .comentario.runtimeType}');
  //       detallePedido.comentario =
  //       detallePedido.comentario == null ? null : _extraerTextoComentario(
  //           detallePedido.comentario);
  //       print('Detalle insertado correctamente para el producto ${producto
  //           .nombreproducto}');
  //       detallePedidocreado = detallePedido;
  //     } else {
  //       print('No se pudo insertar el detalle para el producto ${producto
  //           .nombreproducto}');
  //     }
  //
  //     return detallePedidocreado;
  //   } catch (e) {
  //     print('Error al realizar la consulta: $e');
  //     return detallePedidocreado;
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }


  // Future<int> consultaObtenerDetallePedido(int? idMesa,  BuildContext context) async {
  //   MySqlConnection? conn;
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //
  //     const query = '''
  //     SELECT p.id_pedido
  //     FROM pedidos AS p
  //     JOIN mesas AS m ON p.id_mesa = m.id
  //     WHERE m.id = ?
  //     ORDER BY p.fecha_pedido DESC
  //     LIMIT 1
  //   ''';
  //
  //     final results = await conn.query(query, [idMesa]);
  //     if (results.isEmpty) {
  //       print('No se encontraron datos en las tablas.');
  //       return 0; // Retorna 0 si no se encuentra ningún dato
  //     } else {
  //       // Obtén el valor del campo id_pedido de la primera fila y conviértelo a entero
  //       int detallePedido = results.first.fields['id_pedido'] as int;
  //       print('ID del pedido recuperado: $detallePedido');
  //       return detallePedido;
  //     }
  //   } catch (e) {
  //     print('Error al realizar la consulta: $e');
  //     return 0; // Retorna 0 si ocurre algún error
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

  // no actualizar
  // Future<List<Detalle_Pedido>> obtenerDetallePedidoLastCreate(int? idPedido,  BuildContext context) async {
  //   MySqlConnection? conn;
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //
  //     final results = await conn.query('''
  //     SELECT * FROM pedido_detalles WHERE id_pedido = ?
  //     ''', [idPedido]);
  //
  //     List<Detalle_Pedido> detallePedidoActualizado = results.map((row) => Detalle_Pedido.fromJson(row.fields)).toList();
  //
  //     print('Cantidad actualizada correctamente en los detalles de pedido');
  //     return detallePedidoActualizado;
  //   } catch (e) {
  //     print('Error al realizar la consulta: $e');
  //     return []; // Retorna 0 si ocurre algún error
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

  String? _extraerTextoComentario(String? comentarioHtml) {
    if (comentarioHtml == null) {
      return null;
    }

    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String textoLimpio = comentarioHtml.replaceAll(exp, ';').trim();

    if (textoLimpio.startsWith(';')) {
      textoLimpio = textoLimpio.substring(1);
    }

    if (textoLimpio.endsWith(';')) {
      textoLimpio = textoLimpio.substring(0, textoLimpio.length - 1);
    }

    textoLimpio = textoLimpio.replaceAll(RegExp(r';+'), ';');

    return textoLimpio;
  }

  String? limpiarPuntoComa(List<Nota> listaNota, Producto producto, String comentariol){
    List<String> partesComentario = [];
    if (producto.comentario != null && producto.comentario!.isNotEmpty) {
      partesComentario = producto.comentario!.split(';');
    }
    if(comentariol.isNotEmpty){
      partesComentario = comentariol.split(';');
    }

    print('Los Dactualizar--> ${producto.comentario} tipo : ${producto.comentario.runtimeType}');

    String? comentarioHTML = '';
    if (partesComentario.isNotEmpty) {
      comentarioHTML = partesComentario.map((parte) {
        return '<span class="badge badge-pill badge-danger" id="texto-comentario-${listaNota.firstWhere((element) => element.descripcion_nota == parte.trim()).id_nota}">${parte.trim()}</span>';
      }).join('');
    }


    return comentarioHTML;
  }
}