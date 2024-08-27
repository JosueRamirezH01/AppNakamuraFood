import 'dart:convert';
import 'package:restauflutter/model/PedidoResponse.dart';
import 'package:restauflutter/model/mesa.dart';
import 'package:http/http.dart' as http;




class MesaServicio {

  final String _url = 'chifalingling.restaupe.com';
  final String _api = '/api/auth';



  Future<List<Mesa>> getAll(String? accessToken, int? id) async {
    try {
      Uri url = Uri.https(_url, '$_api/MesasporPisos/$id');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      Mesa mesa = Mesa.fromJsonList(data);
      return mesa.listMesa;
    } catch (e) {
      print('Error Mesa: $e');
      return [];
    }
  }

  Future<bool> consultarMesa(String? accessToken, int id) async {
    try {

      Uri url = Uri.https(_url, '$_api/obtenermesas/$id');
      print('${url}: ${url}');

      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);

      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body);
        String estadoMesaStr = data['estado_mesa'].toString();
        if (estadoMesaStr == "1") {
          return true;
        } else {
          return false;
        }
      } else {
        print('Error en la respuesta de la API: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      // Maneja las excepciones que puedan ocurrir
      print('Error al realizar la solicitud DELA MESA : $e');
      return false;
    }
  }

  Future<PedidoResponse?> actualizarMesa(int? idMesa,String? accessToken, int idEstado ) async {

    try {

      Uri url = Uri.https(_url, '$_api/actualizar_estado_mesa/$idMesa/$idEstado');
      print('${url}: ${url}');
      String bodiParams = json.encode({
        'estado': idEstado
      });
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      // Realiza la solicitud GET a la API
      final res = await http.post(url, headers: headers,body: bodiParams);
      final data = json.decode(res.body);
      if(res.statusCode == 200){
        PedidoResponse updateMesa = PedidoResponse.fromJson(data);
        print('MENSAJE DE ACTUALZIACION DE DATOS ${updateMesa.mensaje} Y ${updateMesa.status}');
      }else{
        print('ERROR ${res.statusCode}');
      }
      
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return null;
    }
    return null;
  }

  Future<List<Mesa>> getAllxEstado(String? accessToken, int? idEstado) async {
    try {
      Uri url = Uri.https(_url, '$_api/lista_mesas/$idEstado');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      // print('Datos recibidos: $data');
      Mesa mesa = Mesa.fromJsonList(data);
      // print('MESA LIST ${mesa.listMesa[0].toJson()}');
      return mesa.listMesa;
    } catch (e) {
      print('Error Mesa: $e');
      return [];
    }
  }

  void cambiar_mesa (String? accessToken, int id_mesaocupada) async {
    try{
      Uri url = Uri.https(_url, '$_api/MesasporPisos/$id_mesaocupada');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      final res = await http.get(url, headers: headers);
      final data = json.decode(res.body);
      print('Cambiar mesa : ${data}');
    }catch(e){
      print('error ${e}');
    }
  }
  Future<PedidoResponse?> cambiarMesa(int? mesaOcupada,String? accessToken, int? id_mesalibre ) async {

    try {

      Uri url = Uri.https(_url, '$_api/cambiar_mesa/$mesaOcupada');
      print('${url}: ${url}');
      String bodiParams = json.encode({
        "id_mesa":id_mesalibre
      });
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };
      // Realiza la solicitud GET a la API
      final res = await http.post(url, headers: headers,body: bodiParams);
      final data = json.decode(res.body);
      if(res.statusCode == 200){
        PedidoResponse updateMesa = PedidoResponse.fromJson(data);
        print('MENSAJE DE ACTUALZIACION DE DATOS ${updateMesa.mensaje} Y ${updateMesa.status}');
        return updateMesa;
      }else{
        print('ERROR ${res.statusCode}');
      }
    } catch (e) {
      print('Error al realizar la consulta: $e');
      return null;
    }
    return null;
  }
  }








