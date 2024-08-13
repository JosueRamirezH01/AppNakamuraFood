import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restauflutter/utils/shared_pref.dart';

import '../model/producto.dart';
import '../model/usuario.dart';

class TicketBluetooth {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  SharedPref _pref = SharedPref();
  bool conexion = false;

  Future<void> printLabelBluetooth(List<Producto>? producto, int estado, double total, String? nombreMesa, Usuario usuario, String? piso, String motivo) async {
    String tipoBoucher = '';
    if(estado == 1){
      tipoBoucher = 'Pedido';
    }else if(estado == 2){
      tipoBoucher = 'Pedidos Actualizados';
    }else if(estado == 3) {
      tipoBoucher = 'Pre-Cuenta';
    }else if(estado == 4){
     tipoBoucher = 'Anulado';
    }

    testReceipt(producto, tipoBoucher, total, nombreMesa, usuario, piso, motivo);
  }


  Future<void> testReceipt(List<Producto>? producto, String tipoBoucher, double total, String? nombreMesa, Usuario mozo, String? piso, String motivo) async {
    conexion = await _pref.read('conexionBluetooth');
    if (conexion) {
      Map<String, dynamic> config = Map();

      List<LineText> list = [];

      // Título del comprobante
      if (tipoBoucher == 'Anulado') {
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: tipoBoucher,
            weight: 1,
            align: LineText.ALIGN_CENTER,
            fontZoom: 2,
            linefeed: 1));
      } else {
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: tipoBoucher,
            weight: 1,
            align: LineText.ALIGN_CENTER,
            linefeed: 1));
      }

      // Nombre de la mesa
      list.add(LineText(type: LineText.TYPE_TEXT,
          content: nombreMesa ?? '',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT,
          content: '----------------------------------------',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));

      // Detalles del mesero y hora
      String email = '${mozo.user?.nombreUsuario ?? ''}';
      String nomPiso = '${piso ?? ''}';
      DateTime now = DateTime.now();
      String horaActual = '${now.hour}:${now.minute}:${now.second}';
      String fechaActual = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}';

      list.add(LineText(type: LineText.TYPE_TEXT,
          content: 'Piso: $nomPiso',
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT,
          content: 'Mesero(a): $email',
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT,
          content: 'Hora: $horaActual',
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT,
          content: 'Fecha: $fechaActual',
          align: LineText.ALIGN_LEFT,
          linefeed: 1));

      // Encabezado de la tabla
      if (tipoBoucher != 'Pedido' && tipoBoucher != 'Pedidos Actualizados') {
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'CAN.',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            x: 0,
            relativeX: 0,
            linefeed: 0));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'PRODUCTO',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            x: 50,
            relativeX: 0,
            linefeed: 0));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'P.UNIT',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            x: 400,
            relativeX: 0,
            linefeed: 0));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'TOTAL',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            x: 500,
            relativeX: 0,
            linefeed: 1));
      } else {
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'CAN.',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            x: 0,
            relativeX: 0,
            linefeed: 0));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'PRODUCTO',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            x: 50,
            relativeX: 0,
            linefeed: 0));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'NOTA',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            x: 400,
            relativeX: 0,
            linefeed: 1));
      }

      // Contenido de la tabla
      // Contenido de la tabla
      if (tipoBoucher != 'Pedido' && tipoBoucher != 'Pedidos Actualizados') {
        for (int i = 0; i < (producto?.length ?? 0); i++) {
          var prod = producto![i];
          list.add(LineText(type: LineText.TYPE_TEXT,
              content: '${prod.stock}',
              align: LineText.ALIGN_LEFT,
              x: 0,
              relativeX: 0,
              linefeed: 0));
          list.add(LineText(type: LineText.TYPE_TEXT,
              content: '${prod.nombreproducto}',
              align: LineText.ALIGN_LEFT,
              x: 50,
              relativeX: 0,
              linefeed: 0));
          list.add(LineText(type: LineText.TYPE_TEXT,
              content: '${prod.precioproducto}',
              align: LineText.ALIGN_LEFT,
              x: 400,
              relativeX: 0,
              linefeed: 0));
          list.add(LineText(type: LineText.TYPE_TEXT,
              content: '${prod.precioproducto! * prod.stock!}',
              align: LineText.ALIGN_LEFT,
              x: 500,
              relativeX: 0,
              linefeed: 1));

          // Línea de separación solo si no es el último producto
          if (i < (producto.length - 1)) {
            list.add(LineText(type: LineText.TYPE_TEXT,
                content: '----------------------------------------',
                align: LineText.ALIGN_CENTER,
                linefeed: 1));
          }
        }
      } else {
        for (int i = 0; i < (producto?.length ?? 0); i++) {
          var prod = producto![i];
          if (prod.stock == 0) {
            list.add(LineText(type: LineText.TYPE_TEXT,
                content: 'Rechazado',
                weight: 1,
                align: LineText.ALIGN_LEFT,
                x: 0,
                relativeX: 0,
                linefeed: 0));
            list.add(LineText(type: LineText.TYPE_TEXT,
                content: '${prod.nombreproducto}',
                align: LineText.ALIGN_LEFT,
                x: 50,
                relativeX: 0,
                linefeed: 0));
            list.add(LineText(type: LineText.TYPE_TEXT,
                content: prod.comentario ?? '',
                align: LineText.ALIGN_LEFT,
                x: 400,
                relativeX: 0,
                linefeed: 1));
          } else if (prod.stock! < 0) {
            list.add(LineText(type: LineText.TYPE_TEXT,
                content: '${prod.stock}',
                align: LineText.ALIGN_LEFT,
                x: 0,
                relativeX: 0,
                linefeed: 0));
            list.add(LineText(type: LineText.TYPE_TEXT,
                content: '${prod.nombreproducto}',
                align: LineText.ALIGN_LEFT,
                x: 50,
                relativeX: 0,
                linefeed: 0));
            list.add(LineText(type: LineText.TYPE_TEXT,
                content: 'excluidos',
                align: LineText.ALIGN_LEFT,
                x: 400,
                relativeX: 0,
                linefeed: 1));
          } else {
            if (prod.comentario != null) {
              List<String> lines = prod.comentario!.split(';');
              list.add(LineText(type: LineText.TYPE_TEXT,
                  content: '${prod.stock}',
                  align: LineText.ALIGN_LEFT,
                  x: 0,
                  relativeX: 0,
                  linefeed: 0));
              list.add(LineText(type: LineText.TYPE_TEXT,
                  content: '${prod.nombreproducto}',
                  align: LineText.ALIGN_LEFT,
                  x: 50,
                  relativeX: 0,
                  linefeed: 0));
              list.add(LineText(type: LineText.TYPE_TEXT,
                  content: lines[0].trim(),
                  align: LineText.ALIGN_LEFT,
                  x: 400,
                  relativeX: 0,
                  linefeed: 1));
              for (int j = 1; j < lines.length; j++) {
                list.add(LineText(type: LineText.TYPE_TEXT,
                    content: '',
                    align: LineText.ALIGN_LEFT,
                    x: 0,
                    relativeX: 0,
                    linefeed: 0));
                list.add(LineText(type: LineText.TYPE_TEXT,
                    content: '',
                    align: LineText.ALIGN_LEFT,
                    x: 200,
                    relativeX: 0,
                    linefeed: 0));
                list.add(LineText(type: LineText.TYPE_TEXT,
                    content: lines[j].trim(),
                    align: LineText.ALIGN_LEFT,
                    x: 400,
                    relativeX: 0,
                    linefeed: 1));
              }
            } else {
              list.add(LineText(type: LineText.TYPE_TEXT,
                  content: '${prod.stock}',
                  align: LineText.ALIGN_LEFT,
                  x: 0,
                  relativeX: 0,
                  linefeed: 0));
              list.add(LineText(type: LineText.TYPE_TEXT,
                  content: '${prod.nombreproducto}',
                  align: LineText.ALIGN_LEFT,
                  x: 50,
                  relativeX: 0,
                  linefeed: 0));
              list.add(LineText(type: LineText.TYPE_TEXT,
                  content: '',
                  align: LineText.ALIGN_LEFT,
                  x: 400,
                  relativeX: 0,
                  linefeed: 1));
            }
          }

          // Línea de separación solo si no es el último producto
          if (i < (producto.length - 1)) {
            list.add(LineText(type: LineText.TYPE_TEXT,
                content: '----------------------------------------',
                align: LineText.ALIGN_CENTER,
                linefeed: 1));
          }
        }
      }


      // Importe total
      if (tipoBoucher != 'Pedido' && tipoBoucher != 'Pedidos Actualizados' &&
          tipoBoucher != 'Anulado') {
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'IMPORTE TOTAL: S/$total',
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'DNI: _ _ _ _ _ _ _ _ _',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'RUC: _ _ _ _ _ _ _ _ _',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: '******** GRACIAS POR SU VISITA ********',
            weight: 1,
            align: LineText.ALIGN_CENTER,
            linefeed: 1));
      } else if (tipoBoucher == 'Anulado') {
        list.add(LineText(type: LineText.TYPE_TEXT, content: '', linefeed: 1));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: 'Motivo de anulación',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
        list.add(LineText(type: LineText.TYPE_TEXT,
            content: '- : ${motivo}',
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
      }

      list.add(LineText(type: LineText.TYPE_TEXT,
          content: '**********************************************',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));

      // Aquí puedes cargar la imagen si es necesario.
      // ByteData data = await rootBundle.load("assets/img/cart.png");
      // List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // String base64Image = base64Encode(imageBytes);
      // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

      await bluetoothPrint.printReceipt(config, list);
    }else{
      mostrarMensaje('No hay conexion con un dispositivo bluetooth');
    }
  }
  void mostrarMensaje(String mensaje) {
    Fluttertoast.showToast(
      msg: mensaje,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
