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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: options.length, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: options.map((Widget option) {
              return ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(options.indexOf(option));
                },
                child: option,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Button border radius
                    side: BorderSide(color: Colors.black87, width: 2.0), // Button border color and width
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40)
        ),
        child: Container(
          color: Color(0xFFD9D9D9), // Fondo de color D9D9D9
          child: TabBarView(
            controller: _tabController,
            children: options.map((Widget option) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20), // Padding entre los ToggleButtons y el texto
                    child: ToggleButtons(
                      isSelected: _isSelected,
                      onPressed: (int index) {
                        _updateSelection(index);
                      },
                      children: [
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
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
