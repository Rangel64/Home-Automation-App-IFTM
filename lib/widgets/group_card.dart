
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pi8/models/group.dart';
import 'package:pi8/models/relay.dart';
import 'package:pi8/views/group/view_group.dart';

class GroupCard extends StatefulWidget {
  Group group;
  double textScaleFactor;
  dynamic contextHome;
  Function load;

  GroupCard({super.key, required this.group, required this.textScaleFactor, required this.contextHome, required this.load});

  @override
  State<GroupCard> createState() => _RelayCardState();
}

class _RelayCardState extends State<GroupCard> {

  @override
  void initState() {
    super.initState();
    print(widget.group.controll_time);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      color: Colors.black45,
      child: InkWell(
        splashColor: Colors.white.withAlpha(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                ViewGroup(group: widget.group,contextHome: widget.contextHome,load: widget.load)),
          ).then((value) {
            if (value == "closed") {
              setState(() {
                widget.load(widget.contextHome);
              });
            }
          });
        },
        child: SizedBox(
          width: 400,
          height: 300,
          child: Container(
            margin: EdgeInsets.fromLTRB(15* widget.textScaleFactor, 0, 15* widget.textScaleFactor, 0* widget.textScaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Name: ${widget.group.name}",
                  style: TextStyle(color: Colors.white, fontSize: 19 * widget.textScaleFactor),
                ),
                SizedBox(height: 4* widget.textScaleFactor,),
                Text(
                  "Control Pot: ${widget.group.controll_pot}",
                  style: TextStyle(color: Colors.white, fontSize: 19 * widget.textScaleFactor),
                ),
                SizedBox(height: 4* widget.textScaleFactor,),
                Text(
                  "Control Time: ${widget.group.controll_time}",
                  style: TextStyle(color: Colors.white, fontSize: 19 * widget.textScaleFactor),
                ),
                SizedBox(height: 4* widget.textScaleFactor,),
                Text(
                  "Relays: ${widget.group.relays.join(", ")}",
                  style: TextStyle(color: Colors.white, fontSize: 19 * widget.textScaleFactor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
