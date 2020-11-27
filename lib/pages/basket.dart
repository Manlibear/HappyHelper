import 'package:HappyHelper/service/basket_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Basket extends StatefulWidget {
  Basket({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _BasketState createState() => new _BasketState();
}

class _BasketState extends State<Basket> {
  BasketService _basketService = GetIt.I.get<BasketService>();

  @override
  Widget build(BuildContext context) {
    var basketItems = _basketService.getBasketItems();

    return StatefulBuilder(builder: (context, setState) {
      return DefaultTabController(
          length: 2,
          child: new Scaffold(
              appBar: AppBar(
                title: Text(
                  "Basket",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 42),
                ),
                bottom: TabBar(
                  labelColor: Theme.of(context).primaryColor,
                  indicatorColor: Theme.of(context).primaryColor.withAlpha(25),
                  tabs: <Widget>[
                    Tab(
                      child: Text("Materials", style: TextStyle(fontSize: 24)),
                    ),
                    Tab(
                      child: Text("Items", style: TextStyle(fontSize: 24)),
                    )
                  ],
                ),
                brightness: Brightness.light,
                backgroundColor: Theme.of(context).backgroundColor,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(
                    color: Theme.of(context).primaryColor,
                    size: 42 //change your color here
                    ),
              ),
              bottomNavigationBar: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8.0, left: 15, right: 15),
                    child: OutlineButton(
                      borderSide: BorderSide(color: Colors.lightGreen),
                      color: Colors.lightGreen,
                      textColor: Colors.lightGreen,
                      focusColor: Colors.lightGreen,
                      highlightedBorderColor: Colors.lightGreen,
                      onPressed: () => {
                        setState(() {
                          basketItems.clear();
                          _basketService.emptyBasket();
                        })
                      },
                      child: Text(
                        "Empty Baskt",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )),
              body: TabBarView(
                children: <Widget>[
                  Container(
                      color: Theme.of(context).backgroundColor,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          child: Column(children: <Widget>[
                            if (basketItems.length == 0)
                              Expanded(
                                  child: Text(
                                "Your basket is empty",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withAlpha(125)),
                              )),
                            for (var r in _basketService
                                .getBasketMaterials(basketItems))
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Image.asset(
                                      "assets/images/items/" + r.key + ".png",
                                      height: 32,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(r.name, style: Theme.of(context).textTheme.bodyText1),
                                  ),
                                  Text(r.count.toString(), style: Theme.of(context).textTheme.bodyText1)
                                ],
                              )
                          ]))),
                  Container(
                      color: Theme.of(context).backgroundColor,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 20),
                          child: Column(children: <Widget>[
                            if (basketItems.length == 0)
                              Expanded(
                                  child: Text(
                                "Your basket is empty",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withAlpha(125)),
                              )),
                            for (var r in basketItems)
                              Row(
                                children: <Widget>[
                                  Checkbox(
                                    activeColor: Colors.lightGreen,
                                    value: r.complete,
                                    onChanged: (bool value) {
                                      setState(() {
                                        r.complete = value;

                                        _basketService.completeBasketItem(
                                            r.key, basketItems);
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Image.asset(
                                      "assets/images/items/" + r.key + ".png",
                                      height: 32,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(r.name, style: Theme.of(context).textTheme.bodyText1,),
                                  ),
                                  Text(r.getCountText(), style: Theme.of(context).textTheme.bodyText1)
                                ],
                              )
                          ])))
                ],
              )));
    });
  }
}
