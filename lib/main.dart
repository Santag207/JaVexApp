import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_routes.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // AuthBloc compartido por AuthGate y LoginScreen.
    return BlocProvider<AuthBloc>(
      create: (_) => GetIt.I<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Javex Robotics',
        theme: ThemeData(primarySwatch: Colors.red),
        routerConfig: AppRouter.createRouter(),
      ),
    );
  }
}
