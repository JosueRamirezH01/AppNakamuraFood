
import 'dart:convert';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:restauflutter/model/producto.dart';
import 'package:restauflutter/model/usuario.dart';
import 'package:restauflutter/utils/shared_pref.dart';

import '../model/mozo.dart';
import '../model/piso.dart';

class Impresora {



  Future<void> printLabel(String printerIP,List<Producto>? producto, int? estado, double total, String? nombreMesa, Usuario mozo, String? piso, String motivo) async {

    String tipoBoucher = '';

    if(estado == 1){
      tipoBoucher = 'Pedido';
    }else if(estado == 2){
      tipoBoucher = 'Pedidos Actualizados';
    }else if(estado == 3){
      tipoBoucher = 'Pre-Cuenta';
    }else if(estado == 4){
      tipoBoucher = 'Anulado';
    }

    //192.168.10.182
    // Crea la instancia de la impresora
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);
    final PosPrintResult res = await printer.connect(printerIP, port: 9100);

    if (res == PosPrintResult.success) {
      testReceipt(producto ,printer, tipoBoucher, total, nombreMesa!, mozo, piso, motivo);
      printer.disconnect();
    }

  }


  void testReceipt(List<Producto>? producto, NetworkPrinter printer, String tipoBoucher, double total,String nombreMesa, Usuario mozo,  String? piso, String motivo ) {

    // Título de la mesa
    if( tipoBoucher =='Anulado'){
      printer.text(tipoBoucher,
          styles: const PosStyles(bold: true, align: PosAlign.center, width: PosTextSize.size6, height: PosTextSize.size2),linesAfter: 1);
    }else{
      printer.text(tipoBoucher,
          styles: const PosStyles(bold: true, align: PosAlign.center));

    }

    printer.text(nombreMesa,
        styles: const PosStyles(bold: true, align: PosAlign.center));
    printer.hr();

    // Detalles del mesero, hora y fecha
    _buildDetailsPreCuenta(printer, mozo, piso);

    // Encabezado de la tabla
    _buildTableHeaderPreCuenta( tipoBoucher,printer );

    // Contenido de la tabla
    _buildTableContentPreCuenta(producto, tipoBoucher, printer);

    // Importe total
    if(tipoBoucher != 'Pedido' && tipoBoucher !='Pedidos Actualizados' && tipoBoucher !='Anulado'){
      printer.text('IMPORTE TOTAL: S/$total',
          styles: const PosStyles(bold: true), linesAfter: 1);

      // DNI y RUC
      printer.text('DNI: _ _ _ _ _ _ _ _ _');
      printer.text('RUC: _ _ _ _ _ _ _ _ _', linesAfter: 1);

      // Agradecimiento
      printer.text('******** GRACIAS POR SU VISITA ********',
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    }else if (tipoBoucher =='Anulado'){
      printer.text('');
      printer.text('Motivo de anulacion', styles: const PosStyles(bold: true), linesAfter: 1);
      printer.text('- : ${motivo}');
    }

    printer.feed(2);
    printer.cut();
  }



  void _buildDetailsPreCuenta(NetworkPrinter printer, Usuario mozo, String? piso) {

    String? email = '${mozo.user!.nombreUsuario}';
    String? nomPiso = '${piso}';
    //String nombreUsuario = email != null ? email.substring(0, email.indexOf('@')) : '';
    DateTime now = DateTime.now();
    String horaActual = '${now.hour}:${now.minute}:${now.second}';
    String _twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }
    String fechaActual = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';

    printer.text('Piso: $nomPiso');
    printer.text('Mesero(a): $email');
    printer.text('Hora: $horaActual');
    printer.text('Fecha: $fechaActual');
  }

  void _buildTableHeaderPreCuenta( String tipoBoucher, NetworkPrinter printer) {
    if(tipoBoucher != 'Pedido' && tipoBoucher !='Pedidos Actualizados'){
      printer.row([
        PosColumn(text: 'CANTIDAD', width: 2,styles: const PosStyles(bold: true)),  // 3 de ancho
        PosColumn(text: 'PRODUCTO', width: 6,styles: const PosStyles(bold: true)),  // 6 de ancho
        PosColumn(text: 'P.UNIT', width: 2,styles: const PosStyles(bold: true)),      // 3 de ancho
        PosColumn(text: 'TOTAL', width: 2,styles: const PosStyles(bold: true)),      // 3 de ancho
      ]);
      printer.hr();
    }else{
      printer.row([
        PosColumn(text: 'CANTIDAD', width: 3,styles: const PosStyles(bold: true)),  // 3 de ancho
        PosColumn(text: 'PRODUCTO', width: 6,styles: const PosStyles(bold: true)),  // 6 de ancho
        PosColumn(text: 'NOTA', width: 3,styles: const PosStyles(bold: true)),      // 3 de ancho
      ]);
      printer.hr();
    }

  }


  void _buildTableContentPreCuenta(List<Producto>? producto , String tipoBoucher, NetworkPrinter printer) {
    if(tipoBoucher != 'Pedido' && tipoBoucher !='Pedidos Actualizados'){
      producto?.forEach((producto) {
        printer.row([
          PosColumn(text: '${producto.stock}', width: 2 ),
          PosColumn(text: '${producto.nombreproducto}', width: 6),
          PosColumn(text: '${producto.precioproducto}', width: 2),
          PosColumn(text: '${producto.precioproducto! * producto.stock!}', width: 2),
        ]);
      });
    }else{
      producto?.forEach((producto) {
        if(producto.stock == 0){
          printer.row([
            PosColumn(text: 'Rechazado', width: 3),
            PosColumn(text: '${producto.nombreproducto}', width: 6),
            PosColumn(text: producto.comentario ?? '', width: 3),
          ]);
          printer.hr();
        }else if(producto.stock! < 0){
          printer.row([
            PosColumn(text: '${producto.stock}', width: 3),
            PosColumn(text: '${producto.nombreproducto}', width: 6),
            PosColumn(text: 'excluidos', width: 3),
          ]);
          printer.hr();
        }else{
          if (producto.comentario != null){
            List<String> lines = producto.comentario!.split(';');
            printer.row([
              PosColumn(text: '${producto.stock}', width: 3),
              PosColumn(text: '${producto.nombreproducto}', width: 6),
              PosColumn(text: lines[0].trim(), width: 3),
            ]);
            for (int i = 1; i < lines.length; i++) {
              printer.row([
                PosColumn(text: '', width: 3),
                PosColumn(text: '', width: 6),
                PosColumn(text: lines[i].trim(), width: 3),
              ]);
            }
            printer.hr();
          }else {
            printer.row([
              PosColumn(text: '${producto.stock}', width: 3),
              PosColumn(text: '${producto.nombreproducto}', width: 6),
              PosColumn(text: '', width: 3),
            ]);
            printer.hr();
          }
          //
        }
      });
    }
  }
}

// print(' IMPRESORA COMENTARIO :  ${producto.comentario}');
// if(producto.comentario != null ){
// printer.row([
// PosColumn(text: 'NOTA', width: 3,styles: const PosStyles(bold: true)),
// PosColumn(text: '${producto.comentario}' , width: 9),
// ]);
// printer.hr();
// }else{
// printer.hr();
// }