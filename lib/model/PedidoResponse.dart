class PedidoResponse {
  final bool? status;
  final String? mensaje;
  final String? mensajeMinuscula;
  final int? ultimoIdPedido;
  final String? nombreSerie;
  final int? correlativo;

  PedidoResponse({
    this.status,
     this.mensaje,
    this.mensajeMinuscula,
     this.ultimoIdPedido,
     this.nombreSerie,
     this.correlativo,
  });

  factory PedidoResponse.fromJson(Map<String, dynamic> json) {
    return PedidoResponse(
      status: json['status'],
      mensaje: json['Mensaje'],
      mensajeMinuscula: json['mensaje'],
      ultimoIdPedido: json['ultimo_idpedido'],
      nombreSerie: json['nombre_serie'],
      correlativo: json['correlativo'],
    );
  }
}
