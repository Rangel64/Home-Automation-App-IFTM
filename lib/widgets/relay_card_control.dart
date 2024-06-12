import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pi8/models/relay.dart';
import 'package:pi8/services/relay_service.dart';

class RelayCardControl extends StatefulWidget {
  Relay relay;

  RelayCardControl({super.key, required this.relay});

  @override
  State<RelayCardControl> createState() => RelayCardControlState();
}

class RelayCardControlState extends State<RelayCardControl> {
  Color _cardColor = Colors.white;

  void _changeColor() {
    setState(() {
      _cardColor = _cardColor == Colors.white ? Colors.red : Colors.white;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.relay.state) {
      setState(() {
        _cardColor = Colors.red;
      });
    } else {
      setState(() {
        _cardColor = Colors.white;
      });
    }
    print(widget.relay.state);

  }

  RelayService relayService = RelayService();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.black45,
      child: InkWell(
        splashColor: Colors.white.withAlpha(30),
        onTap: () async {
          widget.relay.isManual = !widget.relay.isManual;
          widget.relay.state = !widget.relay.state;
          bool res = await relayService.setActivateRelay(widget.relay);
          if(res){
            _changeColor();
          }
        },
        child: SizedBox(
          width: 400,
          height: 300,
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: const EdgeInsets.fromLTRB(0, 35, 0, 10),
                    child: SvgPicture.asset(
                      'assets/logo/raio_logo.svg',
                      width: 70,
                      height: 70,
                      color: _cardColor,
                    )),
                Text(
                  "${widget.relay.id}",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
