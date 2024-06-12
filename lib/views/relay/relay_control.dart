import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pi8/models/relay.dart';
import 'package:pi8/services/group_services.dart';
import 'package:pi8/services/relay_service.dart';
import 'package:pi8/widgets/relay_card_control.dart';

import 'package:unicons/unicons.dart';

class RelayControll extends StatefulWidget{
  const RelayControll({super.key});

  RelayControllState createState()=> RelayControllState();
}

class RelayControllState extends State<RelayControll>{

  RelayService relayService = RelayService();

  Future<List<Relay>> getRelays({Duration timeoutDuration = const Duration(seconds: 10)}) async {
    if (!_relaysLoaded) {
      try {
        _relays = await relayService.getRelays().timeout(timeoutDuration);
        print("antes cards");
        _relays.forEach((element) {
          print(element.isManual);
        });
        _relaysLoaded = true;
        return _relays;
      } catch (e) {
        // Tratar erro de timeout ou outras exceções
        print('Error fetching groups: $e');
        throw e;
      }
    } else {
      return _relays;
    }
  }

  GroupService groupService = GroupService();
  List<Relay> _relays = [];
  bool _relaysLoaded = false;

  @override
  void initState() {
    super.initState();
    load(context);
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
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                  ),
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
                    return StaggeredGridView.countBuilder(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        itemCount: _relays.length,
                        itemBuilder: (context,index){
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: relayCard(_relays[index])
                            ),
                          );
                        },
                        staggeredTileBuilder: (index) {
                          return StaggeredTile.count(1, index.isEven ? 1 : 1);
                        }
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

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.black45),
                    padding: const EdgeInsets.fromLTRB(30, 5, 30, 5),
                    margin: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                    child: const Text('Componentes',
                        style: TextStyle(color: Colors.white, fontSize: 30)),
                  ),
                  SizedBox( // Usando SizedBox para definir um tamanho fixo
                    width: double.infinity,
                    height: 625, // Altura fixa
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: component,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.fromLTRB(30, 30, 30, 0),
              padding:  const EdgeInsets.fromLTRB(30, 30, 30, 0),
              color: Colors.lightBlueAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}