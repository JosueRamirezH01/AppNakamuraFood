
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/model/pedido.dart';
import 'package:restauflutter/model/producto.dart';
import 'package:restauflutter/services/mesas_service.dart';
import 'package:restauflutter/services/pedido_service.dart';
import 'package:restauflutter/services/detalle_pedido_service.dart';
import 'package:restauflutter/utils/shared_pref.dart';
import 'package:intl/intl.dart';


class DetailsPage extends StatefulWidget {
  final List<Producto>? productosSeleccionados;
  final List<Producto>? productosSeleccionadosOtenidos;
  final List<Detalle_Pedido> detallePedidoLista;
  final List<Detalle_Pedido> detallePedidoLastCreate;
  final int? estado;
  final int? idPedido;
  final Mesa? mesa;
  final void Function(List<Producto>?)? onProductosActualizados; // Función de devolución de llamada
  const DetailsPage({super.key,
    required this.idPedido,
    required this.productosSeleccionados,
    required this.estado,
    required this.detallePedidoLastCreate,
    required this.detallePedidoLista,
    required this.productosSeleccionadosOtenidos,
    required this.mesa,
    this.onProductosActualizados});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  TextEditingController notaController = TextEditingController();
  var bdMesas = MesaServicio();
  var bdPedido = PedidoServicio();

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
  late int estado;
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
    estado = widget.mesa!.estadoMesa!;
    selectObjmesa = widget.mesa!;
    detalles_pedios_tmp = widget.detallePedidoLista ;
    print(widget.detallePedidoLastCreate);

