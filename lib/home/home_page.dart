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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _tabControllerToSubMenu;
  late List<bool> _isSelected;

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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
      side: BorderSide(color: Colors.black87, width: 2.0),
    ),
    //backgroundColor: Colors.transparent,
    foregroundColor: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  child: Text('Listado de pedidos'),
                  style: elevatedButtonStyle,
                ),
                ElevatedButton(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  child: Text('POS'),
                  style: elevatedButtonStyle,
                ),
              ],
            ),
          ),
        ),
        body: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            child: Container(
              color: Color(0xFFD9D9D9), // Fondo de color D9D9D9
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Vista para 'Listado de pedidos'
                  Center(
                    child: Column(
                      children: [
                         Container(

                         )
                      ],
                    ),
                  ),
                  // Vista para 'POS'
                  Center(
                    child: Column(
                      children: [
                        Text('Contenido de POS'),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget _textFieldSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        //onChanged: _con.onChangeText,
        decoration: InputDecoration(
            hintText: 'Buscar',
            suffixIcon: const Icon(Icons.search, color: Colors.grey),
            hintStyle: const TextStyle(fontSize: 17, color: Colors.grey),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Colors.grey)),
            contentPadding: const EdgeInsets.all(10)),
      ),
    );
  }
}
