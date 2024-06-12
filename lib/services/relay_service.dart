import 'dart:convert';
import 'package:pi8/models/group.dart';
import 'package:pi8/models/relay.dart';
import 'package:http/http.dart' as http;
import 'package:pi8/server/server.dart';

class RelayService{

  Future<List<Relay>> getAllRelays() async {
    String finalUrl = '${Server.url}/get_relays';
    dynamic response = await http.get(Uri.parse(finalUrl));
    var data = json.decode(response.body);
    data = data['response'];
    List<Relay> list = (data.isNotEmpty ? (data as List).map((c) => Relay.fromMap(c)).toList():[]);
    return list;
  }

  Future<List<Relay>> getAllRelaysGroup(Group group) async {
    String finalUrl = '${Server.url}/get_relays_group';
    dynamic response = await http.post(Uri.parse(finalUrl),body: json.encode(group.toMap()));
    var data = json.decode(response.body);
    data = data['response'];
    List<Relay> list = (data.isNotEmpty ? (data as List).map((c) => Relay.fromMap(c)).toList():[]);
    return list;
  }

  Future<List<Relay>> getRelays() async {
    String finalUrl = '${Server.url}/get_relays_control';
    dynamic response = await http.get(Uri.parse(finalUrl));
    var data = json.decode(response.body);
    data = data['response'];
    List<Relay> list = (data.isNotEmpty ? (data as List).map((c) => Relay.fromMap(c)).toList():[]);
    return list;
  }

  Future<bool> setActivateRelay(Relay relay)async {
    String finalUrl = '${Server.url}/set_activate_relay';
    dynamic response = await http.post(Uri.parse(finalUrl),
        body: json.encode(relay.toMap()));
    var data = json.decode(response.body);
    print(data["response"]);
    return true;
  }
}