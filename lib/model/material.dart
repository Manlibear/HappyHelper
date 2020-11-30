import 'dart:collection';

class CraftingMaterial {
  String name;
  String background;
  String key;

  CraftingMaterial(this.name, this.key);

  CraftingMaterial.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        key = json['serial_id'];

  CraftingMaterial.fromDb(LinkedHashMap<dynamic, dynamic> data) {
    name = data['name'];
    key = data['key'];
  }
}
