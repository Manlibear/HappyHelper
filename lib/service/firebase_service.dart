import 'package:happy_helper/model/villager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:happy_helper/model/furniture.dart';
import 'package:happy_helper/model/critter.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // --- sign in, up and out
  Future<String> auth() async {
    AuthResult result = await _firebaseAuth.signInAnonymously();
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<Map<String, Furniture>> getAllFurniture() async {
    DataSnapshot snapshot = await _database
        .reference()
        .child("furniture")
        .orderByChild("name")
        .once();
    Map<String, Furniture> furniObjects = new Map<String, Furniture>();

    Map<String, dynamic> json = new Map<String, dynamic>.from(snapshot.value);
    json.forEach((key, value) {
      furniObjects.putIfAbsent(key, () => Furniture.fromDb(value));
    });

    return furniObjects;
  }

  Future<Map<String, Villager>> getAllVillagers() async {
    DataSnapshot snapshot = await _database
        .reference()
        .child("villagers")
        .orderByChild("name")
        .once();
    Map<String, Villager> villagerObjects = new Map<String, Villager>();

    Map<String, dynamic> json = new Map<String, dynamic>.from(snapshot.value);
    json.forEach((key, value) {
      villagerObjects.putIfAbsent(key, () => Villager.fromDb(value));
    });

    return villagerObjects;
  }

  Future<Map<String, Critter>> getAllCritters() async {
    DataSnapshot snapshot = await _database
        .reference()
        .child("critters")
        .orderByChild("name")
        .once();

    Map<String, Critter> critterObjects = new Map<String, Critter>();
    Map<String, dynamic> json = new Map<String, dynamic>.from(snapshot.value);

    json.forEach((key, value) {
      critterObjects.putIfAbsent(key, () => Critter.fromDb(value));
    });
    return critterObjects;
  }
}
