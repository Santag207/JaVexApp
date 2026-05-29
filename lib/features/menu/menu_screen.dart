import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../inventory/inventory_screen.dart';
import '../pending/pending_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const PendingScreen(),
      const InventoryScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primaryAccent,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
          ),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            _buildAnimatedItem(Icons.home_outlined, 'Inicio', 0),
            _buildAnimatedItem(Icons.list_alt_outlined, 'Pendientes', 1),
            _buildAnimatedItem(Icons.widgets_outlined, 'Inventario', 2),
            _buildAnimatedItem(Icons.person_outline, 'Perfil', 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildAnimatedItem(
      IconData icon, String label, int index) {
    final selected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: selected ? 1.15 : 1.0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: selected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glowCyan(0.4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                color: selected
                    ? AppColors.primaryAccent
                    : AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
      label: label,
    );
  }
}
