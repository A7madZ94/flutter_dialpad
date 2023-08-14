import 'package:flutter/material.dart';
import 'package:flutter_dialpad/flutter_dialpad.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: DialPad(
          enableDtmf: true,
          //outputMask: "(000) 000-0000",
          hideSubtitle: false,
          backspaceButtonIconColor: Colors.red,
          buttonTextColor: Colors.white,
          dialOutputTextColor: Colors.black,
          keyPressed: (value) {
            print('$value was pressed');
          },
          makeCall: (number) {
            print(number);
          },
          buttonClipOvalRadius: 60,
          titleFontSize: 20,
          subTitleFontSize: 10,
          starIconSize: 35,
          callIconSize: 25,
          hashIconSize: 20,
          deleteButtonSize: 30,
          dialOutputTextFontSize: 25,
          searchContainerColor: Colors.white,
          
          inputDecoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
                  border: OutlineInputBorder(
                    
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
          
        )),
      ),
    );
  }
}
