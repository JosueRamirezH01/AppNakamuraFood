
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:restauflutter/model/producto.dart';

class DetailsPage extends StatefulWidget {
  final List<Producto>? productosSeleccionados;
  final int estado;
  final void Function(List<Producto>?)? onProductosActualizados; // Función de devolución de llamada

  const DetailsPage({super.key, required this.productosSeleccionados, required this.estado, this.onProductosActualizados});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<String> items = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20'
  ];
  int contador = 0;
  List<String> mesa = ['Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4'];
  String? selectedMesa;
  late int estado;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('ESTADO INICIANDO ${widget.estado}');
    estado = widget.estado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if(estado != 1)
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
                      _iconDelete(),
                      const SizedBox(width: 5),
                       _iconNota(),
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


  Widget _iconDelete() {
    return GestureDetector(
        onTap: (){
            _eliminar();
        },
       child: const Icon(Icons.delete, color: Colors.red),

    );
  }

  Widget _iconNota() {
    return GestureDetector(
        onTap: () {
            _nota();
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
                      onPressed: () {
                        mostrarMesa();
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
                      onPressed: () {},
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
        //onChanged: _con.onChangeText,
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
  Future<String?> _nota(){
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
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?> _eliminar(){
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
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?> mostrarMesa() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Cambiar Mesa'),
        content: DropdownButtonFormField<String>(
          value: selectedMesa,
          onChanged: (String? newValue) {
            setState(() {
              selectedMesa = newValue;
            });
          },
          items: mesa
              .map<DropdownMenuItem<String>>(
                (String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
              .toList(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Ok'),
            child: const Text('Confimar'),
          ),
        ],
      ),
    );
  }
  Widget _pedido(){
    return ElevatedButton(
        style:  ButtonStyle(
            elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(Colors.blue)),
        onPressed: () {
            setState(() {
              estado = 2;
            });
         print('ESTADO $estado');
          _pdf();
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
              child: estado == 1 ? _pedido() : _preCuenta(),
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





  Future<void> _pdf() async {
    final pdf = pw.Document();
    // Tamaño del papel de la etiqueta
    final PdfPageFormat labelSize =  PdfPageFormat(
      80.0 * PdfPageFormat.mm,
      80.0 * PdfPageFormat.mm,
    );// Para 80x80 mm
    // final PdfPageFormat labelSize = PdfPageFormat.custom(
    //   width: 100.0 * PdfPageFormat.mm,
    //   height: 100.0 * PdfPageFormat.mm,
    // ); // Para 100x100 mm

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text( 'PRE-CUENTA',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text( 'MESA 2',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  )]
                ),
                ),
                pw.Divider(),
                pw.Text('Piso: PISO 1', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                pw.Text('Mesero(a): mozo',style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                pw.Text('Hora: 14:20:26',style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                pw.Text('Fecha: 2024-03-26',style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                pw.Divider(),
                pw.Row(
                  children: [
                    pw.Text('CANTIDAD',style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 5),
                    pw.Text('PRODUCTO', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 5),
                    pw.Text('P.UNIT', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 5),
                    pw.Text('TOTAL', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ]
                ),
                pw.Divider(),
                pw.ListView.builder(
                  itemCount: widget.productosSeleccionados!.length,
                  itemBuilder: (_, int index) {
                    return pw.Column(
                      children: [
                        pw.Text(
                          '${widget.productosSeleccionados![index].nombreproducto}',
                        ),
                        if (index != widget.productosSeleccionados!.length - 1) pw.Divider(height: 1, thickness: 2),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );

    // Mostrar el PDF en un widget utilizando PdfPreview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
