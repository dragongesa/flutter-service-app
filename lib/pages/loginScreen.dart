import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:service/constraints.dart';
import 'package:service/pages/dashboardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus { signIn, notSignIn }

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String username, password;
  final _key = GlobalKey<FormState>();

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    final url = baseUrl + "login.php";
    final resp = await http.post(
      url,
      body: {"username": username, "password": password},
    );
    final data = jsonDecode(resp.body);
    int value = data["value"];
    String pesan = data["message"];
    String usernameAPI = data["username"];
    String namaAPI = data["nama"];
    String idAkses = data["id_akses"];
    String idKaryawanAPI = data["id_karyawan"];
    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, usernameAPI, namaAPI, idAkses, idKaryawanAPI);
      });
      print(pesan);
      print(_loginStatus);
      print("nama: $namaAPI");
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Login gagal!",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            content: Text("Username atau password salah, paling."),
            actions: [
              FlatButton(
                color: Colors.red,
                child: Text("Coba lagi"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  savePref(int value, String username, String namaAPI, String idAkses,
      String idKaryawanAPI) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt("value", value);
      prefs.setString("username", username);
      prefs.setString("nama", namaAPI);
      prefs.setString("idAkses", idAkses);
      prefs.setString("idKaryawanAPI", idKaryawanAPI);
    });
  }

  var value;

  getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      value = prefs.getInt("value");
      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt("value", null);
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  bool _secureText = true;
  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    // print(_key);
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Image.asset('assets/images/login-bg.png'),
                Positioned(
                  width: MediaQuery.of(context).size.width,
                  bottom: 10,
                  child: Center(child: Text("Revolution Computer © 2020")),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: MediaQuery.of(context).size.height / 3),
                          child: Form(
                            key: _key,
                            child: ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  // ignore: missing_return
                                  validator: (e) {
                                    if (e.isEmpty) {
                                      return "Username lu apa?";
                                    }
                                  },
                                  keyboardType: TextInputType.name,
                                  onSaved: (e) => username = e,
                                  decoration:
                                      InputDecoration(labelText: "Username"),
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  textInputAction: TextInputAction.go,
                                  onEditingComplete: () => check(),
                                  // ignore: missing_return
                                  validator: (e) {
                                    if (e.isEmpty) {
                                      return "Mana ada password kosong blok!";
                                    }
                                  },
                                  obscureText: _secureText,
                                  keyboardType: TextInputType.visiblePassword,
                                  onSaved: (e) => password = e,
                                  decoration: InputDecoration(
                                      labelText: "Password",
                                      suffixIcon: IconButton(
                                        onPressed: () => showHide(),
                                        icon: Icon(_secureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined),
                                      )),
                                ),
                                SizedBox(height: 20),
                                Material(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    enableFeedback: true,
                                    splashFactory: InkRipple.splashFactory,
                                    splashColor: Colors.amber,
                                    onTap: () => check(),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      child: Center(
                                        child: Text(
                                          "LOGIN",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return Dashboard(signOut);
        break;
    }
  }
}
