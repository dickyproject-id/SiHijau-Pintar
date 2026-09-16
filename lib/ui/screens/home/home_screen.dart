import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'foto_tanaman_screen.dart';
import '../tanya_jawab/tanya_jawab_list_screen.dart';
import '../tips/tips_tanaman_screen.dart';
import '../tips/kompos_screen.dart';
import '../profile/profil_screen.dart';
import '../profile/history_screen.dart';
import '../profile/my_plants_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Foto Tanaman',
      'subtitle': 'Ambil foto tanaman untuk pengecekan dengan AI',
      'icon': Icons.camera_alt,
      'route': const FotoTanamanScreen(),
    },
    {
      'title': 'Tanya Jawab\nTanaman',
      'subtitle': 'Tanyakan masalah tanamanmu ke AI',
      'icon': Icons.question_answer,
      'route': const TanyaJawabListScreen(),
    },
    {
      'title': 'Tips Tanaman',
      'subtitle': 'Dapatkan tips merawat tanaman agar tetap sehat',
      'icon': 'assets/plant_pot.png',
      'route': const TipsTanamanScreen(),
    },
    {
      'title': 'Kompos Sampah\nDapur',
      'subtitle': 'Ubah sampah dapur menjadi kompos bermanfaat',
      'icon': Icons.recycling,
      'route': const KomposScreen(),
    },
  ];

  List<Widget> get _screens => [
    _buildHomeContent(),
    const HistoryScreen(),
    const MyPlantsScreen(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(
            top: BorderSide(color: Color(0xFFF5F5F5), width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: const Color(0xFFFFFFFF),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: const Color(0xFF9E9E9E),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.eco_outlined),
                label: 'Tanaman Saya',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // Background Vector
          Positioned(
            top: -120, // Moved up to avoid touching features
            left: 0,
            right: 0,
            child: Builder(
              builder: (context) {
                return Image.asset(
                  'assets/vector/Vector beranda.png',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fitWidth,
                );
              }
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Content
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hai!',
                              style: GoogleFonts.poppins(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.eco,
                              color: Color(0xFFFFFFFF),
                              size: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yuk, jaga tanamanmu\ntetap sehat bersama AI',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFFFFFFFF),
                      size: 32,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50), // Added gap so the grid clears the green wave

              // Grid Menu Area
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Dynamically calculate aspect ratio to fill all remaining vertical space
                      // 2 columns, 2 rows. 
                      // Horizontal padding: 24 * 2 = 48. Cross spacing = 16.
                      // Vertical padding: 20 * 2 = 40. Main spacing = 16.
                      final double itemWidth = (constraints.maxWidth - 48 - 16) / 2;
                      final double itemHeight = (constraints.maxHeight - 40 - 16) / 2;
                      final double dynamicRatio = itemWidth / itemHeight;

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: dynamicRatio, // perfectly stretches cards to fill space
                        ),
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5), // Added thin border
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => item['route']),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0), // Reduced padding to fit content
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 60, // Smaller circle
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8F5E9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: item['icon'] is String
                                              ? Image.asset(
                                                  item['icon'],
                                                  width: 48, // Enlarged plant_pot icon to match other vector icons
                                                  height: 48,
                                                  fit: BoxFit.contain,
                                                )
                                              : Icon(
                                                  item['icon'],
                                                  color: const Color(0xFF2E7D32),
                                                  size: 30, 
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 8), 
                                      Text(
                                        item['title'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2E7D32),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4), 
                                      Expanded(
                                        child: Text(
                                          item['subtitle'],
                                          textAlign: TextAlign.center,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.sp, // Reduced font size slightly
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF616161),
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
