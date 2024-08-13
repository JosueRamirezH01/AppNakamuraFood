
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/mozo.dart';
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
import 'package:intl/intl.dart';
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
  final void Function(List<Producto>?)? onProductosActualizados; // Función de devolución de llamada

  DetailsPage({
    super.key,
    required this.productosSeleccionados,
    required this.detallePedidoLista,
    required this.mesa,
    required this.idPedido,
    required this.items_independientes,
    this.onProductosActualizados
  });

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
  late  Usuario? usuario = Usuario();
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
  List<Piso> listaPisos =[];
  late Mesa selectObjmesa;
  PedidoServicio pedidoServicio= PedidoServicio();
  MesaServicio mesaServicio = MesaServicio();
  var entornoService = EntornoService();

  DetallePedidoServicio detallePedidoServicio = DetallePedidoServicio();
  late Pedido newpedido = Pedido();
  late double pedidoTotal ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectObjmesa = widget.mesa!;
    detalles_pedios_tmp = widget.detallePedidoLista ;
    UserShared();
    _checkedItems = List.filled(listaNota.length, false);

  }

  Future<int> _getEntornoId() async {
    int entornoId = await entornoService.consultarEntorno(context);
    return entornoId;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (screenWidth < 600)
              icono(),
            if( widget.mesa!.estadoMesa != 1 && widget.mesa!.estadoMesa != 2)
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
    double sizeHeigth= widget.mesa!.estadoMesa != 1 && widget.mesa!.estadoMesa != 2 ? 0.56 : 0.65;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification && notification.metrics.atEdge && notification.metrics.pixels <= 0) {
          return false;
        }
        return true;
      },
      child: SingleChildScrollView(
        child: Container(
          margin: crossAxisCount <= 3 ? EdgeInsets.only(top:15 ,left: 15,right: 15) : null,

          height: MediaQuery.of(context).size.height * sizeHeigth,
          width: screenWidth > 600 ? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 8,
          decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), border: Border.all(width: 2),),
          child: ListView.builder(
            itemCount: widget.productosSeleccionados?.length,
            itemBuilder: (_, int index) {
              return Column(
                children: [
                  Container(
                    decoration: widget.productosSeleccionados?[index]
                                .id_pedido_detalle ==
                            null
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
                              if (widget.mesa!.estadoMesa != 2 &&
                                  widget.items_independientes == false)
                                _addOrRemoveItem(index),
                              _precioProducto(index),
                            ],
                          ),
                          const SizedBox(width: 5),
                          if (selectObjmesa.estadoMesa != 2 ||
                              widget.mesa!.estadoMesa != 2)
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              margin: widget.items_independientes == false ? EdgeInsets.only(bottom: 25) : null ,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _iconDelete(
                                    index,
                                    widget.productosSeleccionados?[index]
                                        .id_pedido_detalle),
                              ),
                            ),
                          const SizedBox(width: 5),
                          if (selectObjmesa.estadoMesa != 2 ||
                              widget.mesa!.estadoMesa != 2)
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
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
    double p = widget.productosSeleccionados![index].precioproducto! *  (widget.productosSeleccionados![index].stock ?? 0);
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
          color: Colors.grey[200],
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
      onTap: (){
        print("CODIGO A ELIMINAR ${id_pedido_detalle}");
        _eliminar(index, id_pedido_detalle);
      },
      child: const Icon(Icons.delete, color: Colors.red),
    );
  }

  Widget _iconNota(int index, int? id_pedido_detalle) {
    return GestureDetector(
      onTap: () async {
        listaNota = await bdPedido.obtenerListasNota(usuario?.accessToken);
        print('INDEX ${index}');
        _nota(listaNota,index, id_pedido_detalle);
      },
      child: const Icon(Icons.edit, color: Colors.amber),
    );
  }

  Widget icono(){
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
            margin: EdgeInsets.only(top : screenWidth < 600 ? 20 : 1, bottom: 10),
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.08,
            decoration: BoxDecoration(
              border: Border.fromBorderSide(BorderSide(width: 2)),
                borderRadius: BorderRadius.all(Radius.circular(20)), color: Color(0xFF99CFB5)
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
                  margin: EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                      style:  ButtonStyle(
                          elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(const Color(0xFF634FD2))),
                      onPressed: () async {
                        print('---->BA BOTON ACTUALIZAR');
                        if (widget.items_independientes) {
                          String? printerIP = await _pref.read('ipCocina');
                          bool _stateConexionTicket = await _pref.read('stateConexionTicket') ?? false;
                          bool conexionBluetooth = await _pref.read('conexionBluetooth') ?? false;

                          if (_stateConexionTicket) {
                            if (conexionBluetooth) {
                              _operacionACitemsIndependiente(1);
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
                              _operacionACitemsIndependiente(2);
                            }
                          }

                        } else {
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

  void _operacionACitemsIndependiente(int WifiOBlue) {
    if (widget.productosSeleccionados!.length > 0) {
      gif();
      List<Producto> productosToPrint = [];

      for (final producto in widget.productosSeleccionados!) {
        int index = widget.productosSeleccionados!.indexOf(producto);
        print('Índice del producto: $index');

        print('Antes de actualizar: Producto ID: ${producto.id}, ID Pedido Detalle: ${producto.id_pedido_detalle}');
      }

      if (productosToPrint.isNotEmpty) {
        // await detallePedidoServicio.actualizarAgregarProductoDetallePedidoItem(widget.idPedido, pedidoTotal,context);

        if (WifiOBlue == 1) {
          ticketBluetooth.printLabelBluetooth(productosToPrint, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso, '');
        } else if (WifiOBlue == 2) {
          imprimir(productosToPrint, 2);
        }

        imprimir(productosToPrint, 2);
        print('Hay productos que Actualizar');
        Navigator.pop(context);
      } else {
        mostrarMensajeActualizado(
            'No hay productos que Actualizar', true);
        print('No hay productos que Actualizar');
        Navigator.pop(context);
      }
    } else {
      mostrarMensajeActualizado(
          'No puedes dejar la lista vacia', true);
    }
  }

  void _operacionAC(int WifiOBlue) async {
    if (widget.productosSeleccionados!.length > 0) {
      gif();
      List<Producto> productosToPrint = [];

      List<Producto> productosConIdDetalle = [];
      List<Producto> productosSinIdDetalle = [];

      List<Detalle_Pedido> detallepedidosToCompare = widget.detallePedidoLista;

      widget.productosSeleccionados!.forEach((producto) {
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
                })
            .toList()
      };
      print('pedidoDetalleAc : ${pedidoDetalleAc['detalle']}');

      Map<String, dynamic> detalleActualizadoJson =
          await detallePedidoServicio.actualizarPedidoConRespuestaApi(
              usuario?.accessToken, pedidoDetalleAc, widget.mesa?.id);
      print(' respuesta ; ${detalleActualizadoJson}');
      bool statusAcJson = detalleActualizadoJson['status'];

      print('statusAcJson ${statusAcJson}');
      print('detalleToAc ${detalleActualizadoJson}');

      if (statusAcJson) {
        List<dynamic> detalleAcJson =
            detalleActualizadoJson['detalle_actualizado'];
        print('Respuesta ${detalleAcJson}');

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
                }))
            .toList();

        detalleActualizado.forEach((element) {
          print('LIsta detalles : ${element.toJson()}');
        });

        productosSinIdDetalle.forEach((producto) {
          Detalle_Pedido? detalleCorrespondiente = detalleActualizado.firstWhere(
                (detalle) =>
                  detalle.id_producto == producto.id &&
                  detalle.precio_unitario == producto.precioproducto,
          );

          if (detalleCorrespondiente != null) {
            producto.id_pedido_detalle =
                detalleCorrespondiente.id_pedido_detalle;
            producto.stock = detalleCorrespondiente.cantidad_actualizada;
            productosToPrint.add(producto);
            // int index = widget.productosSeleccionados!.indexOf(producto);
            //
            // if (index != -1) {
            //   setState(() {
            //     widget.productosSeleccionados![index].id_pedido_detalle = detalleCorrespondiente.id_pedido_detalle;
            //   });
            //   refresh();
            // }
          }
        });

        detalleActualizado.forEach((element) {
          print('detalles ${element}');
        });

        productosConIdDetalle.forEach((producto) {
          // Detalle_Pedido detalleCorrespondiente = detalleActualizado.firstWhere(
          //       (detalle) => detalle.id_producto == producto.id && detalle.precio_unitario == producto.precioproducto,
          // );
          //
          // producto.stock = detalleCorrespondiente.cantidad_actualizada;

          print(' productosConIdDetalle : ${producto.id_pedido_detalle}');
          if (detalleActualizado.any((detalle) =>
              detalle.id_pedido_detalle == producto.id_pedido_detalle)) {
            Detalle_Pedido? detalleCorrespondiente =
                detalleActualizado.firstWhere(
              (detalle) =>
                  detalle.id_producto == producto.id &&
                  detalle.id_pedido_detalle == producto.id_pedido_detalle,
            );

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
                stock: detalleCorrespondiente.cantidad_actualizada));
          }
        });

        print('Cantidad para imprimir ${productosToPrint.length}');

        productosToPrint.forEach((element) {
          print('Productos para imprimir ${element.nombreproducto}');
        });

        if (productosToPrint.isNotEmpty){
          if (WifiOBlue == 1) {
            ticketBluetooth.printLabelBluetooth(productosToPrint, 2, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso, '');
          } else if (WifiOBlue == 2) {
            imprimir(productosToPrint, 2);
          }
          print('Hay productos que Actualizar');
          Navigator.pop(context);
        }else{
          mostrarMensajeActualizado('Revisal la lista productosToPrint : ${productosToPrint.length}', true);
          print('No hay productos que Actualizar');
          Navigator.pop(context);
        }



        widget.productosSeleccionados!.forEach((element) {
          print(
              'RQ->Productos :${element.nombreproducto}, ID_Detalle ${element.id_pedido_detalle}');
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

                      },
                      child: const Text('Actualizar', style: TextStyle(color: Colors.white, fontSize: 16))),
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Producto>> leerProductosDesdeSharedPreferences() async {
    String? jsonProductoData = await _pref.read('productos');
    if (jsonProductoData != null) {
      Iterable decoded = json.decode(jsonProductoData);
      return decoded.map((producto) => Producto.fromJson(producto)).toList();
    }
    return []; // Otra opción: lanzar una excepción si no hay datos
  }

  Future<Producto?> buscarNombreProductoPorId(int? idProducto) async {
    List<Producto> productos = await leerProductosDesdeSharedPreferences();
    for (Producto producto in productos) {
      if (producto.id == idProducto) {
        return producto;
      }
    }
    return null;
  }

  Future gif(){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          gifPath: 'assets/gif/download.gif', // Ajusta la ruta de tu GIF
        );
      },
    );
  }

  Widget _textFieldNota() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: notaController,
        decoration: InputDecoration(
            hintText: 'Observacion',
            suffixIcon: const Icon(
                Icons.note_alt_rounded,
                color: Colors.grey
            ),
            hintStyle: const TextStyle(
                fontSize: 17,
                color: Colors.grey
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(
                    color: Colors.grey
                )
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(
                    color: Colors.grey
                )
            ),
            contentPadding: const EdgeInsets.all(10)
        ),
      ),
    );
  }

  String generateSelectedOptionsString(List<Nota> comidas) {
    List<String> selectedOptions = [];
    for (int i = 0; i < _checkedItems.length; i++) {
      if (_checkedItems[i]) {
        selectedOptions.add(comidas[i].descripcion_nota!);
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
      spans.add(
          '<span class="style_nota" id="texto-comentario-${listaNota.firstWhere((element) => element.descripcion_nota == partes[i]).id_nota}">${partes[i]}</span>');
    }
    print(spans);

    return spans.join();
  }

  List<String> convertStringToList(String selectedOptionsString) {
    return selectedOptionsString.split(';');
  }

  Future<String?> _nota(List<Nota> comidas, int indexProducto, int? id_pedido_detalle) async {
    print('Index entrada : ${indexProducto}');
    String? notabd = widget.productosSeleccionados?[indexProducto].comentario ?? '';
    List<String> seleccionadosBd = convertStringToList(notabd);

    print('seleccionadosBd:  ${seleccionadosBd}');

    _checkedItems = List.filled(comidas.length, false);

    _checkedItems.forEach((element) {
      print('${element}');
    });

    for (int i = 0; i < comidas.length; i++) {
      if (seleccionadosBd.contains(comidas[i].descripcion_nota)) {
        _checkedItems[i] = true;
      }
    }
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Observaciones del Plato'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(comidas.length, (index) {
                        return CheckboxListTile(
                          activeColor: Color( 0xFFFF562F),
                          title: Text(comidas[index].descripcion_nota!),
                          value: _checkedItems[index],
                          onChanged: (value) {
                            setState(() {
                              _checkedItems[index] = value ?? false;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all( Color.fromRGBO(217, 217, 217, 0.8) ),
              ),
              onPressed: () {
                setState(() {
                  _checkedItems = List.filled(comidas.length, false);
                });
                Navigator.pop(context, 'Cancel');
              },
              child: Text('Cancelar',style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF634FD2)),
              ),
              onPressed: () async {
                String selectedOptionsString =
                    generateSelectedOptionsString(comidas);
                String? comentarioSpan = convertToSpan(selectedOptionsString);

                if (widget.items_independientes) {
                  if (id_pedido_detalle != null) {
                    var productoSeleccionado =
                        widget.productosSeleccionados![indexProducto];
                    productoSeleccionado.comentario = comentarioSpan;

                    Map<String, dynamic> pedidoDetalle = {
                      "monto_total": pedidoTotal,
                      "detalle": [
                        {
                          "id_pedido_detalle":
                              productoSeleccionado.id_pedido_detalle,
                          "id_pedido": productoSeleccionado.idPedido,
                          "id_producto": productoSeleccionado.id,
                          "cantidad_producto": productoSeleccionado.stock,
                          "cantidad_real": productoSeleccionado.stock,
                          "precio_unitario":
                              productoSeleccionado.precioproducto,
                          "precio_producto":
                              productoSeleccionado.precioproducto! *
                                  productoSeleccionado.stock!.toInt(),
                          "comentario": productoSeleccionado.comentario,
                          "estado_detalle": 1
                        }
                      ]
                    };
                    await detallePedidoServicio.actualizarPedidoApi(
                        usuario?.accessToken, pedidoDetalle, widget.mesa?.id);

                    agregarMsj('Se agregó una nota al producto');
                  } else {
                    widget.productosSeleccionados?[indexProducto].comentario =
                        comentarioSpan;
                  }
                  // Aquí nos aseguramos de actualizar solo el producto seleccionado
                  widget.productosSeleccionados?[indexProducto].comentario = selectedOptionsString;
                  print('Índice seleccionado (independiente): $indexProducto');

                } else {
                  if (id_pedido_detalle != null) {
                    var productoSeleccionado =
                        widget.productosSeleccionados![indexProducto];
                    productoSeleccionado.comentario = comentarioSpan;

                    Map<String, dynamic> pedidoDetalle = {
                      "monto_total": pedidoTotal,
                      "detalle": [
                        {
                          "id_pedido_detalle":
                              productoSeleccionado.id_pedido_detalle,
                          "id_pedido": productoSeleccionado.idPedido,
                          "id_producto": productoSeleccionado.id,
                          "cantidad_producto": productoSeleccionado.stock,
                          "cantidad_real": productoSeleccionado.stock,
                          "precio_unitario":
                              productoSeleccionado.precioproducto,
                          "precio_producto":
                              productoSeleccionado.precioproducto! *
                                  productoSeleccionado.stock!.toInt(),
                          "comentario": productoSeleccionado.comentario,
                          "estado_detalle": 1
                        }
                      ]
                    };
                    await detallePedidoServicio.actualizarPedidoApi(
                        usuario?.accessToken, pedidoDetalle, widget.mesa?.id);

                    agregarMsj('Se agregó una nota al producto');
                  } else {
                    widget.productosSeleccionados?[indexProducto].comentario =
                        comentarioSpan;
                  }

                  // widget.productosSeleccionados?[indexProducto].comentario = comentarioSpan;
                  // print('Opciones seleccionadas: $selectedOptionsString');
                  // print('Índice seleccionado: $indexProducto');
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

  Future<String?> _eliminar(int index, int? id_pedido_detalle){
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('Estas seguro en eliminar este producto'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if(widget.items_independientes){
                if(id_pedido_detalle != null){
                  int productIndex = widget.productosSeleccionados!.indexWhere((producto) => producto.id_pedido_detalle == id_pedido_detalle);
                  if (productIndex != -1) {
                    // Eliminar el producto de la lista
                    setState(() {
                      widget.productosSeleccionados!.removeAt(productIndex);
                      widget.detallePedidoLista.remove(id_pedido_detalle);

                    });
                    Map<String, dynamic> pedidoDetalle = {
                      "monto_total": pedidoTotal,
                      "detalle": widget.productosSeleccionados!
                          .map((producto) => {
                                "id_pedido_detalle": producto.id_pedido_detalle,
                                "id_pedido": producto.idPedido,
                                "id_producto": producto.id,
                                "cantidad_producto": producto.stock,
                                "cantidad_real": producto.stock,
                                "precio_unitario": producto.precioproducto,
                                "precio_producto": producto.precioproducto! *
                                    producto.stock!.toInt(),
                                "comentario": producto.comentario,
                                "estado_detalle": 1
                              })
                          .toList()
                    };
                    print('<---Eliminar--->');
                    print('Envio data : ${pedidoDetalle}');
                    await detallePedidoServicio.actualizarPedidoApi(
                        usuario?.accessToken, pedidoDetalle, widget.mesa?.id);
                    _actualizarProductosSeleccionados();
                  }
                  agregarMsj('El producto se ha eliminado');
                }else{
                  index = widget.productosSeleccionados!.indexWhere((producto) => producto == widget.productosSeleccionados![index]);
                  if (index != -1) {
                    // Eliminar el producto de la lista
                    setState(() {
                      widget.productosSeleccionados!.removeAt(index);
                    });
                    // Actualizar los productos seleccionados en el widget padre si es necesario
                    _actualizarProductosSeleccionados();
                  }
                }
              } else {
                if (id_pedido_detalle != null) {
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
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?>  mostrarMesa(List<Mesa> mesas) async {
    if (mesas.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Mesas no disponibles'),
            content: Text('Lo sentimos, no hay mesas disponibles en este momento.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        },
      );
      return null;
    }

    int? nuevaMesaId;
    String? nomMesa;
    nomMesa = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Cambiar Mesa'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButtonFormField<Mesa>(
                hint: const Text(
                  "Seleccione una mesa disponible",
                  style: TextStyle(fontSize: 14),
                ),
                focusColor: Color( 0xFFFF562F),
                onChanged: (Mesa? newValue) {
                  setState(() {
                    nuevaMesaId = newValue?.id;
                    nomMesa = newValue?.nombreMesa;
                  });
                },
                items: mesas.map<DropdownMenuItem<Mesa>>(
                      (Mesa mesa) => DropdownMenuItem<Mesa>(
                        value: mesa,
                        child: Text(
                            '${mesa.nombreMesa} -> ${listaPisos.firstWhere((element) => element.id == mesa.pisoId).nombrePiso}'
                        ),
                  ),
                ).toList(),
                borderRadius: BorderRadius.all(Radius.circular(20)),
                menuMaxHeight: 500,

                icon: Icon(Icons.table_bar),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all( Color.fromRGBO(217, 217, 217, 0.8) ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar',style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all( Color(0xFF4C95DD)),
              ),
              onPressed: () async{
                if(nomMesa == null){
                  mostrarMensaje('Debes seleccionar una mesa');
                }else {
                  bool disponible = false; //bool disponible = await bdMesas.consultarMesa(nuevaMesaId!, context); -- SOMBREADO
                  if(disponible == true){
                    int? idPedido = IDPEDIDOPRUEBA == 0 ? widget.idPedido : IDPEDIDOPRUEBA;
                    bdPedido.actualizarPedido(idPedido, nuevaMesaId!, context).then((_) async {
                      //bdMesas.actualizarMesa(nuevaMesaId!, 3, context);
                      //bdMesas.actualizarMesa(widget.mesa!.id, 1, context);
                      widget.mesa?.id = nuevaMesaId ;
                      widget.mesa?.nombreMesa = nomMesa;
                      Navigator.pop(context);
                      Navigator.pop(context, idPedido);
                    });
                  }else {
                    mostrarMensaje('La mesa esta ocupada');
                  }

                }

              },
              child: const Text('Confirmar',style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    return nomMesa;
  }

  Widget _pedido(){
    return ElevatedButton(
        style:  ButtonStyle(
            elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(Colors.blue)),
        onPressed: () async {
          print('---> Boton pedido');
          String? printerIP = await _pref.read('ipCocina');
          bool _stateConexionTicket = await _pref.read('stateConexionTicket') ?? false;
          bool conexionBluetooth = await _pref.read('conexionBluetooth') ?? false;
          if(_stateConexionTicket){
            if(conexionBluetooth){
              crearPedido();
            }else {
              String messague = 'No se ha encontrado conectado a un dispositivo Bluetooth.';
              showMessangueDialog(messague);
              return;
            }
          }else {
            if (printerIP == null) {
              String messague = 'No se ha encontrado la dirección IP de la impresora.';
              showMessangueDialog(messague);
              return; // Salir del método printLabel
            }else {
              crearPedido();
            }
          }
        },
        child: const Text(
          'Pedido',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ));
  }

  Future<void> imprimir(List<Producto> prodSeleccionados, int? estado) async {
    String categoriasJson = await _pref.read('categorias');
    String? ipBar = await _pref.read('ipBar');
    String? ipCocina = await _pref.read('ipCocina');

    List<Producto> ParaBar = [];
    List<Producto> ParaCocina = [];

    List<Categoria> categorias = [];

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
        if (prodSeleccionados.isNotEmpty){
          print('Lista de productos seleccionados:');
          //impresora.printLabel(ipCocina!,prodSeleccionados,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, mozo!, piso,''); -- SOMBREADO
        }else{
          print('nada que imprimir');
        }
      } else {
        print('Productos para el bar:');
        if(ParaBar.isNotEmpty){
         // impresora.printLabel(ipBar,ParaBar,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, mozo!, piso,''); --- SOMBREADO
          if (ParaCocina.isNotEmpty){
            print('Lista de productos seleccionados:');
          //  impresora.printLabel(ipCocina!,ParaCocina,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, mozo!, piso,''); -- SOMBREADO
          }else{
            print('nada que imprimir');
          }
        }else{
          if (ParaCocina.isNotEmpty){
            print('Lista de productos seleccionados:');
          //  impresora.printLabel(ipCocina!,ParaCocina,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, mozo!, piso,''); -- SOMBREADO
          }else{
            print('nada que imprimir');
          }
        }
      }
      print('Productos para consumo normal:');
      ParaCocina.forEach((producto) {
        print(producto.nombreproducto);
      });
    } else {
      print('El JSON de categorías es nulo.');
    }
  }

  Widget _preCuenta(){
    return ElevatedButton(
        style:  ButtonStyle(
            elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(const Color(0xFFFFB500))),
        onPressed: () async {
          String? printerIP = await _pref.read('ipCocina');

          if (selectObjmesa.estadoMesa != 2 || widget.mesa!.estadoMesa !=2){
            gif();
            // PedidoResponse? retornoMesa = await mesaServicio.actualizarMesa( selectObjmesa.id  ?? widget.mesa!.id, usuario?.accessToken ,2 );
            // setState(() {
            //   selectObjmesa.estadoMesa = retornoMesa?.estadoMesa;
            //   widget.mesa?.estadoMesa = retornoMesa?.estadoMesa;
            // });

          }
          Navigator.pop(context,2);
          //impresora.printLabel(printerIP!,widget.productosSeleccionados,3,pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, usuario.user!, piso,''); ---- SOMBREADO
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
            borderRadius: BorderRadius.all(Radius.circular(20)), color: Color(0xFF99CFB5)

          // borderRadius: BorderRadius.all(Radius.circular(20)), color: Color(0xFF99CFB5)
        ),
        child: Row(
          children: [
            // const SizedBox(width: 5),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: selectObjmesa.estadoMesa == 1 || widget.mesa!.estadoMesa == 1 ? _pedido() : _preCuenta(),
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
        //     if (productoSeleccionado != null &&
        //         productoSeleccionado.stock != null &&
        //         productoSeleccionado.stock! > 1) {
        //       setState(() {
        //         productoSeleccionado.stock =
        //             productoSeleccionado.stock! - 1; // Restar al stock
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
                productoSeleccionado.stock = productoSeleccionado.stock! + 1; // Aumentar el stock

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
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void mostrarMensajeActualizado(String mensaje, bool esRojo ) {
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

  void refresh(){
    setState(() {
    });
  }

  void agregarMsj(String mensaje){
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  Future<void> crearPedido() async {
    gif();
    bool disponible = await bdMesas.consultarMesa(usuario?.accessToken ,selectObjmesa.id ?? widget.mesa!.id!);
    if(disponible == true){
      if (widget.productosSeleccionados!.length > 0) {
        // crear el pedido
        Map<String, dynamic> pedidoData = {
          "id_cliente": 1,
          "id_mesa": selectObjmesa.id ?? widget.mesa!.id, // Reemplaza con el ID de la mesa correcto
          "id_tipo_ped": 1,
          "nombremozo": "${usuario?.user?.nombreUsuario}", // Reemplaza con el nombre correcto del mozo
          "id_usuario": usuario?.user?.id, // Reemplaza con el ID del usuario autenticado
          "monto_total": pedidoTotal,
          "detalle": widget.productosSeleccionados!.map((producto) => {
            "id_producto": producto.id,
            "cantidad_producto": producto.stock,
            "precio_unitario": producto.precioproducto,
            "precio_producto": producto.precioproducto! * (producto.stock ?? 0),
            "comentario": cleanComentario(producto.comentario),
            "estado_detalle": 1
            // "comentario": limpiarPuntoComa(listaNota, producto, '')
          }).toList()
        };
        // Ya crea el pedido
        PedidoResponse? response = await pedidoServicio.registrarPedido(pedidoData, usuario?.accessToken);

        print('RESPUEST DE LA CREACION DE PEDIDO ${response?.ultimoIdPedido}');

        PedidoResponse? updateMesa = await mesaServicio.actualizarMesa( selectObjmesa.id ?? widget.mesa!.id , usuario!.accessToken, 3);

        Navigator.pop(context);
        ticketBluetooth.printLabelBluetooth(widget.productosSeleccionados, 1, pedidoTotal, selectObjmesa.nombreMesa, usuario!, selectObjmesa.nombrePiso, '');
        //ticketBluetooth.testReceipt(widget.productosSeleccionados, "1", pedidoTotal,  selectObjmesa.nombreMesa, usuario! ,selectObjmesa.nombrePiso , '');
        Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false, arguments: 1);
      }else{
        mostrarMensaje('No hay productos seleccionados');
        Navigator.pop(context);
      }
    }else{
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
  String cleanComentario(String? comentario) {
    if (comentario == null || comentario.isEmpty) {
      return '';
    }
    final RegExp regExp = RegExp(r'<span[^>]*>([^<]+)<\/span>');
    Iterable<Match> matches = regExp.allMatches(comentario);

    String cleanedComentario = matches.map((match) => match.group(1)).join(';');
    return cleanedComentario;
  }


  Future showMessangueDialog(String messague){
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error de Impresión'),
          content:  Text(messague),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el AlertDialog
                Navigator.pushNamed(context, 'home/ajustes'); // Dirigir a otra pantalla
              },
            ),
          ],
        );
      },
    );
  }
}