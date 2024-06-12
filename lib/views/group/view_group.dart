import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pi8/models/group.dart';
import 'package:pi8/models/relay.dart';
import 'package:pi8/services/group_services.dart';
import 'package:pi8/services/relay_service.dart';
import 'package:pi8/views/group/updade_group.dart';
import 'package:pi8/widgets/relay_card_control.dart';
import 'package:unicons/unicons.dart';

class ViewGroup extends StatefulWidget{
  Group group;
  dynamic contextHome;
  Function load;
  ViewGroup({super.key,required this.group,required this.contextHome, required this.load});

  ViewGroupState createState ()=> ViewGroupState();
}

class ViewGroupState extends State<ViewGroup>{

  List<Relay> _relays = [];
  bool _relaysLoaded = false;

  RelayService relayService = RelayService();

  List<Relay> relays = [];

  GroupService groupService = GroupService();

  @override
  void initState() {
    super.initState();
    load(context);
  }

  Future<List<Relay>> getRelays({Duration timeoutDuration = const Duration(seconds: 10)}) async {
    if (!_relaysLoaded) {
      try {
        _relays = await relayService.getAllRelaysGroup(widget.group).timeout(timeoutDuration);
        _relaysLoaded = true;
        return _relays;
      } catch (e) {
        print('Error fetching groups: $e');
        throw e;
      }
    } else {
      return _relays;
    }
  }

  Widget relayCard(Relay relay) {
    return RelayCardControl(relay: relay);
  }

  late Widget component;

  Future<void> load(BuildContext context) async {
    component = FutureBuilder<List<Relay>>(
        future: getRelays(timeoutDuration: const Duration(seconds: 30)),
        builder: (BuildContext context, AsyncSnapshot<List<Relay>> snapshot) {
          try {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const CircularProgressIndicator(
                  color: Colors.white70,
                );
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Relay> updatedRelays = snapshot.data!;
                  if (updatedRelays.isNotEmpty) {
                    if (!_relaysLoaded) {
                      _relays = updatedRelays;
                      _relaysLoaded = true;
                    }
                    return CarouselSlider(
                      items:
                      updatedRelays.map((relay) => relayCard(relay)).toList(),
                      options: CarouselOptions(
                        height: 200,
                        enlargeCenterPage: true,
                        viewportFraction: 0.8,
                      ),
                    );
                  }
                  else {
                    return notFound();
                  }
                }
            }
          } catch (e) {
            return lostConnection();
          }
        });
  }

  Widget notFound() {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), color: Colors.black45),
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
        child: const Text(
          "Nenhum componente disponivel",
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
            )
            ,
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

  Future<void> deleteGroup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
            backgroundColor: Colors.lightBlueAccent,
            content: SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white70),
              ),
            )
        );
      },
    );

    try {
      String res = await groupService.deleteGroup(widget.group);
      Navigator.of(context).pop(); // Close the loading dialog
      if (res == "done") {
        Fluttertoast.showToast(
            msg: "Grupo excluido com sucesso.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.black,
            fontSize: 16.0);
        Navigator.pop(context, "closed");
      } else {
        Fluttertoast.showToast(
            msg: "Erro ao excluir o grupo.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading dialog
      Fluttertoast.showToast(
          msg: "Erro ao excluir o grupo.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  Future<bool?> _showDeleteConfirmation() async {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false, // Impede que o usuário feche clicando fora do diálogo
      builder: (BuildContext context) {
        return GestureDetector( // Captura o toque fora do diálogo
          onTap: () {
            Navigator.pop(context, false);
          },
          child: AlertDialog(
            backgroundColor: Colors.lightBlueAccent,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            title: const Text('Tem certeza?',style: TextStyle(color: Colors.black87),),
            actions: <Widget>[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.red,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(8),
                ),
                label: const Icon(Icons.close, size: 25, color: Colors.white,),
                onPressed: () {
                  Navigator.pop(context, false);
                },
                icon: const Text('Cancelar',style: TextStyle(color: Colors.white),),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.black54,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(8),
                ),
                label: const Icon(Icons.check, size: 25,color: Colors.white),
                onPressed: () async {
                  Navigator.pop(context, false);
                  deleteGroup();
                },
                icon: const Text('Confirmar exclusão',style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context){
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: Colors.black54),
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          margin: const EdgeInsets.fromLTRB(0, 80, 0, 20),
                          child: const Text('Componentes',
                              style: TextStyle(color: Colors.white, fontSize: 30)),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 180, 10, 0),
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: SizedBox(
                        width: 390,
                        height: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Control Pot: ${widget.group.controll_pot}",
                              style: const TextStyle(color: Colors.white, fontSize: 19),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Control Time: ${widget.group.controll_time}",
                              style: const TextStyle(color: Colors.white, fontSize: 19),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Pot Max: ${widget.group.pot_max}",
                              style: const TextStyle(color: Colors.white, fontSize: 19),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Pot Min: ${widget.group.pot_min}",
                              style: const TextStyle(color: Colors.white, fontSize: 19),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Time Off: ${widget.group.time_off.hour}:${widget.group.time_off.minute}",
                              style: const TextStyle(color: Colors.white, fontSize: 19),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Time On: ${widget.group.time_on.hour}:${widget.group.time_on.minute}",
                              style: const TextStyle(color: Colors.white, fontSize: 19),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Relays: ${widget.group.relays.join(", ")}",
                              style: const TextStyle(color: Colors.white, fontSize: 19),
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
                            margin: const EdgeInsets.fromLTRB(0, 350, 0, 0),
                            child: component,
                          )
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                        width: 60,
                                        height: 60,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.black54,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  UpdateGroup(group: widget.group)),
                                            ).then((value) {
                                              if (value == "closed") {
                                                setState(() {
                                                  widget.load(widget.contextHome);
                                                  Navigator.pop(context,"closed");
                                                });
                                              }
                                            });
                                          },
                                          child: const Icon(
                                            UniconsLine.pen,
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
                                        width: 60,
                                        height: 60,
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.black54,
                                          onPressed: () async {
                                            _showDeleteConfirmation();
                                          },
                                          child: const Icon(
                                            UniconsLine.trash,
                                            color: Colors.red,
                                            size: 26.6,
                                          ),
                                        ),
                                      )
                                  )
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
          )
      ),
    );
  }
}