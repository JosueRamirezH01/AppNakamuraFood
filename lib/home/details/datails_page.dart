import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DetailsPage extends StatefulWidget {
  final List<String> productosSeleccionados;

  const DetailsPage({Key? key, required this.productosSeleccionados}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
          itemCount: widget.productosSeleccionados.length,
          itemBuilder: (_, int index) {
            return Column(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.productosSeleccionados[index],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _addOrRemoveItem(),
                      const SizedBox(width: 5),
                      _iconDelete(),
                      const SizedBox(width: 5),
                       _iconNota(),
                    ],
                  ),
                ),
                if (index != widget.productosSeleccionados.length - 1) const Divider(
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

  Widget debajo() {
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
              child: ElevatedButton(
                  style:  ButtonStyle(
                      elevation: MaterialStateProperty.all(2), backgroundColor: MaterialStateProperty.all(const Color(0xFFFFB500))),
                  onPressed: () {},
                  child: const Text(
                    'Pre Cuenta',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: SizedBox(
                child: Row(
                  children: [
                    Text('TOTAL : ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('S/ 8457.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
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

  Widget _addOrRemoveItem() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (contador > 0) {
              setState(() {
                contador--; // Restar al contador
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8)
                ),
                color: Colors.grey[200]
            ),
            child: const Text('-'),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          color: Colors.grey[200],
          child:  Text(
            contador.toString(),
          )
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              contador++; // Aumentar el contador
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8)
                ),
                color: Colors.grey[200]
            ),
            child: const Text('+'),
          ),
        ),
      ],
    );
  }
}
