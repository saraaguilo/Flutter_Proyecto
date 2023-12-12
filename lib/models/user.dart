class User {
  final String userName;
  final String email;
  final String? idUser;
  final DateTime? birthDate;
  final String password;
  final String? avatar;
  final List<String>? createdEventsId;
  final List<String>? joinedEventsId;
  final List<String>? idCategories;
  final String role;
  final String description;

  const User({
    required this.userName,
    required this.email,
    this.idUser,
    this.birthDate,
    required this.password,
    this.avatar,
    this.createdEventsId,
    this.joinedEventsId,
    this.idCategories,
    required this.role,
    required this.description,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      idUser: json['_id'] ?? '',
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      password: json['password'] ?? '',
      avatar: json['avatar'] ?? '',
      createdEventsId: json['createdEventsId'] != []
          ? List<String>.from(json['createdEventsId'])
          : null,
      joinedEventsId: json['joinedEventsId'] != []
          ? List<String>.from(json['joinedEventsId'])
          : null,
      idCategories: json['idCategories'] != []
          ? List<String>.from(json['idCategories'])
          : null,
      role: json['role'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
