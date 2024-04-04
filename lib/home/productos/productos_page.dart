

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:restauflutter/home/details/datails_page.dart';
import 'package:restauflutter/home/productos/producto_controller.dart';
import 'package:restauflutter/model/producto.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}



class _ProductosPageState extends State<ProductosPage> {
  int estado = 1;

 List<Producto>? productosSeleccionados = [];

  final ProductoController _con = ProductoController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
          length: _con.categorias.length,
          child: Scaffold(
          appBar: AppBar(
            elevation: 3,
            toolbarHeight: 100,
            backgroundColor: const Color(0xFF99CFB5),
            actions: [
              const SizedBox(width: 5),
              Expanded(
                child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton.icon(
                            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.deepOrange)),
                              onPressed: (){
                              Navigator.pushNamed(context, 'home');
                              },
                              icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white,),
                              label: const Text("SALIR", style: TextStyle(fontSize: 18, color: Colors.white),)),
                        ),
              ),
              const SizedBox(width: 50),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: (){
                    },
                    child: const Text('MESA 4', style: TextStyle(fontSize: 18)),),
                ),
              ),
              const SizedBox(width: 5)
            ],
            bottom: TabBar(
              isScrollable: true,
              tabs: List<Widget>.generate(_con.categorias.length, (index) {
                return Tab(
                  child: Text(_con.categorias[index].nombre ?? ''),
                );
              }),
              onTap: (index) async {
                List<Producto> productosCategoria = await _con.getProductosPorCategoria(_con.categorias[index].id);
                setState(() {
                  _con.productos = productosCategoria;
                });
              },
            ),
          ),
          body:  Column(
            children: [
              const SizedBox(height: 10),
              _textFieldSearch(),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  children: _con.categorias.map((categoria)  {
                    return  GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7
                        ),
                        itemCount: _con.productos.length,
                        itemBuilder: (_, index) {
                          if (index < _con.productos.length) {
                            Producto producto = _con.productos[index];
                            return _cardProduct(producto);
                          } else {
                            return const SizedBox(); // Otra opción es devolver un widget vacío si el índice está fuera de rango
                          }
                        }
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
            floatingActionButton: Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    pedido(productosSeleccionados);
                  },
                  child: const Row(
                    children: [
                      Text('CANTIDAD'),
                      SizedBox(width: 30),
                      Text('PRECIO')
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
          ),

    );
  }



  Future pedido(Producto producto){
    return showCupertinoModalBottomSheet(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.87,
            child:  DetailsPage(productosSeleccionados: producto, estado: estado),
          ),
        );
      },
    );
  }
 Widget _cardProduct(Producto producto) {
   return GestureDetector(
     onTap: () {
       setState(() {
         productosSeleccionados?.add(producto);
       });
       agregarMsj();
     },
     child: SizedBox(
       child: Card(
         elevation: 3.0,
         shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(15)
         ),
         child: Stack(
           children: [
             Positioned(
                 bottom: double.minPositive,
                 right: -1.0,
                 child: Container(
                   width: 40,
                   height: 40,
                   decoration: const BoxDecoration(
                       color: Colors.green,
                       borderRadius: BorderRadius.only(
                         bottomLeft: Radius.circular(10),
                         topLeft: Radius.circular(15),
                       )
                   ),
                   child: const Icon(Icons.add, color: Colors.white,),
                 )
             ),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Container(
                   height: MediaQuery.of(context).size.height * 0.2,
                   width: MediaQuery.of(context).size.width,
                   padding: const EdgeInsets.only(left: 10, right: 10),
                   child: const FadeInImage(
                     image: AssetImage('assets/img/arrozconpollo.jpeg'),
                     fit: BoxFit.contain,
                     fadeInDuration: Duration(milliseconds: 50),
                     placeholder: AssetImage('assets/img/no-image.png'),
                   ),
                 ),
                 Container(
                   margin: const EdgeInsets.symmetric(horizontal: 20),
                   height: 40,
                   child:  Text(
                     producto.nombreproducto ?? 'Nombre no disponible',
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                     style: const TextStyle(
                         fontSize: 15,
                         fontFamily: 'NimbusSans'
                     ),
                   ),
                 ),
                 const SizedBox(height: 10),
                 Container(
                   margin: const EdgeInsets.symmetric(horizontal: 20),
                   child: Text(
                     'S/ ${producto.precioproducto ?? 'Precio no disponible'} ' ,
                     style: const TextStyle(
                         fontSize: 15,
                         fontWeight: FontWeight.bold,
                         fontFamily: 'NimbusSans'
                     ),
                   ),
                 )
               ],
             )
           ],
         ),
       ),
     ),
   );
 }


  Widget _textFieldSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: _con.onChangeText,
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
  void agregarMsj(){
    Fluttertoast.showToast(
        msg: "Se Guardo correctamente a Pre-cuenta",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  void refresh(){
    setState(() {});
  }
}
