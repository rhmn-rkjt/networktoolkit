import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/ip_calculator.dart';
import '../../../shared/history_page.dart';
import '../../../shared/widgets/example_section.dart';
import '../../../shared/utils/pdf_utils.dart';
import '../models/subnet_history.dart';

const int _kMaxSubnetCount = 65536;
const int _kMaxTableRows   = 512;

class SubnetPage extends StatefulWidget {
  @override
  State<SubnetPage> createState() => _SubnetPageState();
}

class _SubnetPageState extends State<SubnetPage> {
  final ipController = TextEditingController();
  final newCidrController = TextEditingController();

  List<SubnetHistory> historyList = [];

  // Ringkasan hasil network classfull utama.
  String network            = "-";
  String broadcast          = "-";
  String classfullFirstHost = "-";
  String classfullLastHost  = "-";
  String totalHost          = "-";

  // Statistik subnet hasil pembagian.
  int jumlahSubnet   = 0;
  int jumlahHostStep = 0;
  int blokSubnet     = 0;

  // Flag untuk track apakah sudah dihitung
  bool _isCalculated = false;

  // Warna tema khusus untuk halaman Subnetting (Deep Orange)
  final Color primaryColor = const Color(0xFFFF3C00);

  @override
  void initState() {
    super.initState();
    _loadAllState(); // Muat data riwayat dan status layar dari memori HP
  }

  // Local storage dengan SharedPreferences 
  Future<void> _loadAllState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load History
      final savedHistory = prefs.getStringList('subnet_history');
      List<SubnetHistory> loadedHistory = [];
      
      if (savedHistory != null && savedHistory.isNotEmpty) {
        for (String item in savedHistory) {
          try {
            final Map<String, dynamic> parsedMap = Map<String, dynamic>.from(json.decode(item));
            loadedHistory.add(SubnetHistory.fromMap(parsedMap));
          } catch (e) {
            debugPrint("Mengabaikan data history subnet yang rusak: $e");
          }
        }
      }

      // 2. Load Status Layar Terakhir
      final savedIp = prefs.getString('subnet_last_ip');
      final savedCidr = prefs.getString('subnet_last_cidr');
      final savedIsCalculated = prefs.getBool('subnet_is_calculated') ?? false;

      if (mounted) {
        setState(() {
          historyList = loadedHistory;
          if (savedIp != null) ipController.text = savedIp;
          if (savedCidr != null) newCidrController.text = savedCidr;
          _isCalculated = savedIsCalculated;

          // Jika sebelumnya layar menampilkan hasil hitung, kembalikan angkanya
          if (_isCalculated) {
            network = prefs.getString('subnet_network') ?? "-";
            broadcast = prefs.getString('subnet_broadcast') ?? "-";
            classfullFirstHost = prefs.getString('subnet_first_host') ?? "-";
            classfullLastHost = prefs.getString('subnet_last_host') ?? "-";
            totalHost = prefs.getString('subnet_total_host') ?? "-";
            jumlahSubnet = prefs.getInt('subnet_jumlah_subnet') ?? 0;
            jumlahHostStep = prefs.getInt('subnet_host_step') ?? 0;
            blokSubnet = prefs.getInt('subnet_blok') ?? 0;
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat data subnet dari SharedPreferences: $e");
    }

    // Aktifkan auto-save ketikan secara real-time
    ipController.addListener(_saveCurrentInputOnly);
    newCidrController.addListener(_saveCurrentInputOnly);
  }

  Future<void> _saveAllState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<String> historyStr = historyList.map((e) => json.encode(e.toMap())).toList();
      await prefs.setStringList('subnet_history', historyStr);

      await prefs.setString('subnet_last_ip', ipController.text);
      await prefs.setString('subnet_last_cidr', newCidrController.text);
      await prefs.setBool('subnet_is_calculated', _isCalculated);

      if (_isCalculated) {
        await prefs.setString('subnet_network', network);
        await prefs.setString('subnet_broadcast', broadcast);
        await prefs.setString('subnet_first_host', classfullFirstHost);
        await prefs.setString('subnet_last_host', classfullLastHost);
        await prefs.setString('subnet_total_host', totalHost);
        await prefs.setInt('subnet_jumlah_subnet', jumlahSubnet);
        await prefs.setInt('subnet_host_step', jumlahHostStep);
        await prefs.setInt('subnet_blok', blokSubnet);
      }
    } catch (e) {
      debugPrint("Gagal menyimpan data subnet: $e");
    }
  }

