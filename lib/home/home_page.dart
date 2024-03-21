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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: options.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                        },
                        child: Text('Button 1'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                        },
                        child: Text('Button 2'),
                      ),
                    ],
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
