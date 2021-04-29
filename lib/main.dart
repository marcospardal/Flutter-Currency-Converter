import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=99cf3f10";

void main() async {
  runApp(new MaterialApp(
      title: 'Currency Converter',
      home: Home(),
      theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber),
              ),
              hintStyle: TextStyle(color: Colors.amber)))));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolarBuyPrice, euroBuyPrice;
  TextEditingController reaisController = TextEditingController();
  TextEditingController dollarsController = TextEditingController();
  TextEditingController eurosController = TextEditingController();

  void _convertReal(String text) {
    double reais = reaisController.text != '' ? double.parse(text) : 0;

    dollarsController.text = (reais / dolarBuyPrice).toStringAsFixed(2);
    eurosController.text = (reais / euroBuyPrice).toStringAsFixed(2);
  }

  void _convertDolar(String text) {
    double dollars = dollarsController.text != '' ? double.parse(text) : 0;

    reaisController.text = (dollars * dolarBuyPrice).toStringAsFixed(2);
    eurosController.text =
        (dollars * dolarBuyPrice / euroBuyPrice).toStringAsFixed(2);
  }

  void _convertEuro(String text) {
    double euros = eurosController.text != '' ? double.parse(text) : 0;

    reaisController.text = (euros * euroBuyPrice).toStringAsFixed(2);
    dollarsController.text =
        (euros * euroBuyPrice / dolarBuyPrice).toStringAsFixed(2);
  }

  void _resetFields() {
    dollarsController.text = "";
    reaisController.text = "";
    eurosController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("Currency Conversor"),
          backgroundColor: Colors.amber,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              color: Colors.black,
              onPressed: _resetFields,
            )
          ],
        ),
        body: FutureBuilder<Map>(
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Text(
                      "Fetching Data....",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error fetching data :(",
                        style: TextStyle(color: Colors.amber, fontSize: 25),
                      ),
                    );
                  } else {
                    dolarBuyPrice =
                        snapshot.data['results']['currencies']['USD']['buy'];
                    euroBuyPrice =
                        snapshot.data['results']['currencies']['EUR']['buy'];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150, color: Colors.amber),
                          buildTextField(
                              "Reais", "R\$", reaisController, _convertReal),
                          Divider(),
                          buildTextField("Doláres", "US\$", dollarsController,
                              _convertDolar),
                          Divider(),
                          buildTextField(
                              "Euros", "€", eurosController, _convertEuro),
                        ],
                      ),
                    );
                  }
              }
            },
            future: getData()));
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.tryParse(request));
  return json.decode(response.body);
}

Widget buildTextField(String label, String icon,
    TextEditingController controller, Function convert) {
  return TextField(
    keyboardType: TextInputType.number,
    controller: controller,
    onChanged: convert,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: icon,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25),
  );
}
