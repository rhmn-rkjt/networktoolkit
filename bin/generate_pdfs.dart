import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  print('🔄 Generating PDF files...');

  // Generate Hitung PDF
  await generatePDF(
    'HITUNG - Binary Calculator',
    '''HITUNG adalah tool untuk melakukan operasi pada bilangan biner.

FITUR UTAMA:
• Operasi Aritmatika (+, -, ×, ÷)
• Operasi Logika (AND, OR, XOR, NOT)
• Operasi Shift (Left Shift, Right Shift)
• Operasi Advanced (Negasi, Absolute, Bit Count)

MENGAPA PENTING:
• Developer: Debug binary operations
• Network Engineer: Calculate IP masks
• System Admin: File permissions, memory addresses
• Security: Protocol analysis

--- TEORI DASAR BILANGAN BINER ---

SISTEM BILANGAN BINER (BASIS 2):
Hanya menggunakan 2 digit: 0 dan 1

POSISI BIT DAN NILAINYA:
Position: 7 6 5 4 3 2 1 0
Value: 128 64 32 16 8 4 2 1

CONTOH: 10101010
= 1×128 + 0×64 + 1×32 + 0×16 + 1×8 + 0×4 + 1×2 + 0×1
= 128 + 32 + 8 + 2 = 170 (desimal)

--- OPERASI ARITMATIKA ---

PENJUMLAHAN (ADD):
Aturan Dasar:
0 + 0 = 0
0 + 1 = 1
1 + 0 = 1
1 + 1 = 10 (carry)
1 + 1 + 1 = 11

Contoh: 5 + 3 = 8
0101 (5) + 0011 (3) = 1000 (8)

PENGURANGAN (SUB):
Aturan Dasar:
0 - 0 = 0
1 - 0 = 1
1 - 1 = 0
0 - 1 = 1 (borrow)

Contoh: 8 - 3 = 5
1000 (8) - 0011 (3) = 0101 (5)

PERKALIAN (MUL):
Aturan Dasar:
0 × 0 = 0, 0 × 1 = 0, 1 × 0 = 0, 1 × 1 = 1

Contoh: 5 × 3 = 15
0101 × 0011 = 1111

PEMBAGIAN (DIV):
Contoh: 15 ÷ 3 = 5
1111 (15) ÷ 0011 (3) = 0101 (5)

--- OPERASI LOGIKA ---

AND (Bitwise AND):
Truth Table:
0 AND 0 = 0
0 AND 1 = 0
1 AND 0 = 0
1 AND 1 = 1

Contoh: 12 AND 10 = 8
1100 (12) & 1010 (10) = 1000 (8)

OR (Bitwise OR):
Truth Table:
0 OR 0 = 0
0 OR 1 = 1
1 OR 0 = 1
1 OR 1 = 1

Contoh: 12 OR 10 = 14
1100 (12) | 1010 (10) = 1110 (14)

XOR (Bitwise XOR):
Truth Table:
0 XOR 0 = 0
0 XOR 1 = 1
1 XOR 0 = 1
1 XOR 1 = 0

Contoh: 12 XOR 10 = 6
1100 (12) ^ 1010 (10) = 0110 (6)

NOT (Bitwise NOT):
Contoh:
Input: 01010101
NOT: 10101010

Input: 11111111 (255)
NOT: 00000000 (0)

--- OPERASI SHIFT ---

LEFT SHIFT (<<):
Efek: Mengalikan dengan 2^n

Contoh: 5 << 2 = 20
00000101 (5) → 00010100 (20 = 5 × 4)

RIGHT SHIFT (>>):
Efek: Membagi dengan 2^n

Contoh: 8 >> 2 = 2
00001000 (8) → 00000010 (2 = 8 ÷ 4)

--- CARA MENGGUNAKAN ---

LANGKAH 1: Buka Menu Hitung
Dari Home Screen → Tap kartu "Hitung"

LANGKAH 2: Input Bilangan
Tap field pertama
Masukkan bilangan (format: desimal atau biner)
Contoh: 12 atau 1100

LANGKAH 3: Pilih Operasi
Tap tombol operasi yang diinginkan

LANGKAH 4: Input Operand (jika ada)
Beberapa operasi butuh 2 angka
Tap field kedua

LANGKAH 5: Lihat Hasil
Hasil instant ditampilkan
Format: Desimal | Biner | Hex''',
    'Hitung_Panduan.pdf',
  );

  // Generate Konversi PDF
  await generatePDF(
    'KONVERSI - Number System Converter',
    '''KONVERSI adalah tool untuk mengkonversi bilangan antara berbagai sistem.

FITUR UTAMA:
• Konversi Desimal ↔ Biner
• Konversi Desimal ↔ Hexadecimal
• Konversi Desimal ↔ Oktal
• Format output berbagai basis

MENGAPA PENTING:
• Programmer: Memahami representasi data
• Network: IP addressing (hex/desimal)
• Embedded Systems: Hardware programming
• Security: Data analysis

--- SISTEM BILANGAN ---

DESIMAL (Basis 10):
Menggunakan digit 0-9
Contoh: 255, 1024, 65535

BINER (Basis 2):
Menggunakan digit 0-1
Contoh: 11111111, 10000000000, 1111111111111111

HEXADECIMAL (Basis 16):
Menggunakan digit 0-9 dan A-F (A=10, B=11, ..., F=15)
Contoh: FF, 400, FFFF

OKTAL (Basis 8):
Menggunakan digit 0-7
Contoh: 377, 2000, 177777

--- KONVERSI DESIMAL KE BINER ---

METODE: Bagi dengan 2 (sisa dicatat)

Contoh: 13 ke Biner
13 ÷ 2 = 6 sisa 1
6 ÷ 2 = 3 sisa 0
3 ÷ 2 = 1 sisa 1
1 ÷ 2 = 0 sisa 1

Baca dari bawah ke atas: 1101
Verifikasi: 1×8 + 1×4 + 0×2 + 1×1 = 13 ✓

--- KONVERSI BINER KE DESIMAL ---

METODE: Kalikan setiap bit dengan 2^posisi

Contoh: 1101 ke Desimal
1×2³ + 1×2² + 0×2¹ + 1×2⁰
= 1×8 + 1×4 + 0×2 + 1×1
= 8 + 4 + 0 + 1 = 13 ✓

--- KONVERSI DESIMAL KE HEX ---

METODE: Bagi dengan 16 (sisa dicatat)

Contoh: 255 ke Hex
255 ÷ 16 = 15 sisa 15 (F)
15 ÷ 16 = 0 sisa 15 (F)

Baca dari bawah ke atas: FF
Verifikasi: 15×16 + 15×1 = 240 + 15 = 255 ✓

--- KONVERSI HEX KE DESIMAL ---

METODE: Kalikan setiap digit dengan 16^posisi

Contoh: FF ke Desimal
F×16¹ + F×16⁰
= 15×16 + 15×1
= 240 + 15 = 255 ✓

--- TABEL REFERENSI KONVERSI ---

Desimal | Biner     | Hex
--------|-----------|------
0       | 00000000  | 00
1       | 00000001  | 01
10      | 00001010  | 0A
15      | 00001111  | 0F
16      | 00010000  | 10
255     | 11111111  | FF
256     | 100000000 | 100

--- CARA MENGGUNAKAN ---

LANGKAH 1: Buka Menu Konversi
Dari Home Screen → Tap kartu "Konversi"

LANGKAH 2: Input Bilangan
Tap input field
Masukkan angka (contoh: 255)

LANGKAH 3: Pilih Format Input
Select basis sumber (Desimal/Biner/Hex/Oktal)

LANGKAH 4: Pilih Format Output
Select basis tujuan

LANGKAH 5: Lihat Hasil
Hasil konversi ditampilkan otomatis

TIPS:
• Gunakan 0x prefix untuk hex (contoh: 0xFF)
• Gunakan 0b prefix untuk biner (contoh: 0b11111111)
• Maksimum input: 64-bit integer''',
    'Konversi_Panduan.pdf',
  );

  // Generate Subnet PDF
  await generatePDF(
    'SUBNET - IPv4 Subnetting Calculator',
    '''SUBNET adalah tool untuk menghitung subnet mask dan alokasi IP address.

FITUR UTAMA:
• Hitung subnet dari IP dan CIDR
• Tentukan network/broadcast address
• Hitung host range dan usable hosts
• Dukungan Class A/B/C
• CIDR notation (/8 hingga /32)

MENGAPA PENTING:
• Network Engineer: Network planning
• System Admin: IP allocation
• IT Support: Troubleshooting
• Cybersecurity: Network segmentation

--- KONSEP IPv4 DASAR ---

IPv4 ADDRESS FORMAT:
4 oktet (8-bit) dipisahkan titik
Contoh: 192.168.1.1

Range nilai: 0-255 setiap oktet
Total: 256 × 256 × 256 × 256 = 4.294.967.296 addresses

--- STRUKTUR IPv4 ADDRESS ---

IP Address dibagi 2 bagian:
1. Network Portion: Mengidentifikasi network
2. Host Portion: Mengidentifikasi host dalam network

Contoh: 192.168.1.0/24
Network: 192.168.1 (24 bits)
Host: 0-255 (8 bits)

--- SUBNET MASK ---

Subnet Mask menentukan network/host boundary

CIDR Notation: /[Network Bits]
Contoh: /24 artinya 24 bits untuk network

Konversi ke Dotted Decimal:
/8  = 255.0.0.0
/16 = 255.255.0.0
/24 = 255.255.255.0
/30 = 255.255.255.252

--- IPv4 CLASSES ---

CLASS A:
First bit: 0
Range: 1.0.0.0 - 126.255.255.255
Subnet Mask: 255.0.0.0 (/8)
Networks: 126
Hosts per network: 16,777,214

CLASS B:
First bits: 10
Range: 128.0.0.0 - 191.255.255.255
Subnet Mask: 255.255.0.0 (/16)
Networks: 16,384
Hosts per network: 65,534

CLASS C:
First bits: 110
Range: 192.0.0.0 - 223.255.255.255
Subnet Mask: 255.255.255.0 (/24)
Networks: 2,097,152
Hosts per network: 254

--- CIDR REFERENCE TABLE ---

CIDR | Hosts      | Usable Hosts | Netmask
-----|------------|--------------|------------------
/8   | 16,777,216 | 16,777,214   | 255.0.0.0
/16  | 65,536     | 65,534       | 255.255.0.0
/24  | 256        | 254          | 255.255.255.0
/25  | 128        | 126          | 255.255.255.128
/26  | 64         | 62           | 255.255.255.192
/27  | 32         | 30           | 255.255.255.224
/28  | 16         | 14           | 255.255.255.240
/29  | 8          | 6            | 255.255.255.248
/30  | 4          | 2            | 255.255.255.252
/31  | 2          | 0            | 255.255.255.254
/32  | 1          | 1            | 255.255.255.255

--- CARA MENGHITUNG SUBNET ---

LANGKAH 1: Tentukan Host Bits
Host Bits = 32 - CIDR
Contoh: /24 → 32 - 24 = 8 bits

LANGKAH 2: Hitung Total Hosts
Total Hosts = 2^(Host Bits)
Contoh: 2^8 = 256 hosts

LANGKAH 3: Hitung Usable Hosts
Usable Hosts = 2^(Host Bits) - 2
Contoh: 256 - 2 = 254 hosts
(dikurangi network dan broadcast address)

LANGKAH 4: Tentukan Network Address
Network Address = IP dengan semua host bits = 0
Contoh: 192.168.1.50/24 → 192.168.1.0

LANGKAH 5: Tentukan Broadcast Address
Broadcast = Network + (2^Host Bits - 1)
Contoh: 192.168.1.0/24 → 192.168.1.255

LANGKAH 6: Tentukan Host Range
First Host = Network Address + 1
Last Host = Broadcast Address - 1
Contoh: 192.168.1.1 - 192.168.1.254

--- CONTOH SOAL ---

Soal: Hitung subnet untuk 172.16.50.0/22

Jawab:
Host Bits = 32 - 22 = 10 bits
Total Hosts = 2^10 = 1024
Usable Hosts = 1024 - 2 = 1022
Subnet Mask = 255.255.252.0

Network Address = 172.16.48.0
Broadcast Address = 172.16.51.255
First Host = 172.16.48.1
Last Host = 172.16.51.254

--- CARA MENGGUNAKAN TOOL ---

LANGKAH 1: Buka Menu Subnet
Dari Home Screen → Tap kartu "Subnetting"

LANGKAH 2: Input IP Address
Format: A.B.C.D
Contoh: 192.168.1.0

LANGKAH 3: Pilih CIDR / Class
Option A: Select Class (A/B/C)
Option B: Input Custom CIDR (8-32)

LANGKAH 4: Tap Calculate
Hasil subnet ditampilkan

LANGKAH 5: Review Results
Network Address
Broadcast Address
First Host
Last Host
Usable Hosts
Subnet Mask
CIDR

LANGKAH 6: Optional - Copy Results
Tap tombol Copy untuk menyimpan ke history

--- VALIDASI INPUT ---

IP Address harus:
• 4 oktet terpisah titik
• Setiap oktet: 0-255
• Format: A.B.C.D

CIDR harus:
• Angka 8-32
• /31 dan /32: khusus P2P dan single host

PERINGATAN UMUM:
⚠️ /31: Host bits = 1 (khusus Point-to-Point)
⚠️ /32: Host bits = 0 (single IP address, tidak ada host)''',
    'Subnet_Panduan.pdf',
  );

  print('✅ PDF generation complete!');
  print('📍 Files saved to: assets/pdf/');
}

Future<void> generatePDF(String title, String content, String filename) async {
  final pdf = pw.Document();

  // Split content into paragraphs
  final paragraphs = content.split('\n').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(20),
      build: (context) {
        return [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          ...paragraphs.map((para) {
            return pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                para,
                style: pw.TextStyle(fontSize: 9, height: 1.4),
                textAlign: pw.TextAlign.left,
              ),
            );
          }).toList(),
        ];
      },
    ),
  );

  final file = File('assets/pdf/$filename');
  await file.writeAsBytes(await pdf.save());
  print('✓ Generated: $filename');
}
