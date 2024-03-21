
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
          backgroundColor: Color.fromARGB( 255, 19, 19, 19),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, top:70 ),
                child: Image(image: AssetImage('assets/img/Background.png')),
              ),
              SizedBox(height: 10),
              _centro()
            ],
          ),
    );
  }
  Widget _centro(){
    return  Container(
      //width: ,
      margin: EdgeInsets.only(left: 15, right: 15),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Center(
          child: SizedBox(
            child: Column(
              children: [
                const Text('Bienvenido', style: TextStyle(fontSize: 50, color: Colors.cyan)),
                const Text('Ingresa a tu cuenta.', style: TextStyle(fontSize: 20),),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: TextFormField(
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
