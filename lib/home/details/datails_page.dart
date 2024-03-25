
import 'package:flutter/material.dart';
class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<String> items = [
   '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'
  ];
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            cabecera(),
            SizedBox(height: 10),
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
        height: MediaQuery.of(context).size.height * 0.74,
        width: MediaQuery.of(context).size.height * 0.46,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), border: Border.all()),
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
        padding: const EdgeInsets.only(left: 20),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.08,
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),color: Color(0xFF99CFB5)),
        child: Row(
          children: [
              ElevatedButton(
                style: const ButtonStyle(
                  elevation: MaterialStatePropertyAll(2),
                  backgroundColor: MaterialStatePropertyAll(Color(0xFF4C95DD))
                ),
                  onPressed: (){},
                  child: const Text(
                    'Cambiar Mesa',style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            const SizedBox(width: 20),
            ElevatedButton(
                style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(2),
                    backgroundColor: MaterialStatePropertyAll(Color(0xFF634FD2))
                ),
                onPressed: (){},
                child: const Text(
                    'Actualizar',style: TextStyle(color: Colors.white, fontSize: 16)
                ))
          ],
        ),
      ),
    );
  }


  Widget debajo(){
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.only(left: 20),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)),color: Color(0xFF99CFB5)),
        child: Row(
          children: [
            ElevatedButton(
                style: const ButtonStyle(
                    elevation: MaterialStatePropertyAll(2),
                    backgroundColor: MaterialStatePropertyAll(Color(0xFFFFB500))
                ),
                onPressed: (){},
                child: const Text(
                  'Pre Cuenta',style: TextStyle(color: Colors.white, fontSize: 16),
                )),
            const SizedBox(width: 20),
            Text('TOTAL : ',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('S/ 8457.00',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
