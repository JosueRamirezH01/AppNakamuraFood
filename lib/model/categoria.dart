import 'dart:convert';


Categoria responseApiFromJson(String str) => Categoria.fromJson(json.decode(str));

String responseApiToJson(Categoria data) => json.encode(data.toJson());

class Categoria {
  int? id;
  String? nombre;
  int? estado;
  int? bar;
  int? establecimiento_id;



  List<Categoria> categoria = [];


  Categoria({
    this.id,
    this.nombre,
    this.estado,
    this.bar,
    this.establecimiento_id


  });

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
    id: json["id"],
    nombre: json["nombre"],
    estado: json["estado"],
    bar: json["bar"],
    establecimiento_id: json["establecimiento_id"]
    //puntuacion: double.tryParse(json["puntuacion"]?.toString() ?? "0.0"),

  );
  Categoria.fromJsonList(List<dynamic> jsonList) {
    try {
      jsonList.forEach((item) {
        Categoria empresa = Categoria.fromJson(item);
        categoria.add(empresa);
      });
    } catch (e) {
      return;
    }}

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "estado": estado,
    "establecimiento_id": establecimiento_id,
    "bar": bar

  };
}