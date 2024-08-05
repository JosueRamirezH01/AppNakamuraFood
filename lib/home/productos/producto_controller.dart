import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restauflutter/model/categoria.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/mesaDetallePedido.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/services/detalle_pedido_service.dart';
import 'package:restauflutter/services/modulos_service.dart';
import 'package:restauflutter/utils/shared_pref.dart';

import '../../model/mesa.dart';
import '../../model/producto.dart';
import '../../model/usuario.dart';
import '../../services/modulos_service.dart';

class ProductoController {
  late BuildContext context;
  late Function refresh;
  final SharedPref _sharedPref = SharedPref();
  List<Categoria> categorias = [];
  List<Producto> productos = [];

  late Timer searchOnStoppedTyping = Timer(Duration.zero, () {});
  String productName = '';
  late Mesa mesa = Mesa();
  late int IDPEDIDO = 0;
  late List<Detalle_Pedido> detalle_pedido = [];
  var dbDetallePedido = DetallePedidoServicio();
  var Modulos = ModuloServicio();
  List<Producto>? productosSeleccionados = [];
  bool items_independientes = true; // CAMBIAR A FALSE, ESTA EN TRUE EN CUESTION DE PRUEBA

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _getCategorias();
    _getProductos();
    final dynamic userData = await _sharedPref.read('user_data');
    final Map<String, dynamic> userDataMap = json.decode(userData);
    final Usuario usuario = Usuario.fromJson(userDataMap);

