import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../../../shared/history_page.dart';
import '../../../shared/widgets/example_section.dart';
import '../../../shared/utils/pdf_utils.dart';
import '../models/konversi_history.dart'; 

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

  // Warna tema khusus untuk halaman Konversi (Teal) sesuai dengan di HomePage
  final Color primaryColor = Colors.teal;

  @override
  void initState() {
    super.initState();
    _loadAllState(); // Memuat history dan state layar saat halaman dibuka
  }

  // Membaca data dengan aman dari memori penyimpanan perangkat
  Future<void> _loadAllState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<String>? savedHistory = prefs.getStringList('konversi_history');
      final String? savedInput = prefs.getString('konversi_last_input');
      final String? savedResult = prefs.getString('konversi_last_result');
      final String? savedLastOp = prefs.getString('konversi_last_op');

      List<KonversiHistory> loadedHistory = [];
      
      // Mengurai data satu per satu agar jika ada 1 data lama yang rusak tidak merusak seluruh list
      if (savedHistory != null && savedHistory.isNotEmpty) {
        for (String item in savedHistory) {
          try {
            final Map<String, dynamic> parsedMap = Map<String, dynamic>.from(json.decode(item));
            loadedHistory.add(KonversiHistory.fromMap(parsedMap));
          } catch (e) {
            debugPrint("Mengabaikan data history yang tidak valid: $e");
          }
        }
      }

      if (mounted) {
        setState(() {
          history = loadedHistory;
          if (savedInput != null) input.text = savedInput;
          if (savedResult != null) result = savedResult;
          if (savedLastOp != null) lastOp = savedLastOp;
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat data dari SharedPreferences: $e");
    }

    // Listener aktif untuk menyimpan teks input setiap kali pengguna mengetik secara real-time
    input.addListener(_saveCurrentInputOnly);
  }

  // Menyimpan list history dan kondisi layar aktif saat tombol konversi ditekan
  Future<void> _saveAllState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      List<String> historyStringList =
          history.map((item) => json.encode(item.toMap())).toList();
          
      await prefs.setStringList('konversi_history', historyStringList);
      await prefs.setString('konversi_last_result', result);
      await prefs.setString('konversi_last_op', lastOp);
      await prefs.setString('konversi_last_input', input.text);
    } catch (e) {
      debugPrint("Gagal menyimpan data ke SharedPreferences: $e");
    }
  }

  // Menyimpan ketikan teks secara mandiri untuk backup otomatis
  void _saveCurrentInputOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('konversi_last_input', input.text);
    } catch (_) {}
  }

  @override
  void dispose() {
    input.removeListener(_saveCurrentInputOnly);
    input.dispose();
    super.dispose();
  }
  
  // Memperbarui hasil di UI dan langsung memicu penyimpanan permanen
  void setResult(String res, String op) {
    setState(() {
      result = res;
      lastOp = op;
      // Memasukkan riwayat ke posisi paling atas (index 0)
      history.insert(0, KonversiHistory("$op: ${input.text}", res));
    });

    _saveAllState(); // Tulis data terbaru ke penyimpanan disk internal perangkat
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

  // Konversi Basis Angka
  void decToBin() {
    int? num = int.tryParse(input.text);
    if (num == null) return error("Input decimal tidak valid");
    setResult(num.toRadixString(2), "Dec → Bin");
  }

  void decToHex() {
    int? num = int.tryParse(input.text);
    if (num == null) return error("Input decimal tidak valid");
    setResult(num.toRadixString(16), "Dec → Hex");
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

  // Fitur Konversi IP Address
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

  // Fitur Konversi Teks & ASCII
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

  Widget _actionBtn(String text, VoidCallback onTap) {
    return ElevatedButton(
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
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  // Tampilan utama halaman Konversi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background yang bersih
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          "Kalkulator Konversi Basis & IP",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              PDFUtils.openKonversiPDF();
            },
            tooltip: 'Buka Panduan',
          ),
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
                        // Memisahkan penulisan judul operasi dari data input asli saat di-restore
                        if (h.input.contains(': ')) {
                          input.text = h.input.split(': ')[1];
                          lastOp = h.input.split(': ')[0];
                        } else {
                          input.text = h.input;
                          lastOp = "";
                        }
                        result = h.result;
                      });
                      _saveAllState(); // Mengunci status penyimpanan saat memulihkan riwayat lama
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
              
              // Kartu Hasil 
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E2C), // Warna gelap elegan
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
                      lastOp.isEmpty ? "Belum ada konversi" : "Konversi: $lastOp",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true, // Agar teks hasil selalu terlihat bagian ujung akhirnya
                      child: Text(
                        result,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              ExampleSection(
                tutorialKey: 'konversi',
                onExampleSelected: (val1, val2) {
                  setState(() {
                    input.text = val1;
                  });
                  _saveAllState();
                },
              ),

              SizedBox(height: 20),

              // Form Input Modern
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
                child: TextField(
                  controller: input,
                  style: TextStyle(fontSize: 18, letterSpacing: 1.2, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: "Nilai Input",
                    hintText: "Contoh: 255, 1010, FF, 192.168.1.1",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                    prefixIcon: Icon(Icons.input_rounded, color: primaryColor),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Kumpulan Tombol Operasi Konversi
              _sectionHeader("Sistem Angka", Icons.numbers),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionBtn("Dec → Bin", decToBin),
                  _actionBtn("Dec → Hex", decToHex),
                  _actionBtn("Bin → Dec", binToDec),
                  _actionBtn("Hex → Dec", hexToDec),
                  _actionBtn("Bin → Hex", binToHex),
                  _actionBtn("Hex → Bin", hexToBin),
                ],
              ),

              _sectionHeader("IP Address", Icons.router),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionBtn("IP → Biner", ipToBinary),
                  _actionBtn("Biner → IP", binaryToIp),
                ],
              ),

              _sectionHeader("Teks & ASCII", Icons.text_fields),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionBtn("Teks → ASCII", textToAscii),
                  _actionBtn("ASCII → Teks", asciiToText),
                  _actionBtn("Teks → Biner", textToBinary),
                  _actionBtn("Biner → Teks", binaryToText),
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