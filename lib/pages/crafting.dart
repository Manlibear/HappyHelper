import 'package:HappyHelper/service/basket_service.dart';
import 'package:HappyHelper/service/item_service.dart';
import 'package:HappyHelper/widgets/NookCard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:HappyHelper/model/furniture.dart';
import 'package:HappyHelper/service/firebase_service.dart';
import 'package:get_it/get_it.dart';
import 'package:badges/badges.dart';
import 'package:flutter_counter/flutter_counter.dart';

class Crafting extends StatefulWidget {
  Crafting({Key key, this.title, this.allFurniture}) : super(key: key);
  final String title;

  final Map<String, Furniture> allFurniture;

  @override
  _CraftingState createState() => new _CraftingState();
}

class _CraftingState extends State<Crafting> {
  TextEditingController editingController = TextEditingController();

  FirebaseService _firebaseService = GetIt.I.get<FirebaseService>();
  ItemService _itemService = GetIt.I.get<ItemService>();
  BasketService _basketService = GetIt.I.get<BasketService>();

  Map<String, Furniture> allFurniture;
  Map<String, Furniture> furniture = new Map<String, Furniture>();
  bool isLoading = true;
  bool noItems = false;
  int _initialCraftingCount = 1;

  @override
  initState() {
    _firebaseService.getAllFurniture().then((data) {
      allFurniture = data;
      _itemService.allItems = data;

      allFurniture.forEach((k, f) => furniture[k] = f);

      setState(() {
        isLoading = false;
        setBasketTotal();
      });
    });

    editingController.addListener(() {
      setState(() {
        furniture.clear();
        String query = editingController.text.toLowerCase();
        allFurniture.forEach((k, f) => {
              if ((f.name ?? "").toLowerCase().contains(query))
                {furniture[k] = f}
            });

        noItems = furniture.length == 0;
      });
    });

    super.initState();
  }

  int basketItemsCounts = 0;
  Widget basketItemsBadge;
  String searchText = "";

