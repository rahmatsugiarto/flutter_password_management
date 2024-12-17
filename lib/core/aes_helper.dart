import 'dart:convert';
import 'dart:developer';

import 'package:encrypt/encrypt.dart';

class AESHelper {
  static const length = 4;
  static final ivLength = (24 / length).ceil();
  static final keyLength = (24 / length).ceil();

  static String encrypt(String plainText) {
    try {
      var data = utf8.encode(plainText);
      final key = Key.fromSecureRandom(16);
      var iv = IV.fromSecureRandom(16);

      var encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      var encrypted = encrypter.encryptBytes(data, iv: iv);

      var encodedKey = base64.encode(key.bytes);
      var encodedIv = base64.encode(iv.bytes);
      var encodedCt = base64.encode(encrypted.bytes);

      var output = '';
      for (var i = length; i > 0; i--) {
        var iv0 = (encodedIv.length * (i - 1) / length).floor();
        var iv1 = (encodedIv.length * i / length).floor();
        var key0 = (encodedKey.length * (i - 1) / length).floor();
        var key1 = (encodedKey.length * i / length).floor();
        var ct0 = (encodedCt.length * (i - 1) / length).floor();
        var ct1 = (encodedCt.length * i / length).floor();
        output += encodedIv.substring(iv0, iv1) +
            encodedKey.substring(key0, key1) +
            encodedCt.substring(ct0, ct1);
      }

      log("encrypted: $output");
      return output;
    } catch (e) {
      return e.toString();
    }
  }

  static String decrypt(String encryptText) {
    try {
      var ivStr = '';
      var keyStr = '';
      var ctStr = '';
      var result = encryptText;

      for (var i = length; i > 0; i--) {
        var formIV = (result.length * (i - 1) / length).ceil();
        var formKey = (result.length * (i - 1) / length).ceil() + ivLength;
        var formCT1 =
            (result.length * (i - 1) / length).ceil() + ivLength + keyLength;
        var formCT2 = (result.length * i / length).ceil();

        ivStr += result.substring(formIV, formIV + ivLength);
        keyStr += result.substring(formKey, formKey + keyLength);
        ctStr += result.substring(formCT1, formCT2);
      }

      var key = base64.decode(keyStr.replaceAll(' ', '+'));
      var iv = base64.decode(ivStr.replaceAll(' ', '+'));
      var ct = base64.decode(ctStr.replaceAll(' ', '+'));
      var encrypter = Encrypter(
        AES(Key.fromBase64(base64.encode(key)), mode: AESMode.cbc),
      );

      var decrypted = encrypter.decrypt64(
        base64.encode(ct),
        iv: IV.fromBase64(base64.encode(iv)),
      );

      log("decrypted: $decrypted");
      return decrypted;
    } catch (e) {
      return e.toString();
    }
  }
}
