import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/mesa.dart';
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


}
