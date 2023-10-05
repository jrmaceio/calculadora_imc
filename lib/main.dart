import 'package:calculadora_imc/models/imc_model.dart';
import 'package:calculadora_imc/repositorie/imc_repositorie.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculadora IMC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<double> imcList = [];
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  String _result ='';

  void initState() {
    super.initState();
    resetFields();
  }

  void resetFields() {
    _weightController.text = '';
    _heightController.text = '';
    setState(() {
      _result = 'Informe seus dados';
    });
    imcList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            padding: EdgeInsets.all(20.0), 
            child:  Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildTextFormField(
              label: "Peso (kg)",
              error: "Insira seu peso!",
              controller: _weightController),
          buildTextFormField(
              label: "Altura (cm)",
              error: "Insira sua altura!",
              controller: _heightController),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 36.0),
              child: Text(
              _result,
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            //style: raisedButtonStyle,
            onPressed: () { 
              //if (_formKey.currentState.validate()) {
                calculateImc();
              //}  
            },
            child: Text('CALCULAR', style: TextStyle(color: Colors.black)),
          ),
          buildIMCList(),
        ],
      ),
    ),
    ));
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text('Calculadora de IMC - Sqlite'),
      backgroundColor: Colors.blue,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            resetFields();
          },
        )
      ],
    );
  }

  void calculateImc() async {
    double weight = double.parse(_weightController.text);
    double height = double.parse(_heightController.text) / 100.0;
    double imc = weight / (height * height);

    setState(() {
      _result = "IMC = ${imc.toStringAsPrecision(2)}\n";
      if (imc < 18.6)
        _result += "Abaixo do peso";
      else if (imc < 25.0)
        _result += "Peso ideal";
      else if (imc < 30.0)
        _result += "Levemente acima do peso";
      else if (imc < 35.0)
        _result += "Obesidade Grau I";
      else if (imc < 40.0)
        _result += "Obesidade Grau II";
      else
        _result += "Obesidade Grau IIII";
    });

    imcList.add(imc);

    // Save IMC result to the SQLite database
    final repository = ImcRepository();
    await repository.save(
        ImcSQLiteModel(height: height.toString(), weight: weight.toString()));
  }

  Widget buildIMCList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: imcList.length,
        itemBuilder: (BuildContext context, int index) {
          double imc = imcList[index];
          String message = "IMC = ${imc.toStringAsPrecision(2)} ";
          if (imc < 18.6) {
            message += "Abaixo do peso";
          } else if (imc < 24.9)
            message += "Peso ideal";
          else if (imc < 29.9)
            message += "Levemente acima do peso";
          else if (imc < 34.9)
            message += "Obesidade Grau I";
          else if (imc < 39.9)
            message += "Obesidade Grau II";
          else
            message += "Obesidade Graus III";
          return ListTile(
            title: Text(message),
          );
        },
      ),
    );
  }

  Widget buildTextFormField(
      {required TextEditingController controller, required String error, required String label}) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      controller: controller,
      validator: (text) {
        return text!.isEmpty ? error : null;
      },
    );
  }

}
