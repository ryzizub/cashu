import 'dart:convert';
import 'dart:typed_data';
import 'package:cashu/src/utils/extensions/point.dart';
import 'package:cashu/src/utils/hex.dart';
import 'package:pointycastle/export.dart';

final _secp256k1 = ECDomainParameters('secp256k1');

ECPoint hashToCurve(Uint8List secret) {
  ECPoint? point;
  while (point == null) {
    final hash = _sha256(secret);
    final hashHex = hexEncode(hash);
    final pointX = '02$hashHex';
    try {
      point = pointX.point;
    } catch (e) {
      secret = _sha256(secret);
    }
  }
  return point;
}

ECPoint hashHexToCurve(String secret) {
  return hashToCurve(hexDecode(secret));
}

ECPoint? getBlindingPoint(String secret, {String? blindingFactor}) {
  final y = hashToCurve(utf8.encode(secret));

  if (blindingFactor == null) {
    return y;
  }

  final rG = _secp256k1.G * BigInt.parse("0x$blindingFactor");

  final blinding = y + rG;

  return blinding;
}

// Utils

Uint8List _sha256(Uint8List data) {
  final digest = SHA256Digest();
  return Uint8List.fromList(digest.process(data));
}
