
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
      const query = 'SELECT *  FROM categorias WHERE establecimiento_id = ?  AND estado = 1';
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
        int todosIndex = categorias.indexWhere((categoria) => categoria.nombre?.toLowerCase() == 'todos');
        if (todosIndex != -1) {
          Categoria todosCategoria = categorias.removeAt(todosIndex);
          categorias.insert(0, todosCategoria);
        }
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

  Future<void> consultarProductos(BuildContext context, int id_establecimiento) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();
      // Consulta para obtener todos los datos de las tablas categorias y productos
      const query = 'SELECT id,nombreproducto, foto, precioproducto, stock, categoria_id, codigo_interno FROM productos WHERE establecimiento_id = ? AND estado = 1';
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

  Future<bool> consultarCategoriaIpBar(BuildContext context, int? id_establecimiento) async {
    MySqlConnection? conn;
    try {
      conn = await _connectionSQL.getConnection();

      const query = 'SELECT *  FROM categorias WHERE bar = ? AND establecimiento_id = ?';
      final results = await conn.query(query, [1, id_establecimiento]);

      List<Categoria> categorias = results.map((row) => Categoria.fromJson(row.fields)).toList();

      if (categorias.isNotEmpty) {
        print(categorias);
        return true; // Si hay categorías, devuelve true
      } else {
        agregarMsj('Error en la configuracion de codigo de Bar de Categoria');
        return false; // Si la lista está vacía, devuelve false
      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return false; // Si hay algún error, devuelve false
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

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

  Future<List<Producto>> consultarStockProductos( int? establecimiento, List<Producto> productosConsultar ) async {
    MySqlConnection? conn;
    conn = await _connectionSQL.getConnection();

    List<Producto> productos = [];

    for (final producto in productosConsultar) {
      var results = await conn.query(
          'SELECT * FROM productos as p WHERE p.establecimiento_id = ? AND p.codigo_interno = ?',
          [establecimiento, producto.codigo_interno]
      );

      for (var row in results) {
        Producto prod = Producto(
            idPedido: row['idPedido'],
            id: row['id'],
            nombreproducto: row['nombreproducto'],
            foto: row['foto'],
            precioproducto: row['precioproducto'],
            stock: row['stock'],
            codigo_interno: row['codigo_interno'],
            categoria_id: row['categoria_id'],
            estado: row['estado']
        );
        productos.add(prod);
      }
    }

    return productos;
  }

  Future<Producto> consultarStockProducto( int? establecimiento, Producto productoConsultar ) async {
    MySqlConnection? conn;
    conn = await _connectionSQL.getConnection();

    Producto prod =  new Producto();

      var results = await conn.query(
          'SELECT * FROM productos as p WHERE p.establecimiento_id = ? AND p.codigo_interno = ?',
          [establecimiento, productoConsultar.codigo_interno]
      );

      for (var row in results) {
        prod = Producto(
            idPedido: row['idPedido'],
            id: row['id'],
            nombreproducto: row['nombreproducto'],
            foto: row['foto'],
            precioproducto: row['precioproducto'],
            stock: row['stock'],
            codigo_interno: row['codigo_interno'],
            categoria_id: row['categoria_id'],
            estado: row['estado']
        );
      }
    return prod;
  }

  Future<bool> cambiarStockProducto(BuildContext context, int? establecimiento, Producto producto ) async {
    MySqlConnection? conn;
    try {
      // Conexión a la base de datos
      conn = await _connectionSQL.getConnection();

      // Consulta para actualizar el stock
      var results = await conn.query(
          'UPDATE productos SET stock = stock - ? WHERE codigo_interno = ? AND establecimiento_id = ?',
          [producto.stock, producto.codigo_interno, establecimiento]
      );

      // Comprobar si la actualización afectó alguna fila
      if (results.affectedRows! > 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error al actualizar el stock: $e');
      return false;
    } finally {
      // Cerrar la conexión
      await conn?.close();
    }
  }
}