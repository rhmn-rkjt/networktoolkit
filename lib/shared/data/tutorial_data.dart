class TutorialGuide {
  final String title;
  final String description;
  final String icon;
  final List<String> steps;
  final List<Example> examples;
  final List<Tip> tips;

  const TutorialGuide({
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
    required this.examples,
    required this.tips,
  });
}

class Example {
  final String title;
  final String description;
  final String value1;
  final String? value2;
  final String result;

  const Example({
    required this.title,
    required this.description,
    required this.value1,
    this.value2,
    required this.result,
  });
}

class Tip {
  final String title;
  final String content;
  final IconType type;

  const Tip({
    required this.title,
    required this.content,
    required this.type,
  });
}

enum IconType { info, warning, success, idea }

class TutorialData {
  static const Map<String, TutorialGuide> guides = {
    'hitung': TutorialGuide(
      title: '🧮 Panduan Hitung Biner',
      description: 'Lakukan operasi matematika dengan bilangan biner (basis 2)',
      icon: '🧮',
      steps: [
        '1️⃣ Masukkan bilangan biner pertama (hanya gunakan angka 0 dan 1)',
        '2️⃣ Masukkan bilangan biner kedua',
        '3️⃣ Pilih jenis operasi: Aritmatika (+, -, *, /), Logika (AND, OR, XOR), atau Bitwise',
        '4️⃣ Tekan tombol operasi untuk melihat hasil dalam format biner',
        '5️⃣ Hasil otomatis tersimpan di history untuk referensi',
      ],
      examples: [
        Example(
          title: 'Penjumlahan Biner',
          description: 'Menambahkan dua bilangan biner',
          value1: '101',
          value2: '011',
          result: '1000 (Desimal: 5 + 3 = 8)',
        ),
        Example(
          title: 'AND Logika',
          description: 'Operasi AND bit per bit',
          value1: '1010',
          value2: '1100',
          result: '1000',
        ),
        Example(
          title: 'OR Logika',
          description: 'Operasi OR bit per bit',
          value1: '1010',
          value2: '0101',
          result: '1111',
        ),
        Example(
          title: 'XOR Logika',
          description: 'Operasi XOR (exclusive or)',
          value1: '1100',
          value2: '1010',
          result: '0110',
        ),
      ],
      tips: [
        Tip(
          title: '💡 Biner Itu Dasar 2',
          content: 'Hanya ada 2 digit: 0 dan 1. Setiap digit bernilai 2^n',
          type: IconType.idea,
        ),
        Tip(
          title: '⚠️ Format Input',
          content: 'Jangan gunakan spasi atau karakter lain. Hanya 0 dan 1',
          type: IconType.warning,
        ),
        Tip(
          title: '✅ Konversi Cepat',
          content: 'Gunakan menu "Konversi" untuk ubah Desimal ke Biner atau sebaliknya',
          type: IconType.success,
        ),
      ],
    ),
    'konversi': TutorialGuide(
      title: '🔄 Panduan Konversi',
      description: 'Konversi antar basis bilangan: Desimal, Biner, Heksadesimal & IP Address',
      icon: '🔄',
      steps: [
        '1️⃣ Masukkan nilai yang ingin dikonversi',
        '2️⃣ Pilih tipe konversi dari kategori yang tersedia:',
        '   • Basis Bilangan: Dec ↔ Bin, Dec ↔ Hex, Bin ↔ Hex',
        '   • IP Address: IP ↔ Biner (berguna untuk subnetting)',
        '   • Text/ASCII: Teks ↔ ASCII ↔ Biner',
        '3️⃣ Hasil ditampilkan secara instant',
        '4️⃣ Gunakan history untuk melihat konversi sebelumnya',
      ],
      examples: [
        Example(
          title: 'Desimal ke Biner',
          description: 'Konversi angka desimal ke format biner',
          value1: '255',
          result: '11111111',
        ),
        Example(
          title: 'Desimal ke Heksadesimal',
          description: 'Konversi ke basis 16 (0-9, A-F)',
          value1: '255',
          result: 'FF',
        ),
        Example(
          title: 'IP ke Biner',
          description: 'Konversi alamat IP ke format biner 32-bit',
          value1: '192.168.1.1',
          result: '11000000.10101000.00000001.00000001',
        ),
        Example(
          title: 'Teks ke ASCII',
          description: 'Konversi teks menjadi kode ASCII',
          value1: 'Hi',
          result: '72 105',
        ),
      ],
      tips: [
        Tip(
          title: '📊 Tabel Konversi Umum',
          content: 'Desimal 10 = Biner 1010 = Heks A | Desimal 16 = Biner 10000 = Heks 10',
          type: IconType.info,
        ),
        Tip(
          title: '🌐 IP Addresses',
          content: 'Setiap oktet IP (0-255) = 8 bit biner. Contoh: 192 = 11000000',
          type: IconType.idea,
        ),
        Tip(
          title: '✅ Heksadesimal',
          content: 'Gunakan A=10, B=11, C=12, D=13, E=14, F=15 di basis 16',
          type: IconType.success,
        ),
      ],
    ),
    'subnet': TutorialGuide(
      title: '🌐 Panduan Subnetting',
      description: 'Pelajari cara membagi jaringan IP menjadi subnet-subnet lebih kecil',
      icon: '🌐',
      steps: [
        '1️⃣ Pilih Kelas IP (A/B/C) sesuai dengan range alamat Anda:',
        '   • Kelas A: 1.0.0.0 - 126.255.255.255 (CIDR /8)',
        '   • Kelas B: 128.0.0.0 - 191.255.255.255 (CIDR /16)',
        '   • Kelas C: 192.0.0.0 - 223.255.255.255 (CIDR /24)',
        '2️⃣ Masukkan IP address contoh dari kelas yang dipilih',
        '3️⃣ Masukkan CIDR target yang lebih besar dari CIDR dasar',
        '4️⃣ Sistem akan hitung:',
        '   • Network address & Broadcast address',
        '   • Host pertama & Host terakhir',
        '   • Jumlah subnet & Host per subnet',
        '5️⃣ Lihat tabel detail semua subnet yang dihasilkan',
      ],
      examples: [
        Example(
          title: 'Subnet Kelas C Standar',
          description: 'Membagi network /24 menjadi /25 (2 subnet)',
          value1: '192.168.1.0',
          value2: '25',
          result: 'Network: 192.168.1.0 | Broadcast: 192.168.1.127 | Hosts: 126',
        ),
        Example(
          title: 'VLSM Kelas B',
          description: 'Membagi network /16 menjadi /26 (64 subnet)',
          value1: '172.16.0.0',
          value2: '26',
          result: '64 subnet dengan 62 host per subnet',
        ),
        Example(
          title: 'Enterprise Network',
          description: 'Kelas A dengan subnetting /30 untuk link point-to-point',
          value1: '10.0.0.0',
          value2: '30',
          result: 'Banyak subnet kecil, ideal untuk WAN links',
        ),
      ],
      tips: [
        Tip(
          title: '📐 CIDR Notation',
          content: '/24 berarti 24 bit untuk network, 8 bit untuk host = 256 alamat total',
          type: IconType.info,
        ),
        Tip(
          title: '⚠️ CIDR Target',
          content: 'CIDR target HARUS lebih besar dari CIDR dasar kelas. /24 → /25 atau lebih',
          type: IconType.warning,
        ),
        Tip(
          title: '🎯 Rumus Host',
          content: 'Jumlah Host = 2^(32 - CIDR) - 2 (minus 2 untuk network & broadcast)',
          type: IconType.idea,
        ),
        Tip(
          title: '✅ Tabel Subnet',
          content: 'Scroll tabel untuk lihat detail setiap subnet hasil pembagian',
          type: IconType.success,
        ),
      ],
    ),
  };

  // Daftar untuk first time user
  static const Map<String, String> firstTimeMessages = {
    'hitung': '👋 Selamat datang! Menu ini digunakan untuk menghitung operasi bilangan biner. Tekan ? untuk panduan lengkap!',
    'konversi': '👋 Ubah antar basis bilangan dengan mudah! Dari Desimal, Biner, Heksadesimal, hingga IP Address.',
    'subnet': '👋 Pelajari subnetting IP dengan visualisasi lengkap. Pilih kelas IP dan CIDR target untuk mulai!',
  };
}
