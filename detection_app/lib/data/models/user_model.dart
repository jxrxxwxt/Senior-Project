class UserModel {
  final String username;
  final String? email;
  final String? department;

  UserModel({required this.username, this.email, this.department});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      email: json['email'],
      department: json['department'],
    );
  }
}