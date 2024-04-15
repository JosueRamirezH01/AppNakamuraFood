import 'dart:convert';
import 'dart:ffi';


Producto responseApiFromJson(String str) => Producto.fromJson(json.decode(str));

String responseApiToJson(Producto data) => json.encode(data.toJson());

class Producto {
  int? idPedido;
  int? id;
  String? nombreproducto;
  String? foto;
  double? precioproducto;
  int? stock;
  int? categoria_id;
  String? comentario;
  List<Producto> productos = [];


  Producto({
    this.idPedido,
    this.id,
    this.nombreproducto,
    this.foto,
    this.precioproducto,
    this.stock,
    this.categoria_id,
    this.comentario


  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Producto &&
              runtimeType == other.runtimeType &&
              nombreproducto == other.nombreproducto &&
              precioproducto == other.precioproducto &&
              stock == other.stock &&
              comentario == other.comentario &&
              idPedido == other.idPedido;

  @override
  int get hashCode =>
      nombreproducto.hashCode ^
      precioproducto.hashCode ^
      stock.hashCode ^
      comentario.hashCode ^
      idPedido.hashCode;

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    idPedido: json["idPedido"],
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
    "idPedido": idPedido,
    "id": id,
    "nombreproducto": nombreproducto,
    "foto": foto,
    "precioproducto": precioproducto,
    "stock": stock,
    "categoria_id": categoria_id,
    "comentario": comentario
  };
}