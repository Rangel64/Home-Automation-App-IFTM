
class Relay{
  late int id;
  String id_group;
  bool isManual;
  bool state;

  Relay({required this.id_group,required this.isManual,required this.state});

  factory Relay.fromMap(Map<String, dynamic> json) {
    Relay relay = Relay(
        isManual: json["isManual"],
        state: json["state"],
        id_group: json["id_group"]);
    relay.id = json["id"];
    return relay;
  }

  Map<String,dynamic> toMap() => <String,dynamic>{
    "id":id,
    "id_group": id_group,
    "isManual": isManual,
    "state": state
  };
}