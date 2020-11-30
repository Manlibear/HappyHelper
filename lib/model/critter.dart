import 'dart:collection';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Critter {
  String key;
  String name;
  String area;
  bool hasBeenCaught;
  int sellPrice;
  String fishShadowSize;
  List<CritterSpawnMonth> months;
  bool isFish;
  bool isSeaCreature;
  String imageUrl;

  Critter.fromDb(LinkedHashMap<dynamic, dynamic> data) {
    key = data['key'];
    name = data['name'];
    area = data['area'];
    isFish = data['key'].toString().startsWith("Fish");
    hasBeenCaught =
        GetIt.I.get<SharedPreferences>().getBool("Caught$key") ?? false;

    months = new List<CritterSpawnMonth>();

    for (var m in data['months'] as List<dynamic>) {
      months.add(CritterSpawnMonth.fromDb(m));
    }
  }

  Critter.fromJson(dynamic json) {
    String hemisphere =
        GetIt.I.get<SharedPreferences>().getString("Hemisphere") ?? "north";

    name = json["name"];
    area = json["location"] ?? "";
    sellPrice = json["sell_nook"];
    isFish = json["shadow_size"] != null;
    isSeaCreature = json["shadow_movement"] != null;
    imageUrl = json["image_url"];

    if (isFish) {
      fishShadowSize = json["shadow_size"];
    }

    if (isSeaCreature) {
      key = "SeaCreature" + json["number"].toString();
    } else if (isFish) {
      key = "Fish" + json["number"].toString();
    } else {
      key = "Bug" + json["number"].toString();
    }

    hasBeenCaught =
        GetIt.I.get<SharedPreferences>().getBool("Caught$key") ?? false;

    months = new List<CritterSpawnMonth>();

    try {
      (json[hemisphere]["times_by_month"] as Map<String, dynamic>)
          .forEach((month, time) {
        months.add(CritterSpawnMonth.parseFromString(
            int.parse(month), time.toString()));
      });
    } catch (e) {
      print(e);
    }
  }
}

class CritterSpawnMonth {
  int earlyAfter;
  int earlyMorn;
  int eve;
  int lateAfter;
  int lateMorn;
  int midday;
  int midMorn;
  int month;
  int morning;
  int night;

  List times;

  bool insectSpawns() {
    // return morning + midday + eve > 0;
    return times.any((element) => element);
  }

  bool fishSpawns() {
    // return earlyMorn + midMorn + lateMorn + earlyAfter + lateAfter + night > 0;
    return times.any((element) => element);
  }

  bool spawns() {
    // return earlyMorn +
    //         midMorn +
    //         lateMorn +
    //         earlyAfter +
    //         lateAfter +
    //         night +
    //         morning +
    //         midday +
    //         eve >
    //     0;
    return times.any((element) => element);
  }

  CritterSpawnMonth.fromDb(dynamic data) {
    earlyAfter = data['EarlyAfter'];
    earlyMorn = data['EarlyMorn'];
    eve = data['Eve'];
    lateAfter = data['LateAfter'];
    lateMorn = data['LateMorn'];
    midday = data['Midday'];
    midMorn = data['MidMorn'];
    month = data['Month'];
    morning = data['Morning'];
    night = data['Night'];
  }

  // This is awful, a truly awful thing this is.
  CritterSpawnMonth.parseFromString(int month, String time) {
    this.month = month;

    times = List.filled(24, false);

    if (time == "NA") {
      return;
    }

    if (time == "All day") {
      times = List.filled(24, true);
      return;
    }

    var multiTimes = time.split(";");

    for (var mt in multiTimes) {
      var timeParts = mt.trim().split("–");

      try {
        var startTime = timeParts[0].trim();
        var endTime = timeParts[1].trim();

        int startTimeInt;
        int endTimeInt;

        if (startTime.contains("AM"))
          startTimeInt = int.parse(startTime.replaceAll(" AM", ""));
        if (endTime.contains("AM"))
          endTimeInt = int.parse(endTime.replaceAll(" AM", ""));

        if (startTime.contains("PM")) {
          startTimeInt = int.parse(startTime.replaceAll(" PM", "")) + 12;
        }

        if (endTime.contains("PM")) {
          endTimeInt = int.parse(endTime.replaceAll(" PM", "")) + 12;
        }

        if (endTimeInt > startTimeInt) {
          // loop normally
          for (int t = 0; t < 24; t++) {
            if (t + 1 >= startTimeInt && t + 1 <= endTimeInt) times[t] = true;
          }
        } else {
          // loop in reverse
          for (int t = 23; t >= 0; t--) {
            if (t + 1 <= endTimeInt || t + 1 >= startTimeInt) times[t] = true;
          }
        }
      } catch (e) {}
    }
  }
}
