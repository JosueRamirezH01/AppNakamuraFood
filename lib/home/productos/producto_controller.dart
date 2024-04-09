


import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restauflutter/model/categoria.dart';
import 'package:restauflutter/utils/shared_pref.dart';

import '../../model/mesa.dart';
import '../../model/producto.dart';
class ProductoController {
  late BuildContext context;
  late Function refresh;
  final SharedPref _sharedPref = SharedPref();
  List<Categoria> categorias = [];
  List<Producto> productos = [];
  late Timer searchOnStoppedTyping = Timer(Duration.zero, () {});
  String productName = '';
  late  Mesa mesa =  Mesa();
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _getProductos();
    _getCategorias();
     mesa = ModalRoute.of(context)?.settings.arguments as Mesa;
     print('---> Producto controller');
     print('ESTADO Id DE MESA : ${mesa.estadoMesa} \n Estado : ${mesa.estDisMesa}');
    refresh();
  }


  void onChangeText(String text) {
    const duration = Duration(
        milliseconds: 800); // set the duration that you want call search() after that.
    searchOnStoppedTyping.cancel();
    refresh();

    searchOnStoppedTyping = Timer(duration, () {
      productName = text;

      refresh();
      _getProductos();
      print('TEXTO COMPLETO $text');
    });
  }


  Future<void> _getCategorias() async {
    try {
      String categoriasJson = await _sharedPref.read('categorias');
      if (categoriasJson.isNotEmpty) {
        List<dynamic> categoriasData = json.decode(categoriasJson);
        categorias = categoriasData.map((categoriaJson) =>
            Categoria.fromJson(categoriaJson)).toList();
      }
    } catch (e) {
      print('Error al obtener las categorías: $e');
    }
  }

  Future<void> _getProductos() async {
    try {
      String productosJson = await _sharedPref.read('productos');
      if (productosJson.isNotEmpty) {
        List<dynamic> productosData = json.decode(productosJson);

        // Filtra los productos según el nombre basado en la búsqueda
        if (productName.isNotEmpty) {
          productos = productosData
              .map((productoJson) => Producto.fromJson(productoJson))
              .where((producto) =>
              producto.nombreproducto!.toLowerCase().contains(
                  productName.toLowerCase()))
              .toList();
        } else {
          productos = productosData.map((productoJson) =>
              Producto.fromJson(productoJson)).toList();
        }
      }
    } catch (e) {
      print('Error al obtener los productos: $e');
    }
  }



  Future<List<Producto>> getProductosPorCategoria(int? categoriaId) async {
    try {
      String productosJson = await _sharedPref.read('productos');
      if (productosJson.isNotEmpty) {
        List<dynamic> productosData = json.decode(productosJson);

        if (categoriaId == 1) {
          List<Producto> productosCategoria = productosData
              .map((productoJson) => Producto.fromJson(productoJson))
              .toList();
          return productosCategoria;
        }
        // Filtra los productos por el ID de categoría
        List<Producto> productosCategoria = productosData
            .map((productoJson) => Producto.fromJson(productoJson))
            .where((producto) => producto.categoria_id == categoriaId)
            .toList();

        return productosCategoria;
      }
    } catch (e) {
      print('Error al obtener los productos por categoría: $e');
    }
    return [];
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
  void agregarMsj(String mensaje){
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}


