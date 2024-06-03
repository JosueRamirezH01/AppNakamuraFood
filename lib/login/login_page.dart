
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:password_hash_plus/password_hash_plus.dart';
import 'package:restauflutter/bd/conexion.dart';
import 'package:restauflutter/login/login_controller.dart';
import 'package:restauflutter/services/login_service.dart';
import 'package:restauflutter/services/producto_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final LoginController _con = LoginController();
  var dbSQL = LoginService();
  String email = '';
  String password = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 19),
      body: GestureDetector(
        onTap: () {
          _emailFocus.unfocus();
          _passwordFocus.unfocus();
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 30, top: 80),
                  child: Image(image: AssetImage('assets/img/Background.png')),
                ),
                const SizedBox(height: 30),
                _centro(),
                const SizedBox(height: 60),
                const Text('970 333 599/946 285 690',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                const Text('Calle las camelias 657 San Isidro, Lima',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
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
                      controller: _emailController,
                      focusNode: _emailFocus,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Ingresar su usuario',
                        labelText: 'Usuario',
                        border: UnderlineInputBorder(borderSide: BorderSide(width: 20))
                      ),
                      onChanged: (value) {
                        email = value; // Actualiza el valor de email cada vez que cambia el texto
                      },
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
                        obscureText: true,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.lock),
                            hintText: 'Ingresar su password',
                            labelText: 'Password',
                            border: UnderlineInputBorder(borderSide: BorderSide(width: 20))
                        ),
                        onChanged:(String? value) {
                          password = value!;
                        },
                        onSaved: (String? value) {

                        },
                        validator: (String? value) {
                          return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
                        },
                      )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: ElevatedButton(onPressed: () async {
                      print(email);
                      print(password);
                      await dbSQL.consultarUsuarios(email,password,context);
                    }, style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.deepOrange),
                    ), child: const Text('Iniciar Session', style: TextStyle(color: Colors.white, fontSize: 20),),),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
  void refresh(){
    setState(() {

    });
  }
}
