import 'package:cached_network_image/cached_network_image.dart';
import 'package:happy_helper/model/villager.dart';
import 'package:happy_helper/service/nookipedia_api_service.dart';
import 'package:happy_helper/widgets/NookCard.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get_it/get_it.dart';
import 'package:flag/flag.dart';

class Villagers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new VillagersState();
}

class VillagersState extends State<Villagers> {
  bool isLoading = true;
  bool noItems = false;
  TextEditingController editingController = TextEditingController();
  var cardKeys = Map<int, GlobalKey<FlipCardState>>();
  Map<String, Villager> villagers = new Map<String, Villager>();
  Map<String, Villager> allVillagers = new Map<String, Villager>();

  Map<String, Map<String, bool>> filter = new Map<String, Map<String, bool>>();

  Nookipedia _nookipedia = GetIt.I.get<Nookipedia>();

  @override
  void initState() {
    // prepare the filter maps
    filter["gender"] = new Map<String, bool>();
    filter["personality"] = new Map<String, bool>();
    filter["species"] = new Map<String, bool>();

    _nookipedia.fetchList<Villager>(NookipediaEndpoints.Villagers).then((data) {
      for (var v in data) {
        allVillagers[v.key] = v;
      }

      allVillagers.forEach((k, v) {
        villagers[k] = v;

        if (!filter["gender"].containsKey(v.gender)) {
          filter['gender'][v.gender] = true;
        }

        if (!filter["personality"].containsKey(v.personality)) {
          filter['personality'][v.personality] = true;
        }

        if (!filter["species"].containsKey(v.species)) {
          filter['species'][v.species] = true;
        }
      });

      setState(() {
        isLoading = false;
      });

      editingController.addListener(() {
        setState(() {
          villagers.clear();
          String query = editingController.text.toLowerCase();

          allVillagers.forEach((k, v) => {
                if ((v.name ?? "").toLowerCase().contains(query) &&
                    filter["species"][v.species] &&
                    filter["personality"][v.personality] &&
                    filter["gender"][v.gender])
                  {villagers[k] = v}
              });
        });
      });
    });

    super.initState();
  }

  void updateFilter() {
    villagers.clear();
    allVillagers.forEach((k, v) => {
          if (filter["species"][v.species] &&
              filter["personality"][v.personality] &&
              filter["gender"][v.gender])
            {villagers[k] = v}
        });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Villagers",
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 42)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showFilterDialog(context),
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
                        String key = villagers.values.toList()[i].key;
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
                                    tag: "VillagerPopup$key",
                                    child: NookCard(
                                        backgroundColour: Villager
                                                .villagerColors[
                                            villagers.values.toList()[i].name],
                                        builder: (BuildContext context) {
                                          return Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CachedNetworkImage(
                                                imageUrl: villagers.values
                                                    .toList()[i]
                                                    .imageUrl,
                                                placeholder: (context, url) =>
                                                    Center(
                                                      child: SizedBox(
                                                          width: 100.w,
                                                          height: 100.w,
                                                          child:
                                                              CircularProgressIndicator()),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error)),
                                          );
                                        },
                                        contentPadding: 15,
                                        onTapFunc: () async {
                                          await Navigator.of(context).push(
                                            PageRouteBuilder(
                                              barrierColor: Colors.black45,
                                              opaque: false,
                                              pageBuilder: (_, __, ___) =>
                                                  SingleFlipCard(villagers
                                                      .values
                                                      .toList()[i]),
                                            ),
                                          );
                                        }),
                                  ),
                                ))));
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 5 / 7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      itemCount: villagers.length,
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

  void _showFilterDialog(BuildContext ctx) {
    Navigator.of(ctx).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Scaffold(
                backgroundColor: Colors.black87,
                appBar: AppBar(
                  brightness: Brightness.light,
                  backgroundColor: Theme.of(context).backgroundColor,
                  elevation: 0,
                  centerTitle: true,
                  iconTheme: IconThemeData(
                      color: Theme.of(context).primaryColor, size: 42),
                  title: Text("Filter",
                      style: Theme.of(context).textTheme.headline1),
                ),
                body: Container(
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).backgroundColor,
                    child: CustomScrollView(
                      slivers: <Widget>[
                        _filterSectionHeader('Gender', setState),
                        _filterSectionChips(
                            field: 'gender',
                            columnCount: 2,
                            stateSetter: setState),
                        _filterSectionHeader('Personality', setState),
                        _filterSectionChips(
                            field: 'personality', stateSetter: setState),
                        _filterSectionHeader('Species', setState),
                        _filterSectionChips(
                            field: 'species', stateSetter: setState),
                      ],
                    )));
          });
        },
        fullscreenDialog: true));
  }

  SliverList _filterSectionHeader(String title, Function stateSetter) {
    String toggleButtonText =
        filter[title.toLowerCase()].values.first ? "Clear" : "All";
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: EdgeInsets.only(top: 70.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(fontSize: 80.w),
                ),
                OutlineButton(
                  child: Text(
                    toggleButtonText,
                    style: TextStyle(fontSize: 40.w),
                  ),
                  onPressed: () {
                    var targetState;

                    filter[title.toLowerCase()].forEach((key, value) {
                      if (targetState == null)
                        targetState = !filter[title.toLowerCase()][key];

                      filter[title.toLowerCase()][key] = targetState;
                    });

                    updateFilter();
                    stateSetter(() => {});
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  SliverGrid _filterSectionChips(
      {String field, int columnCount = 3, Function stateSetter}) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount, childAspectRatio: 2.5),
      delegate: SliverChildListDelegate(
        [
          for (var p in filter[field].keys)
            FilterChip(
              label: Text(
                p,
                style: TextStyle(
                    color: filter[field][p]
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    fontSize: 40.w),
              ),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Colors.grey)),
              selectedColor: Colors.greenAccent,
              backgroundColor: Theme.of(context).backgroundColor,
              selected: filter[field][p],
              onSelected: (bool value) {
                filter[field][p] = value;
                updateFilter();
                stateSetter(() {});
              },
            )
        ],
      ),
    );
  }
}

