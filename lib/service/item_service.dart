import 'package:HappyHelper/model/furniture.dart';
import 'package:HappyHelper/service/firebase_service.dart';
import 'package:get_it/get_it.dart';

class ItemService {
  Map<String, Furniture> allItems = new Map<String, Furniture>();

  void init() {
    FirebaseService _firebaseService = GetIt.I.get<FirebaseService>();
    _firebaseService.getAllFurniture().then((data) {
      allItems = data;
    });
  }

  static String itemNameFromKey(String key) {
    return key;
  }

  List<RecipeItem> getRecipeItemsFromKey(String key) {
    if (allItems.containsKey(key)) {
      return allItems[key].recipe;
    } else {
      return new List<RecipeItem>();
    }
  }
}
