import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../domain/repositories/task_repository.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({Key? key}) : super(key: key);

  @override
  _PendingScreenState createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  final TaskRepository _taskRepository = GetIt.I<TaskRepository>();

  Map<String, List<Map<String, dynamic>>> tareasPorSubsistema = {};
  String? _nombreUsuario;
  String? _errorMessage;
  bool _isLoading = true;

  String subsistemaSeleccionado = 'Logística';
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _nombreUsuario = '${authState.user.nombre} ${authState.user.apellidos}';
    } else if (authState is AuthAuthenticatedAwaitingBiometricChoice) {
      _nombreUsuario = '${authState.user.nombre} ${authState.user.apellidos}';
    }
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tasks = await _taskRepository.getTasks();
      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final t in tasks) {
        final sub = t.subsistema.isEmpty ? 'Sin subsistema' : t.subsistema;
        grouped.putIfAbsent(sub, () => []);
        grouped[sub]!.add({
          'id': t.id,
          'titulo': t.titulo,
          'descripcion': t.descripcion,
          'urgencia': t.urgencia,
          'fecha': DateTime.tryParse(t.fecha) ?? DateTime.now(),
          'subsistema': sub,
          'nombreCreador': t.nombreCreador,
        });
      }
      if (!mounted) return;
      setState(() {
        tareasPorSubsistema = grouped;
        if (!grouped.containsKey(subsistemaSeleccionado) && grouped.isNotEmpty) {
          subsistemaSeleccionado = grouped.keys.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('// ${_errorMessage!}',
                  style:
                      textTheme.bodyMedium?.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              AppButton(
                label: 'Reintentar',
                onPressed: _loadTasks,
                icon: Icons.refresh,
                glow: true,
              ),
            ],
          ),
        ),
      );
    }

    // Obtener las tareas filtradas por subsistema
    final tareasSeleccionadas =
        tareasPorSubsistema[subsistemaSeleccionado] ?? [];

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primaryAccent,
        onRefresh: _loadTasks,
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Text(
                'LISTA DE PENDIENTES',
                style: textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
            ).fadeInUp(),
            const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'SUBSISTEMA: ',
                    style: textTheme.labelLarge,
                  ),
                  DropdownButton<String>(
                    value: subsistemaSeleccionado,
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    iconEnabledColor: AppColors.primaryAccent,
                    underline: Container(
                      height: 1,
                      color: AppColors.border,
                    ),
                    items: tareasPorSubsistema.keys.map((String subsistema) {
                      return DropdownMenuItem<String>(
                        value: subsistema,
                        child: Text(
                          subsistema,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? nuevoValor) {
                      setState(() {
                        subsistemaSeleccionado =
                            nuevoValor ?? subsistemaSeleccionado;
                      });
                    },
                  ),
                ],
              ),
              PopupMenuButton<String>(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.border),
                ),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primaryAccent),
                  ),
                  child: const Icon(Icons.menu, color: AppColors.primaryAccent),
                ),
                onSelected: (String value) {
                  if (value == 'Agregar') {
                    _showAgregarPendienteDialog();
                  } else if (value == 'Completar') {
                    _showCompletarPendienteDialog();
                  } else if (value == 'Notion') {
                    _showNotionDialog();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'Agregar',
                    child: Text('Agregar pendiente',
                        style: TextStyle(color: AppColors.textPrimary)),
                  ),
                  PopupMenuItem(
                    value: 'Completar',
                    child: Text('Completar pendiente',
                        style: TextStyle(color: AppColors.textPrimary)),
                  ),
                  PopupMenuItem(
                    value: 'Notion',
                    child: Text('Abrir Notion',
                        style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Mostrar tareas filtradas por subsistema
          Expanded(
            child: tareasSeleccionadas.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: Text(
                          '// Sin pendientes en este subsistema',
                          style: textTheme.labelMedium,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: tareasSeleccionadas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tarea = tareasSeleccionadas[index];
                      return AppCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        onTap: () => _mostrarDetallesPendiente(
                            context, tarea, subsistemaSeleccionado),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: _getUrgenciaColor(tarea['urgencia'])),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${tarea['titulo']} (${tarea['urgencia']})',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Fecha límite: ${_formatDate(tarea['fecha'])}',
                                    style: textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          // Calendario del mes actual
          Text('CALENDARIO', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selectedDayNew, focusedDayNew) {
              setState(() {
                selectedDay = selectedDayNew;
                focusedDay = focusedDayNew;
                _mostrarTareasDelDia(context);
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primaryAccent,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: AppColors.background),
              selectedDecoration: BoxDecoration(
                color: AppColors.secondaryAccent,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: AppColors.background),
              defaultTextStyle: TextStyle(color: AppColors.textPrimary),
              weekendTextStyle: TextStyle(color: AppColors.secondaryAccent),
              outsideDaysVisible: false,
            ),
            eventLoader: (day) {
              final todasLasTareas = tareasPorSubsistema.values
                  .expand((tareas) => tareas)
                  .toList();
              final tareasDelDia = todasLasTareas
                  .where((tarea) => isSameDay(tarea['fecha'], day))
                  .toList();
              return tareasDelDia;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  final tareasDelDia = events as List<Map<String, dynamic>>;
                  final urgenciaMasAlta = tareasDelDia
                      .map((tarea) => tarea['urgencia'] as String)
                      .reduce(
                        (a, b) =>
                            _getUrgenciaPeso(a) > _getUrgenciaPeso(b) ? a : b,
                      );

                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getUrgenciaColor(urgenciaMasAlta),
                      shape: BoxShape.circle,
                    ),
                  );
                }
                return null;
              },
            ),
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              formatButtonVisible: false,
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: AppColors.primaryAccent),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: AppColors.primaryAccent),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: AppColors.textSecondary),
              weekendStyle: TextStyle(color: AppColors.secondaryAccent),
            ),
          ),
          ],
        ),
        ),
      ),
    );
  }

  // Modal para agregar pendiente
  void _showAgregarPendienteDialog() {
    String? titulo, descripcion, urgencia = '!';
    DateTime? fechaSeleccionada;
    String subsistemaSeleccionadoAgregar = subsistemaSeleccionado;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                top: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AGREGAR PENDIENTE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selección de Subsistema
                  DropdownButton<String>(
                    value: subsistemaSeleccionadoAgregar,
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    iconEnabledColor: AppColors.primaryAccent,
                    items: tareasPorSubsistema.keys.map((String subsistema) {
                      return DropdownMenuItem<String>(
                        value: subsistema,
                        child: Text(subsistema,
                            style: const TextStyle(color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (String? nuevoValor) {
                      setModalState(() {
                        subsistemaSeleccionadoAgregar = nuevoValor!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Título',
                    onChanged: (value) => titulo = value,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Descripción',
                    maxLines: 3,
                    onChanged: (value) => descripcion = value,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CREADOR: ${(_nombreUsuario ?? "Desconocido").toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selección de Prioridad
                  DropdownButton<String>(
                    value: urgencia,
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    iconEnabledColor: AppColors.primaryAccent,
                    items: ['!', '!!', '!!!'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('Prioridad $value'),
                      );
                    }).toList(),
                    onChanged: (String? nuevoValor) {
                      setModalState(() {
                        urgencia = nuevoValor!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Botón para seleccionar la fecha
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.primaryAccent,
                                onPrimary: AppColors.background,
                                surface: AppColors.cardBackground,
                                onSurface: AppColors.textPrimary,
                              ),
                              dialogTheme: const DialogThemeData(
                                backgroundColor: AppColors.cardBackground,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setModalState(() {
                          fechaSeleccionada = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      fechaSeleccionada == null
                          ? 'Seleccionar Fecha'
                          : 'Fecha: ${_formatDate(fechaSeleccionada)}',
                      style: const TextStyle(
                          color: AppColors.primaryAccent, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Agregar',
                    fullWidth: true,
                    glow: true,
                    onPressed: () async {
                      if (titulo != null &&
                          descripcion != null &&
                          urgencia != null &&
                          fechaSeleccionada != null) {
                        try {
                          final createdRaw =
                              await _taskRepository.createTask({
                            'titulo': titulo!,
                            'descripcion': descripcion!,
                            'urgencia': urgencia!,
                            'fecha':
                                '${fechaSeleccionada!.year.toString().padLeft(4, '0')}-${fechaSeleccionada!.month.toString().padLeft(2, '0')}-${fechaSeleccionada!.day.toString().padLeft(2, '0')}',
                            'subsistema': subsistemaSeleccionadoAgregar,
                            'nombreCreador': _nombreUsuario ?? 'Desconocido',
                          });
                          final newTask = {
                            'id': createdRaw.id,
                            'titulo': createdRaw.titulo,
                            'descripcion': createdRaw.descripcion,
                            'urgencia': createdRaw.urgencia,
                            'fecha':
                                DateTime.tryParse(createdRaw.fecha) ??
                                    fechaSeleccionada!,
                            'subsistema': subsistemaSeleccionadoAgregar,
                            'nombreCreador': createdRaw.nombreCreador,
                          };

                          setState(() {
                            tareasPorSubsistema.putIfAbsent(
                                subsistemaSeleccionadoAgregar, () => []);
                            tareasPorSubsistema[subsistemaSeleccionadoAgregar]!
                                .add(newTask);
                          });
                          if (!mounted) return;
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al crear la tarea: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Por favor completa todos los campos'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Modal para completar pendiente
  void _showCompletarPendienteDialog() {
    String subsistemaSeleccionadoCompletar = subsistemaSeleccionado;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final pendientes =
                tareasPorSubsistema[subsistemaSeleccionadoCompletar] ?? [];
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                top: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COMPLETAR TAREAS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SUBSISTEMAS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: subsistemaSeleccionadoCompletar,
                    dropdownColor: AppColors.cardBackground,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    iconEnabledColor: AppColors.primaryAccent,
                    items: tareasPorSubsistema.keys.map((String subsistema) {
                      return DropdownMenuItem<String>(
                        value: subsistema,
                        child: Text(
                          subsistema,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? nuevoValor) {
                      setModalState(() {
                        subsistemaSeleccionadoCompletar = nuevoValor!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (pendientes.isEmpty)
                    const Text(
                      '// Sin pendientes para este subsistema.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    )
                  else
                    ...pendientes.map((tarea) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                tarea['titulo'],
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppButton(
                              label: 'Completar',
                              variant: AppButtonVariant.primary,
                              onPressed: () async {
                                try {
                                  await _taskRepository
                                      .deleteTask(tarea['id'] as int);
                                  setState(() {
                                    pendientes.remove(tarea);
                                  });
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Error al completar la tarea'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNotionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text(
            '¿Abrir Notion?',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          actions: [
            AppButton(
              label: 'Sí',
              onPressed: () {
                Navigator.of(context).pop();
                _openNotion();
              },
              glow: true,
            ),
            AppButton(
              label: 'No',
              variant: AppButtonVariant.danger,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _openNotion() async {
    final Uri notionUrl = Uri.parse(
        'https://www.notion.so/Javex-Robotics-13f4be11d8ed8012be7afa6b10bbf0d1?pvs=4');

    try {
      if (await canLaunchUrl(notionUrl)) {
        await launchUrl(
          notionUrl,
          mode: LaunchMode.externalApplication,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abriendo el calendario de pendientes en Notion...'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace. Verifica tu conexión.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      print('Error al intentar abrir el enlace: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error al abrir el enlace.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Modal para mostrar tareas del día seleccionado
  void _mostrarTareasDelDia(BuildContext context) {
    final todasLasTareas =
        tareasPorSubsistema.values.expand((tareas) => tareas).toList();
    final tareasDelDia = todasLasTareas
        .where((tarea) => isSameDay(tarea['fecha'], selectedDay))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PENDIENTES PARA EL ${_formatDate(selectedDay)}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryAccent,
                    letterSpacing: 1.5),
              ),
              const SizedBox(height: 10),
              if (tareasDelDia.isEmpty)
                const Text(
                  '// Sin pendientes para este día.',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                ...tareasDelDia.map((tarea) {
                  final subsistema = tareasPorSubsistema.entries
                      .firstWhere((entry) => entry.value.contains(tarea))
                      .key;

                  return ListTile(
                    leading: Icon(Icons.warning_amber_rounded,
                        color: _getUrgenciaColor(tarea['urgencia'])),
                    title: Text(
                      '${tarea['titulo']} - ($subsistema)',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Urgencia: ${tarea['urgencia']}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _mostrarDetallesPendiente(context, tarea, subsistema);
                    },
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Modal para mostrar detalles de un pendiente seleccionado
  void _mostrarDetallesPendiente(
      BuildContext context, Map<String, dynamic> tarea, String subsistema) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DETALLES DEL PENDIENTE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryAccent,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Título', tarea['titulo'].toString()),
              const SizedBox(height: 8),
              _detailRow('Subsistema', subsistema),
              const SizedBox(height: 8),
              _detailRow('Fecha límite', _formatDate(tarea['fecha'])),
              const SizedBox(height: 8),
              _detailRow('Creado por', tarea['nombreCreador'] ?? 'Anónimo'),
              const SizedBox(height: 8),
              Text(
                'Prioridad: ${tarea['urgencia']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _getUrgenciaColor(tarea['urgencia']),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        text: '${label.toUpperCase()}: ',
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  // Colores según la urgencia
  Color _getUrgenciaColor(String urgencia) {
    switch (urgencia) {
      case '!':
        return AppColors.success;
      case '!!':
        return AppColors.warning;
      case '!!!':
        return AppColors.error;
      default:
        return AppColors.textPrimary;
    }
  }

  // Formato de fecha
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Obtener peso para evaluar urgencia
  int _getUrgenciaPeso(String urgencia) {
    switch (urgencia) {
      case '!':
        return 1;
      case '!!':
        return 2;
      case '!!!':
        return 3;
      default:
        return 0;
    }
  }
}
