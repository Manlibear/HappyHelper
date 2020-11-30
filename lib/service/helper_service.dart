import 'package:happy_helper/model/critter.dart';
import 'package:happy_helper/model/villager.dart';
import 'package:happy_helper/model/furniture.dart';

class HelperService {
  static String monthNameFromNumber(int number) {
    switch (number) {
      case 1:
        return "jan";
      case 2:
        return "feb";
      case 3:
        return "mar";
      case 4:
        return "apr";
      case 5:
        return "may";
      case 6:
        return "jun";
      case 7:
        return "jul";
      case 8:
        return "aug";
      case 9:
        return "sep";
      case 10:
        return "oct";
      case 11:
        return "nov";
      case 12:
        return "dec";
    }

    return number.toString();
  }

  /// If T is a List, K is the subtype of the list.
  static T fromJson<T, K>(dynamic json) {
    if (json is Iterable) {
      return _fromJsonList<K>(json) as T;
    } else if (T == Critter) {
      return Critter.fromJson(json) as T;
    } else if (T == Villager) {
      return Villager.fromJson(json) as T;
    } else if (T == Furniture) {
      return Furniture.fromJson(json) as T;
    } else {
      throw Exception("Unknown class: $T");
    }
  }

  static List<K> _fromJsonList<K>(List<dynamic> jsonList) {
    return jsonList
        ?.map<K>((dynamic json) => fromJson<K, void>(json))
        ?.toList();
  }
}
