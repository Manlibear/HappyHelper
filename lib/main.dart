import 'package:happy_helper/pages/basket.dart';
import 'package:happy_helper/pages/villagers.dart';
import 'package:happy_helper/service/basket_service.dart';
import 'package:happy_helper/service/item_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy_helper/service/firebase_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:device_preview/device_preview.dart';
import 'package:happy_helper/service/nookipedia_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/crafting.dart';
import 'pages/critters.dart';

GetIt locator = GetIt.instance;
bool usePreview = false;

void setupSingletons() async {
  locator.registerLazySingleton<FirebaseService>(() => FirebaseService());
  locator.registerLazySingleton<BasketService>(() => BasketService());
  locator.registerLazySingleton<ItemService>(() => ItemService());
  locator.registerLazySingleton<Nookipedia>(() => Nookipedia());
  locator.registerLazySingletonAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance());
}

void main() {
  setupSingletons();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF534D41), // navigation bar color
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent, // status bar color
  ));

  WidgetsFlutterBinding.ensureInitialized();

  GetIt.I.isReady<SharedPreferences>().then((_) {
    runApp(DevicePreview(
      enabled: !kReleaseMode && usePreview,
      builder: (context) => HappyHelper(),
    ));
  });
}

class HappyHelper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        locale: DevicePreview.of(context)?.locale,
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Color(0xFF534D41),
            accentColor: Colors.cyan[600],
            backgroundColor: Color(0xFFF3F0D3),
            brightness: Brightness.light,
            textTheme: TextTheme(
                headline1: TextStyle(fontSize: 42, color: Color(0xFF534D41)),
                headline2: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF534D41)),
                headline3: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Color(0x99534D41)),
                bodyText1: TextStyle(fontSize: 22, color: Color(0xFF534D41)),
                bodyText2: TextStyle(
                    color: Colors.white, fontSize: 50)), // used by homebuttons
            fontFamily: 'FinkHeavy'),
        home: HomeButtons(),
        routes: <String, WidgetBuilder>{
          '/crafting': (BuildContext context) => Crafting(),
          '/villagers': (BuildContext context) => Villagers(),
          '/critters': (BuildContext context) => Critters(),
          '/basket': (BuildContext context) => Basket()
        });
  }
}

class HomeButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1080, height: 2280, allowFontScaling: true);

    return new Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: <Widget>[
          Container(
              margin: EdgeInsets.all(40.w.toDouble()),
              child: ListView(
                children: <Widget>[
                  Image(image: AssetImage("assets/images/ac-logo.png")),
                  Text(
                    "Happy Helper",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline2
                        .copyWith(fontSize: ScreenUtil().setSp(150).toDouble()),
                  ),
                  Divider(color: Colors.transparent, height: 250.h.toDouble()),
                  _buildHomeButton("Crafting", Color(0xffDB8B68), context),
                  _buildHomeButton("Villagers", Color(0xff82E1C3), context),
                  _buildHomeButton("Critters", Color(0xffE9D179), context),
                ],
              )),
        ],
      ),
    );
  }
}

Widget _buildHomeButton(String name, Color color, BuildContext ctx) {
  return Container(
      margin: EdgeInsets.only(bottom: 50.h.toDouble()),
      height: 175.h.toDouble(),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 2,
        color: color,
        child: Center(
          child: InkWell(
              onTap: () {
                Navigator.pushNamed(ctx, "/" + name.toLowerCase());
              },
              child: ListTile(
                leading: Image(
                  image: AssetImage(
                      'assets/images/' + name.toLowerCase() + '.png'),
                ),
                title: Text(
                  name,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(120).toDouble(),
                      color: Colors.white),
                ),
              )),
        ),
      ));
}
