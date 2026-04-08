import 'package:flutter/material.dart';
import '../../../shared/history_page.dart';

// MODEL HISTORY
class KonversiHistory {
  final String input;
  final String operation;
  final String result;

  KonversiHistory(this.input, this.operation, this.result);

  @override
  String toString() => "$operation: $input → $result";
}

class KonversiPage extends StatefulWidget {
  @override
  State<KonversiPage> createState() => _KonversiPageState();
}

class _KonversiPageState extends State<KonversiPage> {
  // Controller untuk membaca teks input pengguna.
  final TextEditingController input = TextEditingController();

  // Menyimpan hasil konversi terakhir dan jenis operasinya.
  String result = "-";
  String lastOp = "";

  // Menyimpan riwayat konversi (terbaru di index 0).
  List<KonversiHistory> history = [];

  // Memperbarui hasil di UI dan langsung menyimpan ke history.
  void setResult(String res, String op) {
    setState(() {
      result = res;
      lastOp = op;
    });

    history.insert(0, KonversiHistory(input.text, op, res));
  }

  void error(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // KONVERSI BASIS ANGKA
  void decToBin() {
    int? num = int.tryParse(input.text);
    if (num == null) return error("Input decimal tidak valid");
    setResult(num.toRadixString(2), "Dec → Bin");
  }

  void decToHex() {
    int? num = int.tryParse(input.text);
    if (num == null) return error("Input decimal tidak valid");
    setResult(num.toRadixString(16), "Dec →Hex");
  }

  void binToDec() {
    try {
      setResult(int.parse(input.text, radix: 2).toString(), "Bin → Dec");
    } catch (_) {
      error("Input biner salah");
    }
  }

  void hexToDec() {
    try {
      setResult(int.parse(input.text, radix: 16).toString(), "Hex → Dec");
    } catch (_) {
      error("Input hex salah");
    }
  }

  void binToHex() {
    try {
      int num = int.parse(input.text, radix: 2);
      setResult(num.toRadixString(16), "Bin → Hex");
    } catch (_) {
      error("Input biner salah");
    }
  }

  void hexToBin() {
    try {
      int num = int.parse(input.text, radix: 16);
      setResult(num.toRadixString(2), "Hex → Bin");
    } catch (_) {
      error("Input hex salah");
    }
  }

  // KONVERSI IP ADDRESS
  void ipToBinary() {
    try {
      List<String> parts = input.text.split('.');
      if (parts.length != 4) return error("Format IP salah");

      String res = parts
          .map((e) => int.parse(e).toRadixString(2).padLeft(8, '0'))
          .join('.');

      setResult(res, "IP → Bin");
    } catch (_) {
      error("Format IP salah");
    }
  }

  void binaryToIp() {
    try {
      List<String> parts = input.text.split('.');
      if (parts.length != 4) return error("Format binary IP salah");

      String res =
          parts.map((e) => int.parse(e, radix: 2).toString()).join('.');

      setResult(res, "Bin → IP");
    } catch (_) {
      error("Format binary IP salah");
    }
  }

  // KONVERSI TEXT / ASCII / BINARY
  void textToAscii() {
    setResult(input.text.codeUnits.join(' '), "Text → ASCII");
  }

  void asciiToText() {
    try {
      List<int> codes = input.text.split(' ').map(int.parse).toList();
      setResult(String.fromCharCodes(codes), "ASCII → Text");
    } catch (_) {
      error("Format ASCII salah");
    }
  }

  void textToBinary() {
    String res = input.text.codeUnits
        .map((c) => c.toRadixString(2).padLeft(8, '0'))
        .join(' ');
    setResult(res, "Text → Bin");
  }

  void binaryToText() {
    try {
      List<String> parts = input.text.split(' ');
      String res = String.fromCharCodes(
        parts.map((b) => int.parse(b, radix: 2)).toList(),
      );
      setResult(res, "Bin → Text");
    } catch (_) {
      error("Format binary text salah");
    }
  }

  // Factory tombol agar semua tombol aksi konsisten.
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
        title: Text("Konversi Programmer"),
        actions: [
          // Membuka halaman history, lalu bisa pilih item untuk restore state.
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryPage(
                    history: history,
                    title: "History Konversi",
                    onSelect: (h) {
                      setState(() {
                        input.text = h.input;
                        result = h.result;
                        lastOp = h.operation;
                      });
                    },
                  ),
                ),
              );
            },
          )
        ],
      ),
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

            // aksi konversi antar basis angka.
            Text("Number System", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("Dec → Bin", decToBin),
                btn("Dec → Hex", decToHex),
                btn("Bin → Dec", binToDec),
                btn("Hex → Dec", hexToDec),
                btn("Bin → Hex", binToHex),
                btn("Hex → Bin", hexToBin),
              ],
            ),

            SizedBox(height: 20),

            // aksi konversi IP <-> biner.
            Text("IP Address", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("IP → Bin", ipToBinary),
                btn("Bin → IP", binaryToIp),
              ],
            ),

            SizedBox(height: 20),

            // Kelompok aksi konversi text, ASCII, dan biner.
            Text("Text & ASCII", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("Text → ASCII", textToAscii),
                btn("ASCII → Text", asciiToText),
                btn("Text → Bin", textToBinary),
                btn("Bin → Text", binaryToText),
              ],
            ),

            SizedBox(height: 20),

            Text("Operasi Terakhir: $lastOp"),

            Card(
              elevation: 2,
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