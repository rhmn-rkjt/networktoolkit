import 'package:flutter/material.dart';
import 'dart:io';

import 'hitung/pages/hitung_page.dart';
import 'konversi/pages/konversi_page.dart';
import 'subnet/pages/subnet_page.dart';
import 'package:networktoolkit/shared/utils/pdf_utils.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Tampilan Header Welcome
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E2C), // Warna gelap ala terminal/tech
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.dashboard_customize, color: Colors.white70, size: 28),
              Icon(Icons.wifi_tethering, color: Colors.greenAccent, size: 28),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Network Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Pilih alat untuk memulai kalkulasi jaringan hari ini.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget menuCard(BuildContext context, String title, String subtitle, IconData icon, Widget page, Color accentColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: accentColor.withOpacity(0.1),
              offset: Offset(0, 8),
            )
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 32, color: accentColor),
            ),
            Spacer(),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilan kartu untuk membuka PDF panduan
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
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: color.withOpacity(0.4),
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  // =========================
  void exitApp() {
    exit(0);
  }

  void _showPanduanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Pilih Panduan', style: TextStyle(fontWeight: FontWeight.bold)),
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
              leading: Icon(Icons.swap_horiz, color: Colors.teal),
              title: Text('Panduan KONVERSI'),
              onTap: () {
                Navigator.pop(context);
                PDFUtils.openKonversiPDF();
              },
            ),
            ListTile(
              leading: Icon(Icons.network_check, color: Color(0xFFFF3C00)),
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
            child: Text('Tutup', style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background yang lebih bersih
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Text(
          "Network Toolkit",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, size: 24),
            tooltip: 'Buka Panduan Cepat',
            onPressed: () => _showPanduanDialog(context),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Dashboard
                    _buildHeader(),
                    SizedBox(height: 30),

                    // 2. Title Section
                    Text(
                      'ALAT JARINGAN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),

                    // 3. Tools Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1, // Membuat kotak sedikit lebih proporsional
                      children: [
                        menuCard(context, "Hitung", "Kalkulator biner", Icons.calculate_outlined, HitungPage(), Colors.blue),
                        menuCard(context, "Konversi", "Sistem angka & IP", Icons.swap_horiz_rounded, KonversiPage(), Colors.teal),
                        menuCard(context, "Subnetting", "Kalkulator IPv4", Icons.router_outlined, SubnetPage(), Color(0xFFFF3C00)),
                      ],
                    ),

                    SizedBox(height: 40),

                    // 4. Panduan Section
                    Row(
                      children: [
                        Icon(Icons.library_books, color: Colors.grey[600], size: 20),
                        SizedBox(width: 8),
                        Text(
                          'PUSTAKA PANDUAN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // 5. Daftar PDF
                    _tutorialBookCard(
                      context,
                      'Hitung - Binary',
                      'Teori dan praktik operasi bilangan biner.',
                      'Hitung_Panduan.pdf',
                      Colors.blue[700]!,
                    ),
                    _tutorialBookCard(
                      context,
                      'Konversi - Number',
                      'Panduan konversi basis angka dan ASCII.',
                      'Konversi_Panduan.pdf',
                      Colors.teal[700]!,
                    ),
                    _tutorialBookCard(
                      context,
                      'Subnet - IPv4',
                      'Konsep CIDR, Host, dan Network calculation.',
                      'Subnet_Panduan.pdf',
                      Color(0xFFFF3C00),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. Tombol Exit Elegan di Bawah
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.shade100),
                    ),
                    backgroundColor: Colors.red.shade50,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text("Keluar Aplikasi"),
                        content: Text("Apakah kamu yakin ingin menutup Network Toolkit?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Batal", style: TextStyle(color: Colors.grey[700])),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: exitApp,
                            child: Text("Keluar", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(Icons.power_settings_new, color: Colors.redAccent),
                  label: Text(
                    "Tutup Aplikasi",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}