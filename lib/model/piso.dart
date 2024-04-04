import 'dart:convert';

Piso responseApiFromJson(String str) => Piso.fromJson(json.decode(str));
String responseApiToJson(Piso data) => json.encode(data.toJson());


class Piso {
  int id;
  int idEstablecimiento;
  String nombrePiso;
  bool estado;

  Piso({
    required this.id,
    required this.nombrePiso,
    required this.estado,
    this.idEstablecimiento = 0,
  });

  factory Piso.fromJson(Map<String, dynamic> json) {
    return Piso(
      id: json['idPrimaria'],
      idEstablecimiento: json['id_establecimiento'],
      nombrePiso: json['nombre_piso'],
      estado: json['estado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPrimaria': id,
      'id_establecimiento': idEstablecimiento,
      'nombre_piso': nombrePiso,
      'estado': estado ? 1 : 0,
    };
  }
}
