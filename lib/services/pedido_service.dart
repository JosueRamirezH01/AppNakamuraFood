import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restauflutter/model/nota.dart';

import '../bd/api.dart';
import '../model/PedidoResponse.dart';
import 'package:http/http.dart' as http;

class PedidoServicio {
  Api _apiRuta = Api();

  final String _api = '/api/auth';

  Future<PedidoResponse?> registrarPedido(Map<String, dynamic> pedidoData, String? accessToken) async {
    String _url =  await _apiRuta.readApi();

    try {
      Uri url = Uri.https(_url, '$_api/registrarPedido');
//nakamurafoods.restaupe.com
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
    String _url =  await _apiRuta.readApi();

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
