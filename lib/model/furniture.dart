import 'dart:collection';

class Furniture {
  String name;
  String background;
  String key;
  List<RecipeItem> recipe = new List<RecipeItem>();

  Furniture(this.name, this.background, this.key);

  Furniture.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        background = json['background'],
        key = json['key'];

  Furniture.fromDb(LinkedHashMap<dynamic, dynamic> data) {
    name = data['name'];
    key = data['key'];
    background = data['background'];
    for (var r in data['recipe'] as List<dynamic>) {
      recipe.add(new RecipeItem(r['key'], r['name'], r['count']));
    }
  }
}

class RecipeItem {
  RecipeItem(String key, String name, int count) {
    this.key = key;
    this.name = name;
    this.count = count;
  }

  String key;
  String name;
  int count;
  bool complete = false;
}

class BasketItem {
  BasketItem(this.key, this.name, this.count, this.isSubItem);

  String key;
  String name;
  int count;
  int completedCount = 0;
  bool complete = false;
  bool isSubItem;

  String getCountText() {
    if (!this.isSubItem ||
        this.completedCount == 0 ||
        this.completedCount == this.count) return count.toString();

    return this.completedCount.toString() + "/" + this.count.toString();
  }
}
