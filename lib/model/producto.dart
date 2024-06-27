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
  String? codigo_interno;
  int? categoria_id;
  String? comentario;
  int? estado;
  List<Producto> productos = [];


  Producto({
    this.idPedido,
    this.id,
    this.nombreproducto,
    this.foto,
    this.precioproducto,
    this.stock,
    this.codigo_interno,
    this.categoria_id,
    this.comentario,
    this.estado
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
    codigo_interno: json["codigo_interno"],
    precioproducto: double.tryParse(json["precioproducto"]?.toString() ?? "0.0"),
    comentario: json["comentario"],
    estado: json["estado"]
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
    "codigo_interno": codigo_interno,
    "categoria_id": categoria_id,
    "comentario": comentario,
    "estado": estado
  };
}