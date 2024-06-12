import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pi8/models/group.dart';
import 'package:pi8/models/relay.dart';
import 'package:pi8/services/group_services.dart';
import 'package:pi8/services/relay_service.dart';
import 'package:pi8/utils/utils.dart';
import 'package:pi8/widgets/relay_card.dart';
import 'package:unicons/unicons.dart';

class UpdateGroup extends StatefulWidget {
  Group group;
  UpdateGroup({super.key, required this.group});

  @override
  UpdateGroupState createState() => UpdateGroupState();
}

class UpdateGroupState extends State<UpdateGroup> {
  late String name;
  late double pot_min;
  late double pot_max;
  late String time_on_;
  late String time_off_;

  late bool _isCheckedPot;
  late bool _isCheckedTime;

  RelayService relayService = RelayService();

  List<Relay> relays = [];
  List<int> selectedRelayIds = [];

  TimeOfDay? time_on;
  TimeOfDay? time_off;

  final GlobalKey<FormState> _updateGroupForm = GlobalKey<FormState>();

  late TextEditingController controller_pot_min;
  late TextEditingController controller_pot_max;
  late TextEditingController controller_time_off;
  late TextEditingController controller_time_on;

  var maskFormatter = MaskTextInputFormatter(
      mask: '##:##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  Future<List<Relay>> getRelays({Duration timeoutDuration = const Duration(seconds: 10)}) async {
    if (!_relaysLoaded) {
      try {
        _relays = await relayService.getRelays().timeout(timeoutDuration);
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
    name = widget.group.name;
    pot_min = widget.group.pot_min;
    pot_max = widget.group.pot_max;
    time_on = widget.group.time_on;
    time_off = widget.group.time_off;
    _isCheckedPot = widget.group.controll_pot;
    _isCheckedTime = widget.group.controll_time;

    widget.group.relays.forEach((element) {
      selectedRelayIds.add(element);
    });

    // selectedRelayIds = widget.group.relays;

    controller_pot_min = _isCheckedPot?TextEditingController(text: pot_min.toString()):TextEditingController(text: '0');
    controller_pot_max = _isCheckedPot?TextEditingController(text: pot_max.toString()):TextEditingController(text: '0');
    controller_time_off = _isCheckedTime?TextEditingController(text: "${time_off?.hour}:${time_off?.minute}"):TextEditingController(text: '12:00');
    controller_time_on = _isCheckedTime?TextEditingController(text: "${time_on?.hour}:${time_on?.minute}"):TextEditingController(text: '00:00');

    load(context);
  }

  Widget relayCard(Relay relay) {
    return RelayCard(relay: relay, selectedRelayIds: selectedRelayIds);
  }

  Future<void> update() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.lightBlueAccent,
          content: SizedBox(
            height: 60,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white70,),
            ),
          ),
        );
      },
    );

    try {
      time_on = Utils.convertTime(controller_time_on.text);
      time_off = Utils.convertTime(controller_time_off.text);
      Group group = Group(
          name: name,
          controll_pot: _isCheckedPot,
          controll_time: _isCheckedTime);
      group.id = widget.group.id;
      group.pot_max = pot_max;
      group.pot_min = pot_min;
      group.time_on = time_on!;
      group.time_off = time_off!;
      group.relays = widget.group.relays;
      print(group.relays);
      // print(selectedRelayIds);
      String res = await groupService.updateGroup(group,selectedRelayIds);
      Navigator.of(context).pop(); // Close the loading dialog
      if (res == "done") {
        Fluttertoast.showToast(
            msg: "Grupo atualizado com sucesso.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.black,
            fontSize: 16.0);
        Navigator.pop(context, "closed");
      } else {
        Fluttertoast.showToast(
            msg: "Erro ao atualizar o grupo.",
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
          msg: "Erro ao atualizar o grupo.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 16.0);
    }
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
                      items: updatedRelays.map((relay) => relayCard(relay)).toList(),
                      options: CarouselOptions(
                        height: 150,
                        enlargeCenterPage: true,
                        viewportFraction: 0.8,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.black45),
                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                  child: const Text('Atualizar Grupo',
                      style: TextStyle(color: Colors.white, fontSize: 30)),
                ),
                Form(
                  key: _updateGroupForm,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 70,
                        child: TextFormField(
                            initialValue: name,
                            onChanged: (text) {
                              name = text;
                            },
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Nome do grupo',
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Campo Obrigatório";
                              }
                              return null;
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CheckboxListTile(

                        title: const Text('Controle por potencia',
                            style: TextStyle(color: Colors.white, fontSize: 18)),
                        value: _isCheckedPot,
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        hoverColor: Colors.white,
                        tileColor: Colors.black45,
                        secondary: const Icon(
                          UniconsLine.bolt,
                          color: Colors.white,
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            _isCheckedPot = newValue!;
                          });
                        },
                      ),
                      Visibility(
                        visible: _isCheckedPot,
                        child: Column(
                          children: [
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            TextFormField(
                                controller: controller_pot_min,
                                onChanged: (text) {
                                  pot_min = double.tryParse(text) ?? 0.0;
                                },
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Potência mínima (W)',
                                  labelStyle: TextStyle(color: Colors.grey),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return "Campo Obrigatório";
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                                controller: controller_pot_max,
                                onChanged: (text) {
                                  pot_max = double.tryParse(text) ?? 0.0;
                                },
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Potência máxima (W)',
                                  labelStyle: TextStyle(color: Colors.grey),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return "Campo Obrigatório";
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction)
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CheckboxListTile(
                        title: const Text('Controle por Horário',
                            style: TextStyle(color: Colors.white, fontSize: 18)),
                        value: _isCheckedTime,
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        hoverColor: Colors.white,
                        tileColor: Colors.black45,
                        secondary: const Icon(
                          UniconsLine.clock,
                          color: Colors.white,
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            _isCheckedTime = newValue!;
                          });
                        },
                      ),
                      Visibility(
                        visible: _isCheckedTime,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                                controller: controller_time_on,
                                inputFormatters: [maskFormatter],
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Horário de Ligamento (HH:MM)',
                                  labelStyle: TextStyle(color: Colors.grey),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return "Campo Obrigatório";
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                                controller: controller_time_off,
                                inputFormatters: [maskFormatter],
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Horário de Desligamento (HH:MM)',
                                  labelStyle: TextStyle(color: Colors.grey),
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return "Campo Obrigatório";
                                  }
                                  return null;
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction)
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                          child: const Text("Selecione os relés do grupo",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500))),
                      FutureBuilder<List<Relay>>(
                          future: getRelays(timeoutDuration: const Duration(seconds: 30)),
                          builder: (BuildContext context, AsyncSnapshot<List<Relay>> snapshot) {
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
                                  if (snapshot.data!.isNotEmpty) {
                                    return CarouselSlider(
                                      items: snapshot.data!.map((relay) => relayCard(relay)).toList(),
                                      options: CarouselOptions(
                                        height: 150,
                                        enlargeCenterPage: true,
                                        viewportFraction: 0.8,
                                      ),
                                    );
                                  } else {
                                    return notFound();
                                  }
                                }
                            }
                          }),
                      const SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_updateGroupForm.currentState!.validate()) {
                            _updateGroupForm.currentState!.save();
                            await update();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black45,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10)),
                        child: const Text(
                          'Atualizar Grupo',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
