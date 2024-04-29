import 'dart:convert';


Mozo responseApiFromJson(String str) => Mozo.fromJson(json.decode(str));

String responseApiToJson(Mozo data) => json.encode(data.toJson());

class Mozo {
  int? id;
  String? email;
  int? id_establecimiento;
  int? idperfil;
  String? mombre_usuario;

  Mozo({
    this.id,
    this.id_establecimiento,
    this.email,
    this.idperfil,
    this.mombre_usuario

  });

  factory Mozo.fromJson(Map<String, dynamic> json) => Mozo(
    id_establecimiento: json["id_establecimiento"],
    id: json["id"],
      email: json["email"],
      idperfil:json["idperfil"],
      mombre_usuario:json["mombre_usuario"]
  );

  Map<String, dynamic> toJson() => {
    "id_establecimiento": id_establecimiento,
    "id": id,
    "email": email,
    "idperfil": idperfil,
    "mombre_usuario": mombre_usuario

  };
}