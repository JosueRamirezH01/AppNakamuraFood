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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _isSelected = List.generate(3, (_) => false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateSelection(int index) {
    setState(() {
      for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
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
      borderRadius: BorderRadius.all( Radius.circular(40)),
      side: BorderSide(color: Colors.black87, width: 2.0),
    ),
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
                onPressed: null,
                child: Text('Listado de pedidos'),
                style: elevatedButtonStyle,
              ),
              ElevatedButton(
                onPressed: null,
                child: Text('POS'),
                style: elevatedButtonStyle,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Vista para 'Listado de pedidos'
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ToggleButtons(
                    isSelected: _isSelected,
                    onPressed: (int index) {
                      _updateSelection(index);
                    },
                    children: const [
                      Text('Local'),
                      Text('Llevar'),
                      Text('Delivery'),
                    ],
                    borderRadius: BorderRadius.circular(15),
                    selectedBorderColor: Colors.black87,
                    selectedColor: Colors.black87,
                    borderWidth: 2.0,
                    borderColor: Colors.black87,
                  ),
                ),
                Text('Contenido de Listado de pedidos'),
              ],
            ),
          ),
          // Vista para 'POS'
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ToggleButtons(
                    isSelected: _isSelected,
                    onPressed: (int index) {
                      _updateSelection(index);
                    },
                    children: const [
                      Text('Local'),
                      Text('Para Llevar'),
                      Text('Delivery'),
                    ],
                    borderRadius: BorderRadius.circular(15),
                    selectedBorderColor: Colors.black87,
                    selectedColor: Colors.black87,
                    borderWidth: 2.0,
                    borderColor: Colors.black87,
                  ),
                ),
                Text('Contenido de POS'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}