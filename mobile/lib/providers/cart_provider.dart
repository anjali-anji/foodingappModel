import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_model.dart';

class CartItem {
  const CartItem({required this.food, required this.quantity});

  final FoodModel food;
  final int quantity;

  double get lineTotal => food.price * quantity;
}

class CartProvider extends ChangeNotifier {
  static const _storageKey = 'cart_items';

  final Map<int, int> _quantities = {};
  final Map<int, FoodModel> _foods = {};

  Map<int, int> get quantities => Map.unmodifiable(_quantities);

  List<CartItem> get items {
    return _quantities.entries
        .map((e) => CartItem(food: _foods[e.key]!, quantity: e.value))
        .toList();
  }

  bool get isEmpty => _quantities.isEmpty;

  int get itemCount =>
      _quantities.values.fold(0, (sum, qty) => sum + qty);

  int quantityOf(int foodId) => _quantities[foodId] ?? 0;

  double get subtotal {
    var total = 0.0;
    for (final entry in _quantities.entries) {
      final food = _foods[entry.key];
      if (food != null) {
        total += food.price * entry.value;
      }
    }
    return total;
  }

  double get total => subtotal;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _quantities.clear();
      _foods.clear();
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final food = FoodModel.fromJson(map['food'] as Map<String, dynamic>);
        final qty = (map['quantity'] as num).toInt();
        if (qty > 0) {
          _foods[food.id] = food;
          _quantities[food.id] = qty;
        }
      }
      debugPrint('CART RESTORED items=$itemCount');
      notifyListeners();
    } catch (e) {
      debugPrint('CART RESTORE ERROR $e');
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = items
        .map((e) => {'food': e.food.toJson(), 'quantity': e.quantity})
        .toList();
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  void add(FoodModel food) {
    _foods[food.id] = food;
    _quantities[food.id] = (_quantities[food.id] ?? 0) + 1;
    notifyListeners();
    _persist();
  }

  void increase(int foodId) {
    if (_quantities.containsKey(foodId)) {
      _quantities[foodId] = _quantities[foodId]! + 1;
      notifyListeners();
      _persist();
    }
  }

  void decrease(int foodId) {
    final qty = _quantities[foodId];
    if (qty == null) return;
    if (qty <= 1) {
      remove(foodId);
      return;
    }
    _quantities[foodId] = qty - 1;
    notifyListeners();
    _persist();
  }

  void remove(int foodId) {
    _quantities.remove(foodId);
    _foods.remove(foodId);
    notifyListeners();
    _persist();
  }

  void clear() {
    _quantities.clear();
    _foods.clear();
    notifyListeners();
    _persist();
  }
}
