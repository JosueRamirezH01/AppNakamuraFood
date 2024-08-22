import 'package:flutter/material.dart';

class Mesa {
  int? id;
  String? nombreMesa;
  int? estadoMesa;
  String? nombrePiso;
  TimeOfDay? tiempoMesa;
  int? tipoPedido;
  int? pisoId;
  List<Mesa> listMesa = [];

  Mesa({
    this.id,
    this.nombreMesa,
    this.nombrePiso,
    this.estadoMesa,
    this.tiempoMesa,
    this.pisoId,
  });

  Mesa.fromJsonList(List<dynamic> jsonList) {
    try {
      jsonList.forEach((item) {
        Mesa mesa = Mesa.fromJson(item);
        listMesa.add(mesa);
      });
    } catch (e) {
      return;
    }}

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['id_mesa'],
      nombreMesa: json['nombre_mesa'],
      estadoMesa: json['estado_mesa'],
      nombrePiso: json['nombre_piso'],
      tiempoMesa:  json['tiempo_mesa'],
      pisoId: json['piso_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mesa': id,
      'nombre_mesa': nombreMesa,
      'nombre_piso': nombrePiso,
      'estado_mesa': estadoMesa,
      'tiempo_mesa': tiempoMesa,
      'tipo_pedido': pisoId,
    };
  }
}
