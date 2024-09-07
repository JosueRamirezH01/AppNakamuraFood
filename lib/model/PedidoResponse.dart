import 'nota.dart';

class PedidoResponse {
  final bool? status;
  final String? mensaje;
  final int? ultimoIdPedido;
  final String? nombreSerie;
  final int? correlativo;
  final List<Nota>? listaActualizadaNotas;

  PedidoResponse({
    this.status,
     this.mensaje,
     this.ultimoIdPedido,
     this.nombreSerie,
     this.correlativo,
    this.listaActualizadaNotas,
  });

  factory PedidoResponse.fromJson(Map<String, dynamic> json) {
    return PedidoResponse(
      status: json['status'],
      mensaje: json['Mensaje'] ?? json['message'] ?? json['mensaje'],
      ultimoIdPedido: json['ultimo_idpedido'],
      nombreSerie: json['nombre_serie'],
      correlativo: json['correlativo'],
      listaActualizadaNotas: json['lista_actualizada_notas'] != null
          ? Nota.fromJsonList(json['lista_actualizada_notas'])
          : null,
    );
  }
}