    //items_independientes = await Modulos.consultarItemsIndependientes(usuario.accessToken);
    print('activo itemsindependientes : ${items_independientes}');

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Mesa) {
      mesa = args;
      print('ESTADO DE MESA ${mesa.estadoMesa}');
    }
    // Verifica si los argumentos son de tipo List<Detalle_Pedido>
    else if (args is MesaDetallePedido) {
      mesa = args.mesa;
      detalle_pedido = args.detallePedido;
      IDPEDIDO = detalle_pedido.first.id_pedido!;
      // Itera sobre los detalles del pedido, si es necesario

      detalle_pedido.forEach((detalle) async {
        // Busca el producto correspondiente al detalle
        Producto? producto = await _getProductoPorId(detalle.id_producto);
        print('LISTA DE PRODUCTOS ${producto?.toJson()}');
        Producto? setproducto = Producto(
            id_pedido_detalle: detalle.id_pedido_detalle,
            id: producto?.id,
            nombreproducto: producto?.nombreproducto,
            precioproducto: detalle.precio_producto,
            stock: detalle.cantidad_producto,
            comentario: detalle.comentario,
            idPedido: detalle.id_pedido);
        print('NOMBRE PRODUCTO ${producto?.nombreproducto}');
        print('CANTIDAD PRODUCTO ${detalle.cantidad_producto}');
        print('PRECIO PRODUCTO ${detalle.precio_producto}');

        if (producto != null) {
          // Agrega el producto a la lista de productos encontrados
          productosSeleccionados?.add(setproducto);
        }
      });
    }

    refresh();
  }

  Future<int> obtenerIdPedidoLast() async {
    return await dbDetallePedido.consultaObtenerDetallePedido(mesa.id, context);
  }

  // Sin usar
  Future<List<Detalle_Pedido>> obtenerDetallePedidoLastCreate(
      int idPedido) async {
    return await dbDetallePedido.obtenerDetallePedidoLastCreate(
        idPedido, context);
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
    const duration = Duration(milliseconds: 800);
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
        categorias = categoriasData
            .map((categoriaJson) => Categoria.fromJson(categoriaJson))
            .toList();
        refresh();
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

        if (productName.isNotEmpty) {
          // Filtra los productos según el código interno exacto o el nombre basado en la búsqueda
          productos = productosData
              .map((productoJson) => Producto.fromJson(productoJson))
              .where((producto) {
            final codigoInterno = producto.codigo_interno ?? "";
            final nombreProducto = producto.nombreproducto ?? "";
            final isNumeric = RegExp(r'^[0-9]+$').hasMatch(productName);
            final isAlphaNumeric = RegExp(r'^[0-9a-zA-Z]+$').hasMatch(productName);


            if (isNumeric) {
              // Si el término de búsqueda es un número, buscar por código interno
              return codigoInterno.toLowerCase() == productName.toLowerCase();
            } else if (isAlphaNumeric) {
              // Si el término de búsqueda es alfanumérico, buscar por nombre o código interno
              return codigoInterno.toLowerCase() == productName.toLowerCase() || nombreProducto.toLowerCase().contains(productName.toLowerCase());
            } else {
              // Si el término de búsqueda no es ni un número ni alfanumérico, buscar solo por nombre
              return nombreProducto.toLowerCase().contains(productName.toLowerCase());
            }
          })
              .toList();
        } else {
          // Si no se proporciona ningún texto de búsqueda, reinicia la lista de productos
          productos = await getProductosPorCategoria(categorias.isNotEmpty ? categorias.first  : null);
        }
      }
    } catch (e) {
      print('Error al obtener los productos: $e');
    }
  }

  // Future<void> _getProductos() async {
  //   try {
  //     final response = await http.get(Uri.parse('https://chifalingling.restaupe.com/api/obtener_lista_productos'));
  //     late Mozo? mozo = Mozo();
  //     final dynamic userData = await _sharedPref.read('user_data');
  //     if (userData != null) {
  //       final Map<String, dynamic> userDataMap = json.decode(userData);
  //       mozo = Mozo.fromJson(userDataMap);
  //     }
  //
  //     if (response.statusCode == 200) {
  //       List<dynamic> productosData = json.decode(response.body);
  //       productosData = productosData.where((producto) {
  //         return producto['estado'] == 1 && producto['establecimiento_id'] == mozo!.id_establecimiento;
  //       }).toList();
  //
  //       // Guardar productos filtrados en SharedPreferences
  //       // SharedPreferences prefs = await SharedPreferences.getInstance();
  //       _sharedPref.save('productos', json.encode(productosData));
  //
  //       if (productName.isNotEmpty) {
  //         productos = productosData
  //             .map((productoJson) => Producto.fromJson(productoJson))
  //             .where((producto) {
  //           final codigoInterno = producto.codigo_interno ?? "";
  //           final nombreProducto = producto.nombreproducto ?? "";
  //           final isNumeric = RegExp(r'^[0-9]+$').hasMatch(productName);
  //           final isAlphaNumeric = RegExp(r'^[0-9a-zA-Z]+$').hasMatch(productName);
  //
  //           if (isNumeric) {
  //             return codigoInterno.toLowerCase() == productName.toLowerCase();
  //           } else if (isAlphaNumeric) {
  //             return codigoInterno.toLowerCase() == productName.toLowerCase() ||
  //                 nombreProducto.toLowerCase().contains(productName.toLowerCase());
  //           } else {
  //             return nombreProducto.toLowerCase().contains(productName.toLowerCase());
  //           }
  //         }).toList();
  //       } else {
  //         productos = productosData
  //             .map((productoJson) => Producto.fromJson(productoJson))
  //             .toList();
  //       }
  //     } else {
  //       print('Error al obtener los productos: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error al obtener los productos: $e');
  //   }
  // }

  Future<List<Producto>> getProductosPorCategoria(Categoria? categoria) async {
    try {
      String productosJson = await _sharedPref.read('productos');
      if (productosJson.isNotEmpty) {
        List<dynamic> productosData = json.decode(productosJson);

        if (categoria!.nombre!.toLowerCase() == 'todos') {
          List<Producto> productosCategoria = productosData
              .map((productoJson) => Producto.fromJson(productoJson))
              .toList();
          return productosCategoria;
        }
        // Filtra los productos por el ID de categoría
        List<Producto> productosCategoria = productosData
            .map((productoJson) => Producto.fromJson(productoJson))
            .where((producto) => producto.categoria_id == categoria.id)
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

  void agregarMsj(String mensaje) {
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
