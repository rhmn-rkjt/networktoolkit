import 'package:flutter/material.dart';
import 'hitung/pages/hitung_page.dart';
import 'konversi/pages/konversi_page.dart';
import 'subnet/pages/subnet_page.dart';

class HomePage extends StatelessWidget {
  Widget menuCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Network Toolkit")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
          menuCard(context, "Hitung", Icons.calculate, HitungPage()),
          menuCard(context, "Konversi", Icons.swap_horiz, KonversiPage()),
          menuCard(context, "Subnetting", Icons.network_check, SubnetPage()),
        ],
      ),
    );
  }
}