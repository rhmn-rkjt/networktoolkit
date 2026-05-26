import 'package:flutter/material.dart';
import '../../../shared/history_page.dart';
import '../../../shared/widgets/example_section.dart';
import '../../../shared/utils/pdf_utils.dart';

// MODEL HISTORY
class HitungHistory {
  final String a;
  final String b;
  final String op;
  final String result;

  HitungHistory(this.a, this.b, this.op, this.result);

  @override
  String toString() => "$a $op $b = $result";
}

class HitungPage extends StatefulWidget {
  @override
  State<HitungPage> createState() => _HitungPageState();
}

class _HitungPageState extends State<HitungPage> {
  // Dua input biner yang dipakai untuk operasi.
  final TextEditingController bin1 = TextEditingController();
  final TextEditingController bin2 = TextEditingController();

  // Menyimpan hasil dan nama operasi terakhir.
  String result = "-";
  String lastOp = "";

  // Riwayat perhitungan
  List<HitungHistory> history = [];

  // Validasi bahwa string hanya berisi 0 dan 1.
  bool isBinary(String s) {
    return RegExp(r'^[01]+$').hasMatch(s);
  }

  // Helper untuk parsing nilai input biner ke integer.
  int getA() => int.parse(bin1.text, radix: 2);
  int getB() => int.parse(bin2.text, radix: 2);

  // Menyimpan hasil ke state dan ke history.
  void setResult(int value, String op) {
    setState(() {
      result = value.toRadixString(2);
      lastOp = op;
    });

    // SIMPAN HISTORY
    history.insert(
      0,
      HitungHistory(bin1.text, bin2.text, op, result),
    );
  }

  // Menampilkan pesan kesalahan sederhana.
  void error(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // Factory tombol agar tidak mengulang widget yang sama.
  Widget btn(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(text),
    );
  }

  // Validasi input sebelum operasi dijalankan.
  bool validateAB({bool needB = true}) {
    if (!isBinary(bin1.text)) {
      error("Binary 1 tidak valid");
      return false;
    }
    if (needB && !isBinary(bin2.text)) {
      error("Binary 2 tidak valid");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hitung Biner Lengkap"),
        actions: [
          // Help button - Open PDF tutorial
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              PDFUtils.openHitungPDF();
            },
            tooltip: 'Buka Panduan',
          ),
          // Buka history lalu restore nilai saat item dipilih.
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryPage(
                    history: history,
                    title: "History Hitung",
                    onSelect: (h) {
                      setState(() {
                        bin1.text = h.a;
                        bin2.text = h.b;
                        result = h.result;
                        lastOp = h.op;
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
            // Example Section
            ExampleSection(
              tutorialKey: 'hitung',
              onExampleSelected: (val1, val2) {
                setState(() {
                  bin1.text = val1;
                  bin2.text = val2 ?? '';
                });
              },
            ),

            SizedBox(height: 16),

            // Input Fields dengan Tooltip
            Tooltip(
              message: 'Masukkan bilangan biner (hanya 0 dan 1)',
              child: TextField(
                controller: bin1,
                decoration: InputDecoration(
                  labelText: "Binary 1",
                  helperText: 'Contoh: 1010, 11111, 0101',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
            ),
            SizedBox(height: 10),
            Tooltip(
              message: 'Masukkan bilangan biner kedua (hanya 0 dan 1)',
              child: TextField(
                controller: bin2,
                decoration: InputDecoration(
                  labelText: "Binary 2",
                  helperText: 'Contoh: 1100, 10101, 0011',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Operasi aritmatika: +, -, *, dan pembagian integer.
            Text("Aritmatika", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("+", () {
                  if (!validateAB()) return;
                  setResult(getA() + getB(), "+");
                }),
                btn("-", () {
                  if (!validateAB()) return;
                  setResult(getA() - getB(), "-");
                }),
                btn("*", () {
                  if (!validateAB()) return;
                  setResult(getA() * getB(), "*");
                }),
                btn("/", () {
                  if (!validateAB()) return;
                  if (getB() == 0) return error("Tidak bisa dibagi 0");
                  setResult(getA() ~/ getB(), "/");
                }),
              ],
            ),

            SizedBox(height: 20),

            //LOGIKA BIT: AND, OR, XOR, dan NOT.
            Text("Logika Bit", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("AND", () {
                  if (!validateAB()) return;
                  setResult(getA() & getB(), "AND");
                }),
                btn("OR", () {
                  if (!validateAB()) return;
                  setResult(getA() | getB(), "OR");
                }),
                btn("XOR", () {
                  if (!validateAB()) return;
                  setResult(getA() ^ getB(), "XOR");
                }),
                btn("NOT A", () {
                  if (!validateAB(needB: false)) return;
                  setResult(~getA(), "NOT");
                }),
              ],
            ),

            SizedBox(height: 20),

            //SHIFT BIT: geser kiri/kanan 1 bit.
            Text("Shift Bit", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("A << 1", () {
                  if (!validateAB(needB: false)) return;
                  setResult(getA() << 1, "<<");
                }),
                btn("A >> 1", () {
                  if (!validateAB(needB: false)) return;
                  setResult(getA() >> 1, ">>");
                }),
              ],
            ),

            SizedBox(height: 20),

            // ADVANCED LOGIC: kombinasi negasi dari operator dasar.
            Text("Advanced Logic", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: [
                btn("NAND", () {
                  if (!validateAB()) return;
                  setResult(~(getA() & getB()), "NAND");
                }),
                btn("NOR", () {
                  if (!validateAB()) return;
                  setResult(~(getA() | getB()), "NOR");
                }),
                btn("XNOR", () {
                  if (!validateAB()) return;
                  setResult(~(getA() ^ getB()), "XNOR");
                }),
              ],
            ),

            SizedBox(height: 20),

            // menampilkan operasi terakhir dan hasil biner.
            Text("Operasi Terakhir: $lastOp"),

            Card(
              elevation: 2,
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