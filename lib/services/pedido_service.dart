import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/home/home_page.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/model/nota.dart';
import 'package:restauflutter/model/pedido.dart';

import '../model/PedidoResponse.dart';
import 'package:http/http.dart' as http;

class PedidoServicio {
  final Connection _connectionSQL = Connection();
  final String _url = 'nakamurafoods.restaupe.com';
  final String _api = '/api/auth';

  Future<PedidoResponse?> registrarPedido(Map<String, dynamic> pedidoData, String? accessToken) async {
    final url = Uri.parse('https://nakamurafoods.restaupe.com/api/auth/registrarPedido');
    try {
      final response = await http.post(url,
        headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
        },
        body: json.encode(pedidoData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        agregarMsj('Pedido registrado exitosamente');
        final responseData = json.decode(response.body);
        return PedidoResponse.fromJson(responseData);
      } else {
        mostrarMensaje('Error al registrar el pedido: ${response.body}');
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      mostrarMensaje('Error al registrar el pedido: $e');
    }
    return null;
  }
  void agregarMsj(String mensaje){
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void mostrarMensaje(String mensaje) {
    Fluttertoast.showToast(
      msg: mensaje,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<List<Nota>> obtenerListasNota(String? accessToken) async {
    Uri url = Uri.https(_url, '$_api/notas');
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(res.body);

      List<dynamic> data = jsonResponse['data'];
      List<Nota> notas = Nota.fromJsonList(data);

      return notas;
    } else {
      throw Exception('Failed to load notas');
    }
  }








  Future<int?> consultarMesasDisponibilidad( int? idUsuario, int? idMesa ,BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT id_pedido FROM `pedidos` WHERE id_usuario = ? AND id_mesa = ? AND estado_pedido != 0 AND estado_pedido != 2  ORDER by id_pedido DESC LIMIT 1';
      final results = await conn.query(query, [idUsuario, idMesa]);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return null;
      } else {
        final idPedido = results.first.fields['id_pedido'] as int;
        print('ID del pedido recuperado MESA: $idPedido');
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

  // el bingo
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
        // List<Detalle_Pedido> detallePedido = results.map((row) => Detalle_Pedido.fromJson(row.fields)).toList();
        List<Detalle_Pedido> detallePedido = results.map((row) {
          Detalle_Pedido detalle = Detalle_Pedido.fromJson(row.fields);
          detalle.comentario = detalle.comentario == null ? null : _extraerTextoComentario(detalle.comentario);
          return detalle;
        }).toList();

        print('Detalles del pedido recuperados:');
        for (var detalle in detallePedido) {
          print('ID del detalle de pedido: ${detalle.id_pedido_detalle}');
          print('ID del pedido: ${detalle.id_pedido}');
          // Imprime otras propiedades aquí según sea necesario
          print('-----------------------------');
        }
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

  Future<int> crearPedidoPrueba( Pedido pedido, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();
      const query = 'INSERT INTO pedidos ( id_entorno, id_cliente,id_usuario, id_tipo_ped, id_mesa, id_establecimiento, id_serie_pedido, Monto_total, fecha_pedido, estado_pedido, created_at, updated_at) VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
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
          pedido.created_at,
        pedido.updated_at

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

  Future<List<Pedido>> obtenerListasPedidos( SubOptTypes variable, int idEstablecimiento,BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();
      int id_tipo_ped = 1;
     if(variable == SubOptTypes.llevar){
        id_tipo_ped = 2;
      }else if(variable == SubOptTypes.delivery){
        id_tipo_ped = 3;
      }
      const query = 'SELECT * FROM pedidos where id_tipo_ped = ? AND id_establecimiento = ? AND estado_pedido = 1 ORDER BY correlativo_pedido DESC ';
      final results = await conn.query(query,[id_tipo_ped, idEstablecimiento] );
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

  Future<int?> anularPedido(String motivo, Mozo mozo, int idPedido, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'UPDATE pedidos SET id_mesa = ?, estado_pedido = ? ,motivo = ? ,anulado_por = ? WHERE id_pedido = ?';
      final results = await conn.query(query, [null,0, motivo, mozo.nombre_usuario, idPedido ]);
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

}
