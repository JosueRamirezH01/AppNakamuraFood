import 'package:flutter/material.dart';

class Mesa {
  final int id;
  final String nombreMesa;
  final String estDisMesa;
  final int estadoMesa;
  final TimeOfDay tiempoMesa;
  final int pisoId;

  Mesa({
    required this.id,
    required this.nombreMesa,
    required this.estDisMesa,
    required this.estadoMesa,
    required this.tiempoMesa,
    required this.pisoId,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: json['idPrimaria'],
      nombreMesa: json['nombre_mesa'],
      estDisMesa: json['est_dis_mesa'],
      estadoMesa: json['estado_mesa'],
      tiempoMesa: TimeOfDay.fromDateTime(DateTime.parse(json['tiempo_mesa'])),
      pisoId: json['piso_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPrimaria': id,
      'nombre_mesa': nombreMesa,
      'est_dis_mesa': estDisMesa,
      'estado_mesa': estadoMesa,
      'tiempo_mesa': tiempoMesa.toString(),
      'piso_id': pisoId,
    };
  }
}
