

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/utils/shared_pref.dart';

import '../model/usuario.dart';

class LoginController {
  TextEditingController _url = TextEditingController();
  late BuildContext context;
  late Function refresh;
  final SharedPref _pref = SharedPref();
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    final dynamic userData = await _pref.read('user_data');
    if (userData != null) {
      final Map<String, dynamic> userDataMap = json.decode(userData);
      final expiracion_in = await _pref.read('expires');

      final DateTime expiracionDateTime = DateTime.parse(expiracion_in);
      final DateTime now = DateTime.now();

      final Usuario usuario = Usuario.fromJson(userDataMap);
      print('expiracionDateTime $expiracionDateTime');
      print('now $now');

      if (now.isAfter(expiracionDateTime)) {
        print('DESPUES DE TIEMPO');
        _pref.remove('user_data');
        _pref.remove('categorias');
        _pref.remove('productos');
        _pref.remove('stateConexionTicket');
        _pref.remove('conexionBluetooth');
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      }else {
        print('ANTES DE TIEMPO');

        Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
        print('Email del usuario  ${usuario.user?.email}');

      }
    }

    refresh();
  }


  void configurarApi() async {
    String? urlShared = await _pref.read('url') as String?;
    _url.text = urlShared ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Ingresa tu URL')),
          content: TextField(
            keyboardType: TextInputType.url,
            controller: _url,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Ingresa tu URL',
              hintText: 'Ejemplo: chifalingling.restaupe.com'
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () async {
                String url = _url.text.trim(); // Obtén el valor del TextField y elimina espacios en blanco al inicio y al final

                if (url.isEmpty) {
                  // Mostrar un mensaje de error si el campo está vacío
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Por favor ingresa una URL válida.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Aceptar'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  // Guardar el valor solo si el campo no está vacío
                  print(url);
                  await _pref.save('url', url);
                  Navigator.of(context).pop(); // Cierra el AlertDialog
                }
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                _url.clear();
                _pref.remove('url');
                Navigator.of(context).pop(); // Cierra el AlertDialog
              },
            ),
          ],
        );
      },
    );
  }
}