import 'dart:math';

/// Genera contraseñas aleatorias seguras para los usuarios que crea el
/// superuser. Garantiza al menos una minúscula, una mayúscula, un dígito y un
/// símbolo, evitando caracteres ambiguos (O/0, l/1, etc.).
class PasswordGenerator {
  static const String _lower = 'abcdefghjkmnpqrstuvwxyz';
  static const String _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _digits = '23456789';
  static const String _symbols = '!@#\$%&*?';

  static String generate({int length = 14}) {
    final rnd = Random.secure();
    final all = _lower + _upper + _digits + _symbols;

    // Un carácter garantizado de cada grupo.
    final chars = <String>[
      _lower[rnd.nextInt(_lower.length)],
      _upper[rnd.nextInt(_upper.length)],
      _digits[rnd.nextInt(_digits.length)],
      _symbols[rnd.nextInt(_symbols.length)],
    ];

    // Resto hasta completar la longitud.
    for (var i = chars.length; i < length; i++) {
      chars.add(all[rnd.nextInt(all.length)]);
    }

    // Mezclar para que los garantizados no queden siempre al inicio.
    chars.shuffle(rnd);
    return chars.join();
  }
}
