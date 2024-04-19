import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restauflutter/utils/shared_pref.dart';

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


  @override
  void initState() {
    super.initState();
    _loadPrinters(); // Cargar las impresoras al inicializar la página
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
      _printer2Controller.text = printer2IP;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Configurar Impresoras'),
          elevation: 5,

        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form( // Envolver la columna en un Form
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Cocina',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPrinterInputField(_printer1Controller),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Bar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _showBarPrinter,
                        onChanged: (value) {
                          setState(() {
                            _showBarPrinter = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_showBarPrinter) _buildPrinterInputField(_printer2Controller),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) { // Validar el formulario
                        _savePrinters();
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                  Spacer(),
                  Divider(),
                  const SizedBox(height: 16),
                  iconCerrar()
                ],
              ),
            ),
          ),
    );
  }

  Widget iconCerrar(){
    return Row(
      children: [
        IconButton(
          onPressed: (){
            _sharedPref.remove('user_data');
            _sharedPref.remove('categorias');
            _sharedPref.remove('productos');
            _sharedPref.remove('ipBar');
            Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
          },
          icon: Icon(Icons.logout_outlined),
         style: ButtonStyle(backgroundColor:MaterialStatePropertyAll(Colors.grey)),
        ),
        SizedBox(width: 20),
        Text(
          'Cerrar sesión',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Color del texto
        ),
      ],
    );
  }
  Widget _buildPrinterInputField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Dirección IP',
        hintText: 'Ej. 192.168.1.1',
        border: OutlineInputBorder(),

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
  void agregarMsj(String mensaje){
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  void _savePrinters() {
    final String printer1IP = _printer1Controller.text;
    final String printer2IP = _printer2Controller.text;

    print('Impresora 1 (Cocina): $printer1IP');
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
