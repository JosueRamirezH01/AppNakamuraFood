import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:restauflutter/model/producto.dart';

class Impresora {
  Future<void> printLabel(List<Producto>? producto, int? estado, double total) async {
    String tipoBoucher = '';
    if(estado == 1){
      tipoBoucher = 'Pedido';
    }else if(estado == 2){
      tipoBoucher = 'Pedidos Actualizados';
    }else if(estado == 3){
      tipoBoucher = 'Pre-Cuenta';
    }
    // Crea la instancia de la impresora
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(paper, profile);
    final PosPrintResult res = await printer.connect('192.168.10.182', port: 9100);

    if (res == PosPrintResult.success) {
      testReceipt(producto ,printer, tipoBoucher, total);
      printer.disconnect();
    }

  }

  void testReceipt(List<Producto>? producto, NetworkPrinter printer, String tipoBoucher, double total) {

    // Título de la mesa
    printer.text(tipoBoucher,
        styles: PosStyles(bold: true, align: PosAlign.center));
    printer.text('MESA 1',
        styles: PosStyles(bold: true, align: PosAlign.center));
    printer.hr();

    // Detalles del mesero, hora y fecha
    _buildDetailsPreCuenta(printer);

    // Encabezado de la tabla
    _buildTableHeaderPreCuenta( tipoBoucher,printer );

    // Contenido de la tabla
    _buildTableContentPreCuenta(producto, tipoBoucher, printer);

    // Importe total
    if(tipoBoucher != 'Pedido' && tipoBoucher !='Pedidos Actualizados'){
      printer.text('IMPORTE TOTAL: S/$total',
          styles: PosStyles(bold: true), linesAfter: 1);

      // DNI y RUC
      printer.text('DNI: _ _ _ _ _ _ _ _ _');
      printer.text('RUC: _ _ _ _ _ _ _ _ _', linesAfter: 1);

      // Agradecimiento
      printer.text('******** GRACIAS POR SU VISITA ********',
          styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    }
    printer.feed(2);
    printer.cut();
  }

  void _buildDetailsPreCuenta(NetworkPrinter printer) {
    String? email = 'SUSSAN';
    //String nombreUsuario = email != null ? email.substring(0, email.indexOf('@')) : '';
    DateTime now = DateTime.now();
    String horaActual = '${now.hour}:${now.minute}:${now.second}';
    String _twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }
    String fechaActual = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';

    printer.text('Piso: PISO 1');
    printer.text('Mesero(a): $email');
    printer.text('Hora: $horaActual');
    printer.text('Fecha: $fechaActual');
  }

  void _buildTableHeaderPreCuenta( String tipoBoucher, NetworkPrinter printer) {
    if(tipoBoucher != 'Pedido' && tipoBoucher !='Pedidos Actualizados'){
      printer.row([
        PosColumn(text: 'CANTIDAD', width: 2,styles: PosStyles(bold: true)),  // 3 de ancho
        PosColumn(text: 'PRODUCTO', width: 6,styles: PosStyles(bold: true)),  // 6 de ancho
        PosColumn(text: 'P.UNIT', width: 2,styles: PosStyles(bold: true)),      // 3 de ancho
        PosColumn(text: 'TOTAL', width: 2,styles: PosStyles(bold: true)),      // 3 de ancho
      ]);
    }else{
      printer.row([
        PosColumn(text: 'CANTIDAD', width: 3,styles: PosStyles(bold: true)),  // 3 de ancho
        PosColumn(text: 'PRODUCTO', width: 6,styles: PosStyles(bold: true)),  // 6 de ancho
        PosColumn(text: 'NOTA', width: 3,styles: PosStyles(bold: true)),      // 3 de ancho
      ]);
    }

  }


  void _buildTableContentPreCuenta(List<Producto>? producto , String tipoBoucher, NetworkPrinter printer) {
    if(tipoBoucher != 'Pedido' && tipoBoucher !='Pedidos Actualizados'){
      producto?.forEach((producto) {
        printer.row([
          PosColumn(text: '${producto.stock}', width: 2),
          PosColumn(text: '${producto.nombreproducto}', width: 6),
          PosColumn(text: '${producto.precioproducto}', width: 2),
          PosColumn(text: '${producto.precioproducto! * producto.stock!}', width: 2),
        ]);
      });
    }else{
      producto?.forEach((producto) {
        printer.row([
          PosColumn(text: '${producto.stock}', width: 3),
          PosColumn(text: '${producto.nombreproducto}', width: 6),
          PosColumn(text: producto.comentario ?? '', width: 3),
        ]);
      });
    }
  }
}