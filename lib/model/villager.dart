import 'dart:collection';

class Villager {
  String key;
  String name;
  String gender;
  String species;
  String personality;
  String description;

  Villager(this.key, this.name, this.gender, this.species, this.personality,
      this.description);

  Villager.fromDb(LinkedHashMap<dynamic, dynamic> data) {
    key = data['key'];
    name = data['name'];
    gender = data['gender'];
    species = data['species'];
    personality = data['personality'];
    description = data['description'];
  }
}
