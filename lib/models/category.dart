class Category {

  String code;

  String name;

  // Constructor
  Category({
    required this.code,
    required this.name
  });

  Category copy({
    String? code,
    String? name
  }) =>
      Category(
        code: code ?? this.code,
        name: name ?? this.name
      );

  static Category fromJson(Map<String, dynamic> json) => Category(
        code: json['code'],
        name: json['name']
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name
      };
}