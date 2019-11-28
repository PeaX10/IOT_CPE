import 'package:flutter/material.dart';
import 'package:iot_app/connection_model.dart';
import 'package:iot_app/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IOT - Groupe 6',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'IOT - Weather Station - Grp 6'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final ipController = TextEditingController(text: "172.20.10.2");
  final portController = TextEditingController(text: "10000");

  @override
  void dispose(){
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Text('Connexion au Raspberry', textScaleFactor: 1.4,),
            ),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                  labelText: 'Adresse IP',
                  hintText: 'Entrez une adresse IP'
              ),
            ),
            TextField(
              controller: portController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Port',
                  hintText: 'Entrer le port',

              ),
            ),
            Divider(
              height: 50,
            ),
            FlatButton(
              color: Colors.blueAccent,
              onPressed: connection,
              child: Text("Connexion".toUpperCase(), style: TextStyle(color: Colors.white),textScaleFactor: 1.4,),
            )
          ],
        )
      )
    );
  }

  void connection() {
    if(portController.text.isNotEmpty && ipController.text.isNotEmpty) {
      ConnectionModel connection = ConnectionModel(
        adress: ipController.text,
        port: int.parse(portController.text)
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(),settings: RouteSettings(
          arguments: connection
        )),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Attention'),
          content: Text('Vous devez entrer une IP et port avant de pouvoir vous connecter'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        )
      );
    }
  }
}
