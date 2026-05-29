import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';

class AddHoursScreen extends StatelessWidget {
  const AddHoursScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AGREGAR HORAS'),
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
                    Icons.access_time_filled,
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
                    'Aquí irá el registro de horas',
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
