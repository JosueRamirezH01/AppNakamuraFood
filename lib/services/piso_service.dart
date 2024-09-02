import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/piso.dart';
import 'package:restauflutter/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

import '../bd/api.dart';

class PisoServicio {
  Api _apiRuta = Api();

  final String _api = '/api/auth';

  Future<List<Piso>?> getAll(String? accessToken) async {
    String _url =  await _apiRuta.readApi();

    try {
      Uri url = Uri.https(_url, '$_api/pisosActivos');
      Map<String, String> headers = {
        'Content-type': 'application/json',
      'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      print('Datos recibidos: $data');
      Piso empresa = Piso.fromJsonList(data);
      return empresa.listPiso;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }





}
