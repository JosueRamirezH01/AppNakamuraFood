
import 'package:flutter/material.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        toolbarHeight: 100,
        backgroundColor: const Color(0xFF99CFB5),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 100, top: 10),
            child: ElevatedButton.icon(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.deepOrange)),
                onPressed: (){
                },
                icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white,),
                label: const Text("SALIR", style: TextStyle(fontSize: 18, color: Colors.white),)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10,right: 10),
            child: ElevatedButton(
                onPressed: (){
                },
                 child: const Text('MESA 4', style: TextStyle(fontSize: 18)),),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
              _textFieldSearch()
          ],
        ),
      )

    );
  }
  Widget _textFieldSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        //onChanged: _con.onChangeText,
        decoration: InputDecoration(
            hintText: 'Buscar',
            suffixIcon: const Icon(
                Icons.search,
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
}
