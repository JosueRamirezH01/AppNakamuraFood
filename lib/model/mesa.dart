import 'package:flutter/material.dart';

class Mesa {
  int? id;
  String? nombreMesa;
  String? estDisMesa;
  int? estadoMesa;
  TimeOfDay? tiempoMesa;
  int? pisoId;

  Mesa({
    this.id,
    this.nombreMesa,
    this.estDisMesa,
    this.estadoMesa,
    this.tiempoMesa,
    this.pisoId,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['id'],
      nombreMesa: json['nombre_mesa'],
      estDisMesa: json['est_dis_mesa'],
      estadoMesa: json['estado_mesa'],
      tiempoMesa:  json['tiempo_mesa'],
      pisoId: json['piso_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_mesa': nombreMesa,
      'est_dis_mesa': estDisMesa,
      'estado_mesa': estadoMesa,
      'tiempo_mesa': tiempoMesa,
      'piso_id': pisoId,
    };
  }
}
