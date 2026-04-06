class IPCalculator {
  // =========================
  // CONVERT
  // =========================
  static int ipToInt(String ip) {
    var p = ip.split('.').map(int.parse).toList();
    return (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
  }

  static String intToIp(int val) {
    return [
      (val >> 24) & 255,
      (val >> 16) & 255,
      (val >> 8) & 255,
      val & 255
    ].join('.');
  }

  static String toBinary(String ip) {
    return ip
        .split('.')
        .map((e) => int.parse(e).toRadixString(2).padLeft(8, '0'))
        .join('.');
  }

  // =========================
  // MAIN CALCULATION
  // =========================
  static Map<String, dynamic> calculate(String ip, int cidr) {
    int ipInt = ipToInt(ip);

    int mask = ((0xffffffff << (32 - cidr)) & 0xffffffff);

    int network = ipInt & mask;
    int broadcast = (network | (~mask)) & 0xffffffff;

    return {
      "network": intToIp(network),
      "broadcast": intToIp(broadcast),
      "firstHost": intToIp(network + 1),
      "lastHost": intToIp(broadcast - 1),
      "totalHost": (1 << (32 - cidr)) - 2,
      "netmask": intToIp(mask),
      "wildcard": intToIp((~mask) & 0xffffffff),
      "binaryIP": toBinary(ip),
      "binaryMask": toBinary(intToIp(mask)),
    };
  }

  // =========================
  // SUBNET TABLE
  // =========================
  static List<Map<String, String>> generateSubnets(
      String ip, int cidr, int newCidr) {
    int ipInt = ipToInt(ip);

    int mask = ((0xffffffff << (32 - cidr)) & 0xffffffff);
    int baseNetwork = ipInt & mask;

    int subnetCount = 1 << (newCidr - cidr);
    int subnetSize = 1 << (32 - newCidr);

    List<Map<String, String>> result = [];

    for (int i = 0; i < subnetCount; i++) {
      int net = (baseNetwork + (i * subnetSize)) & 0xffffffff;
      int broad = (net + subnetSize - 1) & 0xffffffff;

      result.add({
        "network": intToIp(net),
        "first": intToIp(net + 1),
        "last": intToIp(broad - 1),
        "broadcast": intToIp(broad),
        "host": (subnetSize - 2).toString(),
      });
    }

    return result;
  }
}