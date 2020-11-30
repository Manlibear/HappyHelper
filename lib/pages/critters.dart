import 'package:cached_network_image/cached_network_image.dart';
import 'package:happy_helper/service/firebase_service.dart';
import 'package:happy_helper/service/helper_service.dart';
import 'package:get_it/get_it.dart';
import 'package:happy_helper/model/critter.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:happy_helper/service/nookipedia_api_service.dart';
import 'package:happy_helper/widgets/NookCard.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Critters extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CrittersState();
}

class _CrittersState extends State<Critters> {
  FirebaseService _firebaseService = GetIt.I.get<FirebaseService>();
  Nookipedia _nookipediaService = GetIt.I.get<Nookipedia>();
  Map<String, Critter> allCritters = new Map<String, Critter>();
  Map<String, Critter> critters = new Map<String, Critter>();

  TextEditingController editingController = TextEditingController();
  bool isLoading = true;
  bool noItems = false;
  var cardKeys = Map<int, GlobalKey<FlipCardState>>();
  bool filterThisMonth = false;

  @override
  void initState() {
    _nookipediaService
        .fetchList<Critter>(NookipediaEndpoints.Fish)
        .then((fish) => ({
              for (var f in fish) {allCritters[f.key] = f},
              _nookipediaService
                  .fetchList<Critter>(NookipediaEndpoints.Bugs)
                  .then((bugs) => ({
                        for (var b in bugs) {allCritters[b.key] = b},
                        _nookipediaService
                            .fetchList<Critter>(
                                NookipediaEndpoints.SeaCreatures)
                            .then((seaCreatures) => ({
                                  for (var sc in seaCreatures)
                                    {allCritters[sc.key] = sc},
                                  allCritters.forEach((key, value) {
                                    critters[key] = value;
                                  }),
                                  setState(() {
                                    isLoading = false;
                                  })
                                }))
                      }))
            }));

    editingController.addListener(() {
      setState(() {
        critters.clear();
        String query = editingController.text.toLowerCase();

        allCritters.forEach((k, v) => {
              if ((v.name ?? "").toLowerCase().contains(query))
                {critters[k] = v}
            });
      });
    });

    super.initState();
  }

  void updateFilter() {
    critters.clear();

    allCritters.forEach((key, value) {
      var thisMonth =
          value.months.firstWhere((x) => x.month == DateTime.now().month);

      var nextMonth =
          value.months.firstWhere((x) => x.month == DateTime.now().month + 1);

      bool onlyThisMonth = thisMonth.spawns() && !nextMonth.spawns();

      if (onlyThisMonth) print(key + " only spawns this month");

      if (!filterThisMonth || onlyThisMonth) critters[key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            Text("Critters",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: (filterThisMonth
                        ? ScreenUtil().setSp(100)
                        : ScreenUtil().setSp(120)))),
            if (filterThisMonth)
              Text("leaving this month",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: ScreenUtil().setSp(70)))
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => {
                    setState(() {
                      filterThisMonth = !filterThisMonth;
                      updateFilter();
                    })
                  })
        ],
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColor, size: 42),
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(fontSize: 60.w),
                    controller: editingController,
                    decoration: InputDecoration(
                        labelText: "Search",
                        hintText: "",
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Colors.white70,
                        prefixIcon: Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          borderSide: BorderSide(
                              width: 1, color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)))),
                  ),
                ),
              ),
              if (isLoading)
                Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ))),
              if (noItems)
                Expanded(
                    child: Center(
                        child: Text(
                  "No Items Found",
                  style: Theme.of(context).textTheme.subtitle1,
                ))),
              Expanded(
                  child: AnimationLimiter(
                child: Scrollbar(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: GridView.builder(
                      itemBuilder: (BuildContext ctx, int i) {
                        String key = critters.values.toList()[i].key;
                        cardKeys.putIfAbsent(
                            i, () => GlobalKey<FlipCardState>());
                        GlobalKey<FlipCardState> thisCard = cardKeys[i];
                        return AnimationConfiguration.staggeredGrid(
                            position: i,
                            duration: const Duration(milliseconds: 375),
                            columnCount: 3,
                            child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                    child: FlipCard(
                                  key: thisCard,
                                  back: Container(),
                                  front: Hero(
                                    tag: "CritterPopup$key",
                                    child: NookCard(
                                        backgroundColour:
                                            critters.values.toList()[i].isFish
                                                ? Color(0xFFC9FDF9)
                                                : Color(0xFFCAFEC9),
                                        builder: (BuildContext context) {
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: critters.values
                                                    .toList()[i]
                                                    .imageUrl,
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                              if (critters.values
                                                  .toList()[i]
                                                  .hasBeenCaught)
                                                Align(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    50.w)),
                                                        color: Colors.green),
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      size: 100.w,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  alignment: Alignment.topRight,
                                                ),
                                            ],
                                          );
                                        },
                                        contentPadding: 15,
                                        onTapFunc: () async {
                                          await Navigator.of(context).push(
                                            PageRouteBuilder(
                                              barrierColor: Colors.black45,
                                              opaque: false,
                                              pageBuilder: (_, __, ___) =>
                                                  SingleFlipCard(critters.values
                                                      .toList()[i]),
                                            ),
                                          );
                                        }),
                                  ),
                                ))));
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.25,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      itemCount: critters.length,
                    ),
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class SingleFlipCard extends StatefulWidget {
  SingleFlipCard(this.critter);

  final Critter critter;

  @override
  SingleFlipCardState createState() => SingleFlipCardState();
}

