import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
// import 'package:i_d/config/permissions.dart';

class ScreenWalletCreate extends StatefulWidget {
    const ScreenWalletCreate({Key? key}) : super(key: key);

    @override
    _ScreenWalletCreateState createState() => _ScreenWalletCreateState();
}

class _ScreenWalletCreateState extends State<ScreenWalletCreate> {
  final JavascriptRuntime jsRuntime = getJavascriptRuntime();
  final number = ValueNotifier(0);
  TextEditingController inputNameWallet = TextEditingController();
  TextEditingController inputPasswordWallet = TextEditingController();

  Future<int> _addFromJs(JavascriptRuntime jsRuntime, int firstNumber, int secondNumber) async {
    String blocJs = await rootBundle.loadString("assets/js/bloc.js");
    final jsResult = jsRuntime.evaluate(blocJs + """add($firstNumber,$secondNumber)""");
    final jsStringResult = jsResult.stringResult;
    return int.parse(jsStringResult);
  }

  void _click() async {
    try {
      final reuslt = await _addFromJs(jsRuntime, number.value, 1);
      number.value = reuslt;
      debugPrint('$number');
    } on PlatformException catch (e) {
      debugPrint('error: ${e.details}');
    }
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                    top: 130,
                    bottom: 35
                  ),
                  child: Image.asset(
                    'assets/images/LogoEPM.jpg',
                    width: 300,
                    height: 200,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 0,
                    left: 50,
                    right: 50,
                    bottom: 0
                  ),
                  child: const Text(
                    'CREATE WALLET',
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 20,
                    left: 50,
                    right: 50,
                    bottom: 10
                  ),
                  height: 50,
                  child: TextField(
                    controller: inputNameWallet,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name Wallet'
                    )
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 0,
                    left: 50,
                    right: 50,
                    bottom: 30
                  ),
                  height: 50,
                  child: TextField(
                    controller: inputPasswordWallet,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Pasword'
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 0,
                    right: 100,
                    left: 100,
                  ),
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _click();
                    },
                    child: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 10
                      )
                    ),
                  ),
                )
              ],
            )
          ),
      );
  } 
}