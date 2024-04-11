


import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restauflutter/model/categoria.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/mesaDetallePedido.dart';
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
  late List<Detalle_Pedido> detalle_pedido = [];

  List<Producto>? productosSeleccionadosOtenidos = [];
  List<Producto>? productosSeleccionados = [];
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _getProductos();
    _getCategorias();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Mesa) {
      mesa = args;
      print('ESTADO DE MESA ${mesa.estadoMesa}');
    }
    // Verifica si los argumentos son de tipo List<Detalle_Pedido>
    else if (args is MesaDetallePedido) {
      mesa = args.mesa;
      detalle_pedido = args.detallePedido;
      // Itera sobre los detalles del pedido, si es necesario

      detalle_pedido.forEach((detalle) async {
        // Busca el producto correspondiente al detalle
        Producto? producto = await _getProductoPorId(detalle.id_producto);
        Producto? setproducto = Producto(
          id: producto?.id,
          nombreproducto: producto?.nombreproducto,
          precioproducto: producto?.precioproducto,
          stock: detalle.cantidad_producto,
          comentario: detalle.comentario,
          idPedido: detalle.id_pedido
        );
        print('NOMBRE PRODUCTO ${producto?.nombreproducto}');
        print('CANTIDAD PRODUCTO ${detalle.cantidad_producto}');
        print('PRECIO PRODUCTO ${detalle.precio_producto}');

        if (producto != null) {
          // Agrega el producto a la lista de productos encontrados
          productosSeleccionados?.add(setproducto);
        }
      });
    }
    obtenerLista();
     // mesa = ModalRoute.of(context)?.settings.arguments as Mesa;
     // print('---> Producto controller');
     // print('ESTADO Id DE MESA : ${mesa.estadoMesa} \n Estado : ${mesa.estDisMesa}');
    refresh();
  }

  void obtenerLista(){
    detalle_pedido.forEach((detalle) async {
      // Busca el producto correspondiente al detalle
      Producto? producto = await _getProductoPorId(detalle.id_producto);
      Producto? setproducto = Producto(
        id: producto?.id,
          nombreproducto: producto?.nombreproducto,
          precioproducto: producto?.precioproducto,
          stock: detalle.cantidad_producto,
          comentario: detalle.comentario,
          idPedido: detalle.id_pedido
      );
      print('NOMBRE PRODUCTO ${producto?.nombreproducto}');
      print('CANTIDAD PRODUCTO ${detalle.cantidad_producto}');
      print('PRECIO PRODUCTO ${detalle.precio_producto}');

      if (producto != null) {
        productosSeleccionadosOtenidos?.add(setproducto);
        print('INIT ${productosSeleccionadosOtenidos![0].stock}');
      }
    });
  }

  Future<Producto?> _getProductoPorId(int? idProducto) async {
    try {
      String productosJson = await _sharedPref.read('productos');
      if (productosJson.isNotEmpty) {
        List<dynamic> productosData = json.decode(productosJson);
        // Busca el producto con el ID dado
        for (var productoJson in productosData) {
          Producto producto = Producto.fromJson(productoJson);
          if (producto.id == idProducto) {
            return producto;
          }
        }
      }
    } catch (e) {
      print('Error al obtener el producto por ID: $e');
    }
    return null; // Devuelve null si no se encuentra el producto
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


