# Application Android & iOS

Utilisation du Framework [Flutter](https://flutter.dev/) crée par Google.

## Page de Connexion au Raspberry

### Controlleur de champs : 

```dart
final ipController = TextEditingController(text: "172.20.10.2");
final portController = TextEditingController(text: "10000");
```

### Contenu de la page : 

Scaffold classique dans la function build

```dart
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      // Barre du haut
    ),
    body: Container(
      // Contenu de la page (2 champs + bouton)
    )
  );
}
```

### ConnectionModel
```dart
class ConnectionModel {
  final String adress;
  final int port;

  ConnectionModel({this.adress, this.port});
}
```

### Validation du formulaire (onButtonPressed)

```dart
void connection() {
    if(portController.text.isNotEmpty && ipController.text.isNotEmpty) { // si les 2 champs ne sont pas vides
      ConnectionModel connection = ConnectionModel(
        adress: ipController.text,
        port: int.parse(portController.text) // parse string to int
      );
      
      // Redirection vers la page d'ordre de l'affichage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(),settings: RouteSettings(
          arguments: connection // On passe en argument l'objet connection pour lutiliser sur la seconde vue
        )),
      );
    } else {
       // Si un des champs est vides, alors on affiche une modal avec un message d'erreur
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
```

## Affichage de l'ordre

###Liste des donnes
```dart 
List<Data> datas = <Data>[
   Data("L", Icon(Icons.lightbulb_outline, color: Colors.amber,), "Luminosité", "-", "Lux", Colors.amber),
   Data("T", Icon(Icons.whatshot, color: Colors.red,), "Température", "-", "°C", Colors.red),
   Data("H", Icon(Icons.local_laundry_service, color: Colors.blue,), "Humidité", "-", "hh", Colors.blue),
];
```

### Modele des donnes
```dart
class Data {
  final String id;
  final Icon icon;
  final String title;
  String value;
  final String unit;
  final Color color;

  Data(this.id, this.icon, this.title, this.value, this.unit, this.color);
}
```
### Contenu de la page

Drag and Drop avec les datas
```dart 

ReorderableListView(
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
              )
```

### Modification de l'ordre de la liste (Drag and Drop)

```dart
void _updateMyItems(int oldIndex, int newIndex) {
    if(newIndex > oldIndex){
      newIndex -= 1;
    }

    final Data item = datas.removeAt(oldIndex);
    datas.insert(newIndex, item);
    getValues(); // Appel de getValues()
  }
  ````
  
  ### Envoi de l'ordre 
  
  ```dart
  void sendOrder() {
    setState(() {
      isBusy = true; // est occupe
    });
    var data = datas[0].id+datas[1].id+datas[2].id; // Recupere l'ID (la lettre) de chaque data dans l'ordre
    var codec = new Utf8Codec();
    List<int> dataToSend = codec.encode(data); // Definition du codec pour les donnees 
    var addressesIListenFrom = InternetAddress.anyIPv4;

    RawDatagramSocket.bind(addressesIListenFrom, _port)
        .then((RawDatagramSocket udpSocket) { // Initialisation du serveur sur le port
      udpSocket.send(dataToSend, new InternetAddress(_adress), _port); // envoi de l'ordre sur l'adresse defini precedement et sur le bon port
      print('Did send data on the stream..'); // Erreur
    });
    setState(() {
      isBusy = false; // n'est plus occupe
    });
  }
  ```
  
  ### Recuperer les donnees du microcontrolleur
  
  ```dart
  
 void getValues() {
    var data = "getValues()";
    var codec = new Utf8Codec();
    List<int> dataToSend = codec.encode(data);
    var addressesIListenFrom = InternetAddress.anyIPv4;

    RawDatagramSocket.bind(addressesIListenFrom, _port) // INIT Serveur on port
        .then((RawDatagramSocket udpSocket) {
      udpSocket.forEach((RawSocketEvent event) {
        if(event == RawSocketEvent.read) { // lecture des datas sur le port defini precedement
          Datagram dg = udpSocket.receive(); 
          print(utf8.decode(dg.data)); // debug JSON
          Map<String,dynamic> json_data = jsonDecode(utf8.decode(dg.data));  // Json to Map
          datas.forEach((data){ // on parcours les datas et on met a jour leur valeur avec celle du json decoder avant
            setState(() {
              switch(data.id) {
                case "L":
                  data.value = json_data['Lux'].toString(); // recuperation de la luminosite
                  break;
                case "T":
                  data.value = json_data['Temp'].toString(); // recuperation de la temperature
                  break;
                case "H":
                  data.value = json_data['Humidity'].toString(); // recuperation de l'humidite
                  break;
              }
            });
          });
        }
      });
      udpSocket.send(dataToSend, new InternetAddress(_adress), _port); // envoi du paquet getValues()

      print('Did send data on the stream..');
    });
}
```
