
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<String> items = [
   '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'
  ];
  List<String> mesa =['Mesa 1', 'Mesa 2', 'Mesa 3', 'Mesa 4'];
  String? selectedMesa;
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
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

  Widget contenido(){
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.height * 0.46,
        decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(15)), border: Border.all()),
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, int index) {
              return ListTile(
              title: Text(items[index]),
            );
    },
      ),
    )
    );
  }

  Widget cabecera(){
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 50),
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),color: Color(0xFF99CFB5)),
        child: Row(
          children: [
            const SizedBox(width: 5),

            Expanded(
                child: ElevatedButton(
                  style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(2),
                    backgroundColor: MaterialStatePropertyAll(Color(0xFF4C95DD))
                  ),
                    onPressed: (){
                    mostrarMesa();
                    },
                    child: const Text(
                      'Cambiar Mesa',style: TextStyle(color: Colors.white, fontSize: 16),
                    )),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                  style: const ButtonStyle(
                      elevation: MaterialStatePropertyAll(2),
                      backgroundColor: MaterialStatePropertyAll(Color(0xFF634FD2))
                  ),
                  onPressed: (){},
                  child: const Text(
                      'Actualizar',style: TextStyle(color: Colors.white, fontSize: 16)
                  )),
            ),
            const SizedBox(width: 5),

          ],
        ),
      ),
    );
  }

  Future<String?> mostrarMesa(){
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

  Widget debajo(){
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),color: Color(0xFF99CFB5)),
        child: Row(
          children: [
            const SizedBox(width: 5),
            Expanded(
              child: ElevatedButton(
                  style: const ButtonStyle(
                      elevation: MaterialStatePropertyAll(2),
                      backgroundColor: MaterialStatePropertyAll(Color(0xFFFFB500))
                  ),
                  onPressed: (){},
                  child: const Text(
                    'Pre Cuenta',style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child:  SizedBox(
                child: Row(
                  children: [
                    Text('TOTAL : ',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('S/ 8457.00',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
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
}
