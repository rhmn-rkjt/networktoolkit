import 'package:flutter/material.dart';
import 'dart:io';

import 'hitung/pages/hitung_page.dart';
import 'konversi/pages/konversi_page.dart';
import 'subnet/pages/subnet_page.dart';

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
  void exitApp() {
    exit(0);
  }

  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Network Toolkit"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  menuCard(context, "Hitung", Icons.calculate, HitungPage()),
                  menuCard(context, "Konversi", Icons.swap_horiz, KonversiPage()),
                  menuCard(context, "Subnetting", Icons.network_check, SubnetPage()),
                ],
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