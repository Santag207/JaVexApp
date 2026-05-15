import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../add_hours/add_hours_screen.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import '../../domain/entities/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditModal(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.nombre);
    final lastNameController = TextEditingController(text: user.apellidos);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar Perfil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: lastNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Center(
                      child: Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;

          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              title: const Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Cerrar sesión',
                    onPressed: () {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: user == null
                ? null
                : FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddHoursScreen()),
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
            body: user == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red))
                : SingleChildScrollView(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              // Foto de perfil
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 250,
                                  height: 250,
                                  color: Colors.grey[800],
                                  child: Image.asset(
                                    'assets/profile_picture.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Nombre y apellidos
                              Column(
                                children: [
                                  Text(
                                    user.nombre,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    user.apellidos,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Información adicional + botón editar
                              Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Fecha de unión: ${user.fechaUnion}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Rango: ${user.rango}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        if (user.subsistemas.isNotEmpty)
                                          Text(
                                            'Subsistemas: ${user.subsistemas.join(', ')}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        if (user.liderSubsistema.isNotEmpty)
                                          Text(
                                            'Líder del subsistema de ${user.liderSubsistema}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: IconButton(
                                        onPressed: () =>
                                            _showEditModal(context, user),
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white),
                                        iconSize: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Divider(color: Colors.white, thickness: 1),
                              ),
                              // Estadísticas
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _statColumn(
                                      user.tareasCompletadas.toString(),
                                      'Tareas\nCompletadas'),
                                  _statColumn(user.tareasCreadas.toString(),
                                      'Tareas\nCreadas'),
                                  _statColumn(
                                      user.horasTrabajadas.toString(), 'Horas'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(color: Colors.white, thickness: 1),
                              const Text(
                                'Tareas completadas por subsistema:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (user.tareasCompletadasPorSubsistema.isNotEmpty)
                                GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 2.5,
                                  children: user.tareasCompletadasPorSubsistema
                                      .entries
                                      .map((e) => _buildSubsystemCard(
                                          e.key,
                                          '${e.value} tareas',
                                          user))
                                      .toList(),
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
          );
        },
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsystemCard(String title, String count, User user) {
    Color backgroundColor = Colors.grey[800]!;
    if (user.subsistemas.contains(title)) {
      backgroundColor =
          user.liderSubsistema == title ? Colors.green : Colors.red;
    }

    final bool highlighted =
        backgroundColor == Colors.red || backgroundColor == Colors.green;

    return SizedBox(
      height: 60,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    highlighted ? FontWeight.bold : FontWeight.normal,
                color: highlighted ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
