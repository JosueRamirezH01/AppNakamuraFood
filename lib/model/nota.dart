import 'dart:convert';


Nota responseApiFromJson(String str) => Nota.fromJson(json.decode(str));

String responseApiToJson(Nota data) => json.encode(data.toJson());

class Nota {
  int? id_nota;
  String? descripcion_nota;
  String? estado_nota;
  int? id_establecimiento;



  List<Nota> nota = [];


  Nota({
    this.id_nota,
    this.descripcion_nota,
    this.estado_nota,
    this.id_establecimiento


  });

  factory Nota.fromJson(Map<String, dynamic> json) => Nota(
      id_nota: json["id_nota"],
      descripcion_nota: json["descripcion_nota"],
      estado_nota: json["estado_nota"],
      id_establecimiento: json["id_establecimiento"]
    //puntuacion: double.tryParse(json["puntuacion"]?.toString() ?? "0.0"),

  );
  static List<Nota> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => Nota.fromJson(item)).toList();
  }

  Map<String, dynamic> toJson() => {
    "id_nota": id_nota,
    "descripcion_nota": descripcion_nota,
    "estado_nota": estado_nota,
    "id_establecimiento": id_establecimiento,

  };
}