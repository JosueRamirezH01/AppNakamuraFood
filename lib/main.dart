import 'package:flutter/material.dart';
import 'package:restauflutter/home/details/datails_page.dart';
import 'package:restauflutter/home/home_page.dart';
import 'package:restauflutter/login/login_page.dart';
import 'package:restauflutter/home/productos/productos_page.dart';

void main() {
  runApp( const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: 'home',
      routes: {
        'login': (_) =>  LoginPage(),
        'home/productos': (_) => ProductosPage(),
        'home':(_)=>HomePage(),
        'home/details': (_) =>DetailsPage()
      },
    );
  }
}