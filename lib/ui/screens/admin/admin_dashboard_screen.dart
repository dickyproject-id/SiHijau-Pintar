import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

import 'home_admin_screen.dart';
import 'list_penyakit_admin_screen.dart';
import 'list_tips_admin_screen.dart';
import 'list_kompos_admin_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    HomeAdminScreen(onNavigate: _onItemTapped),
    const ListPenyakitAdminScreen(),
    const ListTipsAdminScreen(),
    const ListKomposAdminScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.textGrey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.bug_report),
              label: 'Penyakit',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Tips'),
            BottomNavigationBarItem(
              icon: Icon(Icons.recycling),
              label: 'Kompos',
            ),
          ],
        ),
      ),
    );
  }
}
