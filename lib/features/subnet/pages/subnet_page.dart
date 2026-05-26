import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  final ipController   = TextEditingController();
  final newCidrController = TextEditingController();

  List<SubnetHistory> historyList = [];

  // ─── Deteksi kelas OTOMATIS dari IP ────────────────────────────────────────
  // Kelas IP adalah properti intrinsik dari nilai oktet pertama.
  // User TIDAK boleh memilih kelas secara manual karena akan membuka celah
  // kombinasi IP + kelas yang salah (misal 192.168.0.0 + Class A → OOM crash).
  //
  // Classful ranges (RFC 791):
  //   Class A : oktet pertama   1 – 126   → baseCIDR /8
  //   Class B : oktet pertama 128 – 191   → baseCIDR /16
  //   Class C : oktet pertama 192 – 223   → baseCIDR /24
  //   Class D : 224 – 239  (multicast, tidak untuk subnetting)
  //   Class E : 240 – 255  (reserved, tidak untuk subnetting)
  //   127.x.x.x = loopback, bukan host address
  //   0.x.x.x   = network "this", tidak valid sebagai host
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
      default:  return -1; // IP tidak valid / tidak bisa di-subnet
    }
  }

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

  // ─── Bitwise helpers (unsigned 32-bit safe) ────────────────────────────────
  int _buildMask(int prefixLen) {
    if (prefixLen == 0)  return 0;
    if (prefixLen == 32) return 0xffffffff;
    return (0xffffffff << (32 - prefixLen)).toUnsigned(32);
  }

  int _broadcastFromNetwork(int networkInt, int prefixLen) {
    final inverseMask = (~_buildMask(prefixLen)).toUnsigned(32);
    return (networkInt | inverseMask).toUnsigned(32);
  }

  // ─── Validasi format IPv4 ──────────────────────────────────────────────────
  bool _isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  // ─── Validasi lengkap ──────────────────────────────────────────────────────
  String validateInputs() {
    final ip      = ipController.text.trim();
    final cidrStr = newCidrController.text.trim();

    if (ip.isEmpty) return "⚠️ IP Address kosong";

    if (!_isValidIP(ip)) {
      return "❌ Format IP tidak valid (contoh: 10.0.0.0)";
    }

    // Validasi kelas terdeteksi — Class D, E, loopback, reserved tidak bisa
    // di-subnet karena tidak memiliki baseCIDR yang terdefinisi.
    final cls = detectedClass;
    if (cls == "loopback") return "❌ 127.x.x.x adalah alamat loopback, tidak bisa di-subnet";
    if (cls == "reserved") return "❌ 0.x.x.x adalah alamat reserved, tidak bisa di-subnet";
    if (cls == "D") return "❌ Class D (224–239) adalah alamat multicast, tidak bisa di-subnet";
    if (cls == "E") return "❌ Class E (240–255) adalah alamat reserved, tidak bisa di-subnet";
    if (cls == "-") return "❌ IP Address tidak valid";

    if (cidrStr.isEmpty) return "⚠️ CIDR Target kosong";

    final cidr = int.tryParse(cidrStr);
    if (cidr == null) return "❌ CIDR harus berupa angka";

    if (cidr == 31 || cidr == 32) {
      return "❌ CIDR /31 dan /32 tidak didukung (0 atau negatif usable host)";
    }

    if (cidr < 4 || cidr > 30) return "❌ CIDR harus antara 4–30";

    if (cidr <= baseCIDR) {
      return "❌ CIDR target harus lebih besar dari /$baseCIDR (Class $cls)";
    }

    // Cegah OOM: hitung jumlah subnet sebelum kalkulasi dimulai.
    final subnetCount = 1 << (cidr - baseCIDR);
    if (subnetCount > _kMaxSubnetCount) {
      return "❌ Kombinasi ini menghasilkan $subnetCount subnet — terlalu besar "
          "(maks $_kMaxSubnetCount). Gunakan CIDR target yang lebih kecil.";
    }

    return "";
  }

  // ─── HITUNG SUBNET ─────────────────────────────────────────────────────────
  void calculate() {
    final err = validateInputs();
    if (err.isNotEmpty) {
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
  }

  // ─── TABEL SUBNET (lazy render) ────────────────────────────────────────────
  Widget subnetTable() {
    if (network == "-") return const SizedBox();

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(t, style: header ? headerStyle : cellStyle),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (truncated)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "⚠️ Menampilkan $_kMaxTableRows dari $subnetCount subnet. "
              "Export PDF untuk melihat semua.",
              style: TextStyle(color: Colors.orange[800], fontSize: 12),
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalW,
            child: Column(children: [
              Container(
                color: Colors.grey[200],
                child: Row(children: [
                  cell("Network/$newCidr", colNet,  header: true),
                  cell("First Host",       colHost, header: true),
                  cell("Last Host",        colHost, header: true),
                  cell("Broadcast",        colHost, header: true),
                  cell("Host",             colN,    header: true),
                ]),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: renderCount,
                itemBuilder: (_, i) {
                  final netInt   = (baseNetworkInt + i * subnetSize).toUnsigned(32);
                  final broadInt = _broadcastFromNetwork(netInt, newCidr);
                  return Container(
                    color: i.isOdd ? Colors.grey[50] : null,
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
      ],
    );
  }

  // ─── EXPORT PDF ────────────────────────────────────────────────────────────
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

  // ─── Widget info kelas (menggantikan ChoiceChip selector) ─────────────────
  Widget _classInfoBadge() {
    final ip  = ipController.text.trim();
    final cls = detectedClass;

    if (ip.isEmpty || cls == "-") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline, size: 18, color: Colors.grey),
          SizedBox(width: 8),
          Text("Kelas IP akan terdeteksi otomatis setelah IP diisi",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ]),
      );
    }

    // Warna badge per kelas
    final Map<String, Color> bgColor = {
      "A": Colors.blue[50]!,
      "B": Colors.green[50]!,
      "C": Colors.purple[50]!,
    };
    final Map<String, Color> borderColor = {
      "A": Colors.blue[300]!,
      "B": Colors.green[300]!,
      "C": Colors.purple[300]!,
    };
    final Map<String, Color> textColor = {
      "A": Colors.blue[800]!,
      "B": Colors.green[800]!,
      "C": Colors.purple[800]!,
    };
    final Map<String, String> rangeInfo = {
      "A": "Oktet pertama 1–126 · baseCIDR /8",
      "B": "Oktet pertama 128–191 · baseCIDR /16",
      "C": "Oktet pertama 192–223 · baseCIDR /24",
    };

    // Kelas tidak bisa di-subnet (D, E, loopback, reserved)
    if (!["A", "B", "C"].contains(cls)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.red),
          const SizedBox(width: 8),
          Text("Class $cls — tidak dapat di-subnet",
              style: TextStyle(color: Colors.red[800], fontSize: 13)),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor[cls],
        border: Border.all(color: borderColor[cls]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(Icons.check_circle, size: 18, color: borderColor[cls]),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Class $cls terdeteksi",
              style: TextStyle(
                  color: textColor[cls],
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text(rangeInfo[cls]!,
              style: TextStyle(color: textColor[cls], fontSize: 11)),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subnetting Calculator"),
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
                onSelect: (h) => setState(() {
                  ipController.text      = h.ip;
                  newCidrController.text = h.targetCidr.toString();
                  network                = h.network;
                  broadcast              = h.broadcast;
                  classfullFirstHost     = h.firstHost;
                  classfullLastHost      = h.lastHost;
                  jumlahSubnet           = h.jumlahSubnet;
                  jumlahHostStep         = h.hostPerSubnet;
                  blokSubnet             = h.blokSubnet;
                }),
              ),
            )),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          ExampleSection(
            tutorialKey: 'subnet',
            onExampleSelected: (val1, val2) => setState(() {
              ipController.text = val1;
              if (val2 != null) newCidrController.text = val2;
            }),
          ),

          const SizedBox(height: 16),

          // IP Address Input
          Tooltip(
            message: 'Kelas akan terdeteksi otomatis dari IP yang dimasukkan',
            child: TextField(
              controller: ipController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: "IP Address",
                helperText: 'Contoh: 10.0.0.0 · 172.16.0.0 · 192.168.1.0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.router),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Badge kelas otomatis (menggantikan ChoiceChip)
          _classInfoBadge(),

          const SizedBox(height: 10),

          // CIDR Target
          Tooltip(
            message: 'CIDR target harus lebih besar dari baseCIDR kelas terdeteksi',
            child: TextField(
              controller: newCidrController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: "CIDR Target",
                helperText: baseCIDR > 0
                    ? 'Harus > /$baseCIDR (Class $detectedClass), maks /30'
                    : 'Isi IP terlebih dahulu',
                prefixText: "/",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.schema),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Validation Status
          Builder(builder: (ctx) {
            final v = validateInputs();
            if (v.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text("✓ Semua input valid",
                      style: TextStyle(color: Colors.green[800],
                          fontWeight: FontWeight.w500))),
                ]),
              );
            }
            final isErr = v.startsWith("❌");
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isErr ? Colors.red[50] : Colors.orange[50],
                border: Border.all(
                    color: isErr ? Colors.red[400]! : Colors.orange[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(isErr ? Icons.error : Icons.warning,
                    color: isErr ? Colors.red : Colors.orange, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(v,
                    style: TextStyle(
                        color: isErr ? Colors.red[800] : Colors.orange[800],
                        fontWeight: FontWeight.w500,
                        fontSize: 13))),
              ]),
            );
          }),

          const SizedBox(height: 20),

          ElevatedButton(onPressed: calculate, child: const Text("Hitung")),

          const SizedBox(height: 20),

          Text("Jumlah Subnet : $jumlahSubnet"),
          Text("Host/Subnet   : $jumlahHostStep"),
          Text("Blok Subnet   : $blokSubnet"),

          const Divider(),

          if (baseCIDR > 0) ...[
            Text("Network (/$baseCIDR)        : $network"),
            Text("Broadcast               : $broadcast"),
            Text("Host Range (/$baseCIDR)  : $classfullFirstHost – $classfullLastHost"),
            Text("Total Host (/$baseCIDR)  : $totalHost"),
          ],

          const SizedBox(height: 20),

          subnetTable(),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: exportPDF,
            icon: const Icon(Icons.download),
            label: const Text("Download PDF"),
          ),
        ]),
      ),
    );
  }
}