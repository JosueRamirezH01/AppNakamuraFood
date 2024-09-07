import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/nota.dart';
import 'package:restauflutter/model/pedido.dart';
import 'package:restauflutter/model/piso.dart';
import 'package:restauflutter/model/producto.dart';
import 'package:restauflutter/services/entorno_service.dart';
import 'package:restauflutter/services/mesas_service.dart';
import 'package:restauflutter/services/pedido_service.dart';
import 'package:restauflutter/services/detalle_pedido_service.dart';
import 'package:restauflutter/services/piso_service.dart';
import 'package:restauflutter/utils/gifComponent.dart';
import 'package:restauflutter/utils/impresora.dart';
import 'package:restauflutter/utils/shared_pref.dart';
import 'package:restauflutter/utils/ticketBluetooth.dart';

import '../../model/PedidoResponse.dart';
import '../../model/categoria.dart';
import '../../model/usuario.dart';

class DetailsPage extends StatefulWidget {
  final List<Producto>? productosSeleccionados;
  List<Detalle_Pedido> detallePedidoLista;
  final Mesa? mesa;
  int? idPedido;
  bool items_independientes;
  final void Function(List<Producto>?)? onProductosActualizados;

  DetailsPage(
      {super.key,
        required this.productosSeleccionados,
        required this.detallePedidoLista,
        required this.mesa,
        required this.idPedido,
        required this.items_independientes,
        this.onProductosActualizados});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  TextEditingController notaController = TextEditingController();
  var bdPisos = PisoServicio();
  var bdMesas = MesaServicio();
  var bdPedido = PedidoServicio();
  var impresora = Impresora();
  var ticketBluetooth = TicketBluetooth();
  final SharedPref _pref = SharedPref();
  late Usuario? usuario = Usuario();
  late Piso piso = Piso();
  late int? IDPEDIDOPRUEBA = 0;
  List<bool> _checkedItems = [];
  List<Nota> listaNota = [];

  Future<void> UserShared() async {
    final dynamic userData = await _pref.read('user_data');
    if (userData != null) {
      final Map<String, dynamic> userDataMap = json.decode(userData);
      usuario = Usuario.fromJson(userDataMap);
    }
  }

  List<Mesa> mesasDisponibles = [];
  List<Detalle_Pedido> detalles_pedios_tmp = [];
  List<Piso> listaPisos = [];
  late Mesa selectObjmesa;
  PedidoServicio pedidoServicio = PedidoServicio();
  MesaServicio mesaServicio = MesaServicio();
  var entornoService = EntornoService();

