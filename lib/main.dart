import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:restauflutter/home/home_page.dart';
import 'package:restauflutter/home/wifiConnect/wifiConnect_page.dart';
import 'package:restauflutter/login/login_page.dart';
import 'package:restauflutter/home/productos/productos_page.dart';

import 'home/ajustes/ajustes_page.dart';

void main()  async {
  WidgetsFlutterBinding.ensureInitialized();

  // Consulta de conectividad de red WiFi
  var connectivityResult = await Connectivity().checkConnectivity();
  bool isWifiConnected = connectivityResult.contains(ConnectivityResult.wifi);
  bool isDatosConnected = connectivityResult.contains(ConnectivityResult.mobile);

  String initialRoute;
  if(isDatosConnected == true) {
    initialRoute = 'home/wifiConnect';
  }else {
    initialRoute = isWifiConnected ? 'login' : 'home/wifiConnect';
  }
  // Determinar la ruta inicial en función de la conectividad de WiFi

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  var connectivityResult =  Connectivity().checkConnectivity();

   MyApp({required this.initialRoute, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: initialRoute,
      routes: {
        'home/wifiConnect': (_) => WifiConnect(),
        'login': (_) => LoginPage(),
        'home/productos': (_) => ProductosPage(),
        'home': (_) => HomePage(),
        'home/ajustes': (_) => AjustesPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == 'login' || settings.name == 'home/wifiConnect') {
          return MaterialPageRoute(
            builder: (context) => settings.name == 'login' ? LoginPage() : WifiConnect(),
          );
        } else {
          // Verificar la conectividad WiFi antes de mostrar otras rutas
          return MaterialPageRoute(
            builder: (context) {
              return FutureBuilder<List<ConnectivityResult>>(
                future: Connectivity().checkConnectivity(),
                builder: (context, AsyncSnapshot<List<ConnectivityResult>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Si estamos esperando la respuesta de la consulta, mostramos un indicador de carga
                    return Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    // Verificar si hay conexión WiFi
                    bool isWifiConnected = snapshot.data != null && snapshot.data!.contains(ConnectivityResult.wifi);
                    if (isWifiConnected) {
                      // Si hay conexión WiFi, mostramos la ruta solicitada
                      switch (settings.name) {
                        case 'home':
                          return HomePage();
                        case 'home/productos':
                          return ProductosPage();
                        case 'home/ajustes':
                          return AjustesPage();
                        default:
                          return Scaffold(
                            body: Center(
                              child: Text('Ruta desconocida'),
                            ),
                          );
                      }
                    } else {
                      // Si no hay conexión WiFi, redirigimos a la pantalla de conexión WiFi
                      return WifiConnect();
                    }
                  }
                },
              );

            }
          );
        }
      },
    );
  }
}
