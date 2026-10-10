import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../models/food_model.dart';
import '../services/api_service.dart';
import '../services/food_repository.dart';

class FoodsProvider extends ChangeNotifier {
  List<FoodModel> _foods = [];
  bool loading = false;
  String? error;

  List<FoodModel> get foods => _foods;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final json = await ApiService.instance.get(ApiConstants.foods);
      final list = json['foods'] as List<dynamic>;
      _foods = list
          .map((e) => FoodModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      error = e.toString();
      _foods = FoodRepository.foods;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
