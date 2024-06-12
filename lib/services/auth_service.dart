import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pi8/home.dart';

import '../main.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle(BuildContext context) async {
    // Verifica se o usuário já está logado
    if (_auth.currentUser != null) {
      // Se estiver logado, redireciona para a outra tela
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewGroups()),
      );
      return _auth.currentUser;
    }

    // Se não estiver logado, realiza o login com o Google
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }
  getProfileImage(){
    if(_auth.currentUser!.photoURL!=null){

      return CircleAvatar(
        radius: 30.0,
        backgroundImage:
        NetworkImage(_auth.currentUser!.photoURL!),
        backgroundColor: Colors.transparent,
      );
    }
    else{
      return Icon(Icons.account_circle,size: 100,);
    }
  }
}