import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:happy_helper/service/helper_service.dart';

const String api_root = "https://api.nookipedia.com/";
// TODO: Move this to a more secure location, Firebase Remote Config ?
const String api_key = "e4adcca2-5122-4cf6-b8eb-2fc5fb7459f7";

enum NookipediaEndpoints {
  Fish,
  Bugs,
  SeaCreatures,
  Villagers,
  Recipes,
  Artwork
}

class Nookipedia {
  Future<List<T>> fetchList<T>(NookipediaEndpoints endpoint) async {
    String url = api_root;

    switch (endpoint) {
      case NookipediaEndpoints.Fish:
        url += "nh/fish";
        break;
      case NookipediaEndpoints.Bugs:
        url += "nh/bugs";
        break;
      case NookipediaEndpoints.SeaCreatures:
        url += "nh/sea";
        break;
      case NookipediaEndpoints.Villagers:
        url += "villagers?game=nh&nhdetails=true";
        break;
      case NookipediaEndpoints.Recipes:
        url += "nh/recipes";
        break;
      case NookipediaEndpoints.Artwork:
        url += "nh/art";
        throw new Exception("Artwork endpoint not implemented");
    }

    var resp = await http.get(url, headers: {"X-API-KEY": api_key});

    switch (resp.statusCode) {
      case 200:
        return HelperService.fromJson<List, T>(json.decode(resp.body));
      default:
        throw Exception("Nookipedia request failed: [${resp.statusCode}] $url");
    }
  }
}
