import 'package:flutter/material.dart';

class KonversiPage extends StatefulWidget {
  @override
  State<KonversiPage> createState() => _KonversiPageState();
}

class _KonversiPageState extends State<KonversiPage> {
  final TextEditingController input = TextEditingController();
  String result = "";

  // ======================
  // NUMBER SYSTEM
  // ======================

  void decToBin() {
    int num = int.tryParse(input.text) ?? 0;
    setState(() => result = num.toRadixString(2));
  }

  void decToHex() {
    int num = int.tryParse(input.text) ?? 0;
    setState(() => result = num.toRadixString(16));
  }

  void binToDec() {
    try {
      setState(() => result = int.parse(input.text, radix: 2).toString());
    } catch (_) {
      result = "Input biner salah";
      setState(() {});
    }
  }

  void hexToDec() {
    try {
      setState(() => result = int.parse(input.text, radix: 16).toString());
    } catch (_) {
      result = "Input hex salah";
      setState(() {});
    }
  }

  void binToHex() {
    try {
      int num = int.parse(input.text, radix: 2);
      setState(() => result = num.toRadixString(16));
    } catch (_) {
      result = "Input biner salah";
      setState(() {});
    }
  }

  void hexToBin() {
    try {
      int num = int.parse(input.text, radix: 16);
      setState(() => result = num.toRadixString(2));
    } catch (_) {
      result = "Input hex salah";
      setState(() {});
    }
  }

  // ======================
  // IP ADDRESS
  // ======================

  void ipToBinary() {
    try {
      List<String> parts = input.text.split('.');
      result = parts
          .map((e) => int.parse(e).toRadixString(2).padLeft(8, '0'))
          .join('.');
      setState(() {});
    } catch (_) {
      result = "Format IP salah";
      setState(() {});
    }
  }

  void binaryToIp() {
    try {
      List<String> parts = input.text.split('.');
      result = parts
          .map((e) => int.parse(e, radix: 2).toString())
          .join('.');
      setState(() {});
    } catch (_) {
      result = "Format binary IP salah";
      setState(() {});
    }
  }

  // ======================
  // TEXT & ASCII
  // ======================

  void textToAscii() {
    result = input.text.codeUnits.join(' ');
    setState(() {});
  }

  void asciiToText() {
    try {
      List<int> codes = input.text.split(' ').map(int.parse).toList();
      result = String.fromCharCodes(codes);
      setState(() {});
    } catch (_) {
      result = "Format ASCII salah";
      setState(() {});
    }
  }

  void textToBinary() {
    result = input.text.codeUnits
        .map((c) => c.toRadixString(2).padLeft(8, '0'))
        .join(' ');
    setState(() {});
  }

  void binaryToText() {
    try {
      List<String> parts = input.text.split(' ');
      result = String.fromCharCodes(
        parts.map((b) => int.parse(b, radix: 2)).toList(),
      );
      setState(() {});
    } catch (_) {
      result = "Format binary text salah";
      setState(() {});
    }
  }

  // ======================
  // BUTTON UI
  // ======================

  Widget btn(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(text),
    );
  }

  // ======================
  // UI
  // ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Konversi Programmer")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: input,
              decoration: InputDecoration(
                labelText: "Input",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // ======================
            // NUMBER SYSTEM
            // ======================
            Text("Number System", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("Dec→Bin", decToBin),
                btn("Dec→Hex", decToHex),
                btn("Bin→Dec", binToDec),
                btn("Hex→Dec", hexToDec),
                btn("Bin→Hex", binToHex),
                btn("Hex→Bin", hexToBin),
              ],
            ),

            SizedBox(height: 20),

            // ======================
            // IP
            // ======================
            Text("IP Address", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("IP→Bin", ipToBinary),
                btn("Bin→IP", binaryToIp),
              ],
            ),

            SizedBox(height: 20),

            // ======================
            // TEXT ASCII
            // ======================
            Text("Text & ASCII", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("Text→ASCII", textToAscii),
                btn("ASCII→Text", asciiToText),
                btn("Text→Bin", textToBinary),
                btn("Bin→Text", binaryToText),
              ],
            ),

            SizedBox(height: 20),

            // ======================
            // RESULT
            // ======================
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Hasil:\n$result",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}