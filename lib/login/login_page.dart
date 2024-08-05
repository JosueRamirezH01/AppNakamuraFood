
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:restauflutter/login/login_controller.dart';
import 'package:restauflutter/model/usuario.dart';
import 'package:restauflutter/services/login_service.dart';

import '../utils/shared_pref.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final LoginController _con = LoginController();
  var dbSQL = LoginService();
  String email = '';
  String password = '';
  bool _rememberMe = false;
  SharedPref _pref = SharedPref();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readCredentials();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }
  void readCredentials() {
    _pref.read('email').then((value) {
      setState(() {
        _emailController.text = value as String? ?? '';
        email = _emailController.text;
      });
    });

    _pref.read('password').then((value) {
      setState(() {
        _passwordController.text = value as String? ?? '';
        password = _passwordController.text;
      });
    });
  }

  void _saveCredentials() async {
      _pref.save('email', _emailController.text);
      _pref.save('password', _passwordController.text);
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
               Container(
                 alignment: AlignmentDirectional.bottomStart,
                   child: IconButton(onPressed: (){
                     _con.configurarApi();
                   }, icon:Icon(Icons.settings, color: Colors.grey, size: 40,))),
                const Padding(
                  padding: EdgeInsets.only(left: 30, top: 50),
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
                        email= value;
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
                        controller: _passwordController,
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
                          password = _passwordController.text;
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
                      var url = await _pref.read('url');
                      print('URL guardada: $url');
                      if(url != null){
                        Usuario? saveCredentials = await dbSQL.login(email, password,context);;
                        print('CREDENCIALES ${saveCredentials}');
                        if(saveCredentials?.accessToken != null){
                          _saveCredentials();
                        }

                      }else {
                        _con.configurarApi();
                      }


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
