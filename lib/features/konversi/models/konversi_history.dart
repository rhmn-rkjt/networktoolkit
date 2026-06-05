class KonversiHistory {
  final String input;
  final String result;

  KonversiHistory(this.input, this.result);

  @override
  String toString() => "$input → $result";

  // Mengubah objek menjadi format Map sebelum disimpan ke SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'input': input,
      'result': result,
    };
  }

  // Menyusun kembali dari Map menjadi objek saat dibaca dari SharedPreferences
  factory KonversiHistory.fromMap(Map<String, dynamic> map) {
    return KonversiHistory(
      map['input'] ?? '',
      map['result'] ?? '',
    );
  }
}