import 'package:HappyHelper/model/villager.dart';
import 'package:HappyHelper/service/firebase_service.dart';
import 'package:HappyHelper/widgets/NookCard.dart';
import 'package:HappyHelper/widgets/ChipButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get_it/get_it.dart';

class Villagers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new VillagersState();
}

class VillagersState extends State<Villagers> {
  bool isLoading = true;
  bool noItems = false;
  TextEditingController editingController = TextEditingController();

  Map<String, Villager> villagers = new Map<String, Villager>();
  Map<String, Villager> allVillagers = new Map<String, Villager>();

  Map<String, Map<String, bool>> filter = new Map<String, Map<String, bool>>();

  FirebaseService _firebaseService = GetIt.I.get<FirebaseService>();

  @override
  void initState() {
    // prepare the filter maps
    filter["gender"] = new Map<String, bool>();
    filter["personality"] = new Map<String, bool>();
    filter["species"] = new Map<String, bool>();

    _firebaseService.getAllVillagers().then((data) {
      allVillagers = data;

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
                if ((v.name ?? "").toLowerCase().contains(query))
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
                                      imageFolder: "villagers",
                                      imageKey:
                                          villagers.values.toList()[i].key,
                                      extraPadding: 15,
                                      onTapFunc: _showVillagerPopup,
                                      callbackParam:
                                          villagers.values.toList()[i]),
                                )));
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

  Widget _showVillagerPopup(Villager villager) {
    return Container();
  }

  void _showFilterDialog(BuildContext ctx) {
    Navigator.of(ctx).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Scaffold(
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
                        //Start Gender
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Gender", style: Theme.of(context).textTheme.headline4),
                                  OutlineButton(
                                    child: Text("Clear"),
                                    onPressed: () => {},
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, childAspectRatio: 2.5),
                          delegate: SliverChildListDelegate(
                            [
                              for (var p in filter["gender"].keys)
                                FilterChip(
                                  label: Text(p),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      side: BorderSide(color: Colors.grey)),
                                  selectedColor: Colors.lightGreenAccent,
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  selected: filter['gender'][p],
                                  onSelected: (bool value) {
                                    setState(() {
                                      filter['gender'][p] = value;
                                      updateFilter();
                                    });
                                  },
                                )
                            ],
                          ),
                        ),
                        // end gender

                        //Start personality
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Personality", style: Theme.of(context).textTheme.headline4),
                                    OutlineButton(
                                      child: Text("Clear"),
                                      onPressed: () => {},
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, childAspectRatio: 2.5),
                          delegate: SliverChildListDelegate(
                            [
                              for (var p in filter["personality"].keys)
                                FilterChip(
                                  label: Text(p),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      side: BorderSide(color: Colors.grey)),
                                  selectedColor: Colors.lightGreenAccent,
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  selected: filter['personality'][p],
                                  onSelected: (bool value) {
                                    setState(() {
                                      filter['personality'][p] = value;
                                      updateFilter();
                                    });
                                  },
                                )
                            ],
                          ),
                        ),
                        // end personality

                        //Start personality
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Species", style: Theme.of(context).textTheme.headline4,),
                                    OutlineButton(
                                      child: Text("Clear"),
                                      onPressed: () => {},
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, childAspectRatio: 2.5),
                          delegate: SliverChildListDelegate(
                            [
                              for (var p in filter["species"].keys)
                                FilterChip(
                                  label: Text(p),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      side: BorderSide(color: Colors.grey)),
                                  selectedColor: Colors.lightGreenAccent,
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  selected: filter['species'][p],
                                  onSelected: (bool value) {
                                    setState(() {
                                      filter['species'][p] = value;
                                      updateFilter();
                                    });
                                  },
                                )
                            ],
                          ),
                        ),
                        // end species
                      ],
                    )));
          });
        },
        fullscreenDialog: true));
  }
}
