import 'package:flutter/material.dart';
import 'dart:io';

import 'hitung/pages/hitung_page.dart';
import 'konversi/pages/konversi_page.dart';
import 'subnet/pages/subnet_page.dart';
import 'package:networktoolkit/shared/utils/pdf_utils.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // =========================
  Widget menuCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black12,
              offset: Offset(2, 2),
            )
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // =========================
  Widget _tutorialBookCard(
    BuildContext context,
    String title,
    String description,
    String pdfFileName,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        PDFUtils.openPDF(pdfFileName);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.7)],
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: color.withOpacity(0.3),
              offset: Offset(2, 4),
            )
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(Icons.menu_book, color: Colors.white70, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  void exitApp() {
    exit(0);
  }

  // =========================
  void _showPanduanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Panduan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.calculate, color: Colors.blue),
              title: Text('Panduan HITUNG'),
              onTap: () {
                Navigator.pop(context);
                PDFUtils.openHitungPDF();
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz, color: Colors.green),
              title: Text('Panduan KONVERSI'),
              onTap: () {
                Navigator.pop(context);
                PDFUtils.openKonversiPDF();
              },
            ),
            ListTile(
              leading: Icon(Icons.network_check, color: Colors.orange),
              title: Text('Panduan SUBNETTING'),
              onTap: () {
                Navigator.pop(context);
                PDFUtils.openSubnetPDF();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Network Toolkit"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, size: 24),
            tooltip: 'Buka Panduan',
            onPressed: () {
              _showPanduanDialog(context);
            },
          ),
          SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section 1
                    Text(
                      'TOOLS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    SizedBox(height: 12),

                    // Tools Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        menuCard(context, "🧮 Hitung", Icons.calculate, HitungPage()),
                        menuCard(context, "🔄 Konversi", Icons.swap_horiz, KonversiPage()),
                        menuCard(context, "🌐 Subnetting", Icons.network_check, SubnetPage()),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Title Section 2
                    Text(
                      'PANDUAN LENGKAP (PDF)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Baca panduan lengkap untuk setiap menu seperti membuka buku atau PDF',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Tutorial Books Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 1,
                      mainAxisSpacing: 12,
                      children: [
                        _tutorialBookCard(
                          context,
                          '📖 HITUNG - Binary Calculator',
                          'Panduan lengkap tentang operasi bilangan biner dengan teori, praktik, dan use cases',
                          'Hitung_Panduan.pdf',
                          Colors.blue[600]!,
                        ),
                        _tutorialBookCard(
                          context,
                          '📖 KONVERSI - Number Converter',
                          'Panduan konversi basis bilangan, IP address, dan text/ASCII dengan tabel referensi',
                          'Konversi_Panduan.pdf',
                          Colors.green[600]!,
                        ),
                        _tutorialBookCard(
                          context,
                          '📖 SUBNET - IPv4 Calculator',
                          'Panduan lengkap subnetting, CIDR notation, dan network calculation dengan skenario nyata',
                          'Subnet_Panduan.pdf',
                          Colors.orange[600]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tombol Exit
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Keluar Aplikasi"),
                    content: Text("Apakah kamu yakin ingin keluar?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Batal"),
                      ),
                      ElevatedButton(
                        onPressed: exitApp,
                        child: Text("Keluar"),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.exit_to_app),
              label: Text("Exit"),
            ),
          )
        ],
      ),
    );
  }
}