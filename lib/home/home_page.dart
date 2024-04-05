
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/model/piso.dart';
import 'package:restauflutter/services/mesas_service.dart';
import 'package:restauflutter/services/pedido_service.dart';
import 'package:restauflutter/services/piso_service.dart';
import 'package:restauflutter/utils/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Color> colores = [
  const Color(0xFF8EFF72), // verde
  const Color(0xFFF35B5B), // rojo
  const Color(0xFFF2D32A), // amarrillo
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

  Future<void> UserShared() async {
    final dynamic userData = await _pref.read('user_data');
    if (userData != null) {
      final Map<String, dynamic> userDataMap = json.decode(userData);
       mozo = Mozo.fromJson(userDataMap);
    }
  }
  var dbPisos = PisoServicio();
  var dbMesas = MesaServicio();
  var dbPedido = PedidoServicio();


  int idEstablecimiento = 22 ; // seatear al el moso hacer login

  // mesas
  static  List<Tab> myTabs = <Tab>[];
  late int pisoSelect = 0;
  late List<Piso> ListadoPisos = [];
  late List<Mesa> ListadoMesas = [];



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _listSize = 10;
    _subOptType = SubOptTypes.local;
    consultarPisos(idEstablecimiento, context);
    consultarMesas(pisoSelect, context);
    UserShared();
    refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    print(listaPisos);
    setState(() {
      myTabs.clear();
      for (int i = 0; i < listaPisos.length; i++) {
        myTabs.add(Tab(text: listaPisos[i].nombrePiso));
        ListadoPisos.add(listaPisos[i]);
        print(' pisos: ${listaPisos[i]}');
      }
      pisoSelect = listaPisos[0].id!;
      consultarMesas(pisoSelect,context);
    });
  }
  Future<void> consultarMesas(int idPiso, BuildContext context) async {
    print(' piso enviado: $idPiso');
    List<Mesa> listaMesas = await dbMesas.consultarMesas(idPiso, context);
    print('mesas recividas $listaMesas');
    setState(() {
      ListadoMesas.clear();
      for (int i = 0; i < listaMesas.length; i++) {
        ListadoMesas.add(listaMesas[i]);
      }
    });
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
                          color: Colors.redAccent,
                          shape: BoxShape.circle),
                      child: IconButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.remove('user_data');
                          prefs.remove('categorias');
                          prefs.remove('productos');
                          // Redirigir a la nueva pantalla
                          Navigator.pushReplacementNamed(context, 'login');
                        },
                        icon: const Icon(Icons.logout_outlined),
                        tooltip: 'Cerrar sesion',
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 2,
                        right: 1.5
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 0;
                            _tabController.animateTo(0);
                          });
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
                        setState(() {
                          _selectedIndex = 1;
                          _tabController.animateTo(1);
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
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: subopt(),
                          ),
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
                          // Otros widgets...
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
                                          tabs: myTabs,
                                          onTap: (index) {
                                            String selectedTabName = myTabs[index].text!;
                                            print('Selected tab name: $selectedTabName');
                                            for (int i = 0; i < ListadoPisos.length; i++) {
                                              if (ListadoPisos[i].nombrePiso == selectedTabName) {
                                                pisoSelect = ListadoPisos[i].id!;
                                                consultarMesas(pisoSelect,context);
                                                print('Mesas: $ListadoMesas');
                                              }
                                            }
                                          },
                                          indicatorColor: const Color( 0xFFFF562F),
                                          labelColor: const Color( 0xFFFF562F),
                                          labelPadding:
                                          const EdgeInsets.only(left: 12),
                                          labelStyle: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      const Spacer()
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: TabBarView(
                                      children: myTabs.map((Tab tab) {
                                        return GridView.builder(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 10),
                                          gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.7,
                                          ),
                                          itemCount:ListadoMesas.length,
                                          itemBuilder: (_, index) {
                                            return _cardProduct(ListadoMesas[index]);
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
      onSelectionChanged: (Set<SubOptTypes> newSelection) {
        // Acepta un conjunto de valores
        setState(() {
          _subOptType = newSelection.first;
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
            children: [_textFieldSearch(), pedidosList()],
          ),
        ),
      ),
    );
  }

  Widget pedidosList() {
    String buttonText = 'Cliente';

    if (_subOptType == SubOptTypes.local) {
      buttonText =
      'Mesa'; // Si _subOptType es 'local', el texto cambia a 'Mesa'
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
                        buttonText,
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
                child: ListView.builder(
                  itemCount: _listSize,
                  itemBuilder: (context, index) {
                    String npedido = 'PD-${index + 1}';
                    return ListTile(
                      title: Text('PD-${index + 1}'),
                      subtitle: Text('Cliente ${index + 1}'),
                      trailing: const Text('Estado'),
                      onTap: () {
                        pedido(npedido);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future pedido(String numeroPedido) {
    return showCupertinoModalBottomSheet(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
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
                                        'n° pedido: $numeroPedido',
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
                                            _producList([
                                              Product('Chaufa de pollo', 2, 14.50),
                                              Product('Arroz chaufa', 1, 10),
                                              Product('Tallarín saltado', 3, 18.50),
                                              Product('Arroz chaufa', 1, 10),
                                              Product('Tallarín saltado combo familiar', 3, 18.50),
                                              Product('Arroz chaufa', 1, 10),
                                              Product('Tallarín saltado', 3, 18.50),
                                            ])
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
                                      onPressed: () {
                                        print('Botón presionado');
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
                                      onPressed: () {
                                        print('Botón presionado');
                                      },
                                      icon: const Icon(Icons.cancel_outlined),
                                      tooltip: 'Anular',
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              const Text(
                                ' Total S/50',
                                style: TextStyle(
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
        );
      },
    );
  }

  Widget _producList(List<Product> productList) {
    List<Widget> rows = [];

    for (int i = 0; i < productList.length; i++) {
      Product product = productList[i];
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
                      '${product.quantity}',
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
                      product.name,
                      overflow: TextOverflow.ellipsis,
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
                      '${product.price}',
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

  Widget _cardProduct(Mesa mesa) {
    return GestureDetector(
        onTap: () async {
          if (mesa.estadoMesa == 1) {
            Navigator.pushNamed(context, 'home/productos', arguments: mesa);
          } else {
           int? idPedido = await dbPedido.consultarMesasDisponibilidad(mozo!.id, context);
           if(idPedido != null){
             await dbPedido.consultaObtenerDetallePedido(818, context);
             Navigator.pushNamed(context, 'home/productos', arguments: mesa);
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
                      padding: const EdgeInsets.all(15.0),
                      child: FadeInImage(
                        image: int.parse('${mesa.estadoMesa}') > 0 ? const AssetImage('assets/img/pre-cuenta.png')  : const AssetImage('assets/img/Vector.png'),
                        fit: BoxFit.contain,
                        color: Colors.black,
                        fadeInDuration: const Duration(milliseconds: 50),
                        placeholder: const AssetImage('assets/img/no-image.png'),
                      ),
                    ),
                  ),
                   Center(
                    child: Text(
                      '${mesa.estDisMesa}',
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
}
