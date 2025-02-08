class Browseable {
  final String code;
  final String name;
  final String? picture;

  // Constructor
  Browseable({
    required this.code,
    required this.name,
    required this.picture
  });

  Browseable copy({
    String? code,
    String? name,
    String? picture
  }) =>
      Browseable(
        code: code ?? this.code,
        name: name ?? this.name,
        picture: picture ?? this.picture
      );

  static Browseable fromJson(Map<String, dynamic> json) => Browseable(
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        picture: json['picture'] ?? ''
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'picture': picture
      };


  @override
  bool operator ==(Object other) =>
      other is Browseable &&
      other.runtimeType == runtimeType &&
      other.code == code;

  @override
  int get hashCode => code.hashCode;
}