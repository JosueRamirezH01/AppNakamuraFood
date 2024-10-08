
import 'dart:async';
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:restauflutter/model/PedidoResponse.dart';
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

import '../model/usuario.dart';
import '../services/login_service.dart';

List<Color> colores = [
  const Color(0xFFCCF390), // verde
  const Color(0xFFFC930A), // amarrillo
  const Color(0xFFF35B5B), // rojo

];

const List<Widget> options = <Widget>[
  Text('Listado de pedidos'),
  Text('POS'),
];


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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin                                                                        {

  late Usuario? usuario = Usuario();

  //----------------------------------------------------
  late TabController _tabController;
  late int _listSize;
  late SubOptTypes _subOptType;
  final SharedPref _pref = SharedPref();
  late Piso piso = Piso();
  bool isLoading = true;
  late List<Pedido> listaPedido = [];
  late int idEstablecimiento = 0 ;
  late List<Producto> ListadoProductos = [];
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool wifi = false;
  bool datos = false;
  var moduloLogin = LoginService();

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) async {
      await _checkExpiration();
    });
  }
  Future<void> _checkExpiration() async {
    final expiracion_in = await _pref.read('expires');

    if (expiracion_in != null) {
      final DateTime expiracionDateTime = DateTime.parse(expiracion_in);
      final DateTime now = DateTime.now();
      print('DATETIME $expiracionDateTime');
      print('DATETIME $now');
      if (now.isAfter(expiracionDateTime)) {
        _pref.remove('user_data');
        _pref.remove('categorias');
        _pref.remove('productos');
        _pref.remove('stateConexionTicket');
        _pref.remove('conexionBluetooth');
        print('TOKEN ${usuario!.accessToken!}');
        Fluttertoast.showToast(msg: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',backgroundColor: Colors.red,gravity: ToastGravity.TOP,toastLength: Toast.LENGTH_LONG);
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);

      }
    }
  }


  void getConnectivity() {
    subscription = Connectivity().onConnectivityChanged.listen( (List<ConnectivityResult> result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        wifi = result.contains(ConnectivityResult.wifi);
        datos = result.contains(ConnectivityResult.mobile);
        print('Resultado de la consulta de conectividad WIFI: $datos');
        if (!isDeviceConnected && !isAlertSet) {
          if (mounted) {
            showDialogBox('No Connection', 'Please check your internet connectivity');
            setState(() => isAlertSet = true);
          }
        }
        if(!wifi && !isAlertSet ){
          if (mounted) {
            showDialogBox('No WiFi', 'WiFi is not connected.');
            setState(() => isAlertSet = true);
          }
        }
        if(datos && !isAlertSet ){
          if (mounted) {
            showDialogBox('Mobile Data Active', 'Please turn off your mobile data.');
            setState(() => isAlertSet = true);
          }
        }
      },
    );
  }

  Future<void> UserShared() async {
    final dynamic userData = await _pref.read('user_data');
    if (userData != null) {
      final Map<String, dynamic> userDataMap = json.decode(userData);
      usuario = Usuario.fromJson(userDataMap);
    }
    print('->Datos del usuario cargados');
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
    _tabController = TabController(length: 1, vsync: this);
    _listSize = 10;
    _subOptType = SubOptTypes.local;
    getConnectivity();
    _startTimer();
    UserShared().then((_) {
      consultarPisos().then((_) {
        consultarMesas(pisoSelect, context).then((value) async {
          _subOptType = SubOptTypes.local;

          //listaPedido = await dbPedido.obtenerListasPedidos(_subOptType, idEstablecimiento,context);
          //AllListadoMesas = await dbMesas.consultarTodasMesas(ListadoPisos, context);
          setState(() {
            isLoading = false;
          });
        },);
        refresh2();
        refresh();
      });
    });

    refresh2();
    refresh();
  }
  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _tabControllerPisos.dispose();
    _pageControllerPisosPage.dispose();
    subscription?.cancel();
    super.dispose();
  }



  void _updateListSize(int? newValue) {
    if (newValue != null) {
      setState(() {
        _listSize =
            newValue;
      });
    }
  }

  String cleanComentario(String? comentario) {
    if (comentario == null || comentario.isEmpty) {
      return '';
    }
    final RegExp regExp = RegExp(r'<span[^>]*>([^<]+)<\/span>');
    Iterable<Match> matches = regExp.allMatches(comentario);

    String cleanedComentario = matches.map((match) => match.group(1)).join(';');
    return cleanedComentario;
  }

  Future<void> consultarPisos() async {
    print('-----');
    final dynamic userData = await _pref.read('user_data');
      final Map<String, dynamic> userDataMap = json.decode(userData);
      usuario = Usuario.fromJson(userDataMap);

    List<Piso>? listaPisos = await dbPisos.getAll(usuario?.accessToken);
    print('LISTADO DE PISOS ------- ${listaPisos}');
    setState(() {
      myTabs.clear();
      ListadoPisos.clear();
      for (int i = 0; i < listaPisos!.length; i++) {
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
    final dynamic userData = await _pref.read('user_data');
    final Map<String, dynamic> userDataMap = json.decode(userData);
    usuario = Usuario.fromJson(userDataMap);
    print(' Mesas del piso: $idPiso');
    ListadoMesas = await dbMesas.getAll(usuario?.accessToken,idPiso);
    refresh();
  }

  Stream<List<Mesa>> consultarMesasStream(int idPiso, BuildContext context) async* {
    while (true) {
      List<Mesa> mesas = await dbMesas.getAll(usuario?.accessToken,idPiso);
      ListadoMesas = mesas ;
      yield mesas;
      await Future.delayed(const Duration(seconds: 5));
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

    return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(18),
            child: ButtonBar(
              alignment: MainAxisAlignment.start,
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
                    SizedBox(width: 10),
                    ///CAMBIAR MESA
                    ElevatedButton(
                        child: Text('CAMBIAR MESA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.white),backgroundColor: MaterialStatePropertyAll(Color(0xFFeb984e))),
                      onPressed: (){
                          _showMyDialog(context);
                      },
                    )
                    // Container(
                    //   margin: const EdgeInsets.only(
                    //       left: 2,
                    //       right: 1.5
                    //   ),
                    //   child: ElevatedButton.icon(
                    //     onPressed: () {
                    //       consultarPisos().then((value) {
                    //         consultarMesas(pisoSelect, context).then((value) async {
                    //           _subOptType = SubOptTypes.local;
                    //           listaPedido = await dbPedido.obtenerListasPedidos(_subOptType, idEstablecimiento,context);
                    //           AllListadoMesas = await dbMesas.consultarTodasMesas(ListadoPisos, context);
                    //           setState(() {
                    //             isLoading = false;
                    //           });
                    //         },);
                    //         setState(() {
                    //           initialTabIndex = 0;
                    //           _tabController.animateTo(initialTabIndex);
                    //           pisoMesas = 0;
                    //         });
                    //         print('PISOSMESAS $pisoMesas}');
                    //         refresh();
                    //       });
                    //
                    //       // setState(() {
                    //       //   _selectedIndex = 0;
                    //       //   _tabController.animateTo(0);
                    //       // });
                    //       // refresh();
                    //     },
                    //     icon: const Icon(Icons.list_alt_rounded),
                    //     label: const Text('Listado de pedidos'),
                    //     style: initialTabIndex == 0
                    //         ? selectedButtonStyle
                    //         : elevatedButtonStyle,
                    //   ),
                    // ),
                    // ElevatedButton.icon(
                    //   onPressed: () {
                    //
                    //         setState(() {
                    //           isLoading = false;
                    //         });
                    //       setState(() {
                    //         initialTabIndex = 1;
                    //         _tabController.animateTo(initialTabIndex);
                    //         // _tabController.animateTo(initialTabIndex == 0 ? 1 : initialTabIndex);
                    //         pisoMesas = 0;
                    //       });
                    //       print('PISOSMESAS $pisoMesas}');
                    //         consultarPisos();
                    //       refresh();
                    //   },
                    //   icon: const Icon(Icons.shopping_cart_outlined),
                    //   label: const Text('POS'),
                    //   style: initialTabIndex == 1
                    //       ? selectedButtonStyle
                    //       : elevatedButtonStyle,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            // Vista para 'Listado de pedidos'
            // _buildAnimatedContent(
            //   key: const Key('Listado de pedidos'),
            //   child: Center(
            //     child: Container(
            //       // width: crossAxisCount < 2 ? MediaQuery.of(context).size.width * 1  : MediaQuery.of(context).size.width * 0.7 ,
            //       child: Column(
            //         children: [
            //           // Container(
            //           //   margin: const EdgeInsets.all(8),
            //           //   child: subopt(),
            //           // ),
            //           Expanded(
            //             child: mainListado(),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
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
                                    tabAlignment: TabAlignment.start,
                                    splashBorderRadius: BorderRadius.all(Radius.circular(20)),
                                    isScrollable: true,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    controller: _tabControllerPisos,
                                    tabs: myTabs,
                                    onTap: (index) async {
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
                                        pisoMesas = index;
                                      });
                                    },

                                    indicatorColor: const Color( 0xFFFF562F),
                                    labelColor: const Color( 0xFFFF562F),
                                    labelStyle: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 20),
                              ],
                            ),
                            const SizedBox(height: 10),
                        Expanded(
                          child: NonScrollablePageView(
                            controller: _pageControllerPisosPage,
                            onPageChanged: (value) {
                              _tabControllerPisos.animateTo(value);
                              // pisoMesas
                              pisoMesas = value;
                              print('value s $value');
                              print('----${myTabs[value].text}');
                              for (int i = 0; i < ListadoPisos.length; i++) {
                                if (ListadoPisos[i].nombrePiso == myTabs[value].text) {
                                  setState(() {
                                    pisoSelect = ListadoPisos[i].id!;
                                    consultarMesas(pisoSelect, context);
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
                                  if (snapshot.hasData) {
                                    List<Mesa>? mesas = snapshot.data;
                                    return GridView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: crossAxisCount == 2 || crossAxisCount == 3 ? 0.7 : 1,
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
                                      child: CircularProgressIndicator(
                                        color: Color( 0xFFFF562F),
                                      ),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                  ]
                    )
                  )
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        //listaPedido = await dbPedido.obtenerListasPedidos(_subOptType, idEstablecimiento, context);
        refresh();
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  // Widget mainListado() {
  //   return Padding(
  //     padding: const EdgeInsets.all(20),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       // children: [_textFieldSearch(), pedidosList()],
  //       children: [ pedidosList()],
  //     ),
  //   );
  // }

  // Widget pedidosList() {
  //   String buttonText = 'Cliente';
  //   List<Pedido> listaFiltrada = listaPedido;
  //
  //   if (_subOptType == SubOptTypes.local) {
  //     buttonText = 'Mesa';
  //     listaFiltrada = listaPedido.where((pedido) => pedido.idUsuario == mozo?.id && pedido.estadoPedido != 0).toList();
  //     refresh();
  //   }
  //
  //   return Expanded(
  //     child: Container(
  //       //margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
  //       decoration: BoxDecoration(
  //         border: Border.all(width: 2),
  //         borderRadius: BorderRadius.circular(20),
  //         color: const Color(0xFFD1D1D1),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(10),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Expanded(
  //                   child: Container(
  //                     alignment: Alignment.center,
  //                     child: const Text(
  //                       'Pedido',
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(fontWeight: FontWeight.w600),
  //                     ),
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: Container(
  //                     alignment: Alignment.center,
  //                     decoration: const BoxDecoration(
  //                       border: Border(
  //                         left: BorderSide(width: 2),
  //                         right: BorderSide(width: 2),
  //                       ),
  //                     ),
  //                     child: Text(
  //                       buttonText ,
  //                       textAlign: TextAlign.center,
  //                       style: const TextStyle(fontWeight: FontWeight.w600),
  //                     ),
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: Container(
  //                     alignment: Alignment.center,
  //                     child: const Text(
  //                       'Total',
  //                       textAlign: TextAlign.center,
  //                       style: TextStyle(fontWeight: FontWeight.w600),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: Container(
  //               clipBehavior: Clip.antiAlias,
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               child: isLoading
  //                   ? const Center(
  //                 child: CircularProgressIndicator(
  //                   color: Color( 0xFFFF562F),
  //                 ),
  //               )
  //                   : ListView.builder(
  //                 //itemCount: listaPedido.length,
  //                 itemCount: listaFiltrada.length,
  //                 itemBuilder: (_, index) {
  //                   //if (index < listaPedido.length) {
  //                   if (index < listaFiltrada.length) {
  //                     // Funcional
  //                     //Pedido listPedido = listaPedido[index];
  //                     Pedido listPedido = listaFiltrada[index];
  //                     //tp1
  //                     return Card(
  //                        child: ListTile(
  //                         title: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Text('PD-${listPedido.correlativoPedido}'),
  //                             Text('${_subOptType == SubOptTypes.local ? (ListadoMesas.isNotEmpty ? (AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa, orElse: () => Mesa()).nombreMesa ?? "") : "") : listPedido.idCliente}',overflow: TextOverflow.ellipsis),
  //                             Text('${listPedido.montoTotal}',overflow: TextOverflow.ellipsis,
  //                               style: const TextStyle(
  //                                 color: Color(0xFF111111),
  //                                 decoration: TextDecoration.none,
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w500
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                         subtitle: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Text('${ListadoPisos.firstWhere((element) => element.id == AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).pisoId).nombrePiso}' ),
  //                             Container(
  //                                 decoration: BoxDecoration(
  //                                   color: colores[AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).estadoMesa! - 1],
  //                                   borderRadius: BorderRadius.all(Radius.circular(10))
  //                                 ),
  //                                 child: Padding(
  //                                   padding: const EdgeInsets.only(top: 1.5,bottom: 1.5,right: 10,left: 10),
  //                                   child: Text(AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).estadoMesa != 0 ? AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).estadoMesa == 2 ? 'Pre-Cuenta': 'Ocupado': 'Disponible',
  //                                     style: TextStyle(
  //                                       color: AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).estadoMesa != 0 ? AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).estadoMesa == 2 ? Colors.black : Colors.white: Colors.black,
  //                                     ),
  //                                   ),
  //                                 )
  //                             ),
  //                           ],
  //                         ),
  //                         onTap: () async {
  //                           List<Detalle_Pedido> listadoDetalle = await dbDetallePedido.obtenerDetallePedidoLastCreate(listPedido.idPedido, context);
  //                           setState(() {
  //                             initialTabIndex == 0;
  //                           });
  //                           pedido(listPedido, listadoDetalle);
  //                         },
  //                       ),
  //                     );
  //                   } else {
  //                     return null;
  //                   }
  //                 },
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
  bool _isModalOpen = false;
  Future pedido(Pedido listPedido, List<Detalle_Pedido> listadoDetalle) {

    // double screenWidth = MediaQuery.of(context).size.width;
    //
    // double widthListado = 2;
    // if (screenWidth > 600) {
    //   widthListado = 0.7;
    // }

    if (_isModalOpen) {
      return Future.value(); // No hacer nada si el modal ya está abierto
    }

    _isModalOpen = true;

    return showCupertinoModalBottomSheet(
      animationCurve: Curves.easeInToLinear,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      shadow: BoxShadow(
        color: Colors.transparent
      ),
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
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)
                    ),
                    // color: Color.fromRGBO(217, 217, 217, 0.8),
                    color:  Colors.white,
                    // backgroundBlendMode: BlendMode.color,
                  ),
                  // width: screenWidth > 60 ? MediaQuery.of(context).size.width * 0.6 : null,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.62,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(217, 217, 217, 0.8),
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
                                                          SizedBox(width: 10,),
                                                          Container(
                                                            alignment: Alignment.center,
                                                            child: const Text(
                                                              'C.',
                                                              style: TextStyle(
                                                                  color: Color(0xFF111111),
                                                                  decoration: TextDecoration.none,
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w500),
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
                                                          SizedBox(width: 5,),
                                                          Container(
                                                            alignment: Alignment.center,
                                                            child: const Text(
                                                              'P. U',
                                                              style: TextStyle(
                                                                  color: Color(0xFF111111),
                                                                  decoration: TextDecoration.none,
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w500),
                                                            ),
                                                          ),
                                                          SizedBox(width: 20,),
                                                          Container(
                                                            alignment: Alignment.center,
                                                            child: const Text(
                                                              'T.',
                                                              style: TextStyle(
                                                                  color: Color(0xFF111111),
                                                                  decoration: TextDecoration.none,
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w500),
                                                            ),
                                                          ),
                                                          SizedBox(width: 20,),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
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
                                              if(printerIP != null){
                                                List<Producto> listProduct= [];
                                                for (int i = 0; i < listadoDetalle.length; i++) {
                                                  Detalle_Pedido detalle = listadoDetalle[i];
                                                  Producto originalProducto = ListadoProductos.firstWhere((producto) => producto.id == detalle.id_producto);

                                                  Producto producto = Producto(
                                                      id: originalProducto.id,
                                                      nombreproducto: originalProducto.nombreproducto,
                                                      foto: originalProducto.foto,
                                                      codigo_interno: originalProducto.codigo_interno,
                                                      categoria_id: originalProducto.categoria_id,
                                                      stock: detalle.cantidad_producto,
                                                      precioproducto: detalle.precio_unitario
                                                    // Copiar otras propiedades necesarias
                                                  );
                                                  // Producto producto = ListadoProductos.firstWhere((producto) => producto.id == detalle.id_producto);
                                                  // producto.stock = detalle.cantidad_producto;
                                                  // producto.precioproducto = detalle.precio_unitario;
                                                  print(producto.toJson());
                                                  listProduct.add(producto);
                                                }
                                                listProduct.forEach((element) {
                                                  print(' - ${element.toJson()}');
                                                });
                                               // impresora.printLabel(printerIP,listProduct,3, listPedido.montoTotal!, AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).nombreMesa , mozo!, ListadoPisos.firstWhere((element) => element.id == AllListadoMesas.firstWhere((element) => element.id == listPedido.idMesa).pisoId),'');
                                                print('Imprimir');
                                              }else{
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text('Error'),
                                                      content: const Text('No se ha encontrado ninguna impresora.'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text('OK'),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            Navigator.pushNamed(context, 'home/ajustes');
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.print),
                                            tooltip: 'Imprimir',
                                            color: Colors.white,
                                          ),
                                        ),

                                        // --BT ANULAR
                                        // Container(
                                        //   decoration: const BoxDecoration(
                                        //       color: Colors.redAccent,
                                        //       shape: BoxShape.circle
                                        //   ),
                                        //   child: IconButton(
                                        //     onPressed: () async {
                                        //       List<Producto> listProduct= [];
                                        //       List<Pedido> listCompar = listaPedido ;
                                        //       String? printerIP = await _pref.read('ipCocina');
                                        //       if(printerIP != null){
                                        //         for (int i = 0; i < listadoDetalle.length; i++) {
                                        //           Detalle_Pedido detalle = listadoDetalle[i];
                                        //           Producto producto = ListadoProductos.firstWhere((producto) => producto.id == detalle.id_producto);
                                        //           producto.stock = detalle.cantidad_producto;
                                        //           listProduct.add(producto);
                                        //         }
                                        //         mostrarDialogoAnulacion( printerIP, listProduct  ,listPedido ,context).then((value) async {
                                        //           listaPedido = await dbPedido.obtenerListasPedidos(_subOptType, idEstablecimiento,context);
                                        //           consultarMesas(pisoSelect, context);
                                        //           refresh();
                                        //         });
                                        //         refresh();
                                        //       }else{
                                        //         showDialog(
                                        //           context: context,
                                        //           builder: (BuildContext context) {
                                        //             return AlertDialog(
                                        //               title: const Text('Error'),
                                        //               content: const Text('No se ha encontrado ninguna impresora.'),
                                        //               actions: <Widget>[
                                        //                 TextButton(
                                        //                   child: const Text('OK'),
                                        //                   onPressed: () {
                                        //                     Navigator.of(context).pop();
                                        //                     Navigator.pushNamed(context, 'home/ajustes');
                                        //                   },
                                        //                 ),
                                        //               ],
                                        //             );
                                        //           },
                                        //         );
                                        //       }
                                        //     },
                                        //     icon: const Icon(Icons.cancel_outlined),
                                        //     tooltip: 'Anular',
                                        //     color: Colors.white,
                                        //   ),
                                        // ),
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
            ),
          ),
        );
      },
    ).then((_) {
      _isModalOpen = false; // Restablecer el estado del modal cuando se cierre
    });
  }
  // ----LS
  Widget _producList(List<Detalle_Pedido> detalleList) {
    List<Widget> rows = [];

    for (int i = 0; i < detalleList.length; i++) {
      Detalle_Pedido detalle = detalleList[i];
      Future<Producto?> producto =  _getProductoPorId(detalle.id_producto);

      rows.add(
        Container(
          margin: const EdgeInsets.all(5),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Expanded(
                //   child: Container(
                //     alignment: Alignment.center,
                //     child: Text(
                //       '${detalle.cantidad_producto}',
                //       style: const TextStyle(
                //           color: Color(0xFF111111),
                //           decoration: TextDecoration.none,
                //           fontSize: 16,
                //           fontWeight: FontWeight.w500),
                //     ),
                //   ),
                // ),
                SizedBox(width: 10,),
                Text(
                  '${detalle.cantidad_producto}',
                  style: const TextStyle(
                      color: Color(0xFF111111),
                      decoration: TextDecoration.none,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${producto.then((value) => value!.nombreproducto)}',
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
                SizedBox(width: 10,),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    '${detalle.precio_unitario}',
                    style: const TextStyle(
                        color: Color(0xFF111111),
                        decoration: TextDecoration.none,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(width: 10,),
                Container(
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
                SizedBox(width: 10,),

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

        if(mesa.estadoMesa == 1){
          print('ENTRAR MESA STATUS ${mesa.toJson()}');
          Navigator.pushNamed(context, 'home/productos', arguments: mesa);
        }
        else {
          print('ENTRAR MESA STATUS  ${mesa.toJson()}');
          Map<String, dynamic> pedidoRespuesta =  await dbDetallePedido.fetchPedidoDetalle(usuario!.accessToken, mesa.id  );
          String? mozo = await dbMesas.obtenerMozoxMesa(mesa.id, usuario!.accessToken);
          print('PEDIDO OBTENIDO POR MESA ${pedidoRespuesta.toString()}');
          Pedido pedido = pedidoRespuesta['pedido_detalle'] ;
          /*if(pedido.idUsuario != usuario?.user?.id){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Mensaje'),
                  content: Text('La Mesa ya esta ocupada por el Mozo : $mozo'),
                  actions: <Widget>[
                    TextButton(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(2),
                          backgroundColor: MaterialStateProperty.all(Color(0xFFFF562F))),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                );
              },
            );
          }
          else {*/
            if (pedido.idPedido != null && pedido.detalle != null) {
              // Itera sobre la lista de detalles y actualiza el id_pedido
              for (var detalle in pedido.detalle!) {
                detalle.id_pedido = pedido.idPedido;
                print('PRECIO 2222 ${detalle.toJson()}');
              }
            }
            List<Detalle_Pedido>? detallePedido = [];
            detallePedido = pedido.detalle;

            // sin usarse
            print('-------LISTADO DE INSTANCIA $detallePedido');
            MesaDetallePedido mesaDetallePedido = MesaDetallePedido(mesa, detallePedido!);
            print('${detallePedido[0].toJson()}');
            Navigator.pushNamed(context, 'home/productos', arguments: mesaDetallePedido);
          }
        //}

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
                      padding: int.parse('${mesa.estadoMesa}') > 1 ? const EdgeInsets.all(15.0) : const EdgeInsets.only(right: 30, left: 30, top: 72 ),
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


  Future<void> _showMyDialog(BuildContext context) async {
    List<Mesa> listadoMesaDisponibleOrigen = [];
    List<Mesa> listadoMesaDisponibleDestino = [];
    Mesa? selectedMesaOrigen;
    Mesa? selectedMesaDestino;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar Mesa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Mesa Origen :', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8), // Space between text and dropdown
                    FutureBuilder<List<Mesa>>(
                      future: dbMesas.getAllxEstado(usuario!.accessToken, 3),
                      builder: (BuildContext context, AsyncSnapshot<List<Mesa>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Color( 0xFFFF562F),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No hay mesas disponibles');
                        }

                        listadoMesaDisponibleOrigen = snapshot.data!;
                        return DropdownButtonFormField<Mesa>(
                          value: selectedMesaOrigen,
                          items: listadoMesaDisponibleOrigen.map((Mesa mesaOrigen) {
                            return DropdownMenuItem<Mesa>(
                              value: mesaOrigen,
                              child: Text('${mesaOrigen.nombreMesa} - ${mesaOrigen.nombrePiso}'), // Cambia esto según cómo desees mostrar los datos
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30), // Ovalado
                            ),
                            filled: true,
                            hintText: 'Seleccionar Mesa',
                            fillColor: Colors.grey[200], // Color de fondo
                          ),
                          onChanged: (Mesa? value) {
                            setState(() {
                              selectedMesaOrigen = value;
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Text('Mesa Destino :', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8), // Space between text and dropdown
                    FutureBuilder<List<Mesa>>(
                      future: dbMesas.getAllxEstado(usuario!.accessToken, 1),
                      builder: (BuildContext context, AsyncSnapshot<List<Mesa>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Color( 0xFFFF562F),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No hay mesas disponibles');
                        }

                        listadoMesaDisponibleDestino = snapshot.data!;
                        return DropdownButtonFormField<Mesa>(
                          value: selectedMesaDestino,
                          items: listadoMesaDisponibleDestino.map((Mesa mesaDestino) {
                            return DropdownMenuItem<Mesa>(
                              value: mesaDestino,
                              child: Text('${mesaDestino.nombreMesa!} - ${mesaDestino.nombrePiso}'), // Cambia esto según cómo desees mostrar los datos
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30), // Ovalado
                            ),
                            filled: true,
                            hintText: 'Seleccionar Mesa',
                            fillColor: Colors.grey[200], // Color de fondo
                          ),
                          onChanged: (Mesa? value) {
                            setState(() {
                              selectedMesaDestino = value;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
                // Aquí puedes agregar el DropdownButton para la "Mesa Destino" de manera similar
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all( Color.fromRGBO(217, 217, 217, 0.8) ),
              ),
              child: const Text('Cancel',style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.redAccent)),
              child: const Text('OK',style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (selectedMesaOrigen != null && selectedMesaDestino != null) {
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.info,
                      animType: AnimType.rightSlide,
                      title: 'Cambio de ${selectedMesaOrigen!.nombreMesa} a ${selectedMesaDestino!.nombreMesa} ',
                      desc: '¿Estás seguro de que deseas cambiar la mesa?',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () async {
                        PedidoResponse? response = await  dbMesas.cambiarMesa(selectedMesaOrigen!.id, usuario!.accessToken, selectedMesaDestino!.id);
                        if (response != null) {
                          if (response.status == true) {
                            agregarMsj(response.mensaje ?? 'Mensaje sin contenido', true);
                            Navigator.pushNamed(context, 'home');
                          } else {
                            agregarMsj(response.mensaje ?? 'Mensaje sin contenido', false);
                          }
                        } else {
                          agregarMsj('Respuesta nula del servidor', false);
                        }
                      },
                  )..show();

                }else{
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.info,
                    animType: AnimType.rightSlide,
                    title: 'Atención',
                    desc: 'Seleccione las mesas para hacer el cambio de pedido',
                    btnOkOnPress: () {},
                  )..show();
                }
              },
            ),
          ],
        );
      },
    );
  }
  // Future<void> mostrarDialogoAnulacion(String printerIP, List<Producto> listProduct ,Pedido pedido, BuildContext context) async {
  //   String motivo = '';
  //   bool motivoVacio = false;
  //   bool usarMotivoPorDefecto = false;
  //
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return AlertDialog(
  //             // backgroundColor: Color.fromRGBO(217, 217, 217, 1.0),
  //             title: Text('Anular pedido : ${pedido.correlativoPedido}'),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Checkbox(
  //                       activeColor: Color( 0xFFFF562F),
  //                       value: usarMotivoPorDefecto,
  //                       onChanged: (newValue) {
  //                         setState(() {
  //                           usarMotivoPorDefecto = newValue!;
  //                           // Si se marca el checkbox, vaciamos el motivo del TextField
  //                           if (usarMotivoPorDefecto) {
  //                             motivo = '';
  //                             motivoVacio = false;
  //                           }
  //                         });
  //                       },
  //                     ),
  //                     Text('Usar motivo por defecto'),
  //                   ],
  //                 ),
  //                 TextField(
  //                   onChanged: (value) {
  //                     motivo = value;
  //                     setState(() {
  //                       // motivoVacio = motivo.isEmpty;
  //                       motivoVacio = motivo.isEmpty && !usarMotivoPorDefecto;
  //                     });
  //                   },
  //                   enabled: !usarMotivoPorDefecto,
  //                   // decoration: InputDecoration(
  //                   //   labelText: 'Motivo de anulación',
  //                   //   errorText: motivoVacio ? 'Este campo no puede estar vacío' : null,
  //                   //   focusedBorder: UnderlineInputBorder(
  //                   //     borderSide: BorderSide(color: motivoVacio ? Colors.red : Theme.of(context).primaryColor),
  //                   //   ),
  //                   // ),
  //                   decoration: InputDecoration(
  //                       labelText: 'Motivo de anulación',
  //                       hintText: 'Ej. Abandono de mesa',
  //                       errorText: motivoVacio ? 'Este campo no puede estar vacío' : null,
  //                       border:OutlineInputBorder(
  //                           borderSide: BorderSide(
  //                               color: Colors.black
  //                           )
  //                       ),
  //                       floatingLabelStyle: TextStyle(fontSize: 15, color: Color(0xFF000000)),
  //                       hintStyle: TextStyle(
  //                           fontSize: 15,
  //                           color: Color(0xFF000000)
  //                       ),
  //                       enabledBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(20),
  //                         borderSide: BorderSide(
  //                             color: Color(0xFF000000),
  //                             width: 2
  //                         ),
  //                       ),
  //                       focusedBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(20),
  //                         borderSide: BorderSide(
  //                             color: motivoVacio ? Colors.red : Color(0xFF000000),
  //                             width: 2
  //                         ),
  //                       ),
  //                       contentPadding: EdgeInsets.all(10),
  //                       // prefixIcon: Icon(Icons.print, color: Colors.black),
  //                       // error
  //                       errorBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(20),
  //                         borderSide: BorderSide(
  //                             color: motivoVacio ? Colors.red : Color(0xFF000000),
  //                             width: 2
  //                         ),
  //                       ),
  //                       focusedErrorBorder: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(20),
  //                         borderSide: BorderSide(
  //                             color: motivoVacio ? Colors.red : Color(0xFF000000),
  //                             width: 2
  //                         ),
  //                       ),
  //                     disabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(20),
  //                       borderSide: BorderSide(
  //                           color: Colors.grey,
  //                           width: 2
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             actions: <Widget>[
  //               TextButton(
  //                 style: ButtonStyle(
  //                   backgroundColor: MaterialStateProperty.all( Color.fromRGBO(217, 217, 217, 0.8) ),
  //                 ),
  //                 child: Text('Cancelar',style: TextStyle(color: Colors.black),),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //               TextButton(
  //                 style: ButtonStyle(
  //                   backgroundColor: MaterialStateProperty.all( Colors.redAccent ),
  //                 ),
  //                 child: Text('Anular',style: TextStyle(color: Colors.white),),
  //                 onPressed: () {
  //                   // if (motivo.isEmpty) {
  //                   //   setState(() {
  //                   //     motivoVacio = true;
  //                   //   });
  //                   // } else {
  //                   //   impresora.printLabel( printerIP, listProduct ,4, pedido.montoTotal!, AllListadoMesas.firstWhere((element) => element.id == pedido.idMesa).nombreMesa, mozo!, ListadoPisos.firstWhere((element) => element.id == AllListadoMesas.firstWhere((element) => element.id == pedido.idMesa).pisoId),motivo);
  //                   //   dbMesas.actualizarMesa(pedido.idMesa, 1, context);
  //                   //   dbPedido.anularPedido(motivo, mozo!, pedido.idPedido!, context);
  //                   //   Navigator.of(context).pop();
  //                   //   refresh();
  //                   // }
  //                   String motivoFinal = usarMotivoPorDefecto ? 'Motivo por defecto' : motivo;
  //
  //                   if (motivoFinal.isEmpty && !usarMotivoPorDefecto) {
  //                     setState(() {
  //                       motivoVacio = true;
  //                     });
  //                   } else {
  //                     impresora.printLabel(
  //                         printerIP, listProduct, 4, pedido.montoTotal!, AllListadoMesas.firstWhere((element) => element.id == pedido.idMesa).nombreMesa, mozo!,
  //                         ListadoPisos.firstWhere((element) => element.id == AllListadoMesas.firstWhere((element) => element.id == pedido.idMesa).pisoId),
  //                         motivoFinal);
  //                     //dbMesas.actualizarMesa(pedido.idMesa, 1, context); API ACTIALZIAR MESA
  //                     dbPedido.anularPedido(motivoFinal, mozo!, pedido.idPedido!, context);
  //                     // refresh();
  //                     Navigator.of(context).pop();
  //                     Navigator.pop(context);
  //                   }
  //                   refresh();
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  void agregarMsj(String mensaje, bool estado) {
    Fluttertoast.showToast(
        msg: mensaje,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: estado == true ? Colors.green : Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
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

  void refreshTabController(){
    setState(() {
      _tabController = TabController( length: 1, vsync: this);
    });
  }

  Future<Producto?> _getProductoPorId(int? idProducto) async {
    try {
      String productosJson = await _pref.read('productos');
      if (productosJson.isNotEmpty) {
        List<dynamic> productosData = json.decode(productosJson);
        // Busca el producto con el ID dado
        for (var productoJson in productosData) {
          Producto producto = Producto.fromJson(productoJson);
          if (producto.id == idProducto) {
            return producto;
          }
        }
      }
    } catch (e) {
      print('Error al obtener el producto por ID: $e');
    }
    return null; // Devuelve null si no se encuentra el producto
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

  void showDialogBox(String title, String content) => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');
            setState(() => isAlertSet = false);
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox('No Connection', 'Please check your internet connectivity');
              setState(() => isAlertSet = true);
            }
            if (!wifi && isAlertSet == false) {
              showDialogBox('No WiFi', 'WiFi is not connected.');
              setState(() => isAlertSet = true);
            }
            if (datos && isAlertSet == false) {
              showDialogBox('Mobile Data Active', 'Please turn off your mobile data.');
              setState(() => isAlertSet = true);
            }

          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class NonScrollablePageView extends StatelessWidget {
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final List<Widget> children;

  const NonScrollablePageView({
    Key? key,
    required this.controller,
    required this.onPageChanged,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      onPageChanged: onPageChanged,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
      physics: NeverScrollableScrollPhysics(), // Deshabilita el desplazamiento
    );
  }
}