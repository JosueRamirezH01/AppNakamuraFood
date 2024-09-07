import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:restauflutter/home/details/datails_page.dart';
import 'package:restauflutter/home/productos/producto_controller.dart';
import 'package:restauflutter/model/producto.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> with TickerProviderStateMixin {
  int estado = 1;
  int? idPedido;
  List<Producto>? productosSeleccionados = [];
  final ProductoController _con = ProductoController();

  int selectedIndex = 0;
  late TabController _tabController;
  late PageController _pageController;
  final FocusNode _productoFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
    refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        int crossAxisCount = 2;
        if (screenWidth > 1200) {
          crossAxisCount = 4;
        } else if (screenWidth > 800) {
          crossAxisCount = 4;
        } else if (screenWidth > 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }
        return DefaultTabController(
          length: _con.categorias.length,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 3,
              toolbarHeight: 100,
              // backgroundColor: const Color(0xFF99CFB5),
              actions: [
                Container(
                  margin: EdgeInsets.only(top: 10, left: 15),
                  child: ElevatedButton.icon(
                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.deepOrange)),
                      //tp2
                      onPressed: () {
                        //Navigator.pushNamed(context, 'home');
                       Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
                       },
                      icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white,),
                      label: const Text("SALIR", style: TextStyle(fontSize: 18, color: Colors.white),)
                  ),
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(top: 10, right: 15),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[300]!),
                    ),
                    onPressed: (){
                    },
                    child:  Text('${_con.mesa.nombreMesa}', style: TextStyle(fontSize: 18,color: Colors.black)),),
                ),
                SizedBox(width: 5)
              ],
            ),
            body: crossAxisCount > 3 ? Row(
              children: [
                Container(
                  margin: EdgeInsets.only(top : 10 ,bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(width: 2.5)),
                  ),
                  width: MediaQuery.of(context).size.width * 0.60,
                  // color: Colors.blue, // Color de ejemplo
                  child: Column(
                    children: [
                      Container(margin: EdgeInsets.only( top: 20 ,bottom: 20) ,child: _textFieldSearch()),
                      Padding(
                            padding: const EdgeInsets.only(right: 15,left: 15),
                            child: TabBar(
                              tabAlignment: TabAlignment.start,
                              isScrollable: true,
                              controller: _tabController,
                              indicator: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),border: Border.all(width: 2), color: Color(0xFF99cfb5)),
                              indicatorSize: TabBarIndicatorSize.tab,
                              padding: EdgeInsets.only(bottom: 6),
                              labelStyle: TextStyle(fontWeight: FontWeight.bold),
                              tabs: List<Widget>.generate(_con.categorias.length, (index) {
                                return Tab(
                                  child: Text(_con.categorias[index].nombre ?? ''),
                                );
                              }),
                              onTap: (index) async {
                                _productoFocus.unfocus();
                                _pageController.animateToPage(
                                  index,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                List<Producto> productosCategoria = await _con.getProductosPorCategoria(_con.categorias[index]);
                                setState(() {
                                  _con.productos = productosCategoria;
                                });
                              },
                            ),
                          ),
                      Expanded(
                        child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) async {
                          _tabController.animateTo(index);
                          List<Producto> productosCategoria = await _con.getProductosPorCategoria(_con.categorias[index]);
                          setState(() {
                            _con.productos = productosCategoria;
                          });
                        },
                        itemCount: _con.categorias.length,
                        itemBuilder: (context, index) {
                          double screenWidth = MediaQuery.of(context).size.width;

                                  int crossAxisCount = 2;
                                  if (screenWidth > 1200) {
                                    crossAxisCount = 4;
                                  } else if (screenWidth > 800) {
                                    crossAxisCount = 4;
                                  } else if (screenWidth > 600) {
                                    crossAxisCount = 3;
                                  } else {
                                    crossAxisCount = 2;
                                  }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio:  crossAxisCount == 2 || crossAxisCount == 3 ? 0.7 : 0.68,
                        ),
                        itemCount: _con.productos.length,
                        itemBuilder: (_, index) {
                          if (index < _con.productos.length) {
                            Producto producto = _con.productos[index];
                            return _cardProduct(producto);
                          } else {
                            return const SizedBox(); // Otra opción es devolver un widget vacío si el índice está fuera de rango
                          }
                        },
                      );
                    },
                  ),
                ),
                      // Center(child: Text("70% de la pantalla")),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top : 10 ,bottom: 10),
                  width: MediaQuery.of(context).size.width * 0.4,
                  // color: Colors.green, // Color de ejemplo
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.only(right: 10, left: 10),
                          height: MediaQuery.of(context).size.height * 0.773,
                          child: DetailsPage(
                            items_independientes:
                            _con.items_independientes,
                            productosSeleccionados: _con.productosSeleccionados,
                            idPedido: idPedido ?? _con.IDPEDIDO,
                            mesa: _con.mesa,
                            detallePedidoLista: _con.detalle_pedido,
                            onProductosActualizados: _actualizarProductosSeleccionados,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ) : Column(
              children: [
                SizedBox(height: 10),
                _textFieldSearch(),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 15,left: 15),
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    controller: _tabController,
                    indicator: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),border: Border.all(width: 2), color: Color(0xFF99cfb5)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    padding: EdgeInsets.only(bottom: 6),
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: List<Widget>.generate(_con.categorias.length, (index) {
                      return Tab(
                        child: Text(_con.categorias[index].nombre ?? ''),
                      );
                    }),
                    onTap: (index) async {
                      _productoFocus.unfocus();
                      _pageController.animateToPage(
                        index,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      List<Producto> productosCategoria = await _con.getProductosPorCategoria(_con.categorias[index]);
                      setState(() {
                        _con.productos = productosCategoria;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) async {
                      _tabController.animateTo(index);
                      List<Producto> productosCategoria = await _con.getProductosPorCategoria(_con.categorias[index]);
                      setState(() {
                        _con.productos = productosCategoria;
                      });
                    },
                    itemCount: _con.categorias.length,
                    itemBuilder: (context, index) {
                      double screenWidth = MediaQuery.of(context).size.width;

                            int crossAxisCount = 2;
                            if (screenWidth > 1200) {
                              crossAxisCount = 5;
                            } else if (screenWidth > 800) {
                              crossAxisCount = 4;
                            } else if (screenWidth > 600) {
                              crossAxisCount = 3;
                            } else {
                              crossAxisCount = 2;
                            }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio:  crossAxisCount == 2 || crossAxisCount == 3 ? 0.7 : 1,
                        ),
                        itemCount: _con.productos.length,
                        itemBuilder: (_, index) {
                          if (index < _con.productos.length) {
                            Producto producto = _con.productos[index];
                            return _cardProduct(producto);
                          } else {
                            return const SizedBox(); // Otra opción es devolver un widget vacío si el índice está fuera de rango
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: crossAxisCount > 3 ?  Container() : Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[300]!),
                  ),
                  onPressed: () async {
                    _productoFocus.unfocus();
                    pedido();
                  },
                  child:  Row(
                    children: [
                      Expanded(child: cantidad(),flex: 2,),
                      Spacer(flex: 1,),
                      Expanded(child: precio(), flex: 0,),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: crossAxisCount > 3 ? null : FloatingActionButtonLocation.miniCenterFloat,
          ),
        );
      },
    );
  }

  Widget precio() {
    double total = calcularTotal();
    return Text('S/ ${total.toStringAsFixed(2)}', style: TextStyle(color: Colors.black),);
  }

  Widget cantidad() {
    int cantidadProductos = calcularCantidadProductosSeleccionados();
    return Text('CANTIDAD: $cantidadProductos', style: TextStyle(color: Colors.black),);
  }

  double calcularTotal() {
    double total = 0;
    if (_con.productosSeleccionados != null) {
      for (Producto producto in _con.productosSeleccionados!) {
        print('PRECIO ---- --- ${producto.precioproducto.runtimeType}');
        total += (producto.precioproducto ?? 0) * (producto.stock ?? 0);
      }
    }
    return total;
  }

  int calcularCantidadProductosSeleccionados() {
    int cantidad = 0;
    if (_con.productosSeleccionados != null) {
      for (Producto producto in _con.productosSeleccionados!) {
        cantidad += producto.stock ?? 0;
      }
    }
    return cantidad;
  }

  void _actualizarProductosSeleccionados(List<Producto>? nuevosProductosSeleccionados) {
    setState(() {
      _con.productosSeleccionados = nuevosProductosSeleccionados;
    });
  }

  Future pedido() async {
    //List<Producto>? productosSeleccionadosCopy = List.from(_con.productosSeleccionados ?? []);
    int? idPedidoNuevo = await showCupertinoModalBottomSheet<int>(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.87,
            child: DetailsPage(
              items_independientes: _con.items_independientes,
              productosSeleccionados: _con.productosSeleccionados,
              idPedido: idPedido ?? _con.IDPEDIDO,
              mesa: _con.mesa,
              detallePedidoLista: _con.detalle_pedido,
              onProductosActualizados: _actualizarProductosSeleccionados,
            ),
          ),
        );
      },
    );

    if (idPedidoNuevo != null) {
      setState(() {
        idPedido = idPedidoNuevo;
      });
      // Haz lo que necesites con el valor de idPedido, por ejemplo, imprimirlo
    }
    print('-------------Valor de IDPEDIDO: $idPedido');
  }

  Widget _cardProduct(Producto producto) {
    return GestureDetector(
      // onTap: () {
      //   if (_con.items_independientes == true) {
      //     _productoFocus.unfocus();
      //     setState(() {
      //       if (_con.mesa.estadoMesa != 2) {
      //         // Agregar el producto directamente como un nuevo producto
      //         _con.productosSeleccionados?.add(producto);
      //
      //         // Muestra un mensaje de confirmación
      //         _con.agregarMsj(
      //             '${producto.nombreproducto} se ha añadido a la lista.');
      //         print('Productos seleccionados:');
      //         _con.productosSeleccionados?.forEach((prod) {
      //           print(prod.toJson());
      //         });
      //       } else {
      //         _con.mostrarMensaje(
      //             'No se pueden agregar productos porque el pedido está cerrado.');
      //       }
      //     });
      //   } else {
      //     setState(() {
      //       if (_con.mesa.estadoMesa != 2) {
      //         if (_con.productosSeleccionados?.any(
      //                 (p) => p.nombreproducto == producto.nombreproducto) ??
      //             false) {
      //           final Producto? productoExistente = _con.productosSeleccionados
      //               ?.firstWhere((p) =>
      //                   p.nombreproducto == producto.nombreproducto &&
      //                   p.precioproducto == producto.precioproducto);
      //           if (productoExistente != null) {
      //             print('------- ${_con.productosSeleccionados?.first.stock}');
      //             setState(() {
      //               productoExistente.stock =
      //                   (productoExistente.stock ?? 0) + 1;
      //             });
      //             _con.agregarMsj(
      //                 'Se ha aumentado el stock de ${productoExistente.nombreproducto} en 1.');
      //           }
      //         } else {
      //           // El producto no está seleccionado, agrégalo a la lista de productos seleccionados
      //           setState(() {
      //             _con.productosSeleccionados?.add(producto);
      //           });
      //           // Muestra un mensaje de confirmación
      //           _con.agregarMsj('El producto se ha añadido a la lista.');
      //           print('Productos seleccionados:');
      //           _con.productosSeleccionados?.forEach((prod) {
      //             print(prod.toJson());
      //           });
      //         }
      //       } else {
      //         _con.mostrarMensaje(
      //             'No se pueden agregar productos porque el pedido está cerrado.');
      //       }
      //     });
      //   }
      // },
      onTap: () {
        _productoFocus.unfocus();
        if(_con.items_independientes){
          if (_con.mesa.estadoMesa != 2)
          {
            setState(() {
              // Agrega siempre una nueva instancia del producto a la lista de productos seleccionados
              Producto newProducto = Producto(
                  identificador: producto.identificador,
                  idPedido: producto.idPedido,
                  id_pedido_detalle: producto.id_pedido_detalle,
                  id: producto.id,
                  nombreproducto: producto.nombreproducto,
                  foto: producto.foto,
                  precioproducto: producto.precioproducto,
                  stock: producto.stock,
                  codigo_interno: producto.codigo_interno,
                  categoria_id: producto.categoria_id,
                  comentario: producto.comentario
              );
              print('newProducto : ${newProducto.toJson()}');
              _con.productosSeleccionados?.add(newProducto);

              // Muestra un mensaje de confirmation
              // _con.agregarMsj('El producto se ha añadido a la lista.');

              // Imprime los productos seleccionados para verificación
              // print('Productos seleccionados:');
              // _con.productosSeleccionados?.forEach((prod) {
              //   print(prod.toJson());
              // });
            });
          } else {
            _con.mostrarMensaje('No se pueden agregar productos porque el pedido está cerrado.');
          }
        }
        else{
          setState(() {
            // if(_con.mesa.estadoMesa != 2)
            {
              if (_con.productosSeleccionados?.any((p) => p.nombreproducto == producto.nombreproducto) ?? false) {
                final Producto? productoExistente = _con.productosSeleccionados?.firstWhere((p) => p.nombreproducto == producto.nombreproducto);
                if (productoExistente != null) {
                  print('------- ${_con.productosSeleccionados?.first.stock}');
                  setState(() {
                    productoExistente.stock = (productoExistente.stock ?? 0) + 1;
                    productoExistente.aCStock = true;
                  });
                  print('newProducto : ${productoExistente.toJson()}');

                  _con.agregarMsj('Se ha aumentado el stock de ${productoExistente.nombreproducto} en 1.');
                }
              } else {
                // El producto no está seleccionado, agrégalo a la lista de productos seleccionados
                Producto producToAdd = producto;
                producToAdd.stock = 1;
                print(' producToAdd : ${producToAdd.toJson()} ');
                setState(() {
                  _con.productosSeleccionados?.add(producToAdd);
                });
              }
            }
            // else{
            //   _con.mostrarMensaje('No se pueden agregar productos porque el pedido está en PreCuenta.');
            // }
          });
        }
      },
      child: SizedBox(
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 3.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                        )),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    // height: MediaQuery.of(context).size.height * 0.08,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 10,bottom: 10),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: ClipRRect(
                      // child: Image.network(
                      //   'http://137.184.54.213/storage/${producto.foto}',
                      //   fit: BoxFit.contain,
                      // ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    // height: 60,
                    child: Text(
                      producto.nombreproducto ?? 'Nombre no disponible',
                      // maxLines: 5,
                      // overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontFamily: 'NimbusSans'),
                    ),
                  ),
                  const SizedBox(height: 10),

                ],
              ),
              Container(
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: Text(
                  'S/ ${producto.precioproducto ?? 'Precio no disponible'} ',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NimbusSans'),
                ),
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
        focusNode: _productoFocus,
        onChanged: _con.onChangeText,
        decoration: InputDecoration(
            hintText: 'Buscar',
            suffixIcon: const Icon(Icons.search, color: Color(0xFF000000)),
            hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF000000)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    const BorderSide(color: Color(0xFF000000), width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    const BorderSide(color: Color(0xFF000000), width: 2)),
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }

  void refresh() {
    setState(() {
      _tabController = TabController(
          length: _con.categorias.length,
          vsync: this,
          initialIndex: selectedIndex);
      _pageController = PageController();
    });
  }
}
