import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated
        ? authState.user
        : authState is AuthAuthenticatedAwaitingBiometricChoice
            ? authState.user
            : null;

    return BlocProvider<DashboardBloc>(
      create: (_) {
        final bloc = GetIt.I<DashboardBloc>();
        if (user != null) bloc.add(LoadDashboardRequested(user));
        return bloc;
      },
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  // 0 = Mi equipo, 1 = General
  int _vista = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DASHBOARD')),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DashboardError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error)),
                ),
              );
            }
            final loaded = state as DashboardLoaded;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _Toggle(
                    vista: _vista,
                    onChanged: (v) => setState(() => _vista = v),
                  ),
                ),
                Expanded(
                  child: _vista == 0
                      ? _TeamDashboard(equipos: loaded.misEquipos)
                      : _GeneralDashboard(general: loaded.general),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final int vista;
  final ValueChanged<int> onChanged;

  const _Toggle({required this.vista, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleButton(
          label: 'MI EQUIPO',
          selected: vista == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 8),
        _ToggleButton(
          label: 'GENERAL',
          selected: vista == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.glowCyan(0.15)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primaryAccent : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  selected ? AppColors.primaryAccent : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== Vista "Mi equipo" ====================

class _TeamDashboard extends StatelessWidget {
  final List<TeamView> equipos;

  const _TeamDashboard({required this.equipos});

  @override
  Widget build(BuildContext context) {
    if (equipos.isEmpty) {
      return const _Empty(
          mensaje: 'No perteneces a ningún equipo (subsistema) todavía.');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final eq in equipos) _TeamSection(equipo: eq),
      ],
    );
  }
}

class _TeamSection extends StatelessWidget {
  final TeamView equipo;

  const _TeamSection({required this.equipo});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(equipo.subsistema.toUpperCase(), style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          '${equipo.integrantes.length} integrantes · '
          '${equipo.totalCumplidas} cumplidas · '
          '${equipo.totalAtrasadas} atrasadas',
          style: textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        if (equipo.integrantes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Sin integrantes registrados.',
                style: TextStyle(color: AppColors.textSecondary)),
          )
        else
          for (final m in equipo.integrantes) _MemberCard(member: m),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final MemberStats member;

  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final rendimiento = member.rendimiento;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        borderColor: member.esLider ? AppColors.success : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    member.nombre,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (member.esLider)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('LÍDER',
                        style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _stat('Cumplidas', member.cumplidas, AppColors.success),
                _stat('Atrasadas', member.atrasadas, AppColors.error),
                _stat('Pendientes', member.pendientes,
                    AppColors.secondaryAccent),
              ],
            ),
            const SizedBox(height: 10),
            _RendimientoBar(valor: rendimiento),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _RendimientoBar extends StatelessWidget {
  final double? valor; // 0..1 o null

  const _RendimientoBar({required this.valor});

  @override
  Widget build(BuildContext context) {
    final v = valor;
    final label = v == null ? 'Sin datos' : '${(v * 100).round()}%';
    final color = v == null
        ? AppColors.textSecondary
        : v >= 0.75
            ? AppColors.success
            : v >= 0.4
                ? AppColors.secondaryAccent
                : AppColors.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('RENDIMIENTO',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 1)),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: v ?? 0,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ==================== Vista "General" ====================

class _GeneralDashboard extends StatelessWidget {
  final List<SubsistemaAgg> general;

  const _GeneralDashboard({required this.general});

  @override
  Widget build(BuildContext context) {
    if (general.isEmpty) {
      return const _Empty(mensaje: 'No hay equipos para mostrar.');
    }
    final textTheme = Theme.of(context).textTheme;
    // Promedios globales.
    final avancePromedio =
        general.fold<double>(0, (s, a) => s + a.avance) / general.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SizedBox(height: 4),
        Text('PROMEDIO GLOBAL', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        AppCard(
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Avance promedio entre equipos',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text('${(avancePromedio * 100).round()}%',
                  style: textTheme.displayMedium
                      ?.copyWith(color: AppColors.primaryAccent)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('POR EQUIPO', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final agg in general) _AggCard(agg: agg),
      ],
    );
  }
}

class _AggCard extends StatelessWidget {
  final SubsistemaAgg agg;

  const _AggCard({required this.agg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(agg.subsistema.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 1)),
                Text('${agg.integrantes} integrantes',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _metric('Avance', '${(agg.avance * 100).round()}%',
                    AppColors.primaryAccent),
                _metric('Cumpl./pers.',
                    agg.promedioCumplidas.toStringAsFixed(1),
                    AppColors.success),
                _metric('% Atrasadas',
                    '${(agg.porcentajeAtrasadas * 100).round()}%',
                    AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 9)),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String mensaje;

  const _Empty({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
