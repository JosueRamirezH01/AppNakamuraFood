
class Detalle_Pedido {
  int? id_pedido_detalle;
  int? id_pedido;
  int? id_producto;
  int? cantidad_producto;
  int? cantidad_actualizada;
  int? cantidad_exacta;
  int? cantidad_real;
  double? precio_producto;
  String? comentario;
  int? estado_detalle;

  Detalle_Pedido({
    this.id_pedido_detalle,
    this.id_pedido,
    this.id_producto,
    this.cantidad_producto,
    this.cantidad_actualizada,
    this.cantidad_exacta,
    this.cantidad_real,
    this.precio_producto,
    this.comentario,
    this.estado_detalle
  });

  factory Detalle_Pedido.fromJson(Map<String, dynamic> json) => Detalle_Pedido(
    id_pedido_detalle: json["id_pedido_detalle"],
    id_pedido: json["id_pedido"],
    id_producto: json["id_producto"],
    cantidad_producto: json["cantidad_producto"],
    cantidad_actualizada: json["cantidad_actualizada"],
    cantidad_exacta: json["cantidad_exacta"],
    cantidad_real: json["cantidad_real"],
      precio_producto: double.tryParse(json["precio_producto"]?.toString() ?? "0.0"),
    comentario: json["comentario"].toString(),
    estado_detalle: json["estado_detalle"]
  );


  Map<String, dynamic> toJson() => {
    "id_pedido_detalle": id_pedido_detalle,
    "id_pedido": id_pedido,
    "id_producto": id_producto,
    "cantidad_producto": cantidad_producto,
    "cantidad_actualizada": cantidad_actualizada,
    "cantidad_exacta": cantidad_exacta,
    "cantidad_real": cantidad_real,
    "precio_producto": precio_producto,
    "comentario": comentario,
    "estado_detalle": estado_detalle
  };
}