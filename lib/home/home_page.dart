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
  int _selectedIndex = 0;

  Calendar calendarView = Calendar.week;
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'PISO 1'),
    Tab(text: 'PISO 2'),

  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: const Color(0xFF000000),
    elevation: 5
  );
  static final ButtonStyle selectedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF562F), // Cambia el color de fondo cuando está seleccionado
    foregroundColor: Colors.white, // Cambia el color del texto cuando está seleccionado
    elevation: 5
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                      _tabController.animateTo(0);
                    });
                  },
                  icon: Icon(Icons.list_alt_rounded),
                  label: const Text('Listado de pedidos'),
                  style: _selectedIndex == 0 ? selectedButtonStyle : elevatedButtonStyle,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                      _tabController.animateTo(1);
                    });
                  },
                  icon: Icon(Icons.shopping_cart_outlined),
                  label: const Text('POS'),
                  style: _selectedIndex == 1 ? selectedButtonStyle : elevatedButtonStyle,
                ),
              ],
            ),
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(top: 15),
          child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              child: Container(
                color: const Color(0xFFD9D9D9), // Fondo de color D9D9D9
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Vista para 'Listado de pedidos'
                    Center(
                      child: Column(
                        children: [
                          Container(
                            child: subopt(),
                            margin: const EdgeInsets.all(15),
                          ),
                         Expanded(
                            child: pedidosList(),
                          ),
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
                                      SizedBox(width: 20),
                                      Icon(Icons.table_bar_sharp, size: 30),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: TabBar(
                                          tabs: myTabs,
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
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                    ),
                  ],
                ),
              )
          ),
        )
    );
  }

  Widget _textFieldSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        child: TextField(
          decoration: InputDecoration(

              hintText: 'Buscar',
              suffixIcon: const Icon(Icons.search, color: Color(0xFF000000)),
              hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF000000)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5)),
              contentPadding: const EdgeInsets.all(10)),
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Color(0xFF000000), width: 2),
        ),
      ),

      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
          value: Calendar.day,
          label: SizedBox(
          width: 53,
          child: Center(child: Text('Local')
          ),
        ),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.week,
          label: SizedBox(
            width: 53,
            child: Center(child: Text('llevar')),
          ),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.month,
          label: SizedBox(
            width: 53,
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
    return Container(
      decoration: const BoxDecoration(
        color: const Color(0xFF414141),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFD1D1D1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textFieldSearch(),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pedido'),
                    Text('Cliente'),
                    Text('Estado'),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Pedido ${index + 1}'),
                        subtitle: Text('Cliente ${index + 1}'),
                        trailing: const Text('Estado'),
                        onTap: () {
                          // Lógica cuando se toca un pedido
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
