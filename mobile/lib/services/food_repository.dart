import '../models/food_model.dart';

class FoodRepository {
  FoodRepository._();

  static final List<FoodModel> foods = [
    const FoodModel(
      id: 1,
      name: 'Veg Burger',
      price: 149,
      image:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
    ),
    const FoodModel(
      id: 2,
      name: 'Margherita Pizza',
      price: 249,
      image:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80',
    ),
    const FoodModel(
      id: 3,
      name: 'White Sauce Pasta',
      price: 199,
      image:
          'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=800&q=80',
    ),
    const FoodModel(
      id: 4,
      name: 'Chicken Biryani',
      price: 219,
      image:
          'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=800&q=80',
    ),
    const FoodModel(
      id: 5,
      name: 'Veg Fried Rice',
      price: 159,
      image:
          'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=800&q=80',
    ),
    const FoodModel(
      id: 6,
      name: 'Grill Sandwich',
      price: 99,
      image:
          'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
    ),
    const FoodModel(
      id: 7,
      name: 'Veg Momos',
      price: 129,
      image:
          'https://images.unsplash.com/photo-1496116218417-1a781b2c4163?auto=format&fit=crop&w=800&q=80',
    ),
    const FoodModel(
      id: 8,
      name: 'Chocolate Ice Cream',
      price: 89,
      image:
          'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=800&q=80',
    ),
  ];
}
