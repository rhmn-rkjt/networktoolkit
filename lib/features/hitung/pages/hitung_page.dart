import 'package:flutter/material.dart';

class HitungPage extends StatefulWidget {
  @override
  State<HitungPage> createState() => _HitungPageState();
}

class _HitungPageState extends State<HitungPage> {
  final TextEditingController bin1 = TextEditingController();
  final TextEditingController bin2 = TextEditingController();

  String result = "";

  int getA() => int.tryParse(bin1.text, radix: 2) ?? 0;
  int getB() => int.tryParse(bin2.text, radix: 2) ?? 0;

  void setResult(int value) {
    setState(() {
      result = value.toRadixString(2);
    });
  }

  Widget btn(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hitung Biner Lengkap"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: bin1,
              decoration: InputDecoration(labelText: "Binary 1"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: bin2,
              decoration: InputDecoration(labelText: "Binary 2"),
            ),

            SizedBox(height: 20),

            // ======================
            // ARITMATIKA
            // ======================
            Text("Aritmatika", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("+", () => setResult(getA() + getB())),
                btn("-", () => setResult(getA() - getB())),
                btn("*", () => setResult(getA() * getB())),
                btn("/", () {
                  if (getB() == 0) {
                    setState(() => result = "Tidak bisa dibagi 0");
                  } else {
                    setResult(getA() ~/ getB());
                  }
                }),
              ],
            ),

            SizedBox(height: 20),

            // ======================
            // LOGIKA BIT
            // ======================
            Text("Logika Bit", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("AND", () => setResult(getA() & getB())),
                btn("OR", () => setResult(getA() | getB())),
                btn("XOR", () => setResult(getA() ^ getB())),
                btn("NOT A", () => setResult(~getA())),
              ],
            ),

            SizedBox(height: 20),

            // ======================
            // SHIFT
            // ======================
            Text("Shift Bit", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("A << 1", () => setResult(getA() << 1)),
                btn("A >> 1", () => setResult(getA() >> 1)),
              ],
            ),

            SizedBox(height: 20),

            // ======================
            // ADVANCED LOGIC
            // ======================
            Text("Advanced Logic", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("NAND", () => setResult(~(getA() & getB()))),
                btn("NOR", () => setResult(~(getA() | getB()))),
                btn("XNOR", () => setResult(~(getA() ^ getB()))),
              ],
            ),

            SizedBox(height: 20),

            // ======================
            // HASIL
            // ======================
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Hasil: $result",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}