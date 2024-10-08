


class Detalle_Pedido {
  int? id_pedido_detalle;
  int? id_pedido;
  int? id_producto;
  int? cantidad_producto;
  int? cantidad_actualizada;
  int? cantidad_exacta;
  int? cantidad_real;
  double? precio_producto;
  double? precio_unitario;
  String? comentario;
  int? estado_detalle;
  DateTime? updated_at;

  Detalle_Pedido({
    this.id_pedido_detalle,
    this.id_pedido,
    this.id_producto,
    this.cantidad_producto,
    this.cantidad_actualizada,
    this.cantidad_exacta,
    this.cantidad_real,
    this.precio_unitario,
    this.precio_producto,
    this.comentario,
    this.estado_detalle,
    this.updated_at
  });

  factory Detalle_Pedido.fromJson(Map<String, dynamic> json) => Detalle_Pedido(
    id_pedido_detalle: json["id_detalle"],
    id_pedido: json["id_pedido"],
    id_producto: json["id_producto"],
    cantidad_producto: json["cantidad_producto"],
    cantidad_actualizada: json["cantidad_actualizada"],
    cantidad_exacta: json["cantidad_exacta"],
    cantidad_real: json["cantidad_real"],
    precio_producto: double.tryParse(json["precio_producto"]?.toString() ?? "0.0"),
    precio_unitario: double.tryParse(json["precio_unitario"]?.toString() ?? "0.0"),
    comentario: json["comentario"],
    estado_detalle: json["estado_detalle"],
    updated_at: json["updated_at"],
  );


  Map<String, dynamic> toJson() => {
    "id_detalle": id_pedido_detalle,
    "id_pedido": id_pedido,
    "id_producto": id_producto,
    "cantidad_producto": cantidad_producto,
    "cantidad_actualizada": cantidad_actualizada,
    "cantidad_exacta": cantidad_exacta,
    "cantidad_real": cantidad_real,
    "precio_producto": precio_producto,
    "precio_unitario": precio_unitario,
   "comentario": comentario,
    "estado_detalle": estado_detalle,
    "updated_at": updated_at
  };


}