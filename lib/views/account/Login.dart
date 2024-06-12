import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../services/auth_service.dart';
import '../../home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  late String email;
  late String senha;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(color: Colors.lightBlueAccent),
            child: Center(
              child: Stack(
                children: [
                  Container(
                      margin: const EdgeInsets.fromLTRB(0,300, 0,0 ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                                child: SvgPicture.asset(
                                  'assets/logo/raio_logo.svg',
                                  width: 120,
                                  height: 120,
                                  color: Colors.black54,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 150),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                // margin: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                                child: const Row(
                                    children:[
                                      Expanded(
                                          child: Divider(color: Colors.white,)
                                      ),

                                      Text("  Login  ",style: TextStyle(color: Colors.white, fontSize: 18)),

                                      Expanded(
                                          child: Divider(color: Colors.white,)
                                      ),
                                    ]
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: FloatingActionButton(
                                        onPressed: () async {
                                          var res = await AuthService().signInWithGoogle(context);
                                          if (res != null) {
                                            // Se estiver logado, redireciona para a outra tela
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => ViewGroups()),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                              border:
                                              Border.all(color: Colors.white),
                                              borderRadius:
                                              BorderRadius.circular(16),
                                              color: Colors.white),
                                          child: SvgPicture.asset(
                                            'assets/icons/google-icon.svg',
                                            width: 40,
                                            height: 40,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
}