  DetallePedidoServicio detallePedidoServicio = DetallePedidoServicio();
  late Pedido newpedido = Pedido();
  late double pedidoTotal;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectObjmesa = widget.mesa!;
    detalles_pedios_tmp = widget.detallePedidoLista;
    UserShared();
    _checkedItems = List.filled(listaNota.length, false);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (screenWidth < 600) icono(),
            //if (widget.mesa!.estadoMesa != 1 && widget.mesa!.estadoMesa != 2)
            if(widget.mesa!.estadoMesa != 1)
              cabecera(),
            contenido(),
            debajo()
          ],
        ),
      ),
    );
  }

  Widget contenido() {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }
    double sizeHeigth =
    widget.mesa!.estadoMesa != 1  /*&& widget.mesa!.estadoMesa != 2*/
        ? 0.56
        : 0.65;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.metrics.atEdge &&
            notification.metrics.pixels <= 0) {
          return false;
        }
        return true;
      },
      child: SingleChildScrollView(
        child: Container(
          margin: crossAxisCount <= 3 ? EdgeInsets.only(top: 15, left: 15, right: 15) : null,
          height: MediaQuery.of(context).size.height * sizeHeigth,
          width: screenWidth > 600 ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 8,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            border: Border.all(width: 2),
          ),
          child: ListView.builder(
            itemCount: widget.productosSeleccionados?.length,
            itemBuilder: (_, int index) {
              return Column(
                children: [
                  Container(
                    decoration: widget.productosSeleccionados?[index].id_pedido_detalle == null ||
                        widget.productosSeleccionados?[index].aCStock == true
                        ? BoxDecoration(
                            border: Border.all(
                              color: Colors.purpleAccent,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          )
                        : null,
                    margin: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    padding: widget.productosSeleccionados?[index]
                        .id_pedido_detalle ==
                        null
                        ? const EdgeInsets.all(8.0)
                        : null,
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.productosSeleccionados?[index].nombreproducto}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Column(
                            children: [
                               //if (widget.mesa!.estadoMesa != 2 && widget.items_independientes == false)
                              if(widget.items_independientes == false)
                                _addOrRemoveItem(index),
                                _precioProducto(index),
                            ],
                          ),
                          const SizedBox(width: 5),
                           //if (selectObjmesa.estadoMesa != 2 || widget.mesa!.estadoMesa != 2)
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                              margin: widget.items_independientes == false ? EdgeInsets.only(bottom: 25) : null ,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _iconDelete( index, widget.productosSeleccionados?[index].id_pedido_detalle),
                              ),
                            ),
                          const SizedBox(width: 5),
                          //if (selectObjmesa.estadoMesa != 2 || widget.mesa!.estadoMesa != 2)
                            Container(
                              decoration: BoxDecoration( color: Colors.grey[200], borderRadius: BorderRadius.all(Radius.circular(20))),
                              margin: widget.items_independientes == false ? EdgeInsets.only(bottom: 25) : null ,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _iconNota(
                                    index,
                                    widget.productosSeleccionados?[index]
                                        .id_pedido_detalle),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (index != widget.productosSeleccionados!.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 2,
                      indent: 10,
                      endIndent: 10,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _precioProducto(int index) {
    print('---------${widget.productosSeleccionados![index].precioproducto}');
    double p = widget.productosSeleccionados![index].precioproducto! *
        (widget.productosSeleccionados![index].stock ?? 0);
    // Devuelve un widget vacío si el índice está fuera de rango o el detalle del pedido es nulo
    return Container(
      decoration: widget.items_independientes == true ?
        BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
            topRight: Radius.circular(8)
          ),
          color: widget.items_independientes == false ? Colors.grey[200] : null,
        ) : null ,
      child: Padding(
        padding: widget.items_independientes == true ?  EdgeInsets.all(8.0) : EdgeInsets.all(0),
        child: Text(
          '$p',
          // Agrega el estilo de texto necesario aquí
        ),
      ),
    );
  }

  Widget _iconDelete(int index, int? id_pedido_detalle) {
    return GestureDetector(
      onTap: () {
        print("CODIGO A ELIMINAR ${id_pedido_detalle}");
        _eliminar(index, id_pedido_detalle);
      },
      child: const Icon(Icons.delete, color: Colors.red),
    );
  }

  Widget _iconNota(int index, int? id_pedido_detalle) {
    print('_iconNota : ${index}');
    print('Comentario Llegada : ${widget.productosSeleccionados?[index].comentario.runtimeType}');
    return GestureDetector(
      onTap: () async {
        String? listaNotaString = await  _pref.read('listaNota');
        List<dynamic> listaNotaJson = jsonDecode(listaNotaString!);
        listaNota = Nota.fromJsonList(listaNotaJson);
        print('INDEX ${index}');
        _nota(listaNota, index, id_pedido_detalle);
      },
      child: const Icon(Icons.edit, color: Colors.amber),
    );
  }

  Widget icono() {
    return const Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Divider(
        indent: 150,
        endIndent: 150,
        thickness: 4,
      ),
    );
  }

  Widget cabecera() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: screenWidth < 600 ? 20 : 1, bottom: 10),
            width: MediaQuery.of(context).size.width * 0.9,
            // height: MediaQuery.of(context).size.height * 0.08,
            decoration: BoxDecoration(
                border: Border.fromBorderSide(BorderSide(width: 2)),
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.transparent //Color(0xFF99CFB5)
            ),
            child: Row(
              children: [
                // const SizedBox(width: 5),
                // Container(
                //   margin: EdgeInsets.only(left: 10 ),
                //   child: ElevatedButton(
                //       style:  ButtonStyle(
                //           elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(const Color(0xFF4C95DD))),
                //       onPressed: () async {
                //         gif();
                //         //mesasDisponibles = await bdMesas.consultarMesasDisponibles(widget.mesa?.pisoId, context);
                //         //listaPisos = await bdPisos.consultarPisos(mozo!.id_establecimiento!, context);----- SOMBREADO
                //         mesasDisponibles = await bdMesas.consultarTodasMesas(listaPisos, context);
                //         List<Mesa> mesasDisponiblesFiltradas = mesasDisponibles.where((mesa) => mesa.estadoMesa == 1).toList();
                //         Navigator.pop(context);
                //         mostrarMesa(mesasDisponiblesFiltradas);
                //       },
                //       child: const Text(
                //         'Cambiar Mesa',
                //         style: TextStyle(color: Colors.white, fontSize: 16),
                //       )),
                // ),
                // const SizedBox(width: 10),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(right: 0),
                  child: ElevatedButton(
                      style: ButtonStyle(elevation: MaterialStateProperty.all(2),backgroundColor: MaterialStateProperty.all(const Color(0xFF634FD2))),
                      onPressed: () async {
                        print('---->BA BOTON ACTUALIZAR');
                        if (widget.items_independientes) {
                          String? printerIP = await _pref.read('ipCocina');
                          bool _stateConexionTicket = await _pref.read('stateConexionTicket') ?? false;
                          bool conexionBluetooth = await _pref.read('conexionBluetooth') ?? false;

                          if (_stateConexionTicket) {
                            if (conexionBluetooth) {
                              _operacionACtualziaIndependiente(1);
                            } else {
                              String messague = 'No se ha encontrado conectado a un dispositivo Bluetooth.';
                              showMessangueDialog(messague);
                              return;
                            }
                          } else {
                            if (printerIP == null) {
                              String messague = 'No se ha encontrado la dirección IP de la impresora.';
                              showMessangueDialog(messague);
                              return; // Salir del método printLabel
                            } else {
                              _operacionACtualziaIndependiente(2);
                            }
                          }
                        }
                        else {
                          String? printerIP = await _pref.read('ipCocina');
                          bool _stateConexionTicket = await _pref.read('stateConexionTicket') ?? false;
                          bool conexionBluetooth = await _pref.read('conexionBluetooth') ?? false;

                          if (_stateConexionTicket) {
                            if (conexionBluetooth) {
                              _operacionAC(1);
                              refresh();
                            } else {
                              String messague = 'No se ha encontrado conectado a un dispositivo Bluetooth.';
                              showMessangueDialog(messague);
                              return;
                            }
                          } else {
                            if (printerIP == null) {
                              String messague = 'No se ha encontrado la dirección IP de la impresora.';
                              showMessangueDialog(messague);
                              return; // Salir del método printLabel
                            } else {
                              _operacionAC(2);
                              refresh();
                            }
                          }
                        }
                      },
                      child: const Text('Actualizar',
                          style: TextStyle(color: Colors.white, fontSize: 16))),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // void _operacionACitemsIndependiente(int WifiOBlue) {
  //   if (widget.productosSeleccionados!.length > 0) {
  //     gif();
  //     List<Producto> productosToPrint = [];
  //
  //     for (final producto in widget.productosSeleccionados!) {
  //       int index = widget.productosSeleccionados!.indexOf(producto);
  //       print('Índice del producto: $index');
  //
  //       print('Antes de actualizar: Producto ID: ${producto.id}, ID Pedido Detalle: ${producto.id_pedido_detalle}');
  //     }
  //
  //     if (productosToPrint.isNotEmpty) {
  //       // await detallePedidoServicio.actualizarAgregarProductoDetallePedidoItem(widget.idPedido, pedidoTotal,context);
  //
  //       if (WifiOBlue == 1) {
  //         ticketBluetooth.printLabelBluetooth(productosToPrint, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '');
  //       } else if (WifiOBlue == 2) {
  //         imprimir(productosToPrint, 2);
  //       }
  //
  //       imprimir(productosToPrint, 2);
  //       print('Hay productos que Actualizar');
  //       Navigator.pop(context);
  //     } else {
  //       mostrarMensajeActualizado(
  //           'No hay productos que Actualizar', true);
  //       print('No hay productos que Actualizar');
  //       Navigator.pop(context);
  //     }
  //   } else {
  //     mostrarMensajeActualizado(
  //         'No puedes dejar la lista vacia', true);
  //   }
  // }

  void _operacionAC(int WifiOBlue) async {
    if (widget.productosSeleccionados!.length > 0) {
      gif();
      List<Producto> productosToPrint = [];
      List<Producto> productosConIdDetalle = [];
      List<Producto> productosSinIdDetalle = [];

      List<Detalle_Pedido> detallepedidosToCompare = widget.detallePedidoLista;

      detallepedidosToCompare.forEach((element) {
        print('Compare : ${element.toJson()}');
      });

      widget.productosSeleccionados!.forEach((producto) {
        print('cargandoPD : ${producto.id_pedido_detalle}');
        if (producto.id_pedido_detalle != null) {
          if (detallepedidosToCompare.any((detalle) =>
          detalle.id_pedido_detalle == producto.id_pedido_detalle)) {
            productosConIdDetalle.add(producto);
          }
        } else {
          productosSinIdDetalle.add(producto);
        }
      });

      print('productosSinIdDetalle : ${productosSinIdDetalle.length}');
      print('productosConIdDetalle : ${productosConIdDetalle.length}');

      Map<String, dynamic> pedidoDetalleAc = {
        "monto_total": pedidoTotal,
        "detalle": widget.productosSeleccionados!.map((producto) => {
          "id_pedido_detalle": producto.id_pedido_detalle,
          "id_pedido": producto.idPedido,
          "id_producto": producto.id,
          "cantidad_producto": producto.stock,
          "cantidad_real": producto.stock,
          "precio_unitario": producto.precioproducto,
          "precio_producto": producto.precioproducto! * producto.stock!.toInt(),
          "comentario": producto.comentario,
          "estado_detalle": 1
        }).toList()
      };

      Map<String, dynamic> detalleActualizadoJson = await detallePedidoServicio.actualizarPedidoConRespuestaApi( usuario?.accessToken, pedidoDetalleAc, widget.mesa?.id);

      print({'busqueda : ${detalleActualizadoJson}'});
      bool statusAcJson = detalleActualizadoJson['status'];

      if (statusAcJson) {
        List<dynamic> detalleAcJson = detalleActualizadoJson['detalle_actualizado'];
        print('Respuesta ${detalleAcJson}');

        List<Detalle_Pedido> detalleActualizado = detalleAcJson.map((json) => Detalle_Pedido.fromJson({
                  "id_detalle": json["id_pedido_detalle"],
                  "id_pedido": json["id_pedido"],
                  "id_producto": json["id_producto"],
                  "cantidad_producto": json["cantidad_producto"],
                  "cantidad_actualizada": json["cantidad_actualizada"],
                  "cantidad_exacta": json["cantidad_exacta"],
                  "cantidad_real": json["cantidad_real"],
                  "precio_producto": double.tryParse(json["precio_producto"]?.toString() ?? "0.0"),
                  "precio_unitario": double.tryParse(json["precio_unitario"]?.toString() ?? "0.0"),
                  "comentario": json["comentario"],
                  "estado_detalle": json["estado_detalle"],
                  "updated_at": DateTime.parse(json["updated_at"]),
                })).toList();

        print('detalleActualizado${detalleActualizado}');
        // Crear un mapa para contar la cantidad de productos por id_producto
        // Map<int, int> conteoProductos = {};

        // Asignar id_pedido_detalle a productos sin id_pedido_detalle
        productosSinIdDetalle.forEach((producto) {
          Detalle_Pedido? detalleCorrespondiente = detalleActualizado.firstWhere((detalle) =>
            detalle.id_producto == producto.id &&
            detalle.precio_unitario == producto.precioproducto,
          );

          if (detalleCorrespondiente != null) {
            setState(() {
              widget.detallePedidoLista.add(detalleCorrespondiente);
            });
            setState(() {
              producto.id_pedido_detalle = detalleCorrespondiente.id_pedido_detalle;
              producto.idPedido = detalleCorrespondiente.id_pedido;
            });
            producto.stock = detalleCorrespondiente.cantidad_actualizada;
            productosToPrint.add(producto);

            // Reducir el contador de productos
            // conteoProductos[producto.id!] = conteoProductos[producto.id!]! - 1;
          }
        });

        print('cantidadConID : ${productosConIdDetalle.length}');
        productosConIdDetalle.forEach((producto) {
          if (detalleActualizado.any((detalle) => detalle.id_pedido_detalle == producto.id_pedido_detalle)) {
            Detalle_Pedido? detalleCorrespondiente = detalleActualizado.firstWhere((detalle) =>
              detalle.id_producto == producto.id &&
              detalle.id_pedido_detalle == producto.id_pedido_detalle,
            );
            print('paraAc : ${detalleCorrespondiente.toString()}');

            if (detalleCorrespondiente != null) {
              setState(() {
                widget.productosSeleccionados!.firstWhere((element) => element.id_pedido_detalle == detalleCorrespondiente.id_pedido_detalle).aCStock = false;
              });

              productosToPrint.add(Producto(
                codigo: producto.codigo,
                codigo_interno: producto.codigo_interno,
                estado: producto.codigo,
                id_pedido_detalle: producto.id_pedido_detalle,
                identificador: producto.identificador,
                categoria_id: producto.categoria_id,
                establecimiento_id: producto.establecimiento_id,
                comentario: detalleCorrespondiente.comentario,
                idPedido: detalleCorrespondiente.id_pedido,
                nombreproducto: producto.nombreproducto,
                id: detalleCorrespondiente.id_producto,
                stock: detalleCorrespondiente.cantidad_actualizada,
              ));
            }
          }
        });

        if (productosToPrint.isNotEmpty){
          if (WifiOBlue == 1) {
            ticketBluetooth.printLabelBluetooth(productosToPrint, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', detalleActualizado[0].id_pedido);
          } else if (WifiOBlue == 2) {
            imprimir(productosToPrint, 2, detalleActualizado[0].id_pedido);
          }
          print('Hay productos que Actualizar');
          Navigator.pop(context);
        }
        else {
          mostrarMensajeActualizado('Revisal la lista productosToPrint : ${productosToPrint.length}', true);
          print('No hay productos que Actualizar');
          Navigator.pop(context);
        }

        widget.productosSeleccionados!.forEach((element) {
          print('RQ->Productos :${element.nombreproducto}, ID_Detalle ${element.id_pedido_detalle}');
        });
      } else {
        mostrarMensajeActualizado('No hay productos que Actualizar', true);
        print('No hay productos que Actualizar');
        Navigator.pop(context);
      }
    } else {
      mostrarMensajeActualizado('No puedes dejar la lista vacia', true);
    }
  }

  void _operacionACtualziaIndependiente(int WifiOBlue) async {
    if (widget.productosSeleccionados!.length > 0) {
      gif();
      List<Producto> productosToPrint = [];
      List<Producto> productosSinIdDetalle = [];

      widget.productosSeleccionados!.forEach((producto) {
        if (producto.id_pedido_detalle == null) {
          productosSinIdDetalle.add(producto);
        }
      });

      print('productosSinIdDetalle : ${productosSinIdDetalle.length}');

      Map<String, dynamic> pedidoDetalleAc = {
        "monto_total": pedidoTotal,
        "detalle": widget.productosSeleccionados!
            .map((producto) => {
          "id_pedido_detalle": producto.id_pedido_detalle,
          "id_pedido": producto.idPedido,
          "id_producto": producto.id,
          "cantidad_producto": producto.stock,
          "cantidad_real": producto.stock,
          "precio_unitario": producto.precioproducto,
          "precio_producto":
          producto.precioproducto! * producto.stock!.toInt(),
          "comentario": producto.comentario,
          "estado_detalle": 1
        }).toList()
      };

      Map<String, dynamic> detalleActualizadoJson = await detallePedidoServicio.actualizarPedidoConRespuestaApi(usuario?.accessToken, pedidoDetalleAc, widget.mesa?.id);
      bool statusAcJson = detalleActualizadoJson['status'];


      if (statusAcJson) {
        List<dynamic> detalleAcJson = detalleActualizadoJson['detalle_actualizado'];

        List<Detalle_Pedido> detalleActualizado = detalleAcJson
            .map((json) => Detalle_Pedido.fromJson({
          "id_detalle": json["id_pedido_detalle"],
          "id_pedido": json["id_pedido"],
          "id_producto": json["id_producto"],
          "cantidad_producto": json["cantidad_producto"],
          "cantidad_actualizada": json["cantidad_actualizada"],
          "cantidad_exacta": json["cantidad_exacta"],
          "cantidad_real": json["cantidad_real"],
          "precio_producto": double.tryParse(
              json["precio_producto"]?.toString() ?? "0.0"),
          "precio_unitario": double.tryParse(
              json["precio_unitario"]?.toString() ?? "0.0"),
          "comentario": json["comentario"],
          "estado_detalle": json["estado_detalle"],
          "updated_at": DateTime.parse(json["updated_at"]),
        })).toList();



        productosSinIdDetalle.forEach((producto) {
          Detalle_Pedido? detalleCorrespondiente = detalleActualizado.firstWhere(
                (detalle) =>
            detalle.id_producto == producto.id &&
                detalle.precio_unitario == producto.precioproducto,
          );

          if (detalleCorrespondiente != null) {
            setState(() {
              producto.id_pedido_detalle = detalleCorrespondiente.id_pedido_detalle;
              producto.idPedido = detalleCorrespondiente.id_pedido;
            });
            productosToPrint.add(producto);

          }
        });

        if (productosToPrint.isNotEmpty){
          if (WifiOBlue == 1) {
            ticketBluetooth.printLabelBluetooth(productosToPrint, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', detalleActualizado[0].id_pedido);
          } else if (WifiOBlue == 2) {
            imprimir(productosToPrint, 2, detalleActualizado[0].id_pedido);
          }
          print('Hay productos que Actualizar');
          Navigator.pop(context);
        }else{
          mostrarMensajeActualizado('Revisal la lista productosToPrint : ${productosToPrint.length}', true);
          print('No hay productos que Actualizar');
          Navigator.pop(context);
        }

      } else {
        mostrarMensajeActualizado('No hay productos que Actualizar', true);
        print('No hay productos que Actualizar');
        Navigator.pop(context);
      }
    } else {
      mostrarMensajeActualizado('No puedes dejar la lista vacia', true);
    }
  }


  Future gif() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          gifPath: 'assets/gif/download.gif',
        );
      },
    );
  }

  String generateSelectedOptionsString(List<Nota> comidas) {
    List<String> selectedOptions = [];
    for (int i = 0; i < _checkedItems.length; i++) {
      if (_checkedItems[i]) {
        selectedOptions.add(comidas[i].descripcion_nota!);
        print(comidas[i].descripcion_nota!);
      }
    }
    return selectedOptions.join(';');
  }

  String cleanComentario(String? comentario) {
    if (comentario == null || comentario.isEmpty) {
      return '';
    }
    final RegExp regExp = RegExp(r'<span[^>]*>([^<]+)<\/span>');
    Iterable<Match> matches = regExp.allMatches(comentario);

    String cleanedComentario = matches.map((match) => match.group(1)).join(';');
    return cleanedComentario;
  }

  String? convertToSpan(String? comentario) {
    // print('convertToSpan : ${listaNota}');
    if (comentario == null || comentario.isEmpty) {
      return null;
    }

    List<String> partes = comentario.split(';');

    List<String> spans = [];

    for (int i = 0; i < partes.length; i++) {
      spans.add('<span class="style_nota" id="texto-comentario-${listaNota.firstWhere((element) => element.descripcion_nota == partes[i]).id_nota}">${partes[i]}</span>');
    }
    print(spans);

    return spans.join();
  }

  List<String> convertStringToList(String selectedOptionsString) {
    return selectedOptionsString.split(';');
  }

  Future<String?> _nota(List<Nota> comidas, int indexProducto, int? id_pedido_detalle) async {
    print('Index entrada : ${indexProducto}');
    print('comentario entrada : ${widget.productosSeleccionados?[indexProducto].comentario}');

    String? notabd = cleanComentario(widget.productosSeleccionados?[indexProducto].comentario) ?? '';
    List<String> seleccionadosBd = convertStringToList(notabd);

    var productoSeleccionado = widget.productosSeleccionados![indexProducto];
    _checkedItems = List.filled(comidas.length, false);

    for (int i = 0; i < comidas.length; i++) {
      if (seleccionadosBd.contains(comidas[i].descripcion_nota)) {
        _checkedItems[i] = true;
      }
    }

    // Variable para almacenar el texto de búsqueda
    String searchText = '';

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Observaciones del Plato'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Filtrar y reorganizar la lista según la búsqueda
              List<Nota> filteredComidas = comidas;
              if (searchText.isNotEmpty) {
                filteredComidas = comidas
                    .where((nota) => nota.descripcion_nota!.toLowerCase().contains(searchText.toLowerCase()))
                    .toList();
                if (filteredComidas.isNotEmpty) {
                  final notaEncontrada = filteredComidas.removeAt(0);
                  filteredComidas.insert(0, notaEncontrada);
                }
              }
              return Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Buscar nota',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: filteredComidas.isNotEmpty
                          ? Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          itemCount: filteredComidas.length,
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              activeColor: Color(0xFFFF562F),
                              title: Text(filteredComidas[index].descripcion_nota!),
                              value: _checkedItems[comidas.indexOf(filteredComidas[index])],
                              onChanged: (value) {
                                setState(() {
                                  _checkedItems[comidas.indexOf(filteredComidas[index])] = value ?? false;
                                });
                              },
                            );
                          },
                        ),
                      ) : Center(
                        child: ElevatedButton(
                          onPressed: () {
                            print('searchText${searchText}');
                            // Acción para agregar una nueva nota
                          },
                          child: Text('Agregar comentario'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color.fromRGBO(217, 217, 217, 0.8)),
              ),
              onPressed: () {
                setState(() {
                  _checkedItems = List.filled(comidas.length, false);
                });
                Navigator.pop(context, 'Cancel');
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF634FD2)),
              ),
              onPressed: () async {
                String? printerIP = await _pref.read('ipCocina');
                bool _stateConexionTicket = await _pref.read('stateConexionTicket') ?? false;
                bool conexionBluetooth = await _pref.read('conexionBluetooth') ?? false;

                if (_stateConexionTicket) {
                  if (conexionBluetooth) {
                    await acNota(comidas, id_pedido_detalle, indexProducto, 1);
                    refresh();
                  } else {
                    String messague = 'No se ha encontrado conectado a un dispositivo Bluetooth.';
                    showMessangueDialog(messague);
                    return;
                  }
                } else {
                  if (printerIP == null) {
                    String messague = 'No se ha encontrado la dirección IP de la impresora.';
                    showMessangueDialog(messague);
                    return; // Salir del método printLabel
                  } else {
                    await acNota(comidas, id_pedido_detalle, indexProducto, 2);
                    refresh();
                  }
                }

                Navigator.pop(context, 'OK');
              },
              child: Text('Aceptar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> acNota(List<Nota> comidas, int? id_pedido_detalle, int indexProducto, int BlueWifi) async {
    String selectedOptionsString = generateSelectedOptionsString(comidas);
    String? comentarioSpan = convertToSpan(selectedOptionsString);

    if (widget.items_independientes) {
      if (id_pedido_detalle != null) {
        List<Producto> productosToPrint = [];
        var productoSeleccionado = widget.productosSeleccionados![indexProducto];
        productoSeleccionado.comentario = comentarioSpan;

        Map<String, dynamic> pedidoDetalle = {
          "monto_total": pedidoTotal,
          "detalle": [
            {
              "id_pedido_detalle": productoSeleccionado.id_pedido_detalle,
              "id_pedido": productoSeleccionado.idPedido,
              "id_producto": productoSeleccionado.id,
              "cantidad_producto": productoSeleccionado.stock,
              "cantidad_real": productoSeleccionado.stock,
              "precio_unitario": productoSeleccionado.precioproducto,
              "precio_producto": productoSeleccionado.precioproducto! * productoSeleccionado.stock!.toInt(),
              "comentario": productoSeleccionado.comentario,
              "estado_detalle": 1
            }
          ]
        };

        Map<String, dynamic> resultadoNota = await detallePedidoServicio.actualizarPedidoConRespuestaApi( usuario?.accessToken, pedidoDetalle, widget.mesa?.id);
        bool status = resultadoNota['status'];

        if(status){

          if(BlueWifi == 1){
            productosToPrint.add(
                Producto(
                  nombreproducto: productoSeleccionado.nombreproducto,
                  stock: productoSeleccionado.stock,
                  comentario: productoSeleccionado.comentario,
                )
            );
            ticketBluetooth.printLabelBluetooth(productosToPrint, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', productoSeleccionado.idPedido);
          }else if(BlueWifi == 2){
            productosToPrint.add(
                Producto(
                  nombreproducto: productoSeleccionado.nombreproducto,
                  stock: productoSeleccionado.stock,
                  comentario: productoSeleccionado.comentario,
                )
            );
            imprimir(productosToPrint, 2, productoSeleccionado.idPedido);
          }
          print('resultadoNota true : ${resultadoNota.toString()}');
          agregarMsj('Se agregó una nota al producto');
        }
        else{
          print('resultadoNota false: ${resultadoNota.toString()}');
          agregarMsj('No se actualizaron las notas');
        }

        // var productoSeleccionado = widget.productosSeleccionados![indexProducto];
        // productoSeleccionado.comentario = comentarioSpan;
        //
        // Map<String, dynamic> pedidoDetalle = {
        //   "monto_total": pedidoTotal,
        //   "detalle": [
        //     {
        //       "id_pedido_detalle": productoSeleccionado.id_pedido_detalle,
        //       "id_pedido": productoSeleccionado.idPedido,
        //       "id_producto": productoSeleccionado.id,
        //       "cantidad_producto": productoSeleccionado.stock,
        //       "cantidad_real": productoSeleccionado.stock,
        //       "precio_unitario": productoSeleccionado.precioproducto,
        //       "precio_producto": productoSeleccionado.precioproducto! * productoSeleccionado.stock!.toInt(),
        //       "comentario": productoSeleccionado.comentario,
        //       "estado_detalle": 1
        //     }
        //   ]
        // };
        // await detallePedidoServicio.actualizarPedidoApi( usuario?.accessToken, pedidoDetalle, widget.mesa?.id);
        //
        // agregarMsj('Se agregó una nota al producto');
      }
      else {
        widget.productosSeleccionados?[indexProducto].comentario = comentarioSpan;
      }
      print('Índice seleccionado (independiente): $indexProducto');
    }
    else {
      if (id_pedido_detalle != null) {

        List<Producto> productosToPrint = [];
        var productoSeleccionado = widget.productosSeleccionados![indexProducto];
        productoSeleccionado.comentario = comentarioSpan;

        bool hayProductoSinAc = widget.productosSeleccionados!.any((producto) => producto.aCStock == true);

        if(hayProductoSinAc){
          mostrarMensaje('Comentarios agregados');
        }else{
          if(productoSeleccionado.comentario== null){
            Map<String, dynamic> pedidoDetalle = {
              "monto_total": pedidoTotal,
              "detalle": [
                {
                  "id_pedido_detalle": productoSeleccionado.id_pedido_detalle,
                  "id_pedido": productoSeleccionado.idPedido,
                  "id_producto": productoSeleccionado.id,
                  "cantidad_producto": productoSeleccionado.stock,
                  "cantidad_real": productoSeleccionado.stock,
                  "precio_unitario": productoSeleccionado.precioproducto,
                  "precio_producto": productoSeleccionado.precioproducto! * productoSeleccionado.stock!.toInt(),
                  "comentario": productoSeleccionado.comentario,
                  "estado_detalle": 1
                }
              ]
            };

            Map<String, dynamic> resultadoNota = await detallePedidoServicio.actualizarPedidoConRespuestaApi( usuario?.accessToken, pedidoDetalle, widget.mesa?.id);
            bool status = resultadoNota['status'];
            if(status){
              mostrarMensaje('Comentarios vacios');
            }else{
              mostrarMensaje('Error al actualizar sal de la mesa');
            }
          }else{
            Map<String, dynamic> pedidoDetalle = {
              "monto_total": pedidoTotal,
              "detalle": [
                {
                  "id_pedido_detalle": productoSeleccionado.id_pedido_detalle,
                  "id_pedido": productoSeleccionado.idPedido,
                  "id_producto": productoSeleccionado.id,
                  "cantidad_producto": productoSeleccionado.stock,
                  "cantidad_real": productoSeleccionado.stock,
                  "precio_unitario": productoSeleccionado.precioproducto,
                  "precio_producto": productoSeleccionado.precioproducto! * productoSeleccionado.stock!.toInt(),
                  "comentario": productoSeleccionado.comentario,
                  "estado_detalle": 1
                }
              ]
            };

            Map<String, dynamic> resultadoNota = await detallePedidoServicio.actualizarPedidoConRespuestaApi( usuario?.accessToken, pedidoDetalle, widget.mesa?.id);
            bool status = resultadoNota['status'];
            List<dynamic> detalleActualizado = resultadoNota['detalle_actualizado'];
            Map<String, dynamic> detalle = detalleActualizado[0];
            print(detalle.toString());
            int cantidadActualizada = detalle['cantidad_actualizada'];
            print('DATOS ACTUALZIADOS $cantidadActualizada');
            if(status){
              if(BlueWifi == 1){
                productosToPrint.add(
                    Producto(
                        nombreproducto: productoSeleccionado.nombreproducto,
                        stock: cantidadActualizada,
                        comentario: productoSeleccionado.comentario,
                        sinACStock : cantidadActualizada == 0 ? true : false
                    )
                );
                ticketBluetooth.printLabelBluetooth(productosToPrint, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', productoSeleccionado.idPedido);
              }else if(BlueWifi == 2){
                productosToPrint.add(
                    Producto(
                        nombreproducto: productoSeleccionado.nombreproducto,
                        stock: cantidadActualizada,
                        comentario: productoSeleccionado.comentario,
                        sinACStock : cantidadActualizada == 0 ? true : false
                    )
                  // Producto(
                  //   nombreproducto: productoSeleccionado.nombreproducto,
                  //   stock: cantidadActualizada,
                  //   comentario: cleanComentario(productoSeleccionado.comentario) ,
                  // )
                );
                imprimir(productosToPrint, 2, productoSeleccionado.idPedido);
              }
              print('resultadoNota true : ${resultadoNota.toString()}');
              agregarMsj('Se agregó una nota al producto');
            }
            else{
              print('resultadoNota false: ${resultadoNota.toString()}');
              agregarMsj('No se actualizaron las notas');
            }
          }
        }
      }
      else {
        widget.productosSeleccionados?[indexProducto].comentario = comentarioSpan;
      }
    }
  }

  Future<void> _eliminarItemsIndependiente(int? id_pedido_detalle, int index, int BlueWifi) async {
    if (id_pedido_detalle != null) {
      List<Producto> productoImprimir = [];

      int productIndex = widget.productosSeleccionados!.indexWhere((producto) =>
      producto.id_pedido_detalle == id_pedido_detalle);

      Producto productoAEliminar = widget.productosSeleccionados![productIndex];
      var productoSeleccionado = widget.productosSeleccionados![productIndex];
      productoImprimir.add(Producto(
          nombreproducto: productoAEliminar.nombreproducto,
          stock: 0
      ));
      if (productIndex != -1) {
        PedidoResponse respuestaData = await detallePedidoServicio.eliminarDetallePedido(id_pedido_detalle, usuario?.accessToken);
        if(respuestaData.status == true){
          setState(() {
            widget.productosSeleccionados!.removeAt(productIndex);
            widget.detallePedidoLista.remove(id_pedido_detalle);
          });
          _actualizarProductosSeleccionados();

          if(BlueWifi == 1){
            ticketBluetooth.printLabelBluetooth(productoImprimir, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', productoSeleccionado.idPedido);
          }else if(BlueWifi == 2){
           imprimir(productoImprimir, 2, productoSeleccionado.idPedido);
          }
          mostrarMensajeActualizado('${respuestaData.mensaje}', false);
        }else {
          mostrarMensajeActualizado('${respuestaData.mensaje}', true);
        }
      }
    } else {
      index = widget.productosSeleccionados!.indexWhere(
              (producto) =>
          producto == widget.productosSeleccionados![index]);
      if (index != -1) {
        // Eliminar el producto de la lista
        setState(() {
          widget.productosSeleccionados!.removeAt(index);
        });
        // Actualizar los productos seleccionados en el widget padre si es necesario
        _actualizarProductosSeleccionados();
      }
    }
  }

  Future<void> _eliminarProductos(int? id_pedido_detalle, int index, int BlueWifi) async {
    print('items_juntos');
    if (id_pedido_detalle != null) {
      int productoindex = widget.productosSeleccionados!.indexWhere((producto) => producto.id_pedido_detalle == id_pedido_detalle);
      print('Posicion con id detalle : ${productoindex}');
      print('Producto: ${widget.productosSeleccionados![productoindex].nombreproducto}');
      print('Cantidad: ${widget.productosSeleccionados![productoindex].stock}');

      if (productoindex != -1) {

        setState(() {
          widget.productosSeleccionados![productoindex].stock = widget.productosSeleccionados![productoindex].stock! - 1; // Reduce la cantidad en 1
        });

        if (widget.productosSeleccionados![productoindex].stock! <= 0) {
           PedidoResponse respuestaData = await detallePedidoServicio.eliminarDetallePedido(id_pedido_detalle, usuario?.accessToken);
           print('-------------- Eliminar ${respuestaData.status} -- ${respuestaData.mensaje}');

           if(respuestaData.status == true){
             List<Producto> productosToPrint = [];
             var productoSeleccionado = widget.productosSeleccionados![productoindex];
             productosToPrint.add(
                 Producto(
                     nombreproducto: productoSeleccionado.nombreproducto,
                     stock:0
                 )
             );

             if (productosToPrint.isNotEmpty){
               if (BlueWifi == 1) {
                 ticketBluetooth.printLabelBluetooth(productosToPrint, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', productoSeleccionado.idPedido);
               } else if (BlueWifi == 2) {
                 imprimir(productosToPrint, 2, productoSeleccionado.idPedido);
               }
               print('Hay productos que Actualizar');
             }else{
               mostrarMensajeActualizado('Revisal la lista productosToPrint : ${productosToPrint.length}', true);
               print('No hay productos que Actualizar');
             }
             setState(() {
               widget.productosSeleccionados!.removeAt(productoindex);
             });
           }else {
             mostrarMensaje('${respuestaData.mensaje}');

             setState(() {
               widget.productosSeleccionados![productoindex].stock = widget.productosSeleccionados![productoindex].stock! + 1;
               widget.productosSeleccionados![productoindex].aCStock = false;
             });
           }
        }
        else{
          List<Producto> productosToPrint = [];
          var productoSeleccionado = widget.productosSeleccionados![productoindex];

          print('"monto_total": $pedidoTotal');

          // Map<String, dynamic> pedidoRespuesta =  await detallePedidoServicio.fetchPedidoDetalleRespuesta(usuario!.accessToken, selectObjmesa.id ?? widget.mesa!.id );

          Map<String, dynamic> pedidoRespuesta =  await detallePedidoServicio.fetchPedidoDetalle(usuario!.accessToken, selectObjmesa.id ?? widget.mesa!.id  );
          Pedido pedido = pedidoRespuesta['pedido_detalle'];
          List<Detalle_Pedido>? detallePedido = [];
          detallePedido = pedido.detalle;

          Detalle_Pedido compare = detallePedido!.firstWhere((element) => element.id_pedido_detalle == productoSeleccionado.id_pedido_detalle);

          if(productoSeleccionado.stock! > compare.cantidad_producto!){
            mostrarMensaje('Cantidad restada');
          }
          if(productoSeleccionado.stock! == compare.cantidad_producto!){
            mostrarMensaje('No hay nada que actualizar');
            setState(() {
              widget.productosSeleccionados![productoindex].aCStock = false;
            });
          }
          if(productoSeleccionado.stock! < compare.cantidad_producto!){
            Map<String, dynamic> pedidoDetalle = {
              "monto_total": pedidoTotal,
              "detalle": [
                {
                  "id_pedido_detalle": productoSeleccionado.id_pedido_detalle,
                  "id_pedido": productoSeleccionado.idPedido,
                  "id_producto": productoSeleccionado.id,
                  "cantidad_producto": productoSeleccionado.stock,
                  "cantidad_real": productoSeleccionado.stock,
                  "precio_unitario": productoSeleccionado.precioproducto,
                  "precio_producto": productoSeleccionado.precioproducto! * productoSeleccionado.stock!.toInt(),
                  "comentario": productoSeleccionado.comentario,
                  "estado_detalle": 1
                }
              ]
            };
            Map<String, dynamic> detalleActualizadoJson = await detallePedidoServicio.actualizarPedidoConRespuestaApi( usuario?.accessToken, pedidoDetalle, widget.mesa?.id);

            print('detalleActualizadoJson : ${detalleActualizadoJson}');
            bool statusAcJson = detalleActualizadoJson['decremento'] ?? detalleActualizadoJson['status'] ;

            if (statusAcJson) {
              productosToPrint.add(
                  Producto(
                      nombreproducto: productoSeleccionado.nombreproducto,
                      stock:-1
                  )
              );
              String mensaje =  detalleActualizadoJson['mensaje'];
              // mostrarMensajeActualizado(mensaje, false);
              if (productosToPrint.isNotEmpty){
                if (BlueWifi == 1) {
                  ticketBluetooth.printLabelBluetooth(productosToPrint, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', productoSeleccionado.idPedido);
                } else if (BlueWifi == 2) {
                  imprimir(productosToPrint, 2, productoSeleccionado.idPedido);
                }
                print('Hay productos que Actualizar');
                // Navigator.pop(context);
              }else{
                mostrarMensajeActualizado('Revisal la lista productosToPrint : ${productosToPrint.length}', true);
                print('No hay productos que Actualizar');
                // Navigator.pop(context);
              }
            } else {
              mostrarMensaje('${detalleActualizadoJson['mensaje']}');
              // mostrarMensaje('wazaaa');

              setState(() {
                widget.productosSeleccionados![productoindex].aCStock = false;
              });

              print('Wazaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
            }
          }
        }
        _actualizarProductosSeleccionados();
      }
    }
    else{
      int productoindex = widget.productosSeleccionados!.indexWhere( (producto) =>  producto == widget.productosSeleccionados![index]);
      print('Posicion sin id detalle : ${productoindex}');
      if (productoindex != -1) {
        setState(() {
          widget.productosSeleccionados![productoindex].stock = widget.productosSeleccionados![productoindex].stock! - 1;
        });

        if (widget.productosSeleccionados![productoindex].stock! <= 0) {
          setState(() {
            widget.productosSeleccionados!.removeAt(productoindex);
          });
        }
        _actualizarProductosSeleccionados();
      }
    }
  }

  Future<String?> _eliminar(int index, int? id_pedido_detalle) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('Estas seguro en eliminar este producto'),
        actions: <Widget>[
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all( Color.fromRGBO(217, 217, 217, 0.8) ),
            ),
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel',style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)),
            onPressed: () async {

              String? printerIP = await _pref.read('ipCocina');
              bool _stateConexionTicket = await _pref.read('stateConexionTicket') ?? false;
              bool conexionBluetooth = await _pref.read('conexionBluetooth') ?? false;

              if (widget.items_independientes) {
                if (_stateConexionTicket) {
                  if (conexionBluetooth) {
                    _eliminarItemsIndependiente(id_pedido_detalle,index,1);
                  } else {
                    String messague = 'No se ha encontrado conectado a un dispositivo Bluetooth.';
                    showMessangueDialog(messague);
                    return;
                  }
                } else {
                  if (printerIP == null) {
                    String messague = 'No se ha encontrado la dirección IP de la impresora.';
                    showMessangueDialog(messague);
                    return; // Salir del método printLabel
                  } else {
                    _eliminarItemsIndependiente(id_pedido_detalle,index,2);
                  }
                }
              }
              else {
                if (_stateConexionTicket) {
                  if (conexionBluetooth) {
                    _eliminarProductos(id_pedido_detalle,index,1);
                    refresh();
                  } else {
                    String messague = 'No se ha encontrado conectado a un dispositivo Bluetooth.';
                    showMessangueDialog(messague);
                    return;
                  }
                } else {
                  if (printerIP == null) {
                    String messague = 'No se ha encontrado la dirección IP de la impresora.';
                    showMessangueDialog(messague);
                    return; // Salir del método printLabel
                  } else {
                    _eliminarProductos(id_pedido_detalle,index,2);
                    refresh();
                  }
                }
              }

              Navigator.pop(context, 'OK');
            },
            child: const Text('OK',style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  Widget _pedido() {
    return ElevatedButton(
        style: ButtonStyle( elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(Colors.blue)),
        onPressed: () async {
          print('---> Boton pedido');
          String? printerIP = await _pref.read('ipCocina');
          bool _stateConexionTicket = await _pref.read('stateConexionTicket') ?? false;
          bool conexionBluetooth = await _pref.read('conexionBluetooth') ?? false;
          print('CONEXION INICIAL $_stateConexionTicket');
          print('CONEXION BLUETHO $conexionBluetooth');
          if (_stateConexionTicket) {

            print('IMPRESION BLUETOOTH');
            if (conexionBluetooth) {
              crearPedido(1);
            } else {
              String messague = 'No se ha encontrado conectado a un dispositivo Bluetooth.';
              showMessangueDialog(messague);
              return;
            }
          } else {
            print('IMPRESION WIFI');
            if (printerIP == null) {
              String messague = 'No se ha encontrado la dirección IP de la impresora.';
              showMessangueDialog(messague);
              return; // Salir del método printLabel
            } else {
              crearPedido(2);
            }
          }
        },
        child: const Text(
          'Pedido',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ));
  }

  Future<void> imprimir(List<Producto> prodSeleccionados, int? estado, int? codigo) async {
    String categoriasJson = await _pref.read('categorias');
    String? ipBar = await _pref.read('ipBar');
    String? ipCocina = await _pref.read('ipCocina');

    List<Producto> ParaBar = [];
    List<Producto> ParaCocina = [];

    List<Categoria> categorias = [];

    int vecesToPrint = 4 ;

    if (categoriasJson != null) {
      List<dynamic> categoriasList = json.decode(categoriasJson);

      categorias = categoriasList
          .where((cat) => cat['bar'] == 1)
          .map((cat) => Categoria.fromJson(cat))
          .toList();

      if (categorias.isNotEmpty) {
        print('Categorías encontradas:');
        categorias.forEach((categoria) {
          print(categoria.nombre);
        });
      } else {
        print('No se encontraron categorías con bar en 1.');
      }

      for (Producto producto in prodSeleccionados) {
        if (categorias.any((categoria) => categoria.id == producto.categoria_id)) {
          ParaBar.add(producto);
        } else {
          ParaCocina.add(producto);
        }
      }

      if (ipBar == null) {
        if (prodSeleccionados.isNotEmpty) {
          print('Lista de productos seleccionados:');
          if(estado == 1 || estado == 2){
            for(int i = 0; i<vecesToPrint; i++) {
              impresora.printLabel(ipCocina!, prodSeleccionados, estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', codigo);
            }
          }else{
            impresora.printLabel(ipCocina!, prodSeleccionados, estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', codigo);
          }
        } else {
          print('nada que imprimir');
        }
      } else {
        if (ParaBar.isNotEmpty) {
          print('para bar actualizar');
          impresora.printLabel(ipBar,ParaBar,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso,'', codigo);
          if (ParaCocina.isNotEmpty) {
            print('Lista de productos seleccionados:');
            if(estado == 1 || estado == 2){
              for(int i = 0; i< vecesToPrint; i++) {
                impresora.printLabel(ipCocina!, ParaCocina, estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', codigo);
                await Future.delayed(Duration(seconds: 1));
              }
            }else{
              impresora.printLabel(ipCocina!, ParaCocina, estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', codigo);
            }
          } else {
            print('nada que imprimir');
          }
        } else {
          if (ParaCocina.isNotEmpty) {
            print('Lista de productos seleccionados:');
            if(estado == 1 || estado == 2){
              for(int i = 0; i<vecesToPrint; i++) {
                impresora.printLabel(ipCocina!,ParaCocina,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso,'',codigo);
                await Future.delayed(Duration(seconds: 1));
              }
            }else{
              impresora.printLabel(ipCocina!,ParaCocina,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso,'',codigo);
            }
          } else {
            print('nada que imprimir');
          }
        }
      }
      print('Productos para consumo normal:');
      // ParaCocina.forEach((producto) {
      //   print(producto.nombreproducto);
      // });
    } else {
      print('El JSON de categorías es nulo.');
    }
  }

  Widget _preCuenta() {
    return ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(2),
          backgroundColor:MaterialStateProperty.all(const Color(0xFFFFB500))
        ),
        onPressed: () async {
          bool hayProductoSinIdDetalle = widget.productosSeleccionados!.any((producto) => producto.id_pedido_detalle == null);
          bool hayProductoSinAc = widget.productosSeleccionados!.any((producto) => producto.aCStock == true);

          if (hayProductoSinIdDetalle) {
            mostrarMensajeActualizado('Falta actualizar productos antes de mandar a precuenta.', true);
            return; // Salir del método si falta actualizar algún producto
          }
          if(hayProductoSinAc){
            mostrarMensajeActualizado('Falta actualizar productos antes de mandar a precuenta.', true);
            return;
          }

          // Continuar solo si no hay productos sin id_pedido_detalle
          if (selectObjmesa.estadoMesa != 2 || widget.mesa!.estadoMesa != 2) {
            gif();
            PedidoResponse? updateMesa = await mesaServicio.actualizarMesa(selectObjmesa.id ?? widget.mesa!.id, usuario!.accessToken, 2);
            print('updateMesa : ${updateMesa.toString()}');
            setState(() {
              selectObjmesa.estadoMesa = 2;
              widget.mesa?.estadoMesa = 2;
            });
          }

          Navigator.pop(context, 2);

          String? printerIP = await _pref.read('ipCocina');
          bool _stateConexionTicket = await _pref.read('stateConexionTicket') ?? false;
          bool conexionBluetooth = await _pref.read('conexionBluetooth') ?? false;

          String? ipBar = await _pref.read('ipBar');
          String? ipCocina = await _pref.read('ipCocina');

          print('CONEXION INICIAL $_stateConexionTicket');
          print('CONEXION BLUETOOTH $conexionBluetooth');

          if (_stateConexionTicket) {
            print('IMPRESION BLUETOOTH');
            if (conexionBluetooth) {
              ticketBluetooth.printLabelBluetooth(widget.productosSeleccionados, 3, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso, '', widget.productosSeleccionados![0].idPedido);
            } else {
              String messague = 'No se ha encontrado conectado a un dispositivo Bluetooth.';
              showMessangueDialog(messague);
              return;
            }
          } else {
            print('IMPRESION WIFI');
            if (printerIP == null) {
              String messague = 'No se ha encontrado la dirección IP de la impresora.';
              showMessangueDialog(messague);
              return; // Salir del método printLabel
            } else {
              int estado = 3;
              if(estado == 3){
                print('precuenta {estado}]');
                if (ipBar == null){
                  print('para cocina porque bar esta desabilitado 964');
                  impresora.printLabel(ipCocina!, widget.productosSeleccionados, 3, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', widget.productosSeleccionados![0].idPedido);
                  return;
                }else {
                  print('para bar 469');
                  impresora.printLabel(ipBar, widget.productosSeleccionados, 3, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', widget.productosSeleccionados![0].idPedido);
                  return;
                }
              }
              // impresora.printLabel(printerIP, widget.productosSeleccionados, 3, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso, '', widget.productosSeleccionados![0].idPedido);
            }
          }
          // if (selectObjmesa.estadoMesa != 2 || widget.mesa!.estadoMesa != 2) {
          //   gif();
          //   PedidoResponse? updateMesa = await mesaServicio.actualizarMesa(selectObjmesa.id ?? widget.mesa!.id, usuario!.accessToken, 2);
          //   print('updateMesa : ${updateMesa.toString()}');
          //   setState(() {
          //     selectObjmesa.estadoMesa = 2;
          //     widget.mesa?.estadoMesa = 2;
          //   });
          // }
          // Navigator.pop(context, 2);
          // String? printerIP = await _pref.read('ipCocina');
          // bool _stateConexionTicket = await _pref.read('stateConexionTicket') ?? false;
          // bool conexionBluetooth = await _pref.read('conexionBluetooth') ?? false;
          // print('CONEXION INICIAL $_stateConexionTicket');
          // print('CONEXION BLUETHO $conexionBluetooth');
          // if (_stateConexionTicket) {
          //
          //   print('IMPRESION BLUETOOTH');
          //   if (conexionBluetooth) {
          //     ticketBluetooth.printLabelBluetooth(widget.productosSeleccionados, 3, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso, '', widget.productosSeleccionados![0].idPedido );
          //   } else {
          //     String messague = 'No se ha encontrado conectado a un dispositivo Bluetooth.';
          //     showMessangueDialog(messague);
          //     return;
          //   }
          // } else {
          //   print('IMPRESION WIFI');
          //   if (printerIP == null) {
          //     String messague = 'No se ha encontrado la dirección IP de la impresora.';
          //     showMessangueDialog(messague);
          //     return; // Salir del método printLabel
          //   } else {
          //    impresora.printLabel(printerIP,widget.productosSeleccionados,3,pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario!, selectObjmesa.nombrePiso ?? widget.mesa!.nombrePiso,'',widget.productosSeleccionados![0].idPedido);
          //   }
          // }
        },
        child: const Text(
          'Pre Cuenta',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ));
  }

  double calcularTotal() {
    double total = 0;
    if (widget.productosSeleccionados != null) {
      for (Producto producto in widget.productosSeleccionados!) {
        total += (producto.precioproducto ?? 0) * (producto.stock ?? 0);
      }
    }
    return total;
  }

  Widget debajo() {
    double total = calcularTotal();
    pedidoTotal = total;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: const BoxDecoration(
            border: Border.fromBorderSide(BorderSide(width: 2)),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Color(0xFF99CFB5)

          // borderRadius: BorderRadius.all(Radius.circular(20)), color: Color(0xFF99CFB5)
        ),
        child: Row(
          children: [
            // const SizedBox(width: 5),
            Container(
              margin: EdgeInsets.only(left: 15),
              child:
                  selectObjmesa.estadoMesa == 1 || widget.mesa!.estadoMesa == 1
                      ? _pedido()
                      : _preCuenta(),
            ),
            // const SizedBox(width: 10),
            Spacer(),
            Container(
              margin: EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  Text('TOTAL : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('S/ ${total.toStringAsFixed(2)}', style: const TextStyle( fontSize: 16, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            // const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  void _actualizarProductosSeleccionados() {
    if (widget.onProductosActualizados != null) {
      widget.onProductosActualizados!(widget.productosSeleccionados);
    }
  }

  Widget _addOrRemoveItem(int index) {
    return Row(
      children: [
        // GestureDetector(
        //   onTap: () {
        //     final productoSeleccionado = widget.productosSeleccionados?[index];
        //     //final productoSeleccionadoDetalle = widget.detallePedidoLista[index];
        //     if (productoSeleccionado != null && productoSeleccionado.stock != null && productoSeleccionado.stock! > 1) {
        //       setState(() {
        //         productoSeleccionado.stock = productoSeleccionado.stock! - 1; // Restar al stock
        //
        //         // double precioTotalProductoDetalle = productoSeleccionadoDetalle.precio_producto! - productoSeleccionado.precioproducto!;
        //         // productoSeleccionadoDetalle.precio_producto = precioTotalProductoDetalle;
        //       });
        //     } else if (productoSeleccionado != null &&
        //         productoSeleccionado.stock != null &&
        //         productoSeleccionado.stock! == 1) {
        //       // Aquí puedes mostrar un mensaje o tomar alguna acción adicional si el stock ya es 1
        //     }
        //     _actualizarProductosSeleccionados(); // Llama a la función para actualizar los productos seleccionados
        //   },
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        //     decoration: BoxDecoration(
        //       borderRadius: const BorderRadius.only(
        //         topLeft: Radius.circular(8),
        //         bottomLeft: Radius.circular(8),
        //       ),
        //       color: Colors.grey[200],
        //     ),
        //     child: const Text('-'),
        //   ),
        // ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            color: Colors.grey[200],
          ),
          child: Text(
            '${widget.productosSeleccionados?[index].stock ?? ""}',
          ),
        ),
        GestureDetector(
          onTap: () {
            final productoSeleccionado = widget.productosSeleccionados?[index];
            //final productoSeleccionadoDetalle = widget.detallePedidoLista[index];

            if (productoSeleccionado != null && productoSeleccionado.stock != null) {
              setState(() {
                productoSeleccionado.stock =productoSeleccionado.stock! + 1; // Aumentar el stock
                productoSeleccionado.aCStock = true; // Aumentar el stock

                // double precioTotalProductoDetalle = productoSeleccionadoDetalle.precio_producto! + productoSeleccionado.precioproducto!;
                //
                // productoSeleccionadoDetalle.precio_producto = precioTotalProductoDetalle;
              });
            }
            print(productoSeleccionado?.toJson());
            _actualizarProductosSeleccionados(); // Llama a la función para actualizar los productos seleccionados
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              color: Colors.grey[100],
            ),
            child: const Text('+'),
          ),
        ),
      ],
    );
  }

  void mostrarMensaje(String mensaje) {
    Fluttertoast.showToast(
      msg: mensaje,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void mostrarMensajeActualizado(String mensaje, bool esRojo) {
    Color backgroundColor = esRojo ? Colors.red : Colors.green;

    Fluttertoast.showToast(
      msg: mensaje,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void refresh() {
    setState(() {});
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

  Future<void> crearPedido(int WifiOBlue) async {
    gif();
    bool disponible = await bdMesas.consultarMesa(usuario?.accessToken, selectObjmesa.id ?? widget.mesa!.id!);
    if (disponible == true) {
      if (widget.productosSeleccionados!.length > 0) {
        // crear el pedido
        Map<String, dynamic> pedidoData = {
          "id_cliente": 1,
          "id_mesa": selectObjmesa.id ?? widget.mesa!.id, // Reemplaza con el ID de la mesa correcto
          "id_tipo_ped": 1,
          "nombremozo": "${usuario?.user?.nombreUsuario}", // Reemplaza con el nombre correcto del mozo
          "id_usuario": usuario?.user?.id, // Reemplaza con el ID del usuario autenticado
          "monto_total": pedidoTotal,
          "detalle": widget.productosSeleccionados!
              .map((producto) {
            print('Comentario del producto ${producto.id}: ${producto.comentario}');
            return {
              "id_producto": producto.id,
              "cantidad_producto": producto.stock,
              "precio_unitario": producto.precioproducto,
              "precio_producto": producto.precioproducto! *
                  (producto.stock ?? 0),
              "comentario": producto.comentario,
              "estado_detalle": 1
            };
          }).toList()
        };
        // Ya crea el pedido
        PedidoResponse? response = await pedidoServicio.registrarPedido(pedidoData, usuario?.accessToken);

        print('RESPUEST DE LA CREACION DE PEDIDO ${response?.ultimoIdPedido}');

        PedidoResponse? updateMesa = await mesaServicio.actualizarMesa(selectObjmesa.id ?? widget.mesa!.id, usuario!.accessToken, 3);

        if (WifiOBlue == 1) {
          ticketBluetooth.printLabelBluetooth(widget.productosSeleccionados, 1, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso, '', response?.ultimoIdPedido);
        } else if (WifiOBlue == 2) {

          imprimir(widget.productosSeleccionados!, 1,response?.ultimoIdPedido );
        }
        Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
      } else {
        mostrarMensaje('No hay productos seleccionados');
        Navigator.pop(context);
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange,
                ),
                SizedBox(width: 10),
                Text(
                  'ATENCIÓN',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'Hay un pedido en curso. Por favor, atiéndelo.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  //tp10
  Future showMessangueDialog(String messague) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de Impresión'),
          content: Text(messague),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el AlertDialog
                Navigator.pushNamed(
                    context, 'home/ajustes'); // Dirigir a otra pantalla
              },
            ),
          ],
        );
      },
    );
  }
}
