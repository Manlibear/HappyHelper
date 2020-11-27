import 'package:HappyHelper/service/basket_service.dart';
import 'package:HappyHelper/service/item_service.dart';
import 'package:HappyHelper/widgets/NookCard.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flip_card/flip_card.dart';
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

  var cardKeys = Map<int, GlobalKey<FlipCardState>>();

  Map<String, Furniture> allFurniture;
  Map<String, Furniture> furniture = new Map<String, Furniture>();
  bool isLoading = true;
  bool noItems = false;

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
          style: TextStyle(
              fontSize: ScreenUtil().setSp(40),
              color: Theme.of(context).primaryColor),
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
                            String key = furniture.values.toList()[i].key;
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
                                          tag: "FurniturePopup$key",
                                          child: NookCard(
                                            builder: (BuildContext context) {
                                              return Image(
                                                  image: AssetImage(
                                                      "assets/images/items/$key.png"));
                                            },
                                            onTapFunc: () async {
                                              await Navigator.of(context).push(
                                                PageRouteBuilder(
                                                  barrierColor: Colors.black45,
                                                  opaque: false,
                                                  pageBuilder: (_, __, ___) =>
                                                      SingleFlipCard(furniture
                                                          .values
                                                          .toList()[i]),
                                                ),
                                              );
                                              setBasketTotal();
                                            },
                                          ),
                                        ),
                                      ),
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

  void setBasketTotal() {
    int total = 0;
    _basketService.basket.forEach((f, c) => total += c);
    setState(() {
      basketItemsCounts = total;
    });
  }
}

class SingleFlipCard extends StatefulWidget {
  SingleFlipCard(this.furniture);

  final Furniture furniture;

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

  var _initialCraftingCount = 1;

  @override
  Widget build(BuildContext context) {
    String key = widget.furniture.key;

    BasketService _basketService = GetIt.I.get<BasketService>();

    return StatefulBuilder(
      builder: (context, stateSetter) {
        return WillPopScope(
          onWillPop: () {
            if (!cardKey.currentState.isFront) {
              cardKey.currentState
                  .toggleCard(callback: () => Navigator.pop(context));
            } else {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              child: Center(
                child: Hero(
                  tag: "FurniturePopup$key",
                  child: Container(
                    color: Colors.transparent,
                    height: 1800.h,
                    width: 1000.w,
                    child: FlipCard(
                      key: cardKey,
                      flipOnTouch: false,
                      direction: FlipDirection.HORIZONTAL,
                      front: NookCard(
                        onTapFunc: () => {Navigator.pop(context)},
                        builder: (BuildContext context) {
                          return Image(
                              image:
                                  AssetImage("assets/images/items/$key.png"));
                        },
                      ),
                      back: NookCard(
                        onTapFunc: () {
                          cardKey.currentState.toggleCard(
                              callback: () => Navigator.pop(context));
                        },
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15, bottom: 15),
                                    child: Text(
                                      widget.furniture.name ?? "[UNKNOWN]",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline1
                                          .copyWith(
                                              fontSize:
                                                  ScreenUtil().setSp(100)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      for (int i = 0; i < 6; i++)
                                        _buildCraftingRow(widget.furniture, i)
                                    ],
                                  ),
                                ),
                                Counter(
                                  valueSpacing: 110.w,
                                  textTopPadding: 10.w,
                                  textStyle: TextStyle(
                                      fontSize: ScreenUtil().setSp(70),
                                      color: Theme.of(context).primaryColor),
                                  buttonSize: 100.w,
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
                                OutlineButton(
                                  child: Text(
                                    "Add to Basket",
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(70)),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  color: Colors.lightGreen,
                                  borderSide:
                                      BorderSide(color: Colors.lightGreen),
                                  textColor: Colors.lightGreen,
                                  focusColor: Colors.lightGreen,
                                  highlightedBorderColor: Colors.lightGreen,
                                  onPressed: () {
                                    _basketService.addToBasket(widget.furniture,
                                        _initialCraftingCount);
                                    if (!cardKey.currentState.isFront) {
                                      cardKey.currentState.toggleCard(
                                          callback: () =>
                                              Navigator.pop(context));
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              onTap: () {
                cardKey.currentState.toggleCard();
                Navigator.pop(context);
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                cardKey.currentState.toggleCard();
              },
            ),
          ),
        );
      },
    );
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

    Color rowColor = evenCraftingRow ? Color(0xFFE0D4AC) : Color(0xFFD9D0A8);
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
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(60),
                  color: Theme.of(context).primaryColor),
            )),
            Container(
              height: 36,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Text(
                itemCount,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    color: Theme.of(context).primaryColor),
                textAlign: TextAlign.right,
              ),
            )
          ],
        )),
      ),
    );
  }
}
