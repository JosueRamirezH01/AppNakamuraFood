
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/model/categoria.dart';
import 'package:restauflutter/model/producto.dart';
import 'package:restauflutter/utils/shared_pref.dart';
import 'package:http/http.dart' as http;

class ProductoServicio {

  final SharedPref _sharedPref = SharedPref();

  final String _url = 'chifalingling.restaupe.com';
  final String _api = '/api/auth';


  Future<List<Categoria>?> getAll(String? accessToken) async {
    try {
      Uri url = Uri.https(_url, '$_api/categorias');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      print('Datos recibidos: $data');
      Categoria empresa = Categoria.fromJsonList(data);
      return empresa.categoria;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> consultarCategorias(String? accessToken) async {
    try {
      // Obtener categorías desde la API
      List<Categoria>? categoriasAPI = await getAll(accessToken);

      if (categoriasAPI != null && categoriasAPI.isNotEmpty) {
        int todosIndex = categoriasAPI.indexWhere((categoria) => categoria.nombre?.toLowerCase() == 'todos');
        if (todosIndex != -1) {
          Categoria todosCategoria = categoriasAPI.removeAt(todosIndex);
          categoriasAPI.insert(0, todosCategoria);
        }

        // Guardar en SharedPreferences
        final jsonCategoriasData = json.encode(categoriasAPI);
        _sharedPref.save('categorias', jsonCategoriasData);
        print('Lista de categorías guardada en SharedPreferences:');
        print(categoriasAPI);
      } else {
        Fluttertoast.showToast(
          msg: "No se encontraron datos desde la API.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('No se encontraron datos desde la API.');
      }
    } catch (e) {
      print('Error al obtener categorías desde la API: $e');
    }
  }


  Future<List<Producto>?> getAllProducto(String? accessToken) async {
    try {
      Uri url = Uri.https(_url, '$_api/obtenerproductos');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      print('Datos recibidos: ${data}');
      Producto empresa = Producto.fromJsonList(data);
      return empresa.productos;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> consultarProductos(String? accessToken) async {
    try {
      List<Producto>? productos = await getAllProducto(accessToken);
      if (productos == null || productos.isEmpty) {
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
        final jsonProductoData = json.encode(productos);
        _sharedPref.save('productos', jsonProductoData);
      }
    } catch (e) {
      print('Error al obtener los productos: $e');
    }
  }



  // Future<void> consultarCategorias(BuildContext context, int id_establecimiento) async {
  //   MySqlConnection? conn;
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //     // Consulta para obtener todos los datos de las tablas categorias y productos
  //     const query = 'SELECT *  FROM categorias WHERE establecimiento_id = ?  AND estado = 1';
  //     final results = await conn.query(query,[id_establecimiento]);
  //     if (results.isEmpty) {
  //       Fluttertoast.showToast(
  //         msg: "No se encontraron datos en las tablas.",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0,
  //       );
  //       print('No se encontraron datos en las tablas.');
  //     } else {
  //       List<Categoria> categorias = results.map((row) => Categoria.fromJson(row.fields)).toList();
  //       int todosIndex = categorias.indexWhere((categoria) => categoria.nombre?.toLowerCase() == 'todos');
  //       if (todosIndex != -1) {
  //         Categoria todosCategoria = categorias.removeAt(todosIndex);
  //         categorias.insert(0, todosCategoria);
  //       }
  //       final jsonCategoriasData = json.encode(categorias);
  //       _sharedPref.save('categorias', jsonCategoriasData);
  //       print('Lista de categorías guardada en SharedPreferences:');
  //       print(categorias);
  //     }
  //   } catch (e) {
  //     print('Error al realizar la consulta: $e');
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

  // Future<void> consultarProductos(BuildContext context, int id_establecimiento) async {
  //   MySqlConnection? conn;
  //   try {
  //     conn = await _connectionSQL.getConnection();
  //     // Consulta para obtener todos los datos de las tablas categorias y productos
  //     const query = 'SELECT id,nombreproducto, foto, precioproducto, stock, categoria_id, codigo_interno FROM productos WHERE establecimiento_id = ? AND estado = 1';
  //     final results = await conn.query(query,[id_establecimiento]);
  //     if (results.isEmpty) {
  //       Fluttertoast.showToast(
  //         msg: "No se encontraron datos en las tablas.",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0,
  //       );
  //       print('No se encontraron datos en las tablas.');
  //     } else {
  //       List<Producto> producto = results.map((row) => Producto.fromJson(row.fields)).toList();
  //       final jsonProductoData = json.encode(producto);
  //       _sharedPref.save('productos', jsonProductoData);
  //
  //     }
  //   } catch (e) {
  //     print('Error al realizar la consulta: $e');
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }


  void agregarMsj(String mensaje){
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }



}