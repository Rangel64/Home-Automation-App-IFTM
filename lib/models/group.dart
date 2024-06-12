
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pi8/models/relay.dart';
import 'package:pi8/utils/utils.dart';

class Group {
  late String id = "";
  String name;
  bool controll_pot;
  bool controll_time;
  double  pot_max = 0;
  double pot_min = 0;
  late TimeOfDay time_off;
  late TimeOfDay time_on;
  List<int> relays = [];

  Group({required this.name, required this.controll_pot, required this.controll_time});

  factory Group.fromMap(Map<String, dynamic> json) {
    Group group = Group(
      name: json["name"],
      controll_pot: json["controll_pot"],
      controll_time: json["controll_time"],
    );

    if (json["id"] != null) group.id = json["id"];
    if (json["pot_max"] != null) group.pot_max = json["pot_max"];
    if (json["pot_min"] != null) group.pot_min = json["pot_min"];
    if (json["time_off"] != null) group.time_off = Utils.convertTime(json["time_off"])!;
    print(group.time_off);
    if (json["time_on"] != null) group.time_on = Utils.convertTime(json["time_on"])!;
    print(group.time_on);
    if (json["relays"] != null) group.relays = List<int>.from(json["relays"]);
    print(group.relays);

    return group;
  }

  List<String> relaysConvert(){
    List<String> relays = [];
    this.relays.forEach((element) {
      relays.add(element.toString());
    });
    return relays;
  }

  Map<String,dynamic> toMap() => <String,dynamic>{
    "id": id.toString(),
    "name": name.toString(),
    "controll_pot": controll_pot,
    "controll_time": controll_time,
    "pot_max": pot_max.toString(),
    "pot_min": pot_min.toString(),
    "time_off": "${time_off.hour}:${time_off.minute}",
    "time_on": "${time_on.hour}:${time_on.minute}",
    "relays": jsonEncode(relaysConvert())
  };
}