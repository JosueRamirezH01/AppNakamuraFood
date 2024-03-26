
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:restauflutter/bd/conexion.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  var db = Connection();
  var email = '';

  void _getCustomer() async {
    MySqlConnection? conn;
    try {
      conn = await db.getConnection();
      String sql = 'select email from usuarios where id = 42;';
      var results = await conn.query(sql);
      for (var row in results) {
        setState(() {
          email = row[0];
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      await conn?.close();
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          backgroundColor: const Color.fromARGB( 255, 19, 19, 19),
          body: GestureDetector(
            onTap: () {
              _emailFocus.unfocus();
              _passwordFocus.unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 30, top:80 ),
                    child: Image(image: AssetImage('assets/img/Background.png')),
                  ),
                  const SizedBox(height: 30),
                  _centro(),
                  const SizedBox(height: 60),
                  const Text('970 333 599/946 285 690', style: TextStyle(color: Colors.white ,  fontSize: 16),),
                  const Text('Calle las camelias 657 San Isidro, Lima', style: TextStyle(color: Colors.white ,  fontSize: 16),),

                ],
              ),
            ),
          ),
    );
  }
  Widget _centro(){
    return SizedBox(
        width:  MediaQuery.of(context).size.width * 0.9,
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Center(
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Bienvenido', style: TextStyle(fontSize: 50, color: Colors.cyan)),
                   Text('Ingrese a tu cuenta', style: const TextStyle(fontSize: 20),),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                    child: TextFormField(
                      focusNode: _emailFocus,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Ingresar su usuario',
                        labelText: 'Usuario',
                        border: UnderlineInputBorder(borderSide: BorderSide(width: 20))
                      ),
                      onSaved: (String? value) {
                      },
                      validator: (String? value) {
                        return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
                      },
                    )
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: TextFormField(
                        focusNode: _passwordFocus,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.lock),
                            hintText: 'Ingresar su password',
                            labelText: 'Password',
                            border: UnderlineInputBorder(borderSide: BorderSide(width: 20))
                        ),
                        onSaved: (String? value) {
                        },
                        validator: (String? value) {
                          return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
                        },
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: ElevatedButton(onPressed: (){
                      Navigator.pushNamed(context, 'home');
                    }, style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.deepOrange),
                    ), child: const Text('Iniciar Sesion', style: TextStyle(color: Colors.white, fontSize: 20),),),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
