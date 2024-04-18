
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/categoria.dart';
import 'package:restauflutter/model/producto.dart';
import 'package:restauflutter/utils/shared_pref.dart';

class ProductoServicio {

  final Connection _connectionSQL = Connection();
  final SharedPref _sharedPref = SharedPref();

  Future<void> consultarCategorias(BuildContext context, int id_establecimiento) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      // Consulta para obtener todos los datos de las tablas categorias y productos
      const query = 'SELECT *  FROM categorias WHERE establecimiento_id = ?';
      final results = await conn.query(query,[id_establecimiento]);
      if (results.isEmpty) {
        Fluttertoast.showToast(
          msg: "No se encontraron datos en las tablas.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('No se encontraron datos en las tablas.');
      } else {
        List<Categoria> categorias = results.map((row) => Categoria.fromJson(row.fields)).toList();
        final jsonCategoriasData = json.encode(categorias);
        _sharedPref.save('categorias', jsonCategoriasData);
        print('Lista de categorías guardada en SharedPreferences:');
        print(categorias);
      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<void> consultarProductos(BuildContext context) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      // Consulta para obtener todos los datos de las tablas categorias y productos
      const query = 'SELECT id,nombreproducto, foto, precioproducto, stock, categoria_id  FROM productos ';
      final results = await conn.query(query);
      if (results.isEmpty) {
        Fluttertoast.showToast(
          msg: "No se encontraron datos en las tablas.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('No se encontraron datos en las tablas.');
      } else {
        List<Producto> producto = results.map((row) => Producto.fromJson(row.fields)).toList();
        final jsonProductoData = json.encode(producto);
        _sharedPref.save('productos', jsonProductoData);

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