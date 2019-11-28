import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iot_app/connection_model.dart';
import 'package:udp/udp.dart';

class HomeScreen extends StatefulWidget {

  final ConnectionModel connectionModel;


  HomeScreen({this.connectionModel});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {


  _HomeScreenState();

  ConnectionModel _connectionModel;
  Timer timer;

  String _adress;
  int _port;
  bool isBusy = false;


  List<Data> datas = <Data>[
    Data("L", Icon(Icons.lightbulb_outline, color: Colors.amber,), "Luminosité", "-", "Lux", Colors.amber),
    Data("T", Icon(Icons.whatshot, color: Colors.red,), "Température", "-", "°C", Colors.red),
    Data("H", Icon(Icons.local_laundry_service, color: Colors.blue,), "Humidité", "-", "hh", Colors.blue),
  ];


  @override
  Widget build(BuildContext context) {
    _connectionModel = ModalRoute.of(context).settings.arguments;
    _adress = _connectionModel.adress;
    _port = _connectionModel.port;

    //timer = Timer.periodic(Duration(seconds: 5), (Timer t)  => getValues());
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier l'ordre d'affichage"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text('Vous pouvez glisser-déposer !', textScaleFactor: 1.2,),
            Divider(
              height: 20,
              color: Colors.grey,
            ),
            Expanded(
              child: ReorderableListView(
                children: List.generate(datas.length, (index) {
                  return ListTile(
                    key: Key(datas[index].id.toString()),
                    leading: datas[index].icon,
                    title: Text(datas[index].title),
                    trailing: Text(datas[index].value+" "+datas[index].unit, style: TextStyle(color: datas[index].color, fontWeight: FontWeight.bold),),
                  );
                }),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    _updateMyItems(oldIndex, newIndex);
                  });
                  sendOrder();
                  getValues();
                },
              ),
            )
          ],
        )
      )
    );
  }

  void _updateMyItems(int oldIndex, int newIndex) {
    if(newIndex > oldIndex){
      newIndex -= 1;
    }

    final Data item = datas.removeAt(oldIndex);
    datas.insert(newIndex, item);
    getValues();
  }

  void getValues() {
      var data = "getValues()";
      var codec = new Utf8Codec();
      List<int> dataToSend = codec.encode(data);
      var addressesIListenFrom = InternetAddress.anyIPv4;

      RawDatagramSocket.bind(addressesIListenFrom, _port)
          .then((RawDatagramSocket udpSocket) {
        udpSocket.forEach((RawSocketEvent event) {
          if(event == RawSocketEvent.read) {
            Datagram dg = udpSocket.receive();
            print(utf8.decode(dg.data));
            Map<String,dynamic> json_data = jsonDecode(utf8.decode(dg.data));
            datas.forEach((data){
              setState(() {
                switch(data.id) {
                  case "L":
                    data.value = json_data['Lux'].toString();
                    break;
                  case "T":
                    data.value = json_data['Temp'].toString();
                    break;
                  case "H":
                    data.value = json_data['Humidity'].toString();
                    break;
                }
              });
            });
          }
        });
        udpSocket.send(dataToSend, new InternetAddress(_adress), _port);

        print('Did send data on the stream..');
      });
  }

  void sendOrder() {
    setState(() {
      isBusy = true;
    });
    var data = datas[0].id+datas[1].id+datas[2].id;
    var codec = new Utf8Codec();
    List<int> dataToSend = codec.encode(data);
    var addressesIListenFrom = InternetAddress.anyIPv4;

    RawDatagramSocket.bind(addressesIListenFrom, _port)
        .then((RawDatagramSocket udpSocket) {
      udpSocket.send(dataToSend, new InternetAddress(_adress), _port);
      print('Did send data on the stream..');
    });
    setState(() {
      isBusy = false;
    });
  }
}

class Data {
  final String id;
  final Icon icon;
  final String title;
  String value;
  final String unit;
  final Color color;

  Data(this.id, this.icon, this.title, this.value, this.unit, this.color);
}
