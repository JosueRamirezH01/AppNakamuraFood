import 'dart:convert';


Producto responseApiFromJson(String str) => Producto.fromJson(json.decode(str));

String responseApiToJson(Producto data) => json.encode(data.toJson());

class     Producto {
  int? identificador;
  int? idPedido;
  int? id_pedido_detalle;
  int? id;
  int? codigo;
  String? nombreproducto;
  String? foto;
  double? precioproducto;
  int? stock;
  String? codigo_interno;
  int? categoria_id;
  int? establecimiento_id;
  String? comentario;
  int? estado;
  List<Producto> productos = [];
  bool? sinACStock = false;
  bool? aCStock = false;


  Producto({
    this.identificador,
    this.idPedido,
    this.id_pedido_detalle,
    this.id,
    this.codigo,
    this.nombreproducto,
    this.foto,
    this.precioproducto,
    this.stock,
    this.codigo_interno,
    this.categoria_id,
    this.establecimiento_id,
    this.comentario,
    this.estado,
    this.sinACStock,
    this.aCStock
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Producto &&
              runtimeType == other.runtimeType &&
              id_pedido_detalle == other.id_pedido_detalle &&
              nombreproducto == other.nombreproducto &&
              precioproducto == other.precioproducto &&
              stock == other.stock &&
              comentario == other.comentario &&
              idPedido == other.idPedido;

  @override
  int get hashCode =>
      id_pedido_detalle.hashCode ^
      nombreproducto.hashCode ^
      precioproducto.hashCode ^
      stock.hashCode ^
      comentario.hashCode ^
      idPedido.hashCode;

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    idPedido: json["idPedido"],
    id_pedido_detalle: json["id_pedido_detalle"],
    id: json["id"],
    nombreproducto: json["nombreproducto"],
    foto: json["foto"],
    stock: json["stock"],
    codigo: json["codigo"],
    categoria_id: json["categoria_id"],
    codigo_interno: json["codigo_interno"],
    precioproducto: double.tryParse(json["precioproducto"]?.toString() ?? "0.0"),
    establecimiento_id: json["establecimiento_id"],
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
    "id_pedido_detalle": id_pedido_detalle,
    "id": id,
    "codigo": codigo,
    "nombreproducto": nombreproducto,
    "foto": foto,
    "precioproducto": precioproducto,
    "stock": stock,
    "codigo_interno": codigo_interno,
    "categoria_id": categoria_id,
    "establecimiento_id": establecimiento_id,
    "comentario": comentario,
    "estado": estado
  };
}