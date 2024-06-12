
import 'package:pi8/models/group.dart';
import 'package:pi8/server/server.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class GroupService{
  Future<String> setGroup(Group group) async {
    String finalUrl = '${Server.url}/set_group';
    dynamic response = await http.post(Uri.parse(finalUrl),
        body: json.encode(group.toMap()));
    var data = json.decode(response.body);
    var res = data["response"];
    print(res);
    return res;
  }

  Future<List<Group>> getAllGroups() async {
    String finalUrl = '${Server.url}/get_groups';
    dynamic response = await http.get(Uri.parse(finalUrl));
    var data = json.decode(response.body);
    data = data['response'];
    print(data);
    List<Group> list = (data.isNotEmpty ? (data as List).map((c) => Group.fromMap(c)).toList():[]);
    return list;
  }

  Future<String> deleteGroup(Group group) async {
    String finalUrl = '${Server.url}/delete_group';
    dynamic response = await http.post(Uri.parse(finalUrl),
        body: json.encode(group.toMap()));
    var data = json.decode(response.body);
    String res = data['response'];
    print(res);
    return res;
  }

  Future<String>updateGroup(Group group, List<int> selectedRelayIds) async {
    var res = "fail";
    var resDelete = await deleteGroup(group);
    if(resDelete=="done"){
      group.relays = selectedRelayIds;
      print(selectedRelayIds);
      var resAdd = await setGroup(group);
      if(resAdd=="done"){
        res = "done";
      }
    }
    return res;
  }
}