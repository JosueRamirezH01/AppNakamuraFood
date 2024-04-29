import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:restauflutter/services/login_service.dart';
import 'package:restauflutter/utils/shared_pref.dart';

import '../../model/mozo.dart';
import '../../services/producto_service.dart';

class AjustesPage extends StatefulWidget {
  @override
  _AjustesPageState createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  TextEditingController _printer1Controller = TextEditingController();
  TextEditingController _printer2Controller = TextEditingController();
  bool _showBarPrinter = false;
  final _formKey = GlobalKey<FormState>(); // Agregar GlobalKey<FormState>
  final SharedPref _sharedPref = SharedPref();
  var prod = ProductoServicio();
  Mozo mozo = Mozo();
  SharedPref _pref = SharedPref();

  Future<void> UserShared() async {
    final dynamic userData = await _pref.read('user_data');
    if (userData != null) {
      final Map<String, dynamic> userDataMap = json.decode(userData);
      mozo = Mozo.fromJson(userDataMap);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPrinters(); // Cargar las impresoras al inicializar la página
    UserShared();
  }

  @override
  void dispose() {
    _printer1Controller.dispose();
    _printer2Controller.dispose();
    super.dispose();
  }

  void _loadPrinters() async {
    final printer1IP = await _sharedPref.read('ipCocina') ?? '';
    final printer2IP = await _sharedPref.read('ipBar') ?? '';

    setState(() {
      _printer1Controller.text = printer1IP;
      if (printer2IP == '') {
        _printer2Controller.text = printer2IP;
      } else {
        _showBarPrinter = true;
        _printer2Controller.text = printer2IP;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracion'),
        elevation: 5,
      ),
      body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Color.fromRGBO(217, 217, 217, 0.8),
                          ),
                          margin: EdgeInsets.all(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Configurar Impresoras',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Divider(),
                                Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: const Text(
                                    'Cocina',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _buildPrinterInputField(_printer1Controller),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Bar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Switch(
                                        activeColor: Color(0xFFFF562F),
                                        inactiveThumbColor: Colors.grey, // Color del interruptor cuando está inactivo
                                        inactiveTrackColor: Colors.black, // Color del riel cuando está inactivo
                                        activeTrackColor: Colors.black,
                                        value: _showBarPrinter,
                                        onChanged: (value) {
                                          print(value);
                                          setState(() {
                                            _showBarPrinter = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                if (_showBarPrinter)
                                  Container(margin: EdgeInsets.only(top: 10,bottom: 20),child: _buildPrinterInputField(_printer2Controller)),

                                ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.all(
                                          const Color(0xFFFF562F))),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _savePrinters();
                                    }
                                  },
                                  child: const Text(
                                    'Guardar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Color.fromRGBO(217, 217, 217, 0.8),
                          ),
                          margin: EdgeInsets.all(20),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, left: 20,top: 10, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Datos',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Actualizar Producto',
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color(0xFFFF562F))),
                                        onPressed: () {
                                          actualziarCategoria();
                                          actualziarProducto();
                                          agregarMsj('Se actualizo correctamente los productos');
                                        },
                                        child: Text('Actualizar', style: TextStyle(color: Colors.white)))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: iconCerrar(),
              )
            ],
          )),
    );
  }

  Future<void> actualziarProducto() async {
    await prod.consultarProductos(context, mozo.id_establecimiento!);
  }

  Future<void> actualziarCategoria() async {
    await prod.consultarCategorias(context, mozo.id_establecimiento!);
  }

  Widget iconCerrar() {
    return GestureDetector(
      onTap: () {
        _sharedPref.remove('user_data');
        _sharedPref.remove('categorias');
        _sharedPref.remove('productos');
        _sharedPref.remove('ipBar');
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 30),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.logout_outlined,
                size: 30,
              ),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(20)),
            ),
            Expanded(
              child: Text(
                'Cerrar sesión',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold), // Color del texto
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrinterInputField(TextEditingController controller) {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          labelText: 'Dirección IP',
          hintText: 'Ej. 192.168.1.1',
          border:OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.black
              )
          ),
          floatingLabelStyle: TextStyle(fontSize: 15, color: Color(0xFF000000)),
          hintStyle: TextStyle(
              fontSize: 15,
              color: Color(0xFF000000)
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
                color: Color(0xFF000000),
                width: 2
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
                color: Color(0xFF000000),
                width: 2
            ),
          ),
          contentPadding: EdgeInsets.all(10),
          prefixIcon: Icon(Icons.print, color: Colors.black),
          // error
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
                color: Color(0xFF000000),
                width: 2
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
                color: Colors.red,
                width: 2
            ),
          )
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,3}){0,3}$')),
        _IPTextInputFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa una dirección IP';
        }
        final ipParts = value.split('.');
        if (ipParts.length != 4) {
          return 'La dirección IP debe tener cuatro partes separadas por puntos';
        }
        for (final part in ipParts) {
          final intPart = int.tryParse(part);
          if (intPart == null || intPart < 0 || intPart > 255) {
            return 'Cada parte de la dirección IP debe ser un número entre 0 y 255';
          }
        }
        return null;
      },
    );
  }

  void agregarMsj(String mensaje) {
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _savePrinters() {
    final String printer1IP = _printer1Controller.text;
    final String printer2IP = _printer2Controller.text;
    _sharedPref.save('ipCocina', printer1IP);
    if (_showBarPrinter) {
      _sharedPref.save('ipBar', printer2IP);
    }
    agregarMsj('Se guardo correctamente');
    // Aquí puedes guardar las direcciones IP en la configuración de la aplicación
    // o realizar cualquier otra acción necesaria con ellas.
  }
}

class _IPTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final regExp = RegExp(r'^\d{0,3}(\.\d{0,3}){0,3}$');
    final isValid = regExp.hasMatch(newValue.text);
    return isValid ? newValue : oldValue;
  }
}
