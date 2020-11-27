import 'dart:collection';

class Critter {
  String key;
  String name;
  String area;
  List<CritterSpawnMonth> months;
  bool isFish;

  Critter.fromDb(LinkedHashMap<dynamic, dynamic> data) {
    key = data['key'];
    name = data['name'];
    area = data['area'];
    isFish = data['key'].toString().startsWith("Fish");

    months = new List<CritterSpawnMonth>();

    for (var m in data['months'] as List<dynamic>) {
      months.add(CritterSpawnMonth.fromDb(m));
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

  bool insectSpawns() {
    return morning + midday + eve > 0;
  }

  bool fishSpawns() {
    return earlyMorn + midMorn + lateMorn + earlyAfter + lateAfter + night > 0;
  }

  bool spawns(){
    return earlyMorn + midMorn + lateMorn + earlyAfter + lateAfter + night + morning + midday + eve > 0;
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
}
