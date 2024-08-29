import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:restauflutter/model/PedidoResponse.dart';
import 'package:restauflutter/services/piso_service.dart';
import 'package:restauflutter/services/producto_service.dart';
import 'package:restauflutter/utils/shared_pref.dart';

import '../bd/api.dart';
import '../model/usuario.dart';

class LoginService {
  final SharedPref _sharedPreferences = SharedPref();
  var prod = ProductoServicio();
  var pisos = PisoServicio();
  Usuario usuarioShared = Usuario();
  Api _apiRuta = Api();
  final String _api = '/api/auth';


  Future<Usuario?> login(String email, String password, BuildContext context) async{
    String _url =  await _apiRuta.readApi();

    try {
      Uri url = Uri.https(_url, '$_api/login');
      String bodiParams = json.encode({
        'email': email,
        'password': password
      });
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.post(url, headers: headers, body: bodiParams);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        Usuario usuario = Usuario.fromJson(data); // Accede a la parte 'user' del JSON
        print('${usuario.toJson()}');
        int expiresIn = data['expires_in'] - 12;
        print('---- DATO A EXPIRAR $expiresIn');
        DateTime receivedAt = DateTime.now();
        DateTime expiryTime = receivedAt.add(Duration(seconds: expiresIn));
        String formattedExpiryTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryTime);
        _sharedPreferences.save('expires', formattedExpiryTime);
        print('El token expira en: $formattedExpiryTime');
        final userData = json.encode(data);
        _sharedPreferences.save('user_data', userData);
        Fluttertoast.showToast(
          msg: "Inicio de sesión exitoso.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        final dynamic userDataShared = await _sharedPreferences.read('user_data');
        if (userDataShared != null) {
          final Map<String, dynamic> userDataMap = json.decode(userData);
          usuarioShared = Usuario.fromJson(userDataMap);
        }
        await prod.consultarCategorias(usuarioShared.accessToken);
        await prod.consultarProductos(usuarioShared.accessToken);
        Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
        return usuario;
      } else if (res.statusCode == 401) {
        Fluttertoast.showToast(
          msg: "Usuario Incorrecto",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return null; // O maneja el error de alguna otra manera
      } else {
        Fluttertoast.showToast(
          msg: "Cierre la sesión anterior",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return null;
      }
    }catch(e){
      Fluttertoast.showToast(
        msg: "No se detecta la URL ingresada",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return null;
    }
  }


  Future<PedidoResponse?> logout(String accessToken) async {
    String _url =  await _apiRuta.readApi();
    print('object $accessToken');
    try {
      Uri url = Uri.https(_url,'$_api/cerrar_sesion');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final res = await http.post(url,headers: headers);
      final data = json.decode(res.body);

      if(res.statusCode == 200){
        PedidoResponse respuestaData =PedidoResponse.fromJson(data);
        return respuestaData;
      }
    }catch(e){
      print('Error al realizar la consulta: $e');
      return null;
    }
    return null;
  }

}
