class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password; // armazena o hash da senha (nunca o texto puro)
  final String? salt; // null apenas em contas legadas (antes do hash)

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.salt,
  });

  /// Conta criada antes da introdução do hash (senha ainda em texto puro).
  bool get isLegacy => salt == null || salt!.isEmpty;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'email': email,
        'password': password,
        'salt': salt,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        email: map['email'] as String,
        password: map['password'] as String,
        salt: map['salt'] as String?,
      );

  UserModel copyWith({String? password, String? salt}) => UserModel(
        id: id,
        name: name,
        email: email,
        password: password ?? this.password,
        salt: salt ?? this.salt,
      );
}
