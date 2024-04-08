
import 'package:flutter/material.dart';

class ViewGroups extends StatefulWidget{
  const ViewGroups({super.key});

  @override
  ViewGroupsState createState() => ViewGroupsState();
}

class ViewGroupsState extends State<ViewGroups>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: Center(
            child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                constraints: const BoxConstraints.expand(),
                decoration:
                const BoxDecoration(color: Colors.indigo),
                child: const Center(
                  child: Text('Você está na próxima tela!',style:  TextStyle(color: Colors.white),)
                )
            )
        )
    );
  }
}