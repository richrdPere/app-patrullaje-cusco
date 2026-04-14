class UserEntity {
  final String? id;
  final String dni;
  final String? avatar;
  final String firstName;
  final String lastName;
  final String phone;
  final DateTime? birthdate;
  final String? address;
  final String? distrito;
  final String email;
  final String username;
  final String? password;
  final String? role;
  final String? estado;
  final bool? active;

  UserEntity({
    this.id,
    required this.dni,
    this.avatar,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.birthdate,
    this.address,
    this.distrito,
    required this.email,
    required this.username,
    this.password,
    this.role,
    this.estado,
    this.active,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    id: json["id"] ?? '',
    dni: json["dni"] ?? '',
    avatar: json["avatar"] ?? '',
    firstName: json["firstName"] ?? '',
    lastName: json["lastName"] ?? '',
    phone: json["phone"] ?? '',
    birthdate:
        json["birthdate"] != null
            ? DateTime.parse(json["birthdate"])
            : DateTime(2000, 1, 1),
    address: json["address"] ?? '',
    distrito: json["distrito"] ?? '',
    email: json["email"] ?? '',
    username: json["username"] ?? '',
    password: json["password"] ?? '',
    role: json["role"] ?? 'sereno',
    estado: json["estado"] ?? 'Disponible',
    active: json["active"] ?? true,
  );

  Map<String, dynamic> toJson() => {
    "id": id ?? '',
    "dni": dni,
    "avatar": avatar ?? '',
    "firstName": firstName,
    "lastName": lastName,
    "phone": phone,
    //"birthdate": "${birthdate.year.toString().padLeft(4, '0')}-${birthdate.month.toString().padLeft(2, '0')}-${birthdate.day.toString().padLeft(2, '0')}",
    "birthdate": birthdate ?? "2000-01-01",
    // "birthdate": birthdate ?? DateTime(2000, 1, 1),
    "address": address ?? '',
    "distrito": distrito ?? '',
    "email": email,
    "username": username,
    "password": password,
    "role": role,
    "estado": estado ?? 'Disponible',
    "active": active ?? true,
  };
}
