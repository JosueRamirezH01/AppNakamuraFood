
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'dart:convert';



class SharedPref {

  Future<void>  save (String key,  value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) == null) return null;
    return json.decode(prefs.getString(key).toString());
  }

  // Nombre - true - false
  // SI EXISTE UN VALOR CON UNA KEY ESTABLECIDA
  Future<bool> contains(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
  void logout(BuildContext context, String idUsuario) async {

    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

}

