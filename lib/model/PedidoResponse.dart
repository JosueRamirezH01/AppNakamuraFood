class PedidoResponse {
  final bool status;
  final String mensaje;
  final int ultimoIdPedido;
  final String nombreSerie;
  final int correlativo;

  PedidoResponse({
    required this.status,
    required this.mensaje,
    required this.ultimoIdPedido,
    required this.nombreSerie,
    required this.correlativo,
  });

  factory PedidoResponse.fromJson(Map<String, dynamic> json) {
    return PedidoResponse(
      status: json['status'],
      mensaje: json['Mensaje'],
      ultimoIdPedido: json['ultimo_idpedido'],
      nombreSerie: json['nombre_serie'],
      correlativo: json['correlativo'],
    );
  }
}
