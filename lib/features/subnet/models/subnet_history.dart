class SubnetHistory {
  final String ip;
  final String classType;
  final int baseCidr;
  final int targetCidr;

  final String network;
  final String broadcast;
  final String firstHost;
  final String lastHost;

  final int jumlahSubnet;
  final int hostPerSubnet;
  final int blokSubnet;

  SubnetHistory({
    required this.ip,
    required this.classType,
    required this.baseCidr,
    required this.targetCidr,
    required this.network,
    required this.broadcast,
    required this.firstHost,
    required this.lastHost,
    required this.jumlahSubnet,
    required this.hostPerSubnet,
    required this.blokSubnet,
  });

  @override
  String toString() {
    return "$ip ($classType) → /$targetCidr | Subnet: $jumlahSubnet";
  }

  // Mengubah objek menjadi Map (JSON) sebelum disimpan ke memori HP
  Map<String, dynamic> toMap() {
    return {
      'ip': ip,
      'classType': classType,
      'baseCidr': baseCidr,
      'targetCidr': targetCidr,
      'network': network,
      'broadcast': broadcast,
      'firstHost': firstHost,
      'lastHost': lastHost,
      'jumlahSubnet': jumlahSubnet,
      'hostPerSubnet': hostPerSubnet,
      'blokSubnet': blokSubnet,
    };
  }

  // Menyusun kembali objek dari Map (JSON) saat dibaca dari memori HP
  factory SubnetHistory.fromMap(Map<String, dynamic> map) {
    return SubnetHistory(
      ip: map['ip'] ?? '',
      classType: map['classType'] ?? '',
      // Gunakan fallback 0 untuk integer agar terhindar dari null safety error
      baseCidr: map['baseCidr'] ?? 0, 
      targetCidr: map['targetCidr'] ?? 0,
      network: map['network'] ?? '',
      broadcast: map['broadcast'] ?? '',
      firstHost: map['firstHost'] ?? '',
      lastHost: map['lastHost'] ?? '',
      jumlahSubnet: map['jumlahSubnet'] ?? 0,
      hostPerSubnet: map['hostPerSubnet'] ?? 0,
      blokSubnet: map['blokSubnet'] ?? 0,
    );
  }
}