import 'dart:convert';

Piso responseApiFromJson(String str) => Piso.fromJson(json.decode(str));
String responseApiToJson(Piso data) => json.encode(data.toJson());


class Piso {
  int? id;
  int? idEstablecimiento;
  String? nombrePiso;
  int? estado;
  List<Piso> listPiso = [];
  Piso({
     this.id,
     this.nombrePiso,
     this.estado,
    this.idEstablecimiento,
  });

  Piso.fromJsonList(List<dynamic> jsonList) {
    try {
      jsonList.forEach((item) {
        Piso piso = Piso.fromJson(item);
        listPiso.add(piso);
      });
    } catch (e) {
      return;
    }}

  factory Piso.fromJson(Map<String, dynamic> json) {
    return Piso(
      id: json['id'],
      idEstablecimiento: json['id_establecimiento'],
      nombrePiso: json['nombre_piso'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_establecimiento': idEstablecimiento,
      'nombre_piso': nombrePiso,
      'estado': estado,
    };
  }
}
