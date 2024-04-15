
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


import '../../services/auth_service.dart';
import '../group/view_group.dart';


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
        body: Center(
            child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                constraints: const BoxConstraints.expand(),
                decoration:
                    const BoxDecoration(color: Colors.indigo),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(0,0,0,30),
                            child: SvgPicture.asset(
                              'assets/logo/raio_logo.svg',
                              width: 120,
                              height: 120,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              child: TextField(
                                onChanged: (text) {
                                  email = text;
                                },
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            SizedBox(
                              height: 50,
                              child: TextField(
                                onChanged: (text) {
                                  senha = text;
                                },
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Senha',
                                  labelStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),

                           Row(
                             mainAxisAlignment: MainAxisAlignment.start,
                             children: [
                               Container(
                                 margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                 child: SizedBox(
                                   height: 40,
                                   child: TextButton(
                                       onPressed: () {  },
                                       child: const Text('Esqueceu a senha?',style: TextStyle(color: Colors.white),),
                                 )
                                 ),
                               )
                             ],
                           ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: SizedBox(
                                      width: 250,
                                      height: 60,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            // insertFazenda();
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              Colors.lightBlueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  side: const BorderSide(
                                                      color: Colors.blue,
                                                      width: 2
                                                  ))),
                                          child: const Text(
                                            'Entrar',
                                            style: TextStyle(color: Colors.black,fontSize: 18),
                                          )
                                      )
                                  ),
                                )
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: const Row(
                                  children:[
                                    Expanded(
                                        child: Divider(color: Colors.white,)
                                    ),

                                    Text("  ou continue com  ",style: TextStyle(color: Colors.white)),

                                    Expanded(
                                        child: Divider(color: Colors.white,)
                                    ),
                                  ]
                              ),
                            ),
                            Container(
                              margin:  const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
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
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/icons/google-icon.svg',
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 40),

                                  GestureDetector(
                                    onTap: (){

                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white),
                                          borderRadius: BorderRadius.circular(16),
                                          color: Colors.white
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/icons/apple-icon.svg',
                                        width: 40,
                                        height: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: SizedBox(
                                      height: 40,
                                      child: Row(
                                        children: [
                                          const Text('Não é um membro? ',style: TextStyle(color: Colors.white,fontSize: 18)),
                                          TextButton(
                                            onPressed: () {  },
                                            child: const Text('Registre - se',style: TextStyle(color: Colors.lightBlueAccent,fontSize: 18)),
                                          )
                                        ],
                                      )
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
            )
        )
    );

  }
}
