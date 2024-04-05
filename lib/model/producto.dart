import 'dart:convert';
import 'dart:ffi';


Producto responseApiFromJson(String str) => Producto.fromJson(json.decode(str));

String responseApiToJson(Producto data) => json.encode(data.toJson());

class Producto {
  int? id;
  String? nombreproducto;
  String? foto;
  double? precioproducto;
  int? stock;
  int? categoria_id;
  String? comentario;
  List<Producto> productos = [];


  Producto({
    this.id,
    this.nombreproducto,
    this.foto,
    this.precioproducto,
    this.stock,
    this.categoria_id,
    this.comentario


  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    id: json["id"],
    nombreproducto: json["nombreproducto"],
    foto: json["foto"],
    stock: json["stock"],
    categoria_id: json["categoria_id"],
    precioproducto: double.tryParse(json["precioproducto"]?.toString() ?? "0.0"),
    comentario: json["comentario"],

  );
  Producto.fromJsonList(List<dynamic> jsonList) {
    try {
      jsonList.forEach((item) {
        Producto empresa = Producto.fromJson(item);
        productos.add(empresa);
      });
    } catch (e) {
      return;
    }}

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombreproducto": nombreproducto,
    "foto": foto,
    "precioproducto": precioproducto,
    "stock": stock,
    "categoria_id": categoria_id,
    "comentario": comentario


  };
}