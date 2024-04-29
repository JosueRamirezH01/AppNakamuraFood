import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:password_hash_plus/password_hash_plus.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/model/piso.dart';
import 'package:restauflutter/services/piso_service.dart';
import 'package:restauflutter/services/producto_service.dart';
import 'package:restauflutter/utils/shared_pref.dart';

class LoginService {
  final SharedPref _sharedPreferences = SharedPref();
  final Connection _connectionSQL = Connection();
  var generator = PBKDF2();
  var prod = ProductoServicio();
  var pisos = PisoServicio();
  Mozo mozo = Mozo();
  Future<void> consultarUsuarios(String email, String password,
      BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      // Consulta el hash almacenado en la base de datos para el correo electrónico proporcionado
      const query = 'SELECT * FROM usuarios WHERE email = ?';
      final results = await conn.query(query, [email]);
      if (results.isEmpty) {
        Fluttertoast.showToast(
          msg: "No se encontraron usuarios con el correo electrónico proporcionado.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print(
            'No se encontraron usuarios con el correo electrónico proporcionado.');
      } else {
        final perfilId = results.first['idperfil'];
        final hashFromDatabase = results
            .first['password']; // Obtén el hash almacenado en la base de datos
        final isValid = await FlutterBcrypt.verify(
            password: password, hash: hashFromDatabase);
        if (isValid) {
          if (perfilId != 1) {
            Fluttertoast.showToast(
              msg: "Este usuario no tiene permiso para mozo",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            print('No tiene privilegio para iniciar sesión.');
          } else {
            Fluttertoast.showToast(
              msg: "Inicio de sesión exitoso.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            for (final row in results) {
              // Serializa los datos en formato JSON
              final userData = {
                'email': row['email'],
                'id':row['id'],
                'id_establecimiento':row['id_establecimiento'],
                'idperfil':row["idperfil"],
                'mombre_usuario':row["mombre_usuario"]
              };
              final jsonUserData = json.encode(userData);

              // Guarda la cadena JSON en SharedPreferences bajo una sola clave
              _sharedPreferences.save('user_data', jsonUserData);
            }
            final dynamic userData = await _sharedPreferences.read('user_data');
            if (userData != null) {
              final Map<String, dynamic> userDataMap = json.decode(userData);
              mozo = Mozo.fromJson(userDataMap);
            }
            await prod.consultarCategorias(context, mozo.id_establecimiento!);
            await prod.consultarProductos(context, mozo.id_establecimiento!);
            print('DATA OBTENIDO ${mozo.email}');
            Navigator.pushNamedAndRemoveUntil(
                context, 'home', (route) => false);
          }
        } else {
          Fluttertoast.showToast(
            msg: "Contraseña incorrecta.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          print('Contraseña incorrecta.');
        }
      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
