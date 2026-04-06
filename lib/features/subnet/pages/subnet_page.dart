import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/ip_calculator.dart';

class SubnetPage extends StatefulWidget {
  @override
  State<SubnetPage> createState() => _SubnetPageState();
}

class _SubnetPageState extends State<SubnetPage> {
  final ipController = TextEditingController();
  final newCidrController = TextEditingController();

  String selectedClass = "C";

  int get baseCIDR {
    switch (selectedClass) {
      case "A":
        return 8;
      case "B":
        return 16;
      default:
        return 24;
    }
  }

  String network = "-";
  String broadcast = "-";
  String firstHost = "-";
  String lastHost = "-";
  String totalHost = "-";

  int jumlahSubnet = 0;
  int jumlahHostStep = 0;
  int blokSubnet = 0;

  // =========================
  bool isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    for (var p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  // =========================
  void calculate() {
    String ip = ipController.text;
    int cidr = baseCIDR;
    int newCidr = int.tryParse(newCidrController.text) ?? -1;

    if (!isValidIP(ip)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("IP tidak valid")));
      return;
    }

    if (newCidr <= cidr || newCidr > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CIDR target harus lebih besar dari class")),
      );
      return;
    }

    int ipInt = IPCalculator.ipToInt(ip);
    int mask = ((0xffffffff << (32 - cidr)) & 0xffffffff);

    int baseNetwork = (ipInt & mask) & 0xffffffff;
    int broad = (baseNetwork | (~mask)) & 0xffffffff;

    int subnetBits = newCidr - cidr;

    setState(() {
      jumlahSubnet = 1 << subnetBits;
      jumlahHostStep = (1 << (32 - newCidr)) - 2;
      blokSubnet = 1 << (32 - newCidr);

      network = IPCalculator.intToIp(baseNetwork);
      broadcast = IPCalculator.intToIp(broad);
      firstHost = IPCalculator.intToIp(baseNetwork + 1);
      lastHost = IPCalculator.intToIp(broad - 1);
      totalHost = ((1 << (32 - cidr)) - 2).toString();
    });
  }

  // =========================
  Widget subnetTable() {
    if (network == "-") return SizedBox();

    int cidr = baseCIDR;
    int newCidr = int.parse(newCidrController.text);

    int ipInt = IPCalculator.ipToInt(ipController.text);
    int mask = ((0xffffffff << (32 - cidr)) & 0xffffffff);
    int baseNetwork = (ipInt & mask) & 0xffffffff;

    int subnetCount = 1 << (newCidr - cidr);
    int subnetSize = 1 << (32 - newCidr);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Network")),
          DataColumn(label: Text("First")),
          DataColumn(label: Text("Last")),
          DataColumn(label: Text("Broadcast")),
          DataColumn(label: Text("Host")),
        ],
        rows: List.generate(subnetCount, (i) {
          int net = (baseNetwork + (i * subnetSize)) & 0xffffffff;
          int broad = (net + subnetSize - 1) & 0xffffffff;

          return DataRow(cells: [
            DataCell(Text(IPCalculator.intToIp(net))),
            DataCell(Text(IPCalculator.intToIp(net + 1))),
            DataCell(Text(IPCalculator.intToIp(broad - 1))),
            DataCell(Text(IPCalculator.intToIp(broad))),
            DataCell(Text((subnetSize - 2).toString())),
          ]);
        }),
      ),
    );
  }

  // =========================
  Future<void> exportPDF() async {
    if (network == "-") return;

    final pdf = pw.Document();

    int cidr = baseCIDR;
    int newCidr = int.parse(newCidrController.text);

    int ipInt = IPCalculator.ipToInt(ipController.text);
    int mask = ((0xffffffff << (32 - cidr)) & 0xffffffff);
    int baseNetwork = (ipInt & mask) & 0xffffffff;

    int subnetCount = 1 << (newCidr - cidr);
    int subnetSize = 1 << (32 - newCidr);

    List<List<String>> data = [];

    for (int i = 0; i < subnetCount; i++) {
      int net = (baseNetwork + (i * subnetSize)) & 0xffffffff;
      int broad = (net + subnetSize - 1) & 0xffffffff;

      data.add([
        IPCalculator.intToIp(net),
        IPCalculator.intToIp(net + 1),
        IPCalculator.intToIp(broad - 1),
        IPCalculator.intToIp(broad),
        (subnetSize - 2).toString(),
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("Subnetting Report"),
          pw.Text("IP: ${ipController.text}"),
          pw.Text("Class: $selectedClass (/ $cidr → /$newCidr)"),
          pw.Text("Subnet: $jumlahSubnet"),
          pw.Text("Host/Subnet: $jumlahHostStep"),
          pw.Text("Blok: $blokSubnet"),

          pw.SizedBox(height: 20),

          pw.Table.fromTextArray(
            headers: ["Network", "First", "Last", "Broadcast", "Host"],
            data: data,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // =========================
  Widget classSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ["A", "B", "C"].map((c) {
        return ChoiceChip(
          label: Text("Class $c"),
          selected: selectedClass == c,
          onSelected: (_) {
            setState(() => selectedClass = c);
          },
        );
      }).toList(),
    );
  }

  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subnetting Calculator")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: "IP Address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            classSelector(),

            SizedBox(height: 10),

            TextField(
              controller: newCidrController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "CIDR Target",
                prefixText: "/",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: calculate,
              child: Text("Hitung"),
            ),

            SizedBox(height: 20),

            Text("Jumlah Subnet : $jumlahSubnet"),
            Text("Host/Subnet   : $jumlahHostStep"),
            Text("Blok Subnet   : $blokSubnet"),

            Divider(),

            Text("Network       : $network"),
            Text("Broadcast     : $broadcast"),
            Text("Host Range    : $firstHost - $lastHost"),
            Text("Total Host    : $totalHost"),

            SizedBox(height: 20),

            subnetTable(),

            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: exportPDF,
              icon: Icon(Icons.download),
              label: Text("Download PDF"),
            ),
          ],
        ),
      ),
    );
  }
}