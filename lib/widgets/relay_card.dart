
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pi8/models/relay.dart';

class RelayCard extends StatefulWidget {
  Relay relay;
  List<int> selectedRelayIds;
  RelayCard({super.key, required this.relay, required this.selectedRelayIds});

  @override
  State<RelayCard> createState() => _RelayCardState();
}

class _RelayCardState extends State<RelayCard> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.selectedRelayIds.contains(widget.relay.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black45,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CheckboxListTile(
            title: Text("Componente: ${widget.relay.id}",style: TextStyle(color: Colors.white),),
            value: isSelected,
            secondary: Image.asset('assets/icons/relay.png'),
            activeColor: Colors.white,
            checkColor: Colors.black,
            hoverColor: Colors.white,

            onChanged: (newValue) {
              setState(() {
                isSelected = newValue!;
                if (isSelected) {
                  widget.selectedRelayIds.add(widget.relay.id);
                } else {
                  widget.selectedRelayIds.remove(widget.relay.id);
                }
              });
            },
          ),
        ],
      )
    );
  }
}
