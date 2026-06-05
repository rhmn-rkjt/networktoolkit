import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/history_page.dart';
import '../../../shared/widgets/example_section.dart';
import '../../../shared/utils/pdf_utils.dart';
import '../models/hitung_history.dart';

class HitungPage extends StatefulWidget {
  @override
  State<HitungPage> createState() => _HitungPageState();
}

class _HitungPageState extends State<HitungPage> {
  final TextEditingController bin1 = TextEditingController();
  final TextEditingController bin2 = TextEditingController();

  String result = "-";
  String lastOp = "";
  List<HitungHistory> history = [];

  // Warna tema khusus untuk halaman Hitung (Biru)
  final Color primaryColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadAllState();
  }

  // Fungsi Penyimpanan Lokal
  Future<void> _loadAllState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<String>? savedHistory = prefs.getStringList('hitung_history');
      final String? savedBin1 = prefs.getString('hitung_last_bin1');
      final String? savedBin2 = prefs.getString('hitung_last_bin2');
      final String? savedResult = prefs.getString('hitung_last_result');
      final String? savedLastOp = prefs.getString('hitung_last_op');

      List<HitungHistory> loadedHistory = [];

      if (savedHistory != null && savedHistory.isNotEmpty) {
        for (String item in savedHistory) {
          try {
            final Map<String, dynamic> parsedMap = Map<String, dynamic>.from(json.decode(item));
            loadedHistory.add(HitungHistory.fromMap(parsedMap));
          } catch (e) {
            debugPrint("Mengabaikan data history hitung yang rusak: $e");
          }
        }
      }

      if (mounted) {
        setState(() {
          history = loadedHistory;
          if (savedBin1 != null) bin1.text = savedBin1;
          if (savedBin2 != null) bin2.text = savedBin2;
          if (savedResult != null) result = savedResult;
          if (savedLastOp != null) lastOp = savedLastOp;
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat data dari SharedPreferences: $e");
    }

    bin1.addListener(_saveCurrentInputOnly);
    bin2.addListener(_saveCurrentInputOnly);
  }

  Future<void> _saveAllState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> historyStringList = history.map((item) => json.encode(item.toMap())).toList();
      await prefs.setStringList('hitung_history', historyStringList);
      
      await prefs.setString('hitung_last_bin1', bin1.text);
      await prefs.setString('hitung_last_bin2', bin2.text);
      await prefs.setString('hitung_last_result', result);
      await prefs.setString('hitung_last_op', lastOp);
    } catch (e) {
      debugPrint("Gagal menyimpan data ke SharedPreferences: $e");
    }
  }

  void _saveCurrentInputOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hitung_last_bin1', bin1.text);
      await prefs.setString('hitung_last_bin2', bin2.text);
    } catch (_) {}
  }

  @override
  void dispose() {
    bin1.removeListener(_saveCurrentInputOnly);
    bin2.removeListener(_saveCurrentInputOnly);
    bin1.dispose();
    bin2.dispose();
    super.dispose();
  }

  // ================= LOGIKA HITUNG =================
  bool isBinary(String s) {
    return RegExp(r'^[01]+$').hasMatch(s);
  }

  int getA() => int.parse(bin1.text, radix: 2);
  int getB() => int.parse(bin2.text, radix: 2);

  void setResult(int value, String op) {
    setState(() {
      result = value.toRadixString(2);
      lastOp = op;
      history.insert(0, HitungHistory(bin1.text, bin2.text, op, result));
    });
    _saveAllState();
  }

  void error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  bool validateAB({bool needB = true}) {
    if (!isBinary(bin1.text)) {
      error("Binary 1 tidak valid. Hanya gunakan 0 dan 1.");
      return false;
    }
    if (needB && !isBinary(bin2.text)) {
      error("Binary 2 tidak valid. Hanya gunakan 0 dan 1.");
      return false;
    }
    return true;
  }

  Widget _actionBtn(String text, VoidCallback onTap, {bool isWide = false}) {
    return SizedBox(
      width: isWide ? 100 : null,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  // Header untuk grup tombol
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan utama halaman Hitung
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          "Kalkulator Biner",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            tooltip: 'Buka Panduan',
            onPressed: PDFUtils.openHitungPDF,
          ),
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
                      _saveAllState();
                    },
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Kartu Hasil (Result Card) 
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lastOp.isEmpty ? "Belum ada operasi" : "Operasi: $lastOp",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true, // Agar teks panjang bergeser ke kiri
                      child: Text(
                        result,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              ExampleSection(
                tutorialKey: 'hitung',
                onExampleSelected: (val1, val2) {
                  setState(() {
                    bin1.text = val1;
                    bin2.text = val2 ?? '';
                  });
                  _saveAllState();
                },
              ),
              
              SizedBox(height: 20),

              // Input Fields 
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: bin1,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18, letterSpacing: 1.5, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        labelText: "Binary 1",
                        hintText: "010101...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(Icons.looks_one, color: primaryColor),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),
                    TextField(
                      controller: bin2,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18, letterSpacing: 1.5, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        labelText: "Binary 2",
                        hintText: "010101...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(Icons.looks_two, color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // Tombol Operasi
              _sectionHeader("Aritmatika", Icons.calculate),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionBtn("+ Tambah", () {
                    if (!validateAB()) return;
                    setResult(getA() + getB(), "+");
                  }, isWide: true),
                  _actionBtn("- Kurang", () {
                    if (!validateAB()) return;
                    setResult(getA() - getB(), "-");
                  }, isWide: true),
                  _actionBtn("× Kali", () {
                    if (!validateAB()) return;
                    setResult(getA() * getB(), "*");
                  }, isWide: true),
                  _actionBtn("÷ Bagi", () {
                    if (!validateAB()) return;
                    if (getB() == 0) return error("Tidak bisa dibagi dengan 0");
                    setResult(getA() ~/ getB(), "/");
                  }, isWide: true),
                ],
              ),

              _sectionHeader("Logika Bit", Icons.memory),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionBtn("AND", () {
                    if (!validateAB()) return;
                    setResult(getA() & getB(), "AND");
                  }),
                  _actionBtn("OR", () {
                    if (!validateAB()) return;
                    setResult(getA() | getB(), "OR");
                  }),
                  _actionBtn("XOR", () {
                    if (!validateAB()) return;
                    setResult(getA() ^ getB(), "XOR");
                  }),
                  _actionBtn("NOT A", () {
                    if (!validateAB(needB: false)) return;
                    setResult(~getA(), "NOT A");
                  }),
                ],
              ),

              _sectionHeader("Advanced & Shift", Icons.keyboard_double_arrow_right),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionBtn("A << 1", () {
                    if (!validateAB(needB: false)) return;
                    setResult(getA() << 1, "<<");
                  }),
                  _actionBtn("A >> 1", () {
                    if (!validateAB(needB: false)) return;
                    setResult(getA() >> 1, ">>");
                  }),
                  _actionBtn("NAND", () {
                    if (!validateAB()) return;
                    setResult(~(getA() & getB()), "NAND");
                  }),
                  _actionBtn("NOR", () {
                    if (!validateAB()) return;
                    setResult(~(getA() | getB()), "NOR");
                  }),
                  _actionBtn("XNOR", () {
                    if (!validateAB()) return;
                    setResult(~(getA() ^ getB()), "XNOR");
                  }),
                ],
              ),
              
              SizedBox(height: 40), // Jarak aman di bagian bawah
            ],
          ),
        ),
      ),
    );
  }
}