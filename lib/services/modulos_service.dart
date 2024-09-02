import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:http/http.dart' as http;

import '../bd/api.dart';

class ModuloServicio {
  final Connection _connectionSQL = Connection();
  Api _apiRuta = Api();
  final String _api = '/api/auth';

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
    String _url =  await _apiRuta.readApi();

    try {
      Uri url = Uri.https(_url, '$_api/registrarPedido');

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