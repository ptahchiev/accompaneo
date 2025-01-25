class Artist {

  String code;

  String name;

  // Constructor
  Artist({
    required this.code,
    required this.name
  });

  Artist copy({
    String? code,
    String? name
  }) =>
      Artist(
        code: code ?? this.code,
        name: name ?? this.name
      );

  static Artist fromJson(Map<String, dynamic> json) => Artist(
        code: json['code'],
        name: json['name']
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name
      };
}