class SingleFlipCard extends StatefulWidget {
  SingleFlipCard(this.villager);

  final Villager villager;

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
    String key = widget.villager.key;
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
          child: Hero(
            tag: "VillagerPopup$key",
            child: Center(
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                height: 1600.h,
                width: 1000.w,
                child: FlipCard(
                  key: cardKey,
                  flipOnTouch: false,
                  direction: FlipDirection.HORIZONTAL,
                  front: NookCard(
                    backgroundColour:
                        Villager.villagerColors[widget.villager.name],
                    onTapFunc: () => {Navigator.pop(context)},
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: CachedNetworkImage(
                            imageUrl: widget.villager.imageUrl,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error)),
                      );
                    },
                  ),
                  back: NookCard(
                    onTapFunc: () {
                      cardKey.currentState
                          .toggleCard(() => Navigator.pop(context));
                    },
                    backgroundColour:
                        Villager.villagerColors[widget.villager.name],
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                widget.villager.name,
                                style: TextStyle(fontSize: 140.w),
                              ),
                            ),
                            Flex(
                              direction: Axis.horizontal,
                              children: [
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    _leftRightRow(
                                        "Gender", widget.villager.gender),
                                    _leftRightRow(
                                        "Birthday", widget.villager.birthday),
                                    _leftRightRow("Personality",
                                        widget.villager.personality),
                                    _leftRightRow(
                                        "Species", widget.villager.species),
                                    _leftRightRow("Phrase",
                                        "\"" + widget.villager.phrase + "\""),
                                    _leftRightRow(
                                        "Hobby", widget.villager.hobby),
                                  ],
                                )),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 450.h,
                                      decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(30),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Fav. Styles",
                                              style: TextStyle(fontSize: 80.w),
                                            ),
                                            for (var c in widget
                                                .villager.favouriteStyles)
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0),
                                                  child: Text(c,
                                                      style: TextStyle(
                                                          fontSize: 60.w))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 450.h,
                                      decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(30),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Fav. Colours",
                                              style: TextStyle(fontSize: 80.w),
                                            ),
                                            for (var c in widget
                                                .villager.favouriteColours)
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0),
                                                  child: Text(c,
                                                      style: TextStyle(
                                                          fontSize: 60.w))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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
  }
}

Widget _leftRightRow(String left, String right) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.black.withAlpha(30),
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              left,
              style: TextStyle(fontSize: 70.w),
            ),
            Text(right, style: TextStyle(fontSize: 70.w))
          ],
        ),
      ),
    ),
  );
}

class NookChip extends StatelessWidget {
  NookChip({@required this.countryCode, @required this.label});
  final String countryCode;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380.w,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flag(
              countryCode,
              width: 42.w,
            ),
            Text(
              label,
              style: TextStyle(fontSize: 42.w),
            )
          ]),
    );
  }
}
