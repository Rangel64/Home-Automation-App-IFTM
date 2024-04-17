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

class AddGroup extends StatefulWidget {
  const AddGroup({Key? key}) : super(key: key);

  @override
  AddGroupState createState() => AddGroupState();
}

class AddGroupState extends State<AddGroup> {
  String name = "";
  double pot_min = 0;
  double pot_max = 0;
  String time_on_ = "";
  String time_off_ = "";

  bool _isCheckedPot = false;
  bool _isCheckedTime = false;

  RelayService relayService = RelayService();

  List<Relay> relays = [];
  List<int> selectedRelayIds = [];

  TimeOfDay? time_on;
  TimeOfDay? time_off;

  final GlobalKey<FormState> _newGroupForm = GlobalKey<FormState>();

  TextEditingController controller_pot_min = TextEditingController(text: '0');
  TextEditingController controller_pot_max = TextEditingController(text: '0');

  TextEditingController controller_time_off =
      TextEditingController(text: '12:00');
  TextEditingController controller_time_on =
      TextEditingController(text: '00:00');

  var maskFormatter = MaskTextInputFormatter(
      mask: '##:##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  Future<List<Relay>> getRelays({Duration timeoutDuration = const Duration(seconds: 10)}) async {
    if (!_relaysLoaded) {
      try {
        _relays = await relayService.getAllRelays().timeout(timeoutDuration);
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
    return RelayCard(relay: relay, selectedRelayIds: selectedRelayIds);
  }

  Future<void> save() async {
    time_on = Utils.convertTime(time_on_);
    time_off = Utils.convertTime(time_off_);
    Group group = Group(
        name: name, controll_pot: _isCheckedPot, controll_time: _isCheckedTime);
    group.pot_max = pot_max;
    group.pot_min = pot_min;
    group.time_on = time_on!;
    group.time_off = time_off!;
    group.relays = selectedRelayIds;
    print(group.relays.length);
    bool res = await groupService.setGroup(group);
    if (res) {
      Navigator.pop(context, "closed");
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
                      items:
                      updatedRelays.map((relay) => relayCard(relay)).toList(),
                      options: CarouselOptions(
                        height: 150,
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
                  child: const Text('Adicionar Grupo',
                      style: TextStyle(color: Colors.white, fontSize: 30)),
                ),
                Form(
                  key: _newGroupForm,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 70,
                        child: TextFormField(
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CheckboxListTile(
                        title: const Text('Controle por potencia',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        value: _isCheckedPot,
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        hoverColor: Colors.white,
                        tileColor: Colors.black45,
                        onChanged: (newValue) {
                          setState(() {
                            _isCheckedPot = newValue!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: _isCheckedPot,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 70,
                                child: TextFormField(
                                    controller: controller_pot_min,
                                    onChanged: (text) {
                                      pot_min = double.parse(text);
                                    },
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: 'Valor minimo de potencia',
                                      labelStyle: TextStyle(color: Colors.grey),
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo Obrigatório";
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 70,
                                child: TextFormField(
                                    controller: controller_pot_max,
                                    onChanged: (text) {
                                      pot_max = double.parse(text);
                                    },
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: 'Valor maximo de potencia',
                                      labelStyle: TextStyle(color: Colors.grey),
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo Obrigatório";
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text('Controle por horario',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        value: _isCheckedTime,
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        tileColor: Colors.black45,
                        hoverColor: Colors.white,
                        onChanged: (newValue) {
                          setState(() {
                            _isCheckedTime = newValue!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: _isCheckedTime,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 70,
                                child: TextFormField(
                                    controller: controller_time_on,
                                    inputFormatters: [maskFormatter],
                                    keyboardType: TextInputType.number,
                                    onChanged: (text) {
                                      time_on_ = text;
                                    },
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText: 'Horario de ativação (HH:MM)',
                                      labelStyle: TextStyle(color: Colors.grey),
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo Obrigatório";
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 70,
                                child: TextFormField(
                                    controller: controller_time_off,
                                    inputFormatters: [maskFormatter],
                                    keyboardType: TextInputType.number,
                                    onChanged: (text) {
                                      time_off_ = text;
                                    },
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelText:
                                          'Horario de desligamento (HH:MM)',
                                      labelStyle: TextStyle(color: Colors.grey),
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo Obrigatório";
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      component,
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: FloatingActionButton(
                              backgroundColor: Colors.black54,
                              onPressed: () {
                                if (selectedRelayIds.isNotEmpty) {
                                  if (_newGroupForm.currentState!.validate()) {
                                    if (!_isCheckedPot) {
                                      pot_min = 0;
                                      pot_max = 0;
                                    }
                                    if (!_isCheckedTime) {
                                      time_off_ = "00:00";
                                      time_on_ = "00:00";
                                    }
                                    save();
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Adicione pelo menos 1 componente",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: Colors.black,
                                      fontSize: 16.0);
                                }
                              },
                              child: const Text(
                                'Salvar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          )
                        ],
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
