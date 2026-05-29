import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';

/// Pantalla de acceso por NFC al laboratorio físico.
/// Por ahora es un placeholder: la lectura/escritura NFC real se integrará
/// más adelante con el hardware del laboratorio.
class NfcScreen extends StatelessWidget {
  const NfcScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCESO NFC'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: AppCard(
              padding: const EdgeInsets.all(24),
              glow: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.contactless,
                    color: AppColors.primaryAccent,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '// MÓDULO EN CONSTRUCCIÓN',
                    style: textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aquí irá el acceso al laboratorio por NFC',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).fadeInUp(),
          ),
        ),
      ),
    );
  }
}
