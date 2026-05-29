import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/entities/item.dart';
import '../qr_scanner/qr_scanner_screen.dart';
import 'bloc/inventory_bloc.dart';
import 'bloc/inventory_event.dart';
import 'bloc/inventory_state.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InventoryBloc>(
      create: (_) =>
          GetIt.I<InventoryBloc>()..add(const LoadInventoryRequested()),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  String _searchScanned = '';
  String _searchRegistered = '';
  bool _isViewingRegistered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            final loading =
                state is InventoryLoading || state is InventoryInitial;
            final error = state is InventoryError ? state.message : null;
            final scanned =
                state is InventoryLoaded ? state.scannedItems : <Item>[];
            final registered = state is InventoryLoaded
                ? state.registeredItems
                : <RegisteredItem>[];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text('INVENTARIO',
                      style: textTheme.displayMedium,
                      textAlign: TextAlign.center)
                      .fadeInUp(),
                  const SizedBox(height: 8),
                  Text('// Catálogo de recursos',
                      style: textTheme.labelMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Escaneado',
                          variant: !_isViewingRegistered
                              ? AppButtonVariant.primary
                              : AppButtonVariant.ghost,
                          glow: !_isViewingRegistered,
                          fullWidth: true,
                          onPressed: () =>
                              setState(() => _isViewingRegistered = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Registrado',
                          variant: _isViewingRegistered
                              ? AppButtonVariant.primary
                              : AppButtonVariant.ghost,
                          glow: _isViewingRegistered,
                          fullWidth: true,
                          onPressed: () =>
                              setState(() => _isViewingRegistered = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Filtrar por nombre',
                    hint: _isViewingRegistered
                        ? 'Buscar artículo registrado...'
                        : 'Buscar artículo escaneado...',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        if (_isViewingRegistered) {
                          _searchRegistered = value;
                        } else {
                          _searchScanned = value;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primaryAccent,
                      onRefresh: () async {
                        context
                            .read<InventoryBloc>()
                            .add(const LoadInventoryRequested());
                        await context
                            .read<InventoryBloc>()
                            .stream
                            .firstWhere((s) => s is! InventoryLoading);
                      },
                      child: _buildBody(
                        loading: loading,
                        error: error,
                        scanned: scanned,
                        registered: registered,
                        textTheme: textTheme,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: !_isViewingRegistered
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: AppColors.background,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const QRScannerScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                'ESCANEAR',
                style: TextStyle(
                    letterSpacing: 1.5, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildBody({
    required bool loading,
    required String? error,
    required List<Item> scanned,
    required List<RegisteredItem> registered,
    required TextTheme textTheme,
  }) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              '// $error',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (_isViewingRegistered) {
      final filtered = registered
          .where((i) => i.nombre
              .toLowerCase()
              .contains(_searchRegistered.toLowerCase()))
          .toList();
      if (filtered.isEmpty) {
        return _emptyState('// Sin artículos registrados', textTheme);
      }
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = filtered[index];
          return AppCard(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.bookmark_outline,
                    color: AppColors.primaryAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nombre,
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Responsable: ${item.apartadoPor}',
                          style: textTheme.labelMedium),
                      Text('Fecha: ${item.fecha}  •  Cant: ${item.cantidad}',
                          style: textTheme.labelMedium),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    final filtered = scanned
        .where((i) => i.nombre
            .toLowerCase()
            .contains(_searchScanned.toLowerCase()))
        .toList();
    if (filtered.isEmpty) {
      return _emptyState('// Sin artículos escaneados', textTheme);
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: AppColors.primaryAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nombre,
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Cantidad: ${item.cantidad}',
                        style: textTheme.labelMedium),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState(String message, TextTheme textTheme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(child: Text(message, style: textTheme.labelMedium)),
      ],
    );
  }
}
