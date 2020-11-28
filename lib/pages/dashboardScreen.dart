import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:service/constraints.dart';
import 'package:service/models/getAllServiceModel.dart';
import 'package:service/providers/dashboardProviders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  final VoidCallback signOut;
  const Dashboard(this.signOut);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  String nama = "";
  String idKaryawanAPI = "";
  TabController tabController;
  Future getServiceSayaSelesai() async {
    String url = baseUrl + "get.php";
    final resp = await http.get(url);
    List<GetAllServiceModel> data = getAllServiceModelFromJson(resp.body);
    List<GetAllServiceModel> datanya = [];
    setState(() {
      for (var i in data) {
        if (i.status == "3" && i.idKaryawan == idKaryawanAPI) {
          datanya.add(i);
          jumlahService = datanya.length;
        }
      }
    });

    return datanya;
  }

  @override
  void initState() {
    super.initState();
    getPrefs();
    tabController = TabController(vsync: this, length: 2);
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nama = prefs.getString("nama");
      idKaryawanAPI = prefs.getString("idKaryawanAPI");
    });
  }

  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ChangeNotifierProvider<JumlahService>(
        create: (context) => JumlahService(),
        child: SafeArea(
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Revice",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Icon(Icons.logout),
                      ),
                      onTap: () => showDialog(
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
                                  "Konfirmasi",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.white,
                            content: Text("Beneran nih luh mau keluar?"),
                            actions: [
                              FlatButton(
                                color: Colors.red,
                                child: Text("Yoi"),
                                onPressed: () {
                                  signOut();
                                  Navigator.of(context).pop();
                                },
                              ),
                              FlatButton(
                                color: Colors.green,
                                child: Text("Kepencet doang"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: "Selamat datang kembali, \n",
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: nama,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ]),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue),
                      child: Column(
                        children: [
                          FutureBuilder(
                            future: getServiceSayaSelesai(),
                            builder: (context, value) {
                              print("jumlah" + jumlahService.toString());
                              return Text(
                                jumlahService.toString(),
                                style: textWhite.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Selesai",
                            style: textWhite,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: TabBar(
                  unselectedLabelColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  indicator: BubbleTabIndicator(
                    indicatorHeight: 25.0,
                    insets: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    indicatorColor: Colors.blueAccent,
                    tabBarIndicatorSize: TabBarIndicatorSize.label,
                  ),
                  controller: tabController,
                  tabs: [
                    Tab(
                      text: "Daftar Service",
                    ),
                    Tab(
                      text: "Service Saya",
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    80,
                child: TabBarView(
                  controller: tabController,
                  children: [DaftarService(), ServiceSaya()],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DaftarService extends StatefulWidget {
  @override
  _DaftarServiceState createState() => _DaftarServiceState();
}

class _DaftarServiceState extends State<DaftarService> {
  Future getAllServices() async {
    String url = baseUrl + "get.php";
    final resp = await http.get(url);
    List<GetAllServiceModel> data = getAllServiceModelFromJson(resp.body);
    List<GetAllServiceModel> datanya = [];
    setState(() {
      for (var i in data) {
        if (i.status == "2" || i.status == "1") {
          datanya.add(i);
        }
      }
    });
    return datanya.reversed.toList();
  }

  String idKaryawanAPI = "";
  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idKaryawanAPI = prefs.getString("idKaryawanAPI");
      // print(idKaryawanAPI);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
            future: getAllServices(),
            builder: (context, AsyncSnapshot snapshot) {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data == null ? 0 : snapshot.data.length,
                itemBuilder: (context, index) {
                  bool isEnabledButton = true;
                  snapshot.data[index].status == "2"
                      ? isEnabledButton = false
                      : isEnabledButton = true;
                  return ListTile(
                    title: Text(
                      snapshot.data[index].kendala,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(snapshot.data[index].jenis +
                        " - " +
                        snapshot.data[index].namaPelanggan),
                    trailing: FlatButton(
                      disabledColor: Colors.white,
                      disabledTextColor: Colors.black,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        isEnabledButton ? "Kerjakan" : "Diproses",
                        style: isEnabledButton
                            ? textWhite
                            : TextStyle(color: Colors.black.withOpacity(.5)),
                      ),
                      onPressed: isEnabledButton
                          ? () {
                              print(isEnabledButton);
                              http.post(baseUrl + "proses.php", body: {
                                "id": snapshot.data[index].id,
                                "idKaryawanAPI": idKaryawanAPI
                              }).then((value) {
                                print(value.body);
                              });
                            }
                          : null,
                    ),
                    enabled: true,
                    focusColor: Colors.grey,
                    hoverColor: Colors.grey,
                    leading: snapshot.data[index].tipe == "laptop"
                        ? Icon(Icons.laptop_mac_rounded)
                        : Icon(snapshot.data[index].tipe == "printer"
                            ? Icons.print_rounded
                            : Icons.compare),
                  );
                },
              );
            }));
  }
}

class ServiceSaya extends StatefulWidget {
  @override
  _ServiceSayaState createState() => _ServiceSayaState();
}

class _ServiceSayaState extends State<ServiceSaya> {
  String idKaryawanAPI = "";
  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idKaryawanAPI = prefs.getString("idKaryawanAPI");
      print(idKaryawanAPI);
    });
  }

  Future getServiceSayaProses() async {
    String url = baseUrl + "get.php";
    final resp = await http.get(url);
    List<GetAllServiceModel> data = getAllServiceModelFromJson(resp.body);
    List<GetAllServiceModel> datanya = [];
    for (var i in data) {
      if (i.status == "2" && i.idKaryawan == idKaryawanAPI) {
        datanya.add(i);
      }
    }
    return datanya;
  }

  Future getServiceSayaSelesai() async {
    String url = baseUrl + "get.php";
    final resp = await http.get(url);
    List<GetAllServiceModel> data = getAllServiceModelFromJson(resp.body);
    List<GetAllServiceModel> datanya = [];
    setState(() {
      for (var i in data) {
        if (i.status == "3" && i.idKaryawan == idKaryawanAPI) {
          datanya.add(i);
          jumlahService = datanya.length;
        }
      }
    });

    return datanya;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
      child: Column(
        children: [
          StickyHeader(
            header: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.green,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Dikerjakan"),
                  ],
                )),
            content: FutureBuilder(
                future: getServiceSayaProses(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.hasData ? snapshot.data.length : 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          snapshot.data[index].kendala,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(snapshot.data[index].jenis +
                            " - " +
                            snapshot.data[index].namaPelanggan),
                        trailing: FlatButton(
                          splashColor: Colors.blue.withOpacity(.1),
                          highlightColor: Colors.blue.withOpacity(.2),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Selesai",
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {
                            http.post(baseUrl + "selesai.php", body: {
                              "id": snapshot.data[index].id
                            }).then((value) {
                              print(value.body);
                            });
                          },
                        ),
                        enabled: true,
                        focusColor: Colors.grey,
                        hoverColor: Colors.grey,
                        leading: Icon(Icons.print),
                      );
                    },
                  );
                }),
          ),
          StickyHeader(
            header: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Selesai"),
                  ],
                )),
            content: FutureBuilder(
                future: getServiceSayaSelesai(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.hasData ? snapshot.data.length : 1,
                    itemBuilder: (context, index) {
                      return snapshot.hasData
                          ? ListTile(
                              title: Text(
                                snapshot.data[index].kendala,
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(snapshot.data[index].jenis +
                                  " - " +
                                  snapshot.data[index].namaPelanggan),
                              trailing: RichText(
                                textAlign: TextAlign.right,
                                text: TextSpan(
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .copyWith(fontSize: 12),
                                    children: [
                                      TextSpan(
                                          text: hari[snapshot.data[index]
                                                      .finishedAt.weekday -
                                                  1] +
                                              "\n"),
                                      TextSpan(
                                          style: TextStyle(fontSize: 9),
                                          text: snapshot
                                                  .data[index].finishedAt.day
                                                  .toString() +
                                              " " +
                                              bulan[snapshot.data[index]
                                                      .finishedAt.month -
                                                  1]),
                                      TextSpan(
                                          style: TextStyle(fontSize: 9),
                                          text: " | " +
                                              (snapshot.data[index].finishedAt
                                                          .hour +
                                                      7)
                                                  .toString() +
                                              ":" +
                                              snapshot
                                                  .data[index].finishedAt.minute
                                                  .toString() +
                                              " WIB")
                                    ]),
                              ),

                              // Text(
                              //     hari[snapshot.data[index].finishedAt.weekday -
                              //             1] +
                              //         ", " +
                              //         bulan[snapshot
                              //                 .data[index].finishedAt.month -
                              //             1],
                              //     style: TextStyle(
                              //         color: Colors.black.withOpacity(.5))),
                              enabled: true,
                              focusColor: Colors.grey,
                              hoverColor: Colors.grey,
                              leading: Icon(Icons.print),
                            )
                          : Container(
                              width: double.infinity,
                              child: Center(
                                  child: Text("Belum ada pekerjaan selesai")));
                    },
                  );
                }),
          )
        ],
      ),
    ));
  }
}
