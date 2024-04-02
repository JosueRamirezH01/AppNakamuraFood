
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restauflutter/bd/conexionSQL.dart';
import 'package:restauflutter/utils/shared_pref.dart';


class LoginService {

  final SharedPref _sharedPreferences = SharedPref();
  final ConnectionSQL _connectionSQL = ConnectionSQL();

  Future<void> consultarUsuarios(String email, BuildContext context) async {
    try {
      await _connectionSQL.getConnectionSQL(); // Abre la conexión si aún no está abierta

      final connection = _connectionSQL.connection;
      const query = 'SELECT * FROM usuario WHERE email = @email';
      final results = await connection.mappedResultsQuery(query, substitutionValues: {'email': email});
      if (results.isEmpty) {
        Fluttertoast.showToast(
            msg: "No se encontraron usuarios con el correo electrónico proporcionado.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        print('No se encontraron usuarios con el correo electrónico proporcionado.');
      } else {
        for (final row in results) {
          // Serializa los datos en formato JSON
          final userData = {
            'email': row['usuario']?['email'],
            'password': row['usuario']?['password'],
            'activo': row['usuario']?['activo'],
            // Agrega más campos si es necesario
          };
          final jsonUserData = json.encode(userData);

          // Guarda la cadena JSON en SharedPreferences bajo una sola clave
          _sharedPreferences.save('user_data', jsonUserData);
        }
        Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
    } finally {
      await _connectionSQL.closeConnection(); // Cierra la conexión al finalizar
    }
  }
}

