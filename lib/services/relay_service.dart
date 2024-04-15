import 'dart:convert';
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
}