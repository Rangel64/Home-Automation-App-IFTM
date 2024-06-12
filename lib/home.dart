import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pi8/models/group.dart';
import 'package:pi8/server/server.dart';
import 'package:pi8/services/auth_service.dart';
import 'package:pi8/services/group_services.dart';
import 'package:pi8/views/group/add_group.dart';
import 'package:pi8/views/relay/relay_control.dart';
import 'package:pi8/widgets/group_card.dart';
import 'package:unicons/unicons.dart';

class ViewGroups extends StatefulWidget {
  const ViewGroups({Key? key}) : super(key: key);

  @override
  ViewGroupsState createState() => ViewGroupsState();
}

class ViewGroupsState extends State<ViewGroups> with RouteAware {
  dynamic voltage = 0;
  dynamic current = 0;
  dynamic power = 0;
  dynamic energy = 0;
  dynamic frequency = 0;
  dynamic pf = 0;
  late Timer timer;

  GroupService groupService = GroupService();

  List<Group> _groups = [];
  bool groupsLoaded = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(milliseconds: 500), (Timer t) => fetchData());
    load(context);
    user = AuthService().getProfileImage();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  void fetchData() async {
    dynamic response = await http.get(Uri.parse("${Server.url}/get_metrics"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      data = data["response"];
      setState(() {
        voltage = data['voltage'];
        current = data['current'];
        power = data['power'];
        energy = data['energy'];
        frequency = data['frequency'];
        pf = data['pf'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Group>> getGroups(
      {Duration timeoutDuration = const Duration(seconds: 10)}) async {
    try {
      _groups = await groupService.getAllGroups().timeout(timeoutDuration);
      groupsLoaded = true;
      return _groups;
    } catch (e) {
      // Tratar erro de timeout ou outras exceções
      print('Error fetching groups: $e');
      throw e;
    }
  }

  Widget groupCard(Group group, double textScaleFactor) {
    return GroupCard(
      group: group,
      textScaleFactor: textScaleFactor,
      contextHome: context,
      load: load,
    );
  }

  late Widget component;

  Future<void> load(BuildContext context) async {
    component = FutureBuilder<List<Group>>(
      future: getGroups(timeoutDuration: const Duration(seconds: 10)),
      builder: (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
        try {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const CircularProgressIndicator(
                color: Colors.white70,
              );
            default:
              if (snapshot.hasError) {
                return lostConnection();
              } else {
                List<Group> updatedGroups = snapshot.data!;
                if (updatedGroups.isNotEmpty) {
                  _groups = updatedGroups;
                  groupsLoaded = true;
                  return CarouselSlider(
                    carouselController: CarouselController(),
                    items: updatedGroups
                        .map((group) => groupCard(group, _textScaleFactor))
                        .toList(),
                    options: CarouselOptions(
                      height: 320,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      onPageChanged: (index, _) =>
                          _updateTextScaleFactor(index),
                    ),
                  );
                } else {
                  return notFound();
                }
              }
          }
        } catch (e) {
          return lostConnection();
        }
      },
    );
  }

  double _textScaleFactor = 1.0;

  void _updateTextScaleFactor(int index) {
    setState(() {
      _textScaleFactor = index == 0 ? 1.0 : 0.8;
    });
  }

  Widget notFound() {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), color: Colors.black45),
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
        child: const Text(
          "Nenhum grupo adicionado",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ));
  }

  Widget lostConnection() {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), color: Colors.black45),
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        margin: const EdgeInsets.fromLTRB(80, 0, 80, 50),
        child: Column(
          children: [
            const Text(
              "Erro ao Carregar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Container(
                margin: const EdgeInsets.fromLTRB(0, 50, 0, 5),
                child: Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: FloatingActionButton(
                        backgroundColor: Colors.black54,
                        onPressed: () {
                          setState(() {
                            load(context);
                          });
                        },
                        child: const Icon(
                          UniconsLine.refresh,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    )))
          ],
        ));
  }

  late Widget? user;

  @override
  void didPopNext() {
    super.didPopNext();
    load(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(color: Colors.lightBlueAccent),
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Stack(
                  children: [
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 70, 15, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              child: user,
                            )
                          ],
                        )),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 140, 10, 0),
                      padding: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: SizedBox(
                        width: 390,
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Voltage: $voltage V',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'Current: $current A',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'Power: $power W',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'Energy: $energy kWh',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'Frequency: $frequency Hz',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                            Text(
                              'PF: $pf',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0, 250, 0, 0),
                            child: component,
                          )
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  margin:
                                  const EdgeInsets.fromLTRB(0, 0, 0, 30),
                                  child: Center(
                                      child: SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.black54,
                                          onPressed: () {
                                            setState(() {
                                              load(context);
                                            });
                                          },
                                          child: const Icon(
                                            UniconsLine.refresh,
                                            color: Colors.white,
                                            size: 26.6,
                                          ),
                                        ),
                                      ))),
                              const Spacer(),
                              Container(
                                  margin:
                                  const EdgeInsets.fromLTRB(0, 0, 0, 30),
                                  child: Center(
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.black54,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const AddGroup()),
                                            ).then((value) {
                                              if (value == "closed") {
                                                setState(() {
                                                  load(context);
                                                });
                                              }
                                            });
                                          },
                                          child: const Icon(
                                            UniconsLine.plus_circle,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ))),
                              const Spacer(),
                              Container(
                                  margin:
                                  const EdgeInsets.fromLTRB(0, 0, 0, 30),
                                  child: Center(
                                      child: SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.black54,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const RelayControll()),
                                            ).then((value) {
                                              if (value == "closed") {
                                                setState(() {
                                                  load(context);
                                                });
                                              }
                                            });
                                          },
                                          child: const Icon(
                                            UniconsLine.setting,
                                            color: Colors.white,
                                            size: 26.6,
                                          ),
                                        ),
                                      )))
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ))),
    );
  }
}