    UserShared();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if(selectObjmesa.estadoMesa != 1)
              cabecera(),
            const SizedBox(height: 10),
            contenido(),
            debajo()
          ],
        ),
      ),
    );
  }

  Widget contenido() {
    return SingleChildScrollView(
      child: Container(
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
      padding: EdgeInsets.only(top: 10.0, bottom: 10),
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
          icono(),
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.08,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)), color: Color(0xFF99CFB5)),
            child: Row(
              children: [
                const SizedBox(width: 5),
                Expanded(
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
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                      style:  ButtonStyle(
                          elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(const Color(0xFF634FD2))),
                      onPressed: () async {
                        int? idPedidoRecuperado = IDPEDIDOPRUEBA != 0 ? IDPEDIDOPRUEBA : widget.idPedido;

                        print('ID PRUEBA RECUPERADO  222222 $idPedidoRecuperado');
                        List<Detalle_Pedido> listDetalleRecuperado = detalles_pedios_tmp.isNotEmpty ? detalles_pedios_tmp : widget.detallePedidoLastCreate;

                        detalles_pedios_tmp = await detallePedidoServicio.actualizarCantidadProductoDetallePedidoPrueba( idPedidoRecuperado ,listDetalleRecuperado, widget.productosSeleccionados!, pedidoTotal, context);
                        print('DETALLE DE PEDIDO TPM 111$listDetalleRecuperado');
                        
                        if(detalles_pedios_tmp != []){
                          mostrarMensajeActualizado('Productos Actualizados');
                        }else{
                          mostrarMensaje('Nada por actualizar');
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
    notaController.text = widget.productosSeleccionados?[index].comentario ?? '';
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
                widget.productosSeleccionados?[index].comentario = notaController.text;
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
                hint: const Text("Seleccione una mesa disponible"),
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
                int? idPedido = IDPEDIDOPRUEBA == 0 ? widget.productosSeleccionados![0].idPedido : IDPEDIDOPRUEBA;
                bdPedido.actualizarPedido(idPedido, nuevaMesaId!, context).then((_) {
                  bdMesas.actualizarMesa(nuevaMesaId!, 2, context);
                  bdMesas.actualizarMesa(widget.mesa!.id, 1, context);
                  Navigator.pop(context); // Confirmar y pasar el valor seleccionado
                  Navigator.pop(context, nomMesa); // Confirmar y pasar el valor seleccionado
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
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
          DateTime parsedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedDate);

          if (widget.productosSeleccionados!.length > 0) {
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
            Mesa? retornoMesa = await mesaServicio.actualizarMesa( selectObjmesa.id , 2, context);
            List<Detalle_Pedido> retornoPedidoDetalle = await detallePedidoServicio.crearDetallePedidoPrueba( newPedidoId, widget.productosSeleccionados!, context);
            print(retornoPedidoDetalle);
            setState(() {
              IDPEDIDOPRUEBA = newPedidoId;
              print('ID del pedido creado: ${IDPEDIDOPRUEBA}');
              // Actualiza la mesa
              print(retornoMesa!.estDisMesa);
              // genera el detalle de pedido
              detalles_pedios_tmp = retornoPedidoDetalle;
              print('DETALLA TMP $detalles_pedios_tmp');
              // seteo la mesa que ya tengo en el page
              selectObjmesa.estDisMesa = retornoMesa.estDisMesa;
              //selectObjmesa.estDisMesa = retornoMesa.estDisMesa;
              selectObjmesa.estadoMesa = retornoMesa.estadoMesa;
              //selectObjmesa.estadoMesa = retornoMesa.estadoMesa;
            });


            // Actualizar mesa
            //print(retornoPedido);

            //_pdf();

          }else{
            print('no puedes mandar una lista vacia');
          }
        },
        child: const Text(
          'Pedido',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ));
  }

  Widget _preCuenta(){
    return ElevatedButton(
        style:  ButtonStyle(
            elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(const Color(0xFFFFB500))),
        onPressed: () {
          _pdf();
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
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)), color: Color(0xFF99CFB5)),
        child: Row(
          children: [
            const SizedBox(width: 5),
            Expanded(
              child: selectObjmesa.estadoMesa == 1 ? _pedido() : _preCuenta(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                child: Row(
                  children: [
                    const Text('TOTAL : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('S/ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
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




  Future<void> _pdf() async {
    final pdf = pw.Document();

    // Tamaño del papel de la etiqueta
    final PdfPageFormat labelSize =  const PdfPageFormat(
      80.0 * PdfPageFormat.mm,
      80.0 * PdfPageFormat.mm,
    ); // Para 80x80 mm

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Título de la mesa
                pw.Center(
                  child: pw.Text(
                    '${selectObjmesa.nombreMesa}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Divider(),
                _buildDetails(),
                pw.Divider(),
                _buildTableHeader(),
                pw.Divider(),
                _buildTableContent(),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }



  pw.Widget _buildDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Piso: PISO 1', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text('Mesero(a): mozo', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text('Hora: 14:20:26', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text('Fecha: 2024-03-26', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _buildTableHeader() {
    return pw.Row(
      children: [
        pw.SizedBox(width: 5),
        pw.Text('CANTIDAD', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 20),
        pw.Text('PRODUCTO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 20),
        pw.Text('NOTA', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _buildTableContent() {
    return pw.ListView.builder(
      itemCount: widget.productosSeleccionados!.length,
      itemBuilder: (_, int index) {
        return pw.Column(
          children: [
            pw.Row(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.only(left: 25, right: 30),
                  child: pw.Center(
                    child: pw.Text(
                      '${widget.productosSeleccionados![index].stock}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ),
                pw.Container(
                  constraints: const pw.BoxConstraints(maxWidth: 80),
                  padding: const pw.EdgeInsets.only(right: 5),
                  child: pw.Center(
                    child: pw.Text(
                      '${widget.productosSeleccionados![index].nombreproducto}',
                      style: const pw.TextStyle(fontSize: 8),
                      maxLines: 3,
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ),
                pw.Container(
                  constraints: const pw.BoxConstraints(maxWidth: 70),
                  padding: const pw.EdgeInsets.only(right: 20),
                  child: pw.Center(
                    child: pw.Text(
                      '${widget.productosSeleccionados![index].comentario}',
                      style: const pw.TextStyle(fontSize: 8),
                      maxLines: 3,
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            if (index != widget.productosSeleccionados!.length - 1)
              pw.Divider(),
          ],
        );
      },
    );
  }

  void refresh(){
    setState(() {
    });
  }



}