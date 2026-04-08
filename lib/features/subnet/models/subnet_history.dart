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
    return "$ip (${classType}) → /$targetCidr | Subnet: $jumlahSubnet";
  }
}