  void filterSearchResults(String query) {
    searchText = query;
    noItems = true;
    furniture.clear();
    allFurniture.forEach((k, f) => {
          if (f.name.contains(searchText)) {furniture[k] = f}
        });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    basketItemsBadge = Badge(
      badgeContent: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          basketItemsCounts.toString(),
          style: TextStyle(fontSize: ScreenUtil().setSp(40)),
        ),
      ),
      position: BadgePosition.topRight(top: 0, right: 0),
      badgeColor: Colors.white,
      showBadge: basketItemsCounts > 0,
      child: IconButton(
        icon: Icon(Icons.shopping_basket),
        iconSize: 36,
        onPressed: () async {
          await Navigator.pushNamed(context, "/basket");
          setState(() {
            setBasketTotal();
          });
        },
      ),
    );

    ScreenUtil.init(context, width: 1080, height: 2280, allowFontScaling: true);

    return new Scaffold(
        appBar: AppBar(
          title: Text(
            "Crafting",
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 42),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: basketItemsBadge,
            )
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
                        style: TextStyle(fontSize: 20),
                        controller: editingController,
                        decoration: InputDecoration(
                            labelText: "Search",
                            hintText: "",
                            filled: true,
                            fillColor: Colors.white,
                            focusColor: Colors.white70,
                            prefixIcon: Icon(Icons.search),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)),
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Theme.of(context).primaryColor),
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
                      style: Theme.of(context).textTheme.subtitle,
                    ))),
                  Expanded(
                      child: AnimationLimiter(
                    child: Scrollbar(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: GridView.builder(
                          itemBuilder: (BuildContext ctx, int i) {
                            return AnimationConfiguration.staggeredGrid(
                                position: i,
                                duration: const Duration(milliseconds: 375),
                                columnCount: 3,
                                child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: NookCard(
                                          imageFolder: "items",
                                          imageKey:
                                              furniture.values.toList()[i].key,
                                          onTapFunc: _showCraftingPopup,
                                          callbackParam:
                                              furniture.values.toList()[i]),
                                    )));
                          },
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 5 / 7,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10),
                          itemCount: furniture.length,
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            )));
  }

  Future<void> _showCraftingPopup(Furniture furni) async {
    _initialCraftingCount = 1;
    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SimpleDialog(
                title: null,
                contentPadding:
                    EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Color(0xFFF8F6E2),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                          width: 125,
                          height: 175,
                          child: NookCard(
                              imageFolder: "items",
                              imageKey: furni.key,
                              onTapFunc: () => {},
                              callbackParam: null))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Text(
                      furni.name ?? "[UNKNOWN]",
                      style: Theme.of(context)
                          .textTheme
                          .display1
                          .copyWith(fontSize: ScreenUtil().setSp(75)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      for (int i = 0; i < 6; i++) _buildCraftingRow(furni, i)
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, right: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: 325.w,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Counter(
                                valueSpacing: 110.w,
                                textTopPadding: 10.w,
                                textStyle: TextStyle(
                                  fontSize: ScreenUtil().setSp(70),
                                ),
                                buttonSize: 80.w,
                                color: Theme.of(context).primaryColor,
                                decimalPlaces: 0,
                                initialValue: _initialCraftingCount,
                                maxValue: 99,
                                minValue: 1,
                                onChanged: (num value) {
                                  setState(() {
                                    _initialCraftingCount = value;
                                  });
                                },
                              ),
                            )),
                        Expanded(
                          child: OutlineButton(
                            child: Text(
                              "Add to Basket",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(45)),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            color: Colors.lightGreen,
                            borderSide: BorderSide(color: Colors.lightGreen),
                            textColor: Colors.lightGreen,
                            focusColor: Colors.lightGreen,
                            highlightedBorderColor: Colors.lightGreen,
                            onPressed: () {
                              Navigator.pop(context, "Yes");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        })) {
      case "Yes":
        _basketService.addToBasket(furni, _initialCraftingCount);
        setState(() {
          setBasketTotal();
        });
        print("Added to basket");
        break;
      case "No":
        // ...
        break;
    }
  }

  void setBasketTotal() {
    int total = 0;
    _basketService.basket.forEach((f, c) => total += c);
    basketItemsCounts = total;
  }

  bool evenCraftingRow = false;

  Widget _buildCraftingRow(Furniture furni, int count) {
    double cornerRadius = 15;

    double topLeft = 0;
    double topRight = 0;
    double bottomLeft = 0;
    double bottomRight = 0;

    switch (count) {
      case 0:
        topLeft = cornerRadius;
        topRight = cornerRadius;
        break;
      case 5:
        bottomLeft = cornerRadius;
        bottomRight = cornerRadius;
        break;
    }

    String itemName = "";
    String itemKey = "";
    String itemCount = "";

    bool drawChildren = true;

    if (furni.recipe.length > count) {
      itemKey = furni.recipe[count].key;
      itemName = furni.recipe[count].name;
      itemCount = furni.recipe[count].count.toString();
    } else {
      drawChildren = false;
    }

    Color rowColor = evenCraftingRow ? Color(0x30E1D8B7) : Color(0x60E2D5AB);
    evenCraftingRow = !evenCraftingRow;

    return Material(
      color: rowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft),
            topRight: Radius.circular(topRight),
            bottomLeft: Radius.circular(bottomLeft),
            bottomRight: Radius.circular(bottomRight)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
        child: Container(
            child: Row(
          children: <Widget>[
            if (drawChildren)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Image.asset(
                  "assets/images/items/" + itemKey + ".png",
                  height: 36,
                ),
              ),
            Expanded(
                child: Text(
              itemName,
              style: TextStyle(fontSize: ScreenUtil().setSp(50)),
            )),
            Container(
              height: 36,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Text(
                itemCount,
                style: TextStyle(fontSize: ScreenUtil().setSp(50)),
                textAlign: TextAlign.right,
              ),
            )
          ],
        )),
      ),
    );
  }
}
