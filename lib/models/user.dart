class User {
  final String userName;
  final String email;
  final String idUser;
  final DateTime birthDate;
  final String password;
  final String? avatar;
  final List<String>? createdEventsId;
  final List<String>? joinedEventsId;
  final List<String>? idCategories;
  final String role;
  final String? description;

  const User({
    required this.userName,
    required this.email,
    required this.idUser,
    required this.birthDate,
    required this.password,
    this.avatar,
    this.createdEventsId,
    this.joinedEventsId,
    this.idCategories,
    required this.role,
    this.description,
  });
}
