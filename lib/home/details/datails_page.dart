
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/model/pedido.dart';
import 'package:restauflutter/model/producto.dart';
import 'package:restauflutter/services/mesas_service.dart';
import 'package:restauflutter/services/pedido_service.dart';
import 'package:restauflutter/services/detalle_pedido_service.dart';
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
  final void Function(List<Producto>?)? onProductosActualizados; // Función de devolución de llamada
  DetailsPage({super.key,
    required this.productosSeleccionados,
    required this.detallePedidoLista,
    required this.mesa,
    required this.idPedido,
    this.onProductosActualizados});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  TextEditingController notaController = TextEditingController();
  var bdMesas = MesaServicio();
  var bdPedido = PedidoServicio();
  var impresora = Impresora();
  final SharedPref _pref = SharedPref();
  late  Mozo? mozo = Mozo();
  late int? IDPEDIDOPRUEBA = 0;

  Future<void> UserShared() async {
    final dynamic userData = await _pref.read('user_data');
    if (userData != null) {
      final Map<String, dynamic> userDataMap = json.decode(userData);
      mozo = Mozo.fromJson(userDataMap);
    }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    print('formato de Hora: $formattedDate');
    print('Id del mozo : ${mozo?.id}');
    print('Id del establecimiento: ${mozo?.id_establecimiento}');
    print('Id de la mesa : ${selectObjmesa.id}');
  }
  //late int estado;
  List<Mesa> mesasDisponibles = [];
  List<Detalle_Pedido> detalles_pedios_tmp = [];
  late Mesa selectObjmesa;
  PedidoServicio pedidoServicio= PedidoServicio();
  MesaServicio mesaServicio = MesaServicio();
  DetallePedidoServicio detallePedidoServicio = DetallePedidoServicio();
  late Pedido newpedido = Pedido();
  late double pedidoTotal ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('ESTADO INICIANDO ${widget.mesa?.estadoMesa}');
    //estado = widget.mesa!.estadoMesa!;
    selectObjmesa = widget.mesa!;
    detalles_pedios_tmp = widget.detallePedidoLista ;
    UserShared();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            icono(),
            if(selectObjmesa.estadoMesa != 1 && selectObjmesa.estadoMesa != 2)
              cabecera(),
            // const SizedBox(height: 10),
            contenido(),
            debajo()
          ],
        ),
      ),
    );
  }

  Widget contenido() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification && notification.metrics.atEdge && notification.metrics.pixels <= 0) {
          return false;
        }
        return true;
      },
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top:5 ,left: 15,right: 15),
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.height * 0.45,
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
                        _addOrRemoveItem(index),
                        const SizedBox(width: 5),
                        _iconDelete(index),
                        const SizedBox(width: 5),
                        _iconNota(index),
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


  Widget _iconDelete(int index) {
    return GestureDetector(
      onTap: (){
        _eliminar(index);
      },
      child: const Icon(Icons.delete, color: Colors.red),

    );
  }

  Widget _iconNota(int index) {
    return GestureDetector(
      onTap: () {
        _nota(index);
      },
      child: const Icon(Icons.edit, color: Colors.amber),
    );
  }
  Widget icono(){
    return const Padding(
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: Divider(
        indent: 120,
        endIndent: 120,
        thickness: 5,
      ),
    );
  }

  Widget cabecera() {
    return Center(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 15,right: 15, bottom: 10),
            width: MediaQuery.of(context).size.width * 0.95,
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
                        print('CODIGO DE PISO ${widget.mesa?.pisoId}');
                        mesasDisponibles = await bdMesas.consultarMesasDisponibles(widget.mesa?.pisoId, context);
                        mostrarMesa(mesasDisponibles);
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
                        List<Producto> nombresProductos = [];
                        gif();
                        List<Detalle_Pedido> detalleCompletos = await detallePedidoServicio.eliminarCantidadProductoDetallePedidoImprimir(widget.idPedido, widget.productosSeleccionados!, pedidoTotal, context);
                        detalles_pedios_tmp = await detallePedidoServicio.actualizarCantidadProductoDetallePedidoPrueba(widget.idPedido, widget.productosSeleccionados!, pedidoTotal, context);

                        print('INSERTAR OBTENIDO PARA OBTENER EN EL TICKET $detalles_pedios_tmp');

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
                          Navigator.pop(context);
                        } else {
                          mostrarMensajeActualizado('No hay productos que Actualizar');
                          Navigator.pop(context);
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
  Future<String?> _nota(int index){
    // notaController.text = widget.productosSeleccionados?[index].comentario == 'null' ? '' : widget.productosSeleccionados![index].comentario!;
    notaController.text = widget.productosSeleccionados?[index].comentario ?? '';
    print('COMENTARIO EN NOTA ${widget.productosSeleccionados?[index].comentario}');
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Observacion del plato'),
        content: _textFieldNota(),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.productosSeleccionados?[index].comentario = notaController.text == '' ? null : notaController.text;
                print('NOTA SETSTATE ${widget.productosSeleccionados?[index].comentario}');
                print('NOTA SETSTATE Nota${notaController.text}');

              });
              Navigator.pop(context, 'OK');
            } ,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?> _eliminar(int index){
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
            onPressed: () {
              index = widget.productosSeleccionados!.indexWhere((producto) => producto == widget.productosSeleccionados![index]);
              if (index != -1) {
                // Eliminar el producto de la lista
                setState(() {
                  widget.productosSeleccionados!.removeAt(index);
                });
                // Actualizar los productos seleccionados en el widget padre si es necesario
                _actualizarProductosSeleccionados();
              }
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?> mostrarMesa(List<Mesa> mesas) async {
    int? nuevaMesaId;
    String? nomMesa;
    nomMesa = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar Mesa'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButtonFormField<Mesa>(
                hint: const Text("Seleccione una mesa disponible", style: TextStyle(fontSize: 14),),
                onChanged: (Mesa? newValue) {
                  setState(() {
                    nuevaMesaId = newValue?.id;
                    nomMesa = newValue?.nombreMesa;
                  });
                },
                items: mesas.map<DropdownMenuItem<Mesa>>(
                      (Mesa mesa) => DropdownMenuItem<Mesa>(
                    value: mesa,
                    child: Text('${mesa.nombreMesa}'),
                  ),
                ).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancelar: Cierra el diálogo y la página
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                int? idPedido = IDPEDIDOPRUEBA == 0 ? widget.idPedido : IDPEDIDOPRUEBA;
                bdPedido.actualizarPedido(idPedido, nuevaMesaId!, context).then((_) async {
                  bdMesas.actualizarMesa(nuevaMesaId!, 3, context);
                  bdMesas.actualizarMesa(widget.mesa!.id, 1, context);
                  widget.mesa?.id = nuevaMesaId ;
                  widget.mesa?.nombreMesa = nomMesa;
                  Navigator.pop(context); // Confirmar y pasar el valor seleccionado
                  Navigator.pop(context, idPedido);
                });
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    // Regresa el valor de nomMesa
    return nomMesa;
  }
  Widget _pedido(){
    return ElevatedButton(
        style:  ButtonStyle(
            elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(Colors.blue)),
        onPressed: () async {
          print('---> Boton pedido');
          String? printerIP = await _pref.read('ipCocina');
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
          }else if (widget.productosSeleccionados!.length > 0) {
            gif();
            // crear el pedido
            newpedido = Pedido(
              idEntorno: 1, // 1-> demo || 2-> producion
              idCliente: 60, // 60 clientes varios
              idUsuario: mozo?.id, // ID DEL MOSO ✔️
              idTipoPedido: 1, // 1-> local || 2-> llevar || 3->delivery ✖️
              idMesa: selectObjmesa.id, //✔️
              idEstablecimiento: mozo?.id_establecimiento, // ✔️
              idSeriePedido: 1, // nose que es ✖️
              montoTotal: pedidoTotal, // ✔️
              fechaPedido: parsedDateTime.toUtc(), // ✔️
              estadoPedido: 1, // ✔️
            );
            // Ya crea el pedido

            int newPedidoId = await pedidoServicio.crearPedidoPrueba(newpedido, context);
            Mesa? retornoMesa = await mesaServicio.actualizarMesa( selectObjmesa.id , 3, context);
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
            Navigator.pop(context);
            Navigator.pop(context, newPedidoId);
            //impresora.printLabel(printerIP,widget.productosSeleccionados,1, pedidoTotal, selectObjmesa.nombreMesa);
            imprimir(widget.productosSeleccionados!,1);
            // Actualizar mesa
            //print(retornoPedido);
            }else{
            mostrarMensaje('No hay productos seleccionados');
            Navigator.pop(context);
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
          impresora.printLabel(ipCocina!,prodSeleccionados,estado, pedidoTotal, selectObjmesa.nombreMesa);
        }else{
          print('nada que imprimir');
        }
      } else {
        print('Productos para el bar:');
        if(ParaBar.isNotEmpty){
          impresora.printLabel(ipBar,ParaBar,estado, pedidoTotal, selectObjmesa.nombreMesa);
          if (ParaCocina.isNotEmpty){
            print('Lista de productos seleccionados:');
            impresora.printLabel(ipCocina!,ParaCocina,estado, pedidoTotal, selectObjmesa.nombreMesa);
          }else{
            print('nada que imprimir');
          }
        }else{
          if (ParaCocina.isNotEmpty){
            print('Lista de productos seleccionados:');
            impresora.printLabel(ipCocina!,ParaCocina,estado, pedidoTotal, selectObjmesa.nombreMesa);
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

          if (selectObjmesa.estadoMesa != 2){
            gif();
            Mesa? retornoMesa = await mesaServicio.actualizarMesa( selectObjmesa.id , 2, context);
            setState(() {
              selectObjmesa.estadoMesa = retornoMesa?.estadoMesa;
              widget.mesa?.estadoMesa = retornoMesa?.estadoMesa;
            });

          }
          Navigator.pop(context,2);
          impresora.printLabel(printerIP!,widget.productosSeleccionados,3,pedidoTotal, selectObjmesa.nombreMesa);
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
            borderRadius: BorderRadius.all(Radius.circular(20)), color: Color(0xFF99CFB5)),
        child: Row(
          children: [
            // const SizedBox(width: 5),
            Container(
              margin: EdgeInsets.only(left: 15),
              child: selectObjmesa.estadoMesa == 1 ? _pedido() : _preCuenta(),
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
            if (productoSeleccionado != null && productoSeleccionado.stock != null && productoSeleccionado.stock! > 1) {

              setState(() {
                productoSeleccionado.stock = productoSeleccionado.stock! - 1; // Restar al stock
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
            if (productoSeleccionado != null && productoSeleccionado.stock != null) {

              setState(() {
                productoSeleccionado.stock = productoSeleccionado.stock! + 1; // Aumentar el stock
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
  void mostrarMensajeActualizado(String mensaje) {
    Fluttertoast.showToast(
      msg: mensaje,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }


  void refresh(){
    setState(() {
    });
  }



}