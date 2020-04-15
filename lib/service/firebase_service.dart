import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:HappyHelper/model/furniture.dart';

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
    DataSnapshot snapshot = await _database.reference().child("furniture").once();
    Map<String, Furniture> furniObjects =  new Map<String,Furniture>();

    Map<String, dynamic> json = new Map<String,dynamic>.from(snapshot.value);
    json.forEach((key, value) {
      furniObjects.putIfAbsent(key, () => Furniture.fromDb(value));
    });

    return furniObjects;
  }
}
