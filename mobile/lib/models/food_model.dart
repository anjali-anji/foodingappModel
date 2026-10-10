class FoodModel {
  const FoodModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
  });

  final int id;
  final String name;
  final double price;
  final String image;

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
    };
  }
}