class SingleFlipCardState extends State<SingleFlipCard>
    with AfterLayoutMixin<SingleFlipCard> {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void afterFirstLayout(BuildContext context) {
    cardKey.currentState.toggleCard();
  }

  @override
  Widget build(BuildContext context) {
    String key = widget.critter.key;

    final SharedPreferences prefs = GetIt.I.get<SharedPreferences>();

    return WillPopScope(
        onWillPop: () {
          if (!cardKey.currentState.isFront) {
            cardKey.currentState.toggleCard(() => Navigator.pop(context));
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        },
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
                child: Center(
              child: Hero(
                tag: "CritterPopup$key",
                child: Container(
                  width: 1000.w,
                  height: 1250.w,
                  child: FlipCard(
                    key: cardKey,
                    front: NookCard(
                      backgroundColour: widget.critter.isFish
                          ? Color(0xFFC9FDF9)
                          : Color(0xFFCAFEC9),
                      onTapFunc: () => {Navigator.pop(context)},
                      builder: (BuildContext context) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(widget.critter.imageUrl),
                            if (widget.critter.hasBeenCaught)
                              Align(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0, right: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50.w)),
                                        color: Colors.green),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 100.w,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.topRight,
                              ),
                          ],
                        );
                      },
                    ),
                    back: NookCard(
                      backgroundColour: widget.critter.isFish
                          ? Color(0xFFC9FDF9)
                          : Color(0xFFCAFEC9),
                      builder: (BuildContext context) {
                        return Column(
                          children: [
                            Text(
                              widget.critter.name,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(fontSize: ScreenUtil().setSp(125)),
                            ),
                            if (widget.critter.isFish &&
                                !widget.critter.isSeaCreature)
                              Padding(
                                padding: const EdgeInsets.only(top: 25),
                                child: _leftRightRow(
                                    "location", widget.critter.area),
                              ),
                            Expanded(
                              child: GridView.count(
                                  crossAxisCount: 4,
                                  childAspectRatio: 1.75,
                                  children: [
                                    for (var m in widget.critter.months)
                                      FilterChip(
                                        onSelected: (bool value) => {},
                                        label: Container(
                                          width: 130.w,
                                          height: 80.h,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              HelperService.monthNameFromNumber(
                                                  m.month),
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(60),
                                                  color: m.spawns()
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .primaryColor),
                                            ),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(0),
                                        showCheckmark: false,
                                        selected: m.spawns(),
                                        selectedColor: Colors.greenAccent,
                                        checkmarkColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            side: BorderSide(
                                                width: (DateTime.now().month ==
                                                        m.month
                                                    ? 2
                                                    : 1),
                                                color: (DateTime.now().month ==
                                                        m.month
                                                    ? Colors.white
                                                    : Colors.grey))),
                                        backgroundColor:
                                            Theme.of(context).backgroundColor,
                                      )
                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Text(
                                "active hours (this month)",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            Stack(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    for (int i = 1; i <= 24; i++)
                                      if (isBigRuleIncrement(i))
                                        Text(getRuleTimeAsString(i),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize:
                                                    ScreenUtil().setSp(35))),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      for (int i = 1; i <= 24; i++)
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Stack(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  children: [
                                                    Container(
                                                        decoration:
                                                            getRuleSegmentDecoration(
                                                                i,
                                                                widget.critter),
                                                        width: 13.75,
                                                        height: 10),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        top: 5,
                                                      ),
                                                      color:
                                                          DateTime.now().hour ==
                                                                  i
                                                              ? Colors.red
                                                              : Colors.grey,
                                                      width: 2,
                                                      height: DateTime.now()
                                                                  .hour ==
                                                              i
                                                          ? 20
                                                          : getTimeRuleLineHeight(
                                                              i),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Container(
                                  height: 125.h,
                                  child: Material(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    elevation: 2,
                                    color: widget.critter.hasBeenCaught
                                        ? Colors.red[300]
                                        : Colors.green[300],
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            var newVal =
                                                !widget.critter.hasBeenCaught;
                                            prefs.setBool("Caught$key", newVal);
                                            widget.critter.hasBeenCaught =
                                                newVal;
                                          });
                                        },
                                        child: Text(
                                          widget.critter.hasBeenCaught
                                              ? "Mark as not Caught"
                                              : "Mark as Caught",
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(80),
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        );
                      },
                      contentPadding: 25,
                      onTapFunc: () {
                        cardKey.currentState
                            .toggleCard(() => Navigator.pop(context));
                      },
                    ),
                  ),
                ),
              ),
            ))));
  }

  double getTimeRuleLineHeight(int index) {
    if (isBigRuleIncrement(index)) return 20;

    if (isMediumRuleIncrement(index)) return 10;

    return 7;
  }

  bool isBigRuleIncrement(int i) {
    return (i % 6 == 0 || i == 1);
  }

  bool isMediumRuleIncrement(int i) {
    return (i % 3 == 0);
  }

  BoxDecoration getRuleSegmentDecoration(int i, Critter c) {
    bool anyBefore = i != 1 ? showSpawnOnRule(i - 1, c) : false;
    bool anyAfter = i != 24 ? showSpawnOnRule(i + 1, c) : false;

    return BoxDecoration(
        color: showSpawnOnRule(i, widget.critter)
            ? Colors.yellow.withAlpha(200)
            : Colors.transparent,
        borderRadius: new BorderRadius.only(
            topLeft: Radius.circular(anyBefore ? 0 : 20),
            bottomLeft: Radius.circular(anyBefore ? 0 : 20),
            topRight: Radius.circular(anyAfter ? 0 : 20),
            bottomRight: Radius.circular(anyAfter ? 0 : 20)));
  }

  bool showSpawnOnRule(int i, Critter c) {
    CritterSpawnMonth month = c.months[DateTime.now().month - 1];

    return month.times[i - 1];

    if (c.isFish) {
      switch (i) {
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
          return month.morning > 0;

        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
        case 16:
          return month.midday > 0;

        case 17:
        case 18:
        case 19:
        case 20:
        case 21:
        case 22:
        case 23:
        case 24:
          return month.night > 0;
      }
    } else {
      switch (i) {
        case 1:
        case 2:
        case 3:
        case 4:
          return month.earlyMorn > 0;

        case 5:
        case 6:
        case 7:
        case 8:
          return month.midMorn > 0;

        case 9:
        case 10:
        case 11:
        case 12:
          return month.lateMorn > 0;

        case 13:
        case 14:
        case 15:
        case 16:
          return month.earlyAfter > 0;

        case 17:
        case 18:
        case 19:
        case 20:
          return month.lateAfter > 0;

        case 21:
        case 22:
        case 23:
        case 24:
          return month.eve > 0;
      }
    }

    return false;
  }

  String getRuleTimeAsString(int i) {
    switch (i) {
      case 1:
        return '''AM
12''';

      case 6:
      case 18:
        return "6     ";

      case 12:
        return '''PM     
12''';

      case 24:
        return "     ";
    }
    return i.toString();
  }

  Widget _leftRightRow(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          left,
          style:
              TextStyle(fontSize: 70.w, color: Theme.of(context).primaryColor),
        ),
        Text(right ?? "",
            style: TextStyle(
                fontSize: 70.w, color: Theme.of(context).primaryColor))
      ],
    );
  }
}
