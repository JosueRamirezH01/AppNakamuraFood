


import '../utils/shared_pref.dart';

class Api {
  SharedPref _pref = SharedPref();


  Future<String> readApi() async {
    String urlString = await _pref.read('url');
    String url = urlString;
    return url;
  }
}