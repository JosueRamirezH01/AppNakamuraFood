import 'dart:convert';


Mozo responseApiFromJson(String str) => Mozo.fromJson(json.decode(str));

String responseApiToJson(Mozo data) => json.encode(data.toJson());

class Mozo {
  String? id_usuario;
  String? email;
  bool? activo;


  Mozo({
    this.id_usuario,
    this.activo,
    this.email,

  });

  factory Mozo.fromJson(Map<String, dynamic> json) => Mozo(
    activo: json["activo"],
      id_usuario: json["id_usuario"],
      email: json["email"],

  );

  Map<String, dynamic> toJson() => {
    "activo": activo,
    "id_usuario": id_usuario,
    "email": email,

  };
}