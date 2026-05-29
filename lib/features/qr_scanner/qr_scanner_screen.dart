import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESCANEAR QR'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glowCyan(0.3),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: AppColors.primaryAccent,
                    size: 120,
                  ),
                ).fadeInUp(),
                const SizedBox(height: 24),
                Text(
                  '// Apunta la cámara al código',
                  style: textTheme.labelMedium,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Simular escaneo',
                  icon: Icons.camera_alt_outlined,
                  glow: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulación: QR Escaneado'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
