
class Relay{
  late int id;
  String id_group;
  bool isManual;

  Relay({required this.id_group,required this.isManual});

  factory Relay.fromMap(Map<String, dynamic> json) {
    Relay relay = Relay(
        isManual: json["isManual"],
        id_group: json["id_group"]);
    relay.id = json["id"];
    return relay;
  }

  Map<String,dynamic> toMap() => <String,dynamic>{
    "id_group": id_group,
    "isManual": isManual
  };
}