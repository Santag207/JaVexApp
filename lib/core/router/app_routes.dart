import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_gate.dart';
import '../../features/auth/login_screen.dart';
import '../../features/menu/menu_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/pending/pending_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/nfc/nfc_screen.dart';
import '../../features/forms/forms_screen.dart';
import '../../features/forms/document_management_form_screen.dart';
import '../../features/forms/text_form_screen.dart';
import '../../features/forms/weekly_forms.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        // AuthGate: pantalla raíz que decide login vs biometría vs menú.
        GoRoute(
          name: 'authGate',
          path: '/',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const AuthGate(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'login',
          path: '/login',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'menu',
          path: '/menu',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const MenuScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ),

        GoRoute(
          name: 'home',
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'profile',
          path: '/profile',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const ProfileScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'dashboard',
          path: '/dashboard',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const DashboardScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'pending',
          path: '/pending',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const PendingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'inventory',
          path: '/inventory',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const InventoryScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'forms',
          path: '/forms',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const FormsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'documentManagementForm',
          path: '/forms/document-management',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const DocumentManagementFormScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'weeklyIndividualForm',
          path: '/forms/weekly-individual',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const TextFormScreen(
              formType: 'weekly_individual',
              title: 'REPORTE INDIVIDUAL',
              fields: weeklyIndividualFields,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'weeklyCoordinatorForm',
          path: '/forms/weekly-coordinator',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const TextFormScreen(
              formType: 'weekly_coordinator',
              title: 'REPORTE COORDINADOR',
              fields: weeklyCoordinatorFields,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          name: 'nfc',
          path: '/nfc',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const NfcScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Ruta no encontrada: ${state.uri}'),
        ),
      ),
    );
  }
}
