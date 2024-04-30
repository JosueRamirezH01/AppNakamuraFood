import 'dart:convert';


Mozo responseApiFromJson(String str) => Mozo.fromJson(json.decode(str));

String responseApiToJson(Mozo data) => json.encode(data.toJson());

class Mozo {
  int? id;
  String? email;
  int? id_establecimiento;
  int? idperfil;
  String? nombre_usuario;

  Mozo({
    this.id,
    this.id_establecimiento,
    this.email,
    this.idperfil,
    this.nombre_usuario

  });

  factory Mozo.fromJson(Map<String, dynamic> json) => Mozo(
    id_establecimiento: json["id_establecimiento"],
    id: json["id"],
      email: json["email"],
      idperfil:json["idperfil"],
      nombre_usuario:json["nombre_usuario"]
  );

  Map<String, dynamic> toJson() => {
    "id_establecimiento": id_establecimiento,
    "id": id,
    "email": email,
    "idperfil": idperfil,
    "nombre_usuario": nombre_usuario

  };
}