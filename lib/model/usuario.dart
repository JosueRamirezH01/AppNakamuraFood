import 'dart:convert';

Usuario usuarioFromJson(String str) => Usuario.fromJson(json.decode(str));

String usuarioToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
  String? accessToken;
  String? tokenType;
  int? expiresIn;
  User? user;
  
  Usuario({
     this.accessToken,
     this.tokenType,
     this.expiresIn,
     this.user,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    accessToken: json["access_token"],
    tokenType: json["token_type"],
    expiresIn: json["expires_in"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "token_type": tokenType,
    "expires_in": expiresIn,
    "user": user?.toJson(),
  };
}

class User {
  int id;
  String nombreUsuario;
  String email;
  int idperfil;
  int idEstablecimiento;
  String password;
  dynamic tokenTemporal;
  dynamic passwordResetToken;
  String fotoUsuario;
  int estado;
  dynamic usuarioRoot;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.nombreUsuario,
    required this.email,
    required this.idperfil,
    required this.idEstablecimiento,
    required this.password,
    required this.tokenTemporal,
    required this.passwordResetToken,
    required this.fotoUsuario,
    required this.estado,
    required this.usuarioRoot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    nombreUsuario: json["nombre_usuario"],
    email: json["email"],
    idperfil: json["idperfil"],
    idEstablecimiento: json["id_establecimiento"],
    password: json["password"],
    tokenTemporal: json["token_temporal"],
    passwordResetToken: json["password_reset_token"],
    fotoUsuario: json["foto_usuario"],
    estado: json["estado"],
    usuarioRoot: json["usuario_root"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre_usuario": nombreUsuario,
    "email": email,
    "idperfil": idperfil,
    "id_establecimiento": idEstablecimiento,
    "password": password,
    "token_temporal": tokenTemporal,
    "password_reset_token": passwordResetToken,
    "foto_usuario": fotoUsuario,
    "estado": estado,
    "usuario_root": usuarioRoot,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}