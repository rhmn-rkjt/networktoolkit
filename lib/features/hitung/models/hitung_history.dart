import 'dart:convert';

class HitungHistory {
  final String a;
  final String b;
  final String op;
  final String result;

  HitungHistory(this.a, this.b, this.op, this.result);

  @override
  String toString() => "$a $op $b = $result";

  // Mengubah objek menjadi Map/JSON sebelum disimpan
  Map<String, dynamic> toMap() {
    return {
      'a': a,
      'b': b,
      'op': op,
      'result': result,
    };
  }

  // Menyusun kembali objek dari Map/JSON saat dibaca dari memori
  factory HitungHistory.fromMap(Map<String, dynamic> map) {
    return HitungHistory(
      map['a'] ?? '',
      map['b'] ?? '',
      map['op'] ?? '',
      map['result'] ?? '',
    );
  }
}