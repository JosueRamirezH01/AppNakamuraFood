import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/PedidoResponse.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/model/pedido.dart';
import 'package:restauflutter/model/piso.dart';
import 'package:restauflutter/utils/shared_pref.dart';
import 'package:http/http.dart' as http;



//SELECT * FROM `mesas` WHERE piso_id = 14

class MesaServicio {
  final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

  final String _url = 'chifalingling.restaupe.com';
  final String _api = '/api/auth';



  Future<List<Mesa>> getAll(String? accessToken, int? id) async {
    try {
      Uri url = Uri.https(_url, '$_api/MesasporPisos/$id');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      print('Datos recibidos: $data');
      Mesa mesa = Mesa.fromJsonList(data);
      print('MESA LIST ${mesa.listMesa[0].toJson()}');
      return mesa.listMesa;
    } catch (e) {
      print('Error Mesa: $e');
      return [];
    }
  }

  Future<bool> consultarMesa(String? accessToken, int id) async {
    try {

      Uri url = Uri.https(_url, '$_api/obtenermesas/$id');
      print('${url}: ${url}');

      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      // Realiza la solicitud GET a la API
      final res = await http.get(url, headers: headers);

      // Verifica el código de estado de la respuesta
      if (res.statusCode == 200) {
        // Decodifica el JSON recibido
        //final data = json.decode(res.body);
        final Map<String, dynamic> data = json.decode(res.body);
        // Crea una instancia de Mesa usando el JSON
        //Mesa mesa = Mesa.fromJson(data["estado_mesa"].toString());
        String estadoMesaStr = data['estado_mesa'].toString();

        print('---------${estadoMesaStr}');

        // Realiza la lógica basada en el estado de la mesa
        if (estadoMesaStr == "1") {
          return true;
        } else {
          return false;
        }
      } else {
        // Maneja el caso en que la API devuelve un error
        print('Error en la respuesta de la API: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      // Maneja las excepciones que puedan ocurrir
      print('Error al realizar la solicitud DELA MESA : $e');
      return false;
    }
  }

  Future<PedidoResponse?> actualizarMesa(int? idMesa,String? accessToken, int idEstado ) async {

    try {

      Uri url = Uri.https(_url, '$_api/actualizar_estado_mesa/$idMesa/$idEstado');
      print('${url}: ${url}');
      String bodiParams = json.encode({
        'estado': idEstado
      });
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      // Realiza la solicitud GET a la API
      final res = await http.post(url, headers: headers,body: bodiParams);
      final data = json.decode(res.body);
      if(res.statusCode == 200){
        PedidoResponse updateMesa = PedidoResponse.fromJson(data);
        print('MENSAJE DE ACTUALZIACION DE DATOS ${updateMesa.mensaje} Y ${updateMesa.status}');
      }else{
        print('ERROR ${res.statusCode}');
      }
      
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return null;
    }
  }











  Future<List<Mesa>> consultarTodasMesas(List<Piso> pisos, BuildContext context) async {
    MySqlConnection? conn;
    List<Mesa> allMesas = [];

    try {
      conn = await _connectionSQL.getConnection();

      for (Piso piso in pisos) {
        const query = 'SELECT * FROM mesas WHERE piso_id = ?';
        final results = await conn.query(query, [piso.id]);
        List<Mesa> mesas = results.map((row) => Mesa.fromJson(row.fields)).toList();
        if (mesas.isNotEmpty) {
          allMesas.addAll(mesas);
        } else {
          print('No hay mesas en el piso ${piso.id}, pasando al siguiente piso.');
        }
      }

      return allMesas;
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return [];
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }



  Future<List<Mesa>> consultarMesas( int idPiso, BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT * FROM mesas WHERE piso_id = ? AND estado_mesa != 0';
      final results = await conn.query(query, [idPiso]);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return [];
      } else {
        List<Mesa> mesas = results.map((row) => Mesa.fromJson(row.fields)).toList();
        final jsonMesasData = json.encode(mesas);
        // print('Lista de pisos guardada en SharedPreferences: $jsonMesasData');
        return mesas;
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

  Future<List<Mesa>> consultarMesasDisponibles( int? idPiso,  BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT * FROM mesas WHERE piso_id = ? AND estado_mesa = 1';
      final results = await conn.query(query, [idPiso]);
      if (results.isEmpty) {
        print('No se encontraron datos en las tablas.');
        return [];
      } else {
        List<Mesa> mesas = results.map((row) => Mesa.fromJson(row.fields)).toList();
        final jsonMesasData = json.encode(mesas);
        //_sharedPref.save('pisos', jsonPisosData);
        print('Lista de mesas Disponibles en SharedPreferences: $jsonMesasData');
        return mesas;
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
