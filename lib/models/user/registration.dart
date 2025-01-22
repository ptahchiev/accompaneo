class Registration {
  final String name;
  final String username;
  final String password;
  final String repeatPassword;
  
  Registration({required this.name, required this.username, required this.password, required this.repeatPassword});
  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      name: json['name'],
      username: json['username'],
      password: json['password'],
      repeatPassword: json['repeatPassword'],
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'password': password,
    'repeatPassword': repeatPassword,
  };
}