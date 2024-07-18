
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

import '../../model/categoria.dart';


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
  final SharedPref _pref = SharedPref();
  late  Mozo? mozo = Mozo();
  late Piso piso = Piso();
  late int? IDPEDIDOPRUEBA = 0;
  List<bool> _checkedItems = [];
  List<Nota> listaNota = [];

  Future<void> UserShared() async {
    final dynamic userData = await _pref.read('user_data');
    if (userData != null) {
      final Map<String, dynamic> userDataMap = json.decode(userData);
      mozo = Mozo.fromJson(userDataMap);
    }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    piso = await bdPisos.consultarPiso(widget.mesa!.pisoId as int, context);
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
                  ListTile(
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
                            if (widget.mesa!.estadoMesa != 2 && widget.items_independientes == false)
                            _addOrRemoveItem(index),
                            _precioProducto(index)
                          ],
                        ),
                          const SizedBox(width: 5),
                        if(selectObjmesa.estadoMesa != 2 || widget.mesa!.estadoMesa != 2)
                          _iconDelete(index, widget.productosSeleccionados?[index].id_pedido_detalle),
                        const SizedBox(width: 5),
                        if(selectObjmesa.estadoMesa != 2 || widget.mesa!.estadoMesa != 2)
                          _iconNota(index, widget.productosSeleccionados?[index].id_pedido_detalle),
                      ],
                    ),
                  ),
                  if (index != widget.productosSeleccionados!.length - 1) const Divider(
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
    return  Text(
      '$p',
      // Agrega el estilo de texto necesario aquí
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
        listaNota = await bdPedido.obtenerListasNota(mozo!.id_establecimiento!, context);
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
                Container(
                  margin: EdgeInsets.only(left: 10 ),
                  child: ElevatedButton(
                      style:  ButtonStyle(
                          elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(const Color(0xFF4C95DD))),
                      onPressed: () async {
                        gif();
                        //mesasDisponibles = await bdMesas.consultarMesasDisponibles(widget.mesa?.pisoId, context);
                        listaPisos = await bdPisos.consultarPisos(mozo!.id_establecimiento!, context);
                        mesasDisponibles = await bdMesas.consultarTodasMesas(listaPisos, context);
                        List<Mesa> mesasDisponiblesFiltradas = mesasDisponibles.where((mesa) => mesa.estadoMesa == 1).toList();
                        Navigator.pop(context);
                        mostrarMesa(mesasDisponiblesFiltradas);
                      },
                      child: const Text(
                        'Cambiar Mesa',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )),
                ),
                // const SizedBox(width: 10),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                      style:  ButtonStyle(
                          elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(const Color(0xFF634FD2))),
                      onPressed: () async {
                        print('---->BA BOTON ACTUALIZAR');
                        if(widget.items_independientes){
                          String? printerIP = await _pref.read('ipCocina');
                          if (printerIP == null) {
                            // Mostrar un AlertDialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error de Impresión'),
                                  content: const Text(
                                      'No se ha encontrado la dirección IP de la impresora.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Cerrar el AlertDialog
                                        Navigator.pushNamed(context,
                                            'home/ajustes'); // Dirigir a otra pantalla
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            return; // Salir del método printLabel
                          }else if (widget.productosSeleccionados!.length > 0){
                            gif();
                            List<Producto> nombresProductos = [];

                            // for (final producto in widget.productosSeleccionados!) {
                            //   print('Antes de actualizar: Producto ID: ${producto.id}, ID Pedido Detalle: ${producto.id_pedido_detalle}');
                            //
                            //   if (producto.id_pedido_detalle == null) {
                            //     Detalle_Pedido detalles_pedido = await detallePedidoServicio.AgregarProductoDetallePedidoItem(widget.idPedido, producto, context);
                            //     producto.id_pedido_detalle = detalles_pedido.id_pedido_detalle;
                            //     nombresProductos.add(producto);
                            //     detalles_pedios_tmp.add(detalles_pedido);
                            //     print('Después de actualizar: Producto ID: ${producto.id}, ID Pedido Detalle: ${widget.productosSeleccionados.}');
                            //   }
                            // }

                            for (final producto in widget.productosSeleccionados!) {
                              int index = widget.productosSeleccionados!.indexOf(producto);
                              print('Índice del producto: $index');

                              // Resto de tu lógica aquí
                              print('Antes de actualizar: Producto ID: ${producto.id}, ID Pedido Detalle: ${producto.id_pedido_detalle}');

                              if (producto.id_pedido_detalle == null) {
                                Detalle_Pedido detalles_pedido = await detallePedidoServicio.AgregarProductoDetallePedidoItem(widget.idPedido, producto, context);
                                setState(() {
                                  widget.productosSeleccionados![index].id_pedido_detalle = detalles_pedido.id_pedido_detalle;
                                });
                                nombresProductos.add(producto);
                                detalles_pedios_tmp.add(detalles_pedido);
                                print('Después de actualizar: Producto ID: ${producto.id}, ID Pedido Detalle: ${widget.productosSeleccionados![index].id_pedido_detalle}');
                              }
                            }

                            if (nombresProductos.isNotEmpty) {
                              await detallePedidoServicio.actualizarAgregarProductoDetallePedidoItem(widget.idPedido, pedidoTotal,context);
                              imprimir(nombresProductos, 2);
                              print('Hay productos que Actualizar');
                              Navigator.pop(context);
                            } else {
                              mostrarMensajeActualizado('No hay productos que Actualizar', true);
                              print('No hay productos que Actualizar');
                              Navigator.pop(context);
                            }
                          }else {
                            mostrarMensajeActualizado('No puedes dejar la lista vacia', true);
                          }
                        }else {
                          String? printerIP = await _pref.read('ipCocina');
                          if (printerIP == null) {
                            // Mostrar un AlertDialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error de Impresión'),
                                  content: const Text(
                                      'No se ha encontrado la dirección IP de la impresora.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Cerrar el AlertDialog
                                        Navigator.pushNamed(context,
                                            'home/ajustes'); // Dirigir a otra pantalla
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            return; // Salir del método printLabel
                          }else if (widget.productosSeleccionados!.length > 0){
                            gif();
                            List<Producto> nombresProductos = [];
                            List<Detalle_Pedido> detalleCompletos = await detallePedidoServicio.eliminarCantidadProductoDetallePedidoImprimir(widget.idPedido, widget.productosSeleccionados!, pedidoTotal, context);
                            detalles_pedios_tmp = await detallePedidoServicio.actualizarCantidadProductoDetallePedidoPrueba(widget.idPedido, widget.productosSeleccionados!, pedidoTotal, context);
                            if (detalles_pedios_tmp.isNotEmpty) {
                              for (var detalle in detalles_pedios_tmp) {
                                Producto? producto = await buscarNombreProductoPorId(detalle.id_producto);
                                if (producto != null) {
                                  nombresProductos.add(Producto(
                                      categoria_id: producto.categoria_id,
                                      nombreproducto: producto.nombreproducto,
                                      stock: detalle.cantidad_producto,
                                      comentario: detalle.comentario
                                  ));
                                }
                              }
                            }
                            // Agregar productos de detalleCompletos si no está vacío
                            if (detalleCompletos.isNotEmpty) {
                              for (var element in detalleCompletos) {
                                Producto? producto = await buscarNombreProductoPorId(element.id_producto);
                                if (producto != null) {
                                  producto.stock = 0;
                                  nombresProductos.add(producto);
                                }
                              }
                            }
                            if (nombresProductos.isNotEmpty) {
                              imprimir(nombresProductos, 2);
                              print('Hay productos que Actualizar');
                              Navigator.pop(context);
                            } else {
                              mostrarMensajeActualizado('No hay productos que Actualizar', true);
                              print('No hay productos que Actualizar');
                              Navigator.pop(context);
                            }
                          }else {
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
                print('Comidas : ${comidas}');
                String selectedOptionsString = generateSelectedOptionsString(comidas);
                if (widget.items_independientes) {
                  if (id_pedido_detalle != null) {
                    await detallePedidoServicio.notaProductoPorItem(selectedOptionsString, id_pedido_detalle, context);
                    agregarMsj('Se agregó una nota al producto');
                    imprimir([widget.productosSeleccionados![indexProducto]], 2);
                  }
                  // Aquí nos aseguramos de actualizar solo el producto seleccionado
                  widget.productosSeleccionados?[indexProducto].comentario = selectedOptionsString;
                  print('Índice seleccionado (independiente): $indexProducto');

                } else {
                  widget.productosSeleccionados?[indexProducto].comentario = selectedOptionsString;
                  print('Opciones seleccionadas: $selectedOptionsString');
                  print('Índice seleccionado: $indexProducto');
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
                double total;
                if(id_pedido_detalle != null){
                  int productIndex = widget.productosSeleccionados!.indexWhere((producto) => producto.id_pedido_detalle == id_pedido_detalle);
                  if (productIndex != -1) {

                    // Eliminar el producto de la lista
                    setState(() {
                      widget.productosSeleccionados!.removeAt(productIndex);
                    });
                    total = calcularTotal();
                    print('MONTO TOTAL ${total}');

                    // Actualizar los productos seleccionados en el widget padre si es necesario
                    _actualizarProductosSeleccionados();
                    await detallePedidoServicio.actualizarAgregarProductoDetallePedidoItem(widget.idPedido, total,context);
                    await  detallePedidoServicio.eliminarProductoPorItem(id_pedido_detalle);
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
              }else {
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
                  bool disponible = await bdMesas.consultarMesa(nuevaMesaId!, context);
                  if(disponible == true){
                    int? idPedido = IDPEDIDOPRUEBA == 0 ? widget.idPedido : IDPEDIDOPRUEBA;
                    bdPedido.actualizarPedido(idPedido, nuevaMesaId!, context).then((_) async {
                      bdMesas.actualizarMesa(nuevaMesaId!, 3, context);
                      bdMesas.actualizarMesa(widget.mesa!.id, 1, context);
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
          int entornoId = await _getEntornoId();
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
          DateTime parsedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedDate);

          if (printerIP == null) {
            // Mostrar un AlertDialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error de Impresión'),
                  content: const Text('No se ha encontrado la dirección IP de la impresora.'),
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
            return; // Salir del método printLabel

          }else {

            bool disponible = await bdMesas.consultarMesa(selectObjmesa.id ?? widget.mesa!.id!, context);
            print('ESTADO DE MESA $disponible');
            if(disponible == true){
              if (widget.productosSeleccionados!.length > 0) {
                gif();
                // crear el pedido
                newpedido = Pedido(
                    idEntorno: entornoId , // 1-> demo || 2-> producion
                    idCliente: 60, // 60 clientes varios
                    idUsuario: mozo?.id, // ID DEL MOSO ✔️
                    idTipoPedido: 1, // 1-> local || 2-> llevar || 3->delivery ✖️
                    idMesa: selectObjmesa.id ?? widget.mesa!.id, //✔️
                    idEstablecimiento: mozo?.id_establecimiento, // ✔️
                    idSeriePedido: 1, // nose que es ✖️
                    montoTotal: pedidoTotal, // ✔️
                    fechaPedido: parsedDateTime.toUtc(), // ✔️
                    estadoPedido: 1, // ✔️
                    created_at: parsedDateTime.toUtc(),
                    updated_at: parsedDateTime.toUtc()
                );
                // Ya crea el pedido

                int newPedidoId = await pedidoServicio.crearPedidoPrueba(newpedido, context);
                Mesa? retornoMesa = await mesaServicio.actualizarMesa( selectObjmesa.id ?? widget.mesa!.id , 3, context);
                List<Detalle_Pedido> retornoPedidoDetalle = await detallePedidoServicio.crearDetallePedidoPrueba( newPedidoId, widget.productosSeleccionados!, context);
                print(retornoPedidoDetalle);
                setState(() {
                  IDPEDIDOPRUEBA = newPedidoId;
                  widget.idPedido = newPedidoId;
                  print('ID del pedido creado: ${ widget.idPedido }');
                  // Actualiza la mesa
                  print(retornoMesa!.estDisMesa);
                  // genera el detalle de pedido
                  detalles_pedios_tmp = retornoPedidoDetalle;
                  widget.detallePedidoLista = retornoPedidoDetalle;
                  print('DETALLA TMP $detalles_pedios_tmp');
                  // seteo la mesa que ya tengo en el page
                  selectObjmesa.estDisMesa = retornoMesa.estDisMesa;
                  widget.mesa?.estDisMesa = retornoMesa.estDisMesa;
                  //selectObjmesa.estDisMesa = retornoMesa.estDisMesa;
                  selectObjmesa.estadoMesa = retornoMesa.estadoMesa;
                  widget.mesa?.estadoMesa = retornoMesa.estadoMesa;
                  //selectObjmesa.estadoMesa = retornoMesa.estadoMesa;
                });
                imprimir(widget.productosSeleccionados!,1);
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false, arguments: 1);
                //Navigator.pop(context, newPedidoId);
                //impresora.printLabel(printerIP,widget.productosSeleccionados,1, pedidoTotal, selectObjmesa.nombreMesa);
                // Actualizar mesa
                //print(retornoPedido);
              }else{
                mostrarMensaje('No hay productos seleccionados');
                // Navigator.pop(context);
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
          impresora.printLabel(ipCocina!,prodSeleccionados,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, mozo!, piso,'');
        }else{
          print('nada que imprimir');
        }
      } else {
        print('Productos para el bar:');
        if(ParaBar.isNotEmpty){
          impresora.printLabel(ipBar,ParaBar,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, mozo!, piso,'');
          if (ParaCocina.isNotEmpty){
            print('Lista de productos seleccionados:');
            impresora.printLabel(ipCocina!,ParaCocina,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, mozo!, piso,'');
          }else{
            print('nada que imprimir');
          }
        }else{
          if (ParaCocina.isNotEmpty){
            print('Lista de productos seleccionados:');
            impresora.printLabel(ipCocina!,ParaCocina,estado, pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, mozo!, piso,'');
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
            Mesa? retornoMesa = await mesaServicio.actualizarMesa( selectObjmesa.id  ?? widget.mesa!.id, 2, context);
            setState(() {
              selectObjmesa.estadoMesa = retornoMesa?.estadoMesa;
              widget.mesa?.estadoMesa = retornoMesa?.estadoMesa;
            });

          }
          Navigator.pop(context,2);
          impresora.printLabel(printerIP!,widget.productosSeleccionados,3,pedidoTotal, selectObjmesa.nombreMesa ?? widget.mesa!.nombreMesa, mozo!, piso,'');
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
                  const Text('TOTAL : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('S/ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
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
        GestureDetector(
          onTap: () {
            final productoSeleccionado = widget.productosSeleccionados?[index];
            //final productoSeleccionadoDetalle = widget.detallePedidoLista[index];
            if (productoSeleccionado != null && productoSeleccionado.stock != null && productoSeleccionado.stock! > 1) {

              setState(() {
                productoSeleccionado.stock = productoSeleccionado.stock! - 1; // Restar al stock

                // double precioTotalProductoDetalle = productoSeleccionadoDetalle.precio_producto! - productoSeleccionado.precioproducto!;
                // productoSeleccionadoDetalle.precio_producto = precioTotalProductoDetalle;
              });

            } else if (productoSeleccionado != null && productoSeleccionado.stock != null && productoSeleccionado.stock! == 1) {
              // Aquí puedes mostrar un mensaje o tomar alguna acción adicional si el stock ya es 1
            }
            _actualizarProductosSeleccionados(); // Llama a la función para actualizar los productos seleccionados
          },

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              color: Colors.grey[200],
            ),
            child: const Text('-'),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          color: Colors.grey[200],
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
              color: Colors.grey[200],
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

}