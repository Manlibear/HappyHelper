import 'package:HappyHelper/pages/basket.dart';
import 'package:HappyHelper/pages/villagers.dart';
import 'package:HappyHelper/service/basket_service.dart';
import 'package:HappyHelper/service/item_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:HappyHelper/service/firebase_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'pages/crafting.dart';


GetIt locator = GetIt.instance;

void setupSingletons() async {
  locator.registerLazySingleton<FirebaseService>(() => FirebaseService());
  locator.registerLazySingleton<BasketService>(() => BasketService());
  locator.registerLazySingleton<ItemService>(() => ItemService());
}

void main() {
  setupSingletons();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF534D41), // navigation bar color
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent, // status bar color
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          '/critters': (BuildContext context) => Crafting(),
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
              margin: EdgeInsets.all(40.w),
              child: ListView(
                children: <Widget>[
                  Image(image: AssetImage("assets/images/ac-logo.png")),
                  Text(
                    "Happy Helper",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline2
                        .copyWith(fontSize: ScreenUtil().setSp(150)),
                  ),
                  Divider(color: Colors.transparent, height: 250.h),
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
      margin: EdgeInsets.only(bottom: 50.h),
      height: 175.h,
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
                      fontSize: ScreenUtil().setSp(120), color: Colors.white),
                ),
              )),
        ),
      ));
}
