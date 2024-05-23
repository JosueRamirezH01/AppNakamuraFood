
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:restauflutter/model/detalle_pedido.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/model/mesaDetallePedido.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/model/pedido.dart';
import 'package:restauflutter/model/piso.dart';
import 'package:restauflutter/model/producto.dart';
import 'package:restauflutter/services/detalle_pedido_service.dart';
import 'package:restauflutter/services/mesas_service.dart';
import 'package:restauflutter/services/pedido_service.dart';
import 'package:restauflutter/services/piso_service.dart';
import 'package:restauflutter/utils/impresora.dart';
import 'package:restauflutter/utils/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Color> colores = [
  const Color(0xFF8EFF72), // verde
  const Color(0xFFF2D32A), // amarrillo
  const Color(0xFFF35B5B), // rojo

];

const List<Widget> options = <Widget>[
  Text('Listado de pedidos'),
  Text('POS'),
];

class Product {
  final String name;
  final int quantity;
  final double price;

  Product(this.name, this.quantity, this.price);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SubOptTypes {
  local,
  llevar,
  delivery,
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  late int _listSize;
  late SubOptTypes _subOptType;
  final SharedPref _pref = SharedPref();
  late  Mozo? mozo = Mozo();
  late Piso piso = Piso();
  bool isLoading = true;
  late List<Pedido> listaPedido = [];
  late int idEstablecimiento = 0 ;
  late List<Producto> ListadoProductos = [];
  StreamController<List<Mesa>> _mesasStreamController = StreamController<List<Mesa>>();


  Future<void> UserShared() async {
    final dynamic userData = await _pref.read('user_data');
    if (userData != null) {
      final Map<String, dynamic> userDataMap = json.decode(userData);
      mozo = Mozo.fromJson(userDataMap);
      idEstablecimiento = mozo!.id_establecimiento ?? 0;
    }
    String productosJson = await _pref.read('productos');

    print('--L---L--');
    print(productosJson);
    if (productosJson.isNotEmpty) {
      List<dynamic> productosData = json.decode(productosJson);
      ListadoProductos = productosData.map((json) => Producto.fromJson(json)).toList();
    }
  }
  var dbPisos = PisoServicio();
  var dbMesas = MesaServicio();
  var dbPedido = PedidoServicio();
  var dbDetallePedido = DetallePedidoServicio();



  // mesas
  static  List<Tab> myTabs = <Tab>[];
  late int pisoSelect = 0;
  late int pisoMesas = 0 ;
  late List<Piso> ListadoPisos = [];
  late List<Mesa> ListadoMesas = [];
  late List<Mesa> AllListadoMesas = [];

  late TabController _tabControllerPisos;
  late PageController _pageControllerPisosPage;

  var impresora = Impresora();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _listSize = 10;
    _subOptType = SubOptTypes.local;

    UserShared().then((_) {
      // Una vez que UserShared() haya terminado de ejecutarse y se haya actualizado idEstablecimiento, entonces llamamos a las funciones de consulta.
      consultarPisos(idEstablecimiento, context);
      consultarMesas(pisoSelect, context).then((value) async {
        _subOptType = SubOptTypes.local;
        listaPedido = await dbPedido.obtenerListasPedidos(_subOptType, idEstablecimiento,context);
        AllListadoMesas = await dbMesas.consultarTodasMesas(ListadoPisos, context);
        setState(() {
          isLoading = false;
        });
      },);
      refresh();
    });
    refresh2();
    refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabControllerPisos.dispose();
    _pageControllerPisosPage.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      _selectedIndex = _tabController.index;
    });
  }

  void _updateListSize(int? newValue) {
    if (newValue != null) {
      setState(() {
        _listSize =
            newValue;
      });
    }
  }

  Future<void> consultarPisos(int idEstablecimiento, BuildContext context) async {
    List<Piso> listaPisos = await dbPisos.consultarPisos(idEstablecimiento, context);
    print('LISTADO DE PISOS ------- ${listaPisos}');
    setState(() {
      myTabs.clear();
      ListadoPisos.clear();
      for (int i = 0; i < listaPisos.length; i++) {
        myTabs.add(Tab(text: listaPisos[i].nombrePiso));
        ListadoPisos.add(listaPisos[i]);
        print(' pisos: ${listaPisos[i]}');
      }
      pisoSelect = listaPisos[0].id!;
      consultarMesas(pisoSelect,context);
      refresh2();
    });
  }

  Future<void> consultarMesas(int idPiso, BuildContext context) async {
    print(' piso enviado: $idPiso');
    ListadoMesas = await dbMesas.consultarMesas(idPiso, context);
    refresh();
    //refresh2();
  }

  Stream<List<Mesa>> consultarMesasStream(int idPiso, BuildContext context) async* {
    while (true) {
      // Consultar las mesas y emitir el resultado a través del stream
      List<Mesa> mesas = await dbMesas.consultarMesas(idPiso, context);
      yield mesas;
      await Future.delayed(const Duration(seconds: 5)); // Esperar 5 segundos antes de la próxima consulta
      refresh();
    }
  }


  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: const Color(0xFF000000), elevation: 5);
  static final ButtonStyle selectedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color( 0xFFFF562F),
      foregroundColor:
      Colors.white,
      elevation: 5,
      animationDuration: const Duration(milliseconds: 1000));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(18),
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle),
                      child: IconButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, 'home/ajustes');
                        },
                        icon: const Icon(Icons.settings),
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 2,
                          right: 1.5
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {

                          consultarPisos(idEstablecimiento, context).then((value) {
                            consultarMesas(pisoSelect, context).then((value) async {
                              _subOptType = SubOptTypes.local;
                              listaPedido = await dbPedido.obtenerListasPedidos(_subOptType, idEstablecimiento,context);
                              AllListadoMesas = await dbMesas.consultarTodasMesas(ListadoPisos, context);
                              setState(() {
                                isLoading = false;
                              });
                            },);
                            setState(() {
                              _selectedIndex = 0;
                              _tabController.animateTo(0);
                              pisoMesas = 0;
                            });
                            print('PISOSMESAS $pisoMesas}');
                            refresh();
                          });

                          // setState(() {
                          //   _selectedIndex = 0;
                          //   _tabController.animateTo(0);
                          // });
                          // refresh();
                        },
                        icon: const Icon(Icons.list_alt_rounded),
                        label: const Text('Listado de pedidos'),
                        style: _selectedIndex == 0
                            ? selectedButtonStyle
                            : elevatedButtonStyle,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        consultarPisos(idEstablecimiento, context).then((value) {
                          consultarMesas(pisoSelect, context).then((value) async {
                            _subOptType = SubOptTypes.local;
                            listaPedido = await dbPedido.obtenerListasPedidos(_subOptType, idEstablecimiento,context);
                            AllListadoMesas = await dbMesas.consultarTodasMesas(ListadoPisos, context);
                            setState(() {
                              isLoading = false;
                            });
                          },);
                          setState(() {
                            _selectedIndex = 1;
                            _tabController.animateTo(1);
                            pisoMesas = 0;
                          });
                          print('PISOSMESAS $pisoMesas}');
                          refresh();
                        });
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('POS'),
                      style: _selectedIndex == 1
                          ? selectedButtonStyle
                          : elevatedButtonStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            child: Container(
              color: Colors.white, // Fondo de color D9D9D9
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Vista para 'Listado de pedidos'
                  _buildAnimatedContent(
                    key: const Key('Listado de pedidos'),
                    child: Center(
                      child: Column(
                        children: [
                          // Container(
                          //   margin: const EdgeInsets.all(8),
                          //   child: subopt(),
                          // ),
                          Expanded(
                            child: mainListado(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Vista para 'POS'
                  _buildAnimatedContent(
                    key:  const Key('POS'),
                    child: Center(
                      child: Column(
                        children: [
                          DefaultTabController(
                            length: myTabs.length,
                            child: Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 20),
                                      const Icon(Icons.table_bar_sharp, size: 30),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: TabBar(
                                          isScrollable: true,
                                          controller: _tabControllerPisos,
                                          tabs: myTabs,
                                          onTap: (index) {
                                            _pageControllerPisosPage.animateToPage(
                                              index,
                                              duration: Duration(milliseconds: 200),
                                              curve: Curves.linear,
                                            );
                                            String selectedTabName = myTabs[index].text!;
                                            print('Selected tab name: $selectedTabName');
                                            for (int i = 0; i < ListadoPisos.length; i++) {
                                              if (ListadoPisos[i].nombrePiso == selectedTabName) {
                                                setState(() {
                                                  piso = ListadoPisos[i];
                                                  pisoSelect = ListadoPisos[i].id!;
                                                  consultarMesas(pisoSelect,context);
                                                });
                                              }
                                            }
                                            setState(() {
                                              pisoMesas = 0;
                                            });
                                          },
                                          indicatorColor: const Color( 0xFFFF562F),
                                          labelColor: const Color( 0xFFFF562F),
                                          labelPadding:
                                          const EdgeInsets.only(left: 12),
                                          labelStyle: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      const SizedBox(width: 20),

                                      // const SizedBox(height: 20),

                                      // const Spacer()
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: PageView(
                                      controller: _pageControllerPisosPage,
                                      onPageChanged: (value) {
                                        _tabControllerPisos.animateTo(value);
                                        pisoMesas = value;
                                        print('value s ${value}');
                                        print('----${myTabs[value].text}');
                                        for (int i = 0; i < ListadoPisos.length; i++) {
                                          if (ListadoPisos[i].nombrePiso == myTabs[value].text) {
                                            setState(() {
                                              pisoSelect = ListadoPisos[i].id!;
                                            });
                                          }
                                        }
                                        setState(() {
                                          pisoMesas = 0;
                                        });
                                      },
                                      children: myTabs.map((Tab tab) {
                                        return StreamBuilder<List<Mesa>>(
                                          stream: consultarMesasStream(pisoSelect, context),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              List<Mesa>? mesas = snapshot.data;
                                              return GridView.builder(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 0.7,
                                                ),
                                                itemCount: mesas?.length,
                                                itemBuilder: (_, index) {
                                                  return _cardMesa(mesas![index]);
                                                },
                                              );
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                child: Text('Error: ${snapshot.error}'),
                                              );
                                            } else {
                                              return Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
    );
  }

  Widget _textFieldSearch() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: DropdownButton<int>(
                value: _listSize,
                onChanged: _updateListSize,
                dropdownColor: const Color(0xFFD9D9D9),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                selectedItemBuilder: (BuildContext context) {
                  return <int>[10, 20, 50].map<Widget>((int value) {
                    return Center(
                      child: Text(
                        '$value',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList();
                },
                items: const <DropdownMenuItem<int>>[
                  DropdownMenuItem<int>(
                    value: 10,
                    child: Text('10'),
                  ),
                  DropdownMenuItem<int>(
                    value: 20,
                    child: Text('20'),
                  ),
                  DropdownMenuItem<int>(
                    value: 50,
                    child: Text('50'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
                suffixIcon: const Icon(Icons.search, color: Color(0xFF000000)),
                hintStyle:
                const TextStyle(fontSize: 15, color: Color(0xFF000000)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                  const BorderSide(color: Color(0xFF000000), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                  const BorderSide(color: Color(0xFF000000), width: 2),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget subopt() {
    return SegmentedButton<SubOptTypes>(
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: const Color(0xFF000000),
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: const Color(0xFFFF562F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Color(0xFF000000), width: 2),
        ),
      ),
      segments: const <ButtonSegment<SubOptTypes>>[
        ButtonSegment<SubOptTypes>(
          value: SubOptTypes.local,
          label: SizedBox(
            width: 53,
            child: Center(child: Text('Local')),
          ),
        ),
        ButtonSegment<SubOptTypes>(
          value: SubOptTypes.llevar,
          label: SizedBox(
            width: 53,
            child: Center(child: Text('llevar')),
          ),
        ),
        ButtonSegment<SubOptTypes>(
          value: SubOptTypes.delivery,
          label: SizedBox(
            width: 53,
            child: Center(child: Text('Delivery')),
          ),
        ),
      ],
      selected: {_subOptType}, // Corregir _subOptTypes a _subOptType
      onSelectionChanged: (Set<SubOptTypes> newSelection) async {
        // Acepta un conjunto de valores
        setState(() {
          _subOptType = newSelection.first;
          isLoading = true;
          print(_subOptType);
        });
        listaPedido = await dbPedido.obtenerListasPedidos(_subOptType, idEstablecimiento, context);
        refresh();
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  Widget mainListado() {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(65, 65, 65, 0.3),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 2),
            color: const Color(0xFFF9F9F9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // children: [_textFieldSearch(), pedidosList()],
            children: [ pedidosList()],
          ),
        ),
      ),
    );
  }

  Widget pedidosList() {
    String buttonText = 'Cliente';
    List<Pedido> listaFiltrada = listaPedido;

    if (_subOptType == SubOptTypes.local) {
      buttonText = 'Mesa';
      listaFiltrada = listaPedido.where((pedido) => pedido.idUsuario == mozo?.id && pedido.idMesa != null).toList();
      refresh();
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFD1D1D1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Pedido',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(width: 2),
                          right: BorderSide(width: 2),
                        ),
                      ),
                      child: Text(
                        buttonText ,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Estado',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(),
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : ListView.builder(
                  //itemCount: listaPedido.length,
                  itemCount: listaFiltrada.length,
                  itemBuilder: (_, index) {
                    //if (index < listaPedido.length) {
                    if (index < listaFiltrada.length) {

                      // Funcional
                      //Pedido listPedido = listaPedido[index];
                      Pedido listPedido = listaFiltrada[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text('PD-${listPedido.correlativoPedido}')),
                            // Spacer(),
                            //Text('${_subOptType == SubOptTypes.local ? (ListadoMesas.isNotEmpty ? ListadoMesas.firstWhere((element) => element.id == listPedido.idMesa, orElse: () => Mesa()).nombreMesa : "") : listPedido.idCliente}'),
                            Expanded(child: Text('${_subOptType == SubOptTypes.local ? (ListadoMesas.isNotEmpty ? (AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa, orElse: () => Mesa()).nombreMesa ?? "") : "") : listPedido.idCliente}',overflow: TextOverflow.ellipsis)),
                            // Spacer(),
                            Expanded(child: Text('${listPedido.estadoPedido == 1 ? 'Registrado' : listPedido.estadoPedido == 0? 'Anulado':'pendiente'}',overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFF111111),
                                  decoration: TextDecoration.none,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500
                              ),))
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text('${ListadoPisos.firstWhere((element) => element.id == AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).pisoId).nombrePiso}' ),
                          ],
                        ),
                        onTap: () async {
                          List<Detalle_Pedido> listadoDetalle = await dbDetallePedido.obtenerDetallePedidoLastCreate(listPedido.idPedido, context);

                          listadoDetalle.forEach((element) {
                            print('Los home ${element.comentario} tipo : ${element.comentario.runtimeType}');
                          });

                          pedido(listPedido, listadoDetalle);
                        },
                      );
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future pedido(Pedido listPedido, List<Detalle_Pedido> listadoDetalle) {
    return showCupertinoModalBottomSheet(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification && notification.metrics.atEdge && notification.metrics.pixels <= 0) {
              return false;
            }
            return true;
          },
          child: SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(217, 217, 217, 0.8),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.62,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Expanded(
                            child: Container(
                              alignment: Alignment.topLeft,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFf1f1f1),
                                  border: Border.all(width: 2),
                                  borderRadius: const BorderRadius.all(Radius.circular(20))
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child:  Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10
                                        ),
                                        child: Text(
                                          //'n° pedido: ${listPedido.correlativoPedido}',
                                          'n° pedido: ${listPedido.correlativoPedido}',
                                          style: const TextStyle(
                                              color: Color(0xFF111111),
                                              decoration: TextDecoration.none,
                                              fontSize : 30,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10,
                                            left: 20,
                                            bottom: 10,
                                            right: 20
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFD9D9D9),
                                              border: Border.all(width: 2),
                                              borderRadius: const BorderRadius.all(Radius.circular(20))
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.all(5),
                                                decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 2))),
                                                child:  Padding(
                                                  padding: const EdgeInsets.all(5),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          child: const Text(
                                                            'Cantidad',
                                                            style: TextStyle(
                                                                color: Color(0xFF111111),
                                                                decoration: TextDecoration.none,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w500),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          child: const Text(
                                                            'Producto',
                                                            style: TextStyle(
                                                                color: Color(0xFF111111),
                                                                decoration: TextDecoration.none,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w500),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          child: const Text(
                                                            'Precio',
                                                            style: TextStyle(
                                                                color: Color(0xFF111111),
                                                                decoration: TextDecoration.none,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w500),
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                ),
                                              ),
                                              //cp
                                              //obtenerDetallePedidoLastCreate
                                              _producList(listadoDetalle)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                              color: const Color(0xFF99CFB5),
                              border: Border.all(width: 2),
                              borderRadius: const BorderRadius.all(Radius.circular(20))
                          ),

                          child:  Padding(
                            padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 10
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.blueAccent,
                                          shape: BoxShape.circle
                                      ),
                                      margin: const EdgeInsets.only(right: 10),
                                      child: IconButton(
                                        onPressed: () async {
                                          String? printerIP = await _pref.read('ipCocina');

                                          List<Producto> listProduct= [];
                                          for (int i = 0; i < listadoDetalle.length; i++) {
                                            Detalle_Pedido detalle = listadoDetalle[i];
                                            Producto producto = ListadoProductos.firstWhere((producto) => producto.id == detalle.id_producto);
                                            producto.stock = detalle.cantidad_producto;
                                            listProduct.add(producto);
                                          }
                                          impresora.printLabel(printerIP!,listProduct,3, listPedido.montoTotal!, AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).nombreMesa , mozo!, ListadoPisos.firstWhere((element) => element.id == AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).pisoId),'');
                                          print('Imprimir');
                                        },
                                        icon: const Icon(Icons.print),
                                        tooltip: 'Imprimir',
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle
                                      ),
                                      child: IconButton(
                                        onPressed: () async {
                                          List<Producto> listProduct= [];
                                          List<Pedido> listCompar = listaPedido ;
                                          String? printerIP = await _pref.read('ipCocina');
                                          for (int i = 0; i < listadoDetalle.length; i++) {
                                            Detalle_Pedido detalle = listadoDetalle[i];
                                            Producto producto = ListadoProductos.firstWhere((producto) => producto.id == detalle.id_producto);
                                            producto.stock = detalle.cantidad_producto;
                                            listProduct.add(producto);
                                          }
                                          mostrarDialogoAnulacion( printerIP!, listProduct  ,listPedido ,context).then((value) async {
                                            listaPedido = await dbPedido.obtenerListasPedidos(_subOptType, idEstablecimiento,context);
                                            consultarMesas(pisoSelect, context);
                                            refresh();
                                          });
                                          refresh();
                                        },
                                        icon: const Icon(Icons.cancel_outlined),
                                        tooltip: 'Anular',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  ' Total S/${listPedido.montoTotal}',
                                  style:  const TextStyle(
                                      color: Color(0xFF111111),
                                      decoration: TextDecoration.none,
                                      fontSize : 20,
                                      fontWeight: FontWeight.w600
                                  ),
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
            ),
          ),
        );
      },
    );
  }

  // ----LS
  Widget _producList(List<Detalle_Pedido> detalleList) {
    List<Widget> rows = [];

    for (int i = 0; i < detalleList.length; i++) {
      Detalle_Pedido detalle = detalleList[i];
      rows.add(
        Container(
          margin: const EdgeInsets.all(5),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${detalle.cantidad_producto}',
                      style: const TextStyle(
                          color: Color(0xFF111111),
                          decoration: TextDecoration.none,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${ListadoProductos.firstWhere((producto) => producto.id == detalle.id_producto ).nombreproducto}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF111111),
                          decoration: TextDecoration.none,
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${detalle.precio_producto}',
                      style: const TextStyle(
                          color: Color(0xFF111111),
                          decoration: TextDecoration.none,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        ),
      ),
    );
  }

  Widget _cardMesa(Mesa mesa) {
    String estadoMesaDis = 'Disponible';
    if(mesa.estadoMesa == 2){
      estadoMesaDis = 'Pre-Cuenta';
    }else if (mesa.estadoMesa == 3){
      estadoMesaDis = 'Ocupado';
    }

    return GestureDetector(
      onTap: () async {
        if (mesa.estadoMesa == 1) {
          Navigator.pushNamed(context, 'home/productos', arguments: mesa);
        } else {
          int? idPedido = await dbPedido.consultarMesasDisponibilidad(mozo!.id, mesa.id,context);
          if(idPedido != null){
            List<Detalle_Pedido> detallePedido =  await dbPedido.consultaObtenerDetallePedido(idPedido, context);
            // sin usarse
            MesaDetallePedido mesaDetallePedido = MesaDetallePedido(mesa, detallePedido);
            Navigator.pushNamed(context, 'home/productos', arguments: mesaDetallePedido);
          }else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Mensaje'),
                  content: Text('La Mesa ya esta ocupada por otro Mozo'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      },
      child: SizedBox(
        child: Card(
          margin: const EdgeInsets.all(10),
          // aca seleto el color
          //color: const Color(0xFF8EFF72),
          color: colores[int.parse('${mesa.estadoMesa}')-1],
          elevation: 3.0,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    height: 40,
                    child: Text(
                      '${mesa.nombreMesa}',
                      overflow: TextOverflow.ellipsis,
                      style:
                      const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.18,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child:  Padding(
                      padding: int.parse('${mesa.estadoMesa}') > 1 ? const EdgeInsets.all(15.0) : const EdgeInsets.only(right: 28, left: 28, top: 30),
                      child: FadeInImage(
                        image: int.parse('${mesa.estadoMesa}') > 1 ? const AssetImage('assets/img/pre-cuenta.png')  : const AssetImage('assets/img/Vector.png'),
                        fit: BoxFit.contain,
                        color: Colors.black,
                        fadeInDuration: const Duration(milliseconds: 50),
                        placeholder: const AssetImage('assets/img/no-image.png'),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      estadoMesaDis,
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> mostrarDialogoAnulacion(String printerIP, List<Producto> listProduct ,Pedido pedido, BuildContext context) async {
    String motivo = '';
    bool motivoVacio = false;
    bool usarMotivoPorDefecto = false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              // backgroundColor: Color.fromRGBO(217, 217, 217, 1.0),
              title: Text('Anular pedido : ${pedido.correlativoPedido}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Color( 0xFFFF562F),
                        value: usarMotivoPorDefecto,
                        onChanged: (newValue) {
                          setState(() {
                            usarMotivoPorDefecto = newValue!;
                            // Si se marca el checkbox, vaciamos el motivo del TextField
                            if (usarMotivoPorDefecto) {
                              motivo = '';
                              motivoVacio = false;
                            }
                          });
                        },
                      ),
                      Text('Usar motivo por defecto'),
                    ],
                  ),
                  TextField(
                    onChanged: (value) {
                      motivo = value;
                      setState(() {
                        // motivoVacio = motivo.isEmpty;
                        motivoVacio = motivo.isEmpty && !usarMotivoPorDefecto;
                      });
                    },
                    enabled: !usarMotivoPorDefecto,
                    // decoration: InputDecoration(
                    //   labelText: 'Motivo de anulación',
                    //   errorText: motivoVacio ? 'Este campo no puede estar vacío' : null,
                    //   focusedBorder: UnderlineInputBorder(
                    //     borderSide: BorderSide(color: motivoVacio ? Colors.red : Theme.of(context).primaryColor),
                    //   ),
                    // ),
                    decoration: InputDecoration(
                        labelText: 'Motivo de anulación',
                        hintText: 'Ej. Abandono de mesa',
                        errorText: motivoVacio ? 'Este campo no puede estar vacío' : null,
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
                              color: motivoVacio ? Colors.red : Color(0xFF000000),
                              width: 2
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10),
                        // prefixIcon: Icon(Icons.print, color: Colors.black),
                        // error
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: motivoVacio ? Colors.red : Color(0xFF000000),
                              width: 2
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: motivoVacio ? Colors.red : Color(0xFF000000),
                              width: 2
                          ),
                        ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all( Color.fromRGBO(217, 217, 217, 0.8) ),
                  ),
                  child: Text('Cancelar',style: TextStyle(color: Colors.black),),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all( Colors.redAccent ),
                  ),
                  child: Text('Anular',style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    // if (motivo.isEmpty) {
                    //   setState(() {
                    //     motivoVacio = true;
                    //   });
                    // } else {
                    //   impresora.printLabel( printerIP, listProduct ,4, pedido.montoTotal!, AllListadoMesas.firstWhere((element) => element.id == pedido.idMesa).nombreMesa, mozo!, ListadoPisos.firstWhere((element) => element.id == AllListadoMesas.firstWhere((element) => element.id == pedido.idMesa).pisoId),motivo);
                    //   dbMesas.actualizarMesa(pedido.idMesa, 1, context);
                    //   dbPedido.anularPedido(motivo, mozo!, pedido.idPedido!, context);
                    //   Navigator.of(context).pop();
                    //   refresh();
                    // }
                    String motivoFinal = usarMotivoPorDefecto ? 'Motivo por defecto' : motivo;

                    if (motivoFinal.isEmpty && !usarMotivoPorDefecto) {
                      setState(() {
                        motivoVacio = true;
                      });
                    } else {
                      impresora.printLabel(
                          printerIP, listProduct, 4, pedido.montoTotal!, AllListadoMesas.firstWhere((element) => element.id == pedido.idMesa).nombreMesa, mozo!,
                          ListadoPisos.firstWhere((element) => element.id == AllListadoMesas.firstWhere((element) => element.id == pedido.idMesa).pisoId),
                          motivoFinal);
                      dbMesas.actualizarMesa(pedido.idMesa, 1, context);
                      dbPedido.anularPedido(motivoFinal, mozo!, pedido.idPedido!, context);
                      // refresh();
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    }
                    refresh();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedContent({required Key key, required Widget child}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        key: key,
        child: child,
      ),
    );
  }

  void refresh(){
    setState(() {

    });
  }

  void refresh2(){
    setState(() {
      print('CONSULTA DE CANTDAD DE PISOS  ${ListadoPisos.length}');
      _tabControllerPisos = TabController(
          length: ListadoPisos.length,
          vsync: this,
          initialIndex: pisoMesas
      );
      _pageControllerPisosPage = PageController();
    });
  }
}