  void _saveCurrentInputOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('subnet_last_ip', ipController.text);
      await prefs.setString('subnet_last_cidr', newCidrController.text);
    } catch (_) {}
  }

  @override
  void dispose() {
    ipController.removeListener(_saveCurrentInputOnly);
    newCidrController.removeListener(_saveCurrentInputOnly);
    ipController.dispose();
    newCidrController.dispose();
    super.dispose();
  }

  // ================= LOGIKA SUBNETTING & VALIDASI =================

  String get detectedClass {
    final ip = ipController.text.trim();
    if (!_isValidIP(ip)) return "-";
    final first = int.tryParse(ip.split('.').first) ?? -1;
    if (first >= 1   && first <= 126) return "A";
    if (first >= 128 && first <= 191) return "B";
    if (first >= 192 && first <= 223) return "C";
    if (first == 127) return "loopback";
    if (first == 0)   return "reserved";
    if (first >= 224 && first <= 239) return "D";
    if (first >= 240) return "E";
    return "-";
  }

  int get baseCIDR {
    switch (detectedClass) {
      case "A": return 8;
      case "B": return 16;
      case "C": return 24;
      default:  return -1;
    }
  }

  int _buildMask(int prefixLen) {
    if (prefixLen == 0)  return 0;
    if (prefixLen == 32) return 0xffffffff;
    return (0xffffffff << (32 - prefixLen)).toUnsigned(32);
  }

  int _broadcastFromNetwork(int networkInt, int prefixLen) {
    final inverseMask = (~_buildMask(prefixLen)).toUnsigned(32);
    return (networkInt | inverseMask).toUnsigned(32);
  }

  bool _isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  String validateInputs() {
    final ip      = ipController.text.trim();
    final cidrStr = newCidrController.text.trim();

    if (ip.isEmpty) return "⚠️ IP Address kosong";
    if (!_isValidIP(ip)) return "❌ Format IP tidak valid (contoh: 10.0.0.0)";

    final cls = detectedClass;
    if (cls == "loopback") return "❌ 127.x.x.x adalah alamat loopback, tidak bisa di-subnet";
    if (cls == "reserved") return "❌ 0.x.x.x adalah alamat reserved, tidak bisa di-subnet";
    if (cls == "D") return "❌ Class D (224–239) adalah alamat multicast, tidak bisa di-subnet";
    if (cls == "E") return "❌ Class E (240–255) adalah alamat reserved, tidak bisa di-subnet";
    if (cls == "-") return "❌ IP Address tidak valid";

    if (cidrStr.isEmpty) return "⚠️ CIDR Target kosong";

    final cidr = int.tryParse(cidrStr);
    if (cidr == null) return "❌ CIDR harus berupa angka";
    if (cidr == 31 || cidr == 32) return "❌ CIDR /31 dan /32 tidak didukung (0 atau negatif usable host)";
    if (cidr < 4 || cidr > 30) return "❌ CIDR harus antara 4–30";
    if (cidr < baseCIDR) return "❌ CIDR target harus >= /$baseCIDR (Class $cls)";

    final subnetCount = 1 << (cidr - baseCIDR);
    if (subnetCount > _kMaxSubnetCount) {
      return "❌ Kombinasi ini menghasilkan $subnetCount subnet — terlalu besar "
          "(maks $_kMaxSubnetCount). Gunakan CIDR target yang lebih kecil.";
    }

    return "";
  }

  void calculate() {
    final err = validateInputs();
    if (err.isNotEmpty) {
      setState(() {
        _isCalculated = false;
        _saveAllState(); // Simpan state bahwa perhitungan dibatalkan
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err),
        duration: const Duration(seconds: 4),
        backgroundColor: err.startsWith("❌") ? Colors.red : Colors.orange,
      ));
      return;
    }

    final ip      = ipController.text.trim();
    final cidr    = baseCIDR;
    final newCidr = int.parse(newCidrController.text.trim());

    final ipInt          = IPCalculator.ipToInt(ip);
    final mask           = _buildMask(cidr);
    final baseNetworkInt = (ipInt & mask).toUnsigned(32);
    final broadcastInt   = _broadcastFromNetwork(baseNetworkInt, cidr);
    final subnetSize     = 1 << (32 - newCidr);

    setState(() {
      _isCalculated  = true;
      jumlahSubnet   = 1 << (newCidr - cidr);
      jumlahHostStep = subnetSize - 2;
      blokSubnet     = subnetSize;

      network            = IPCalculator.intToIp(baseNetworkInt);
      broadcast          = IPCalculator.intToIp(broadcastInt);
      classfullFirstHost = IPCalculator.intToIp(baseNetworkInt + 1);
      classfullLastHost  = IPCalculator.intToIp(broadcastInt - 1);
      totalHost          = ((1 << (32 - cidr)) - 2).toString();
    });

    historyList.insert(0, SubnetHistory(
      ip:            ip,
      classType:     detectedClass,
      baseCidr:      cidr,
      targetCidr:    newCidr,
      network:       network,
      broadcast:     broadcast,
      firstHost:     classfullFirstHost,
      lastHost:      classfullLastHost,
      jumlahSubnet:  jumlahSubnet,
      hostPerSubnet: jumlahHostStep,
      blokSubnet:    blokSubnet,
    ));

    _saveAllState(); // Langsung tulis hasil kalkulasi ke memori HP
  }

  // ================= UI WIDGETS & BANTUAN =================

  // Header untuk section
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 20),
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

  // Ui widget untuk menampilkan tabel subnetting
  Widget subnetTable() {
    if (!_isCalculated || network == "-") return const SizedBox();

    final newCidr = int.tryParse(newCidrController.text.trim());
    if (newCidr == null) return const SizedBox();

    final cidr           = baseCIDR;
    final ipInt          = IPCalculator.ipToInt(ipController.text.trim());
    final mask           = _buildMask(cidr);
    final baseNetworkInt = (ipInt & mask).toUnsigned(32);
    final subnetCount    = 1 << (newCidr - cidr);
    final subnetSize     = 1 << (32 - newCidr);

    final renderCount = subnetCount > _kMaxTableRows ? _kMaxTableRows : subnetCount;
    final truncated   = subnetCount > _kMaxTableRows;

    const colNet  = 165.0;
    const colHost = 130.0;
    const colN    = 80.0;
    const totalW  = colNet + colHost + colHost + colHost + colN;

    final headerStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    final cellStyle   = const TextStyle(fontSize: 12);

    Widget cell(String t, double w, {bool header = false}) => SizedBox(
      width: w,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Text(t, style: header ? headerStyle : cellStyle),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (truncated)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Menampilkan $_kMaxTableRows dari $subnetCount subnet. Download PDF untuk daftar lengkap.",
                    style: TextStyle(color: Colors.orange[800], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalW,
              child: Column(children: [
                Container(
                  color: Colors.grey[100],
                  child: Row(children: [
                    cell("Network/$newCidr", colNet,  header: true),
                    cell("First Host",       colHost, header: true),
                    cell("Last Host",        colHost, header: true),
                    cell("Broadcast",        colHost, header: true),
                    cell("Host",             colN,    header: true),
                  ]),
                ),
                const Divider(height: 1, color: Colors.grey),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: renderCount,
                  itemBuilder: (_, i) {
                    final netInt   = (baseNetworkInt + i * subnetSize).toUnsigned(32);
                    final broadInt = _broadcastFromNetwork(netInt, newCidr);
                    return Container(
                      color: i.isOdd ? Colors.grey[50] : Colors.white,
                      child: Row(children: [
                        cell(IPCalculator.intToIp(netInt),       colNet),
                        cell(IPCalculator.intToIp(netInt + 1),   colHost),
                        cell(IPCalculator.intToIp(broadInt - 1), colHost),
                        cell(IPCalculator.intToIp(broadInt),     colHost),
                        cell((subnetSize - 2).toString(),        colN),
                      ]),
                    );
                  },
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> exportPDF() async {
    if (network == "-") return;
    final newCidr = int.tryParse(newCidrController.text.trim());
    if (newCidr == null) return;

    final pdf            = pw.Document();
    final cidr           = baseCIDR;
    final ipInt          = IPCalculator.ipToInt(ipController.text.trim());
    final mask           = _buildMask(cidr);
    final baseNetworkInt = (ipInt & mask).toUnsigned(32);
    final subnetCount    = 1 << (newCidr - cidr);
    final subnetSize     = 1 << (32 - newCidr);

    final data = <List<String>>[];
    for (int i = 0; i < subnetCount; i++) {
      final netInt   = (baseNetworkInt + i * subnetSize).toUnsigned(32);
      final broadInt = _broadcastFromNetwork(netInt, newCidr);
      data.add([
        "${IPCalculator.intToIp(netInt)}/$newCidr",
        IPCalculator.intToIp(netInt + 1),
        IPCalculator.intToIp(broadInt - 1),
        IPCalculator.intToIp(broadInt),
        (subnetSize - 2).toString(),
      ]);
    }

    pdf.addPage(pw.MultiPage(build: (ctx) => [
      pw.Text("Subnetting Report",
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      pw.Text("IP         : ${ipController.text}"),
      pw.Text("Class      : $detectedClass  (/$cidr → /$newCidr)"),
      pw.Text("Subnet     : $jumlahSubnet"),
      pw.Text("Host/Subnet: $jumlahHostStep"),
      pw.Text("Blok       : $blokSubnet"),
      pw.SizedBox(height: 16),
      pw.Table.fromTextArray(
        headers: ["Network/$newCidr", "First Host", "Last Host", "Broadcast", "Host"],
        data: data,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellPadding: const pw.EdgeInsets.all(4),
      ),
    ]));

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Widget _classInfoBadge() {
    final ip  = ipController.text.trim();
    final cls = detectedClass;

    if (ip.isEmpty || cls == "-") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline, size: 20, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Text("Kelas IP akan terdeteksi otomatis setelah IP diisi",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ]),
      );
    }

    final Map<String, Color> bgColor = {
      "A": Colors.blue[50]!, "B": Colors.green[50]!, "C": Colors.purple[50]!,
    };
    final Map<String, Color> borderColor = {
      "A": Colors.blue[300]!, "B": Colors.green[300]!, "C": Colors.purple[300]!,
    };
    final Map<String, Color> textColor = {
      "A": Colors.blue[800]!, "B": Colors.green[800]!, "C": Colors.purple[800]!,
    };
    final Map<String, String> rangeInfo = {
      "A": "Oktet pertama 1–126 · baseCIDR /8",
      "B": "Oktet pertama 128–191 · baseCIDR /16",
      "C": "Oktet pertama 192–223 · baseCIDR /24",
    };

    if (!["A", "B", "C"].contains(cls)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, size: 20, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text("Class $cls — tidak dapat di-subnet",
                style: TextStyle(color: Colors.red[800], fontSize: 13)),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor[cls],
        border: Border.all(color: borderColor[cls]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.check_circle, size: 22, color: borderColor[cls]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Class $cls terdeteksi",
                style: TextStyle(
                    color: textColor[cls],
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            Text(rangeInfo[cls]!,
                style: TextStyle(color: textColor[cls], fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  // Widget Dashboard Hasil Utama
  Widget _buildResultDashboard() {
    if (!_isCalculated || network == "-") return const SizedBox();

    Widget statBox(String label, String value, {bool isLarge = false}) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 11)),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isLarge ? 18 : 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E2C), // Panel Modern Gelap
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub, color: primaryColor, size: 24),
              SizedBox(width: 10),
              Text(
                "Network Overview",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          statBox("NETWORK ADDRESS (/$baseCIDR)", network, isLarge: true),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: statBox("BROADCAST", broadcast)),
              SizedBox(width: 10),
              Expanded(child: statBox("TOTAL HOST", totalHost)),
            ],
          ),
          SizedBox(height: 10),
          statBox("HOST RANGE", "$classfullFirstHost  —  $classfullLastHost"),
          
          Divider(color: Colors.white24, height: 30),

          Text(
            "Detail Subnetting (/${newCidrController.text})",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: statBox("SUBNETS", "$jumlahSubnet", isLarge: true)),
              SizedBox(width: 10),
              Expanded(child: statBox("HOSTS/SUB", "$jumlahHostStep", isLarge: true)),
              SizedBox(width: 10),
              Expanded(child: statBox("BLOCK", "$blokSubnet", isLarge: true)),
            ],
          ),
        ],
      ),
    );
  }

  // ================= BINA ANTARMUKA =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background terang bersih
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        title: const Text(
          "Kalkulator Subnetting",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: PDFUtils.openSubnetPDF,
            tooltip: 'Buka Panduan',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => HistoryPage(
                history: historyList,
                title: "History Subnet",
                onSelect: (h) {
                  setState(() {
                    ipController.text      = h.ip;
                    newCidrController.text = h.targetCidr.toString();
                    network                = h.network;
                    broadcast              = h.broadcast;
                    classfullFirstHost     = h.firstHost;
                    classfullLastHost      = h.lastHost;
                    jumlahSubnet           = h.jumlahSubnet;
                    jumlahHostStep         = h.hostPerSubnet;
                    blokSubnet             = h.blokSubnet;
                    _isCalculated          = true; // Flag diaktifkan saat restore data
                  });
                  _saveAllState(); // Amankan state terbaru setelah memilih history
                },
              ),
            )),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Kartu Hasil Kalkulasi (Jika sudah dihitung, letakkan di paling atas)
              if (_isCalculated) ...[
                _buildResultDashboard(),
                const SizedBox(height: 24),
              ],

              ExampleSection(
                tutorialKey: 'subnet',
                onExampleSelected: (val1, val2) {
                  setState(() {
                    ipController.text = val1;
                    if (val2 != null) newCidrController.text = val2;
                  });
                  _saveAllState();
                },
              ),

              const SizedBox(height: 20),

              // Formulir Input Modern
              _sectionHeader("Konfigurasi Network", Icons.settings_ethernet),
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
                      controller: ipController,
                      style: TextStyle(fontSize: 18, letterSpacing: 1.2, fontWeight: FontWeight.w500),
                      onChanged: (_) {
                        setState(() => _isCalculated = false);
                        _saveAllState();
                      },
                      decoration: InputDecoration(
                        labelText: "IP Address",
                        hintText: "192.168.1.0",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(Icons.router, color: primaryColor),
                      ),
                    ),
                    
                    const Divider(height: 1, color: Colors.black12),
                    
                    TextField(
                      controller: newCidrController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18, letterSpacing: 1.2, fontWeight: FontWeight.w500),
                      onChanged: (_) {
                        setState(() => _isCalculated = false);
                        _saveAllState();
                      },
                      decoration: InputDecoration(
                        labelText: "CIDR Target (Prefix)",
                        hintText: baseCIDR > 0 ? "Min. $baseCIDR, Max. 30" : "Isi IP dulu",
                        prefixText: "/",
                        prefixStyle: TextStyle(fontSize: 18, color: Colors.black87),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Icon(Icons.schema, color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _classInfoBadge(),
              const SizedBox(height: 12),

              Builder(builder: (ctx) {
                final v = validateInputs();
                if (v.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text("Semua parameter input valid",
                          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600))),
                    ]),
                  );
                }
                final isErr = v.startsWith("❌");
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isErr ? Colors.red[50] : Colors.orange[50],
                    border: Border.all(color: isErr ? Colors.red[400]! : Colors.orange[400]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(isErr ? Icons.error : Icons.warning,
                        color: isErr ? Colors.red : Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(v,
                        style: TextStyle(
                            color: isErr ? Colors.red[800] : Colors.orange[800],
                            fontWeight: FontWeight.w500,
                            fontSize: 13))),
                  ]),
                );
              }),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: primaryColor.withOpacity(0.5),
                  ),
                  child: const Text("HITUNG SUBNET", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
                ),
              ),

              if (_isCalculated) ...[
                _sectionHeader("Tabel Subnet", Icons.table_chart),
                subnetTable(),
                
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: exportPDF,
                    icon: Icon(Icons.picture_as_pdf, color: primaryColor),
                    label: Text("Download Laporan PDF", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}