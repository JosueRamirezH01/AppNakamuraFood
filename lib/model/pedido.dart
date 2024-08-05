import 'dart:convert';

import 'detalle_pedido.dart';

Pedido responseApiFromJson(String str) => Pedido.fromJson(json.decode(str));
String responseApiToJson(Pedido data) => json.encode(data.toJson());

class Pedido {
  int? idPedido;
  int? idEntorno;
  int? idCliente;
  int? idUsuario;
  int? idTipoPedido;
  int? idMesa;
  int? idEstablecimiento;
  int? idSeriePedido;
  int? correlativoPedido;
  double? montoTotal;
  String? fechaPedido;
  int? estadoPedido;
  String? motivo;
  String? anuladoPor;
  String? nombreCliente;
  DateTime? created_at;
  DateTime? updated_at;
  List<Detalle_Pedido>? detalle = [];

  Pedido({
    this.idPedido,
    this.idEntorno,
    this.idCliente,
    this.idUsuario,
    this.idTipoPedido,
    this.idMesa,
    this.idEstablecimiento,
    this.idSeriePedido,
    this.correlativoPedido,
    this.montoTotal,
    this.fechaPedido,
    this.estadoPedido,
    this.motivo,
    this.anuladoPor,
    this.nombreCliente,
    this.created_at,
    this.updated_at,
    this.detalle
  });

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
    idPedido: json['id_pedido'],
    idEntorno: json['id_entorno'],
    idCliente: json['id_cliente'],
    idUsuario: json['id_usuario'],
    idTipoPedido: json['id_tipo_pedido'],
    idMesa: json['id_mesa'],
    idEstablecimiento: json['id_establecimiento'],
    idSeriePedido: json['id_serie_pedido'],
    correlativoPedido: json['correlativo_pedido'],
    montoTotal: double.tryParse(json["Monto_total"]?.toString() ?? "0.0"),
    fechaPedido: json['fecha_pedido'] ,
    estadoPedido: json['estado_pedido'],
    motivo: json['motivo'],
    anuladoPor: json['anulado_por'],
    nombreCliente: json['nombrecliente'],
    created_at: json['created_at'],
    updated_at: json['updated_at'],
    detalle: (json['detalle'] as List<dynamic>?)?.map((e) => Detalle_Pedido.fromJson(e as Map<String, dynamic>)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'id_pedido': idPedido,
    'id_entorno': idEntorno,
    'id_cliente': idCliente,
    'id_usuario': idUsuario,
    'id_tipo_pedido': idTipoPedido,
    'id_mesa': idMesa,
    'id_establecimiento': idEstablecimiento,
    'id_serie_pedido': idSeriePedido,
    'correlativo_pedido': correlativoPedido,
    'monto_total': montoTotal,
    'fecha_pedido': fechaPedido,
    'estado_pedido': estadoPedido,
    'motivo': motivo,
    'anulado_por': anuladoPor,
    'nombrecliente': nombreCliente,
    'updated_at': updated_at,
    'created_at': created_at,
    'detalle': detalle?.map((e) => e.toJson()).toList(),

  };
}
