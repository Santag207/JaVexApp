import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/task.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => GetIt.I<HomeBloc>()..add(const LoadHomeDataRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryAccent,
          onRefresh: () async {
            context.read<HomeBloc>().add(const LoadHomeDataRequested());
            await context
                .read<HomeBloc>()
                .stream
                .firstWhere((s) => s is! HomeLoading);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  final tasks = state is HomeLoaded ? state.tasks : <Task>[];
                  final members =
                      state is HomeLoaded ? state.activeMembers : <Member>[];
                  final loading = state is HomeLoading || state is HomeInitial;
                  final error = state is HomeError ? state.message : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bienvenido de vuelta',
                        style: textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ).fadeInUp(),
                      const SizedBox(height: 24),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glowCyan(0.25),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset('assets/logo.png', height: 180),
                        ),
                      ).fadeInUp(delay: const Duration(milliseconds: 120)),
                      const SizedBox(height: 24),
                      AppCard(
                        glow: true,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        child: Column(
                          children: [
                            Text('TAREAS PENDIENTES',
                                style: textTheme.labelMedium),
                            const SizedBox(height: 8),
                            loading
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: CircularProgressIndicator(),
                                  )
                                : Text(
                                    '${tasks.length}',
                                    style:
                                        textTheme.displayLarge?.copyWith(
                                      color: AppColors.primaryAccent,
                                      fontSize: 48,
                                    ),
                                  ),
                          ],
                        ),
                      ).fadeInUp(delay: const Duration(milliseconds: 200)),
                      const SizedBox(height: 24),
                      Text(
                        'MIEMBROS EN EL LABORATORIO',
                        style: textTheme.titleLarge,
                      ).fadeInUp(delay: const Duration(milliseconds: 280)),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _membersList(
                          loading: loading,
                          error: error,
                          members: members,
                          textTheme: textTheme,
                        ),
                      ).fadeInUp(delay: const Duration(milliseconds: 360)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _membersList({
    required bool loading,
    required String? error,
    required List<Member> members,
    required TextTheme textTheme,
  }) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '// $error',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (members.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '// Sin miembros activos por ahora.',
          style: textTheme.bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.border, height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          title: Text(members[index].nombre, style: textTheme.bodyMedium),
        );
      },
    );
  }
}
