

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restauflutter/model/mozo.dart';
import 'package:restauflutter/utils/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  late BuildContext context;
  late Function refresh;
  final SharedPref _pref = SharedPref();
  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    final dynamic userData = await _pref.read('user_data');
    if (userData != null) {
      final Map<String, dynamic> userDataMap = json.decode(userData);
      final Mozo mozo = Mozo.fromJson(userDataMap);
      if (mozo.email != null) {
        print('Establecimiento del usuario  ${mozo.id_establecimiento}');
        Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
      }
    }

    refresh();
  }
}