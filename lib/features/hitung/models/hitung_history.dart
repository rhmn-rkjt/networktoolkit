class HitungHistory {
  final String a;
  final String b;
  final String op;
  final String result;

  HitungHistory(this.a, this.b, this.op, this.result);

  @override
  String toString() => "$a $op $b = $result";
}