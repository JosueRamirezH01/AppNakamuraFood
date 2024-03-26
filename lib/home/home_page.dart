import 'package:flutter/material.dart';

const List<Widget> options = <Widget>[
  Text('Listado de pedidos'),
  Text('POS'),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum Calendar { day, week, month, year }

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _tabControllerToSubMenu;
  late List<bool> _isSelected;
  Calendar calendarView = Calendar.week;
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'PISO 1'),
    Tab(text: 'PISO 2'),

  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabControllerToSubMenu = TabController(length: 3, vsync: this);
    _isSelected = List.generate(3, (_) => false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabControllerToSubMenu.dispose();
    super.dispose();
  }

  void _updateSelection(int index) {
    setState(() {
      for (int buttonIndex = 0;
          buttonIndex < _isSelected.length;
          buttonIndex++) {
        if (buttonIndex == index) {
          _isSelected[buttonIndex] = true;
        } else {
          _isSelected[buttonIndex] = false;
        }
      }
    });
  }

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
    ),
    //backgroundColor: Colors.transparent,
    elevation: 5,
    foregroundColor: const Color(0xFF000000),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFFFA726),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  style: elevatedButtonStyle,
                  child: const Row(
                    children: [
                      Icon(Icons.list_alt),
                       SizedBox(width: 5),
                       Text('Listado de pedidos'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  style: elevatedButtonStyle,
                  child: Row(
                    children: [
                      Image.asset('assets/img/cart.png', ),
                      SizedBox(width: 5),
                      Text('POS'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: ClipRRect(
            child: Container(
              color: Colors.white, // Fondo de color D9D9D9
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Vista para 'Listado de pedidos'
                  Center(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(15),
                          child: subopt(),
                        ),
                        _textFieldSearch(),
                        //pedidosList()
                      ],
                    ),
                  ),
                  // Vista para 'POS'
                  Center(
                    child: Column(
                      children: [
                        // Otros widgets...
                        DefaultTabController(
                          length: myTabs.length,
                          child: Expanded(
                            child: Column(
                              children: [
                                    const Row(
                                      children: [
                                        SizedBox(width: 20 ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 15),
                                          child: Icon(Icons.table_bar_sharp, size: 30),
                                        ),
                                        SizedBox(width: 20),
                                        Expanded(
                                          child: TabBar(
                                            tabs: myTabs,
                                            labelStyle: TextStyle(fontSize: 16),
                                            labelPadding: EdgeInsets.only(left: 5),
                                            dividerColor: Colors.orange,
                                            indicatorColor: Colors.orange,
                                            labelColor: Colors.orange,
                                             ),
                                        ),
                                        Spacer()
                                      ],
                                    ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: TabBarView(
                                    children: myTabs.map((Tab tab) {
                                      return GridView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.7,
                                        ),
                                        itemCount: 8,
                                        itemBuilder: (_, index) {
                                          return _cardProduct();
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
                  )
                ],
              ),
            )));
  }

  Widget _textFieldSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 35),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Buscar',
            suffixIcon: const Icon(Icons.search, color: Color(0xFF000000)),
            hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF000000)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.grey)),
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }

  Widget subopt() {
    return SegmentedButton<Calendar>(
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: const Color(0xFF000000),
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: const Color(0xFFFF562F),
      ),

      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
          value: Calendar.day,
          label: SizedBox(
          width: 53, // Ancho fijo deseado
          child: Center(child: Text('Local')),
        ),),
        ButtonSegment<Calendar>(
          value: Calendar.week,
          label: SizedBox(
            width: 53, // Ancho fijo deseado
            child: Center(child: Text('llevar')),
          ),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.month,
          label: SizedBox(
            width: 53, // Ancho fijo deseado
            child: Center(child: Text('Delivery')),
          ),
        ),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          calendarView = newSelection.first;
        });
      },
    );
  }

  Widget pedidosList() {
    return Column(
      children: [
        _textFieldSearch(),
        Expanded(
          child: Container(
            child: const Text('Aquí empezaremos de cero'),
          ),
        ),
      ],
    );
  }

  Widget _cardProduct() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'home/productos');
      },
      child: SizedBox(
        child: Card(
          margin: const EdgeInsets.all(10),
          color: const Color(0xFF8EFF72),
          elevation: 3.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    height: 40,
                    child:  const Text(
                      'MESA 1',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.18,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child:  const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: FadeInImage(
                        image: AssetImage('assets/img/Vector.png'),
                        fit: BoxFit.contain,
                        color: Colors.black,
                        fadeInDuration: Duration(milliseconds: 50),
                        placeholder: AssetImage('assets/img/no-image.png'),
                      ),
                    ),
                  ),
                  const Center(
                      child:  Text(
                        'Disponible',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
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
}
