import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:http/http.dart' as http;

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

  Future<bool> consultarItemsIndependientes(String? accessToken) async {
    try {
      Uri url = Uri.parse('https://chifalingling.restaupe.com/api/auth/item_independiente');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final res = await http.get(url, headers: headers);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        int estado = data['estado'];
        print('DATO DE INDEPENDIENTE $estado');
        if (estado == 1) {
          return true;
        } else {
          return false;
        }
      } else {
        print('Error en la solicitud HTTP: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return false;
    }
  }
}