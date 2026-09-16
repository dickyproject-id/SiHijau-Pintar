import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/foto_tanaman_screen.dart';
import '../tanya_jawab/tanya_jawab_list_screen.dart';
import '../tips/tips_tanaman_screen.dart';
import '../tips/kompos_screen.dart';
import 'widgets/admin_logout_footer.dart';

class HomeAdminScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeAdminScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Foto Tanaman',
        'subtitle': 'Ambil foto tanaman untuk pengecekan dengan AI',
        'icon': Icons.camera_alt,
        'index': -2,
      },
      {
        'title': 'Tanya Jawab\nTanaman',
        'subtitle': 'Tanyakan masalah tanamanmu ke AI',
        'icon': Icons.question_answer,
        'index': -1,
      },
      {
        'title': 'Tips Tanaman',
        'subtitle': 'Dapatkan tips merawat tanaman agar tetap sehat',
        'icon': 'assets/plant_pot.png',
        'index': 2,
      },
      {
        'title': 'Kompos Sampah\nDapur',
        'subtitle': 'Ubah sampah dapur menjadi kompos bermanfaat',
        'icon': Icons.recycling,
        'index': 3,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  // Background Vector
                  Positioned(
                    top: -120, // Moved up to avoid touching features
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'assets/vector/Vector beranda.png',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fitWidth,
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Content
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                          left: 24.0,
                          right: 24.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hai Admin!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kelola data SiHijau Pintar\ndengan mudah',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 50,
                      ), // Added gap so the grid clears the green wave
                      // Grid Menu Area
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 20.0,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio:
                                        0.70, // Proporsi pas mirip dengan tampilan pengguna
                                  ),
                              itemCount: menuItems.length,
                              itemBuilder: (context, index) {
                                final item = menuItems[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: const Color(0xFFEEEEEE),
                                      width: 1.5,
                                    ),
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
                                        final indexVal = item['index'] as int;
                                        if (indexVal == -1) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const TanyaJawabListScreen(),
                                            ),
                                          );
                                        } else if (indexVal == -2) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const FotoTanamanScreen(),
                                            ),
                                          );
                                        } else if (indexVal == 2) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const TipsTanamanScreen(),
                                            ),
                                          );
                                        } else if (indexVal == 3) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const KomposScreen(),
                                            ),
                                          );
                                        } else {
                                          onNavigate(indexVal);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFE8F5E9),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: item['icon'] is String
                                                    ? Image.asset(
                                                        item['icon'],
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Icon(
                                                        item['icon'],
                                                        color: const Color(
                                                          0xFF2E7D32,
                                                        ),
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
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(
                                                    0xFF616161,
                                                  ),
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
                    ],
                  ),
                ],
              ),

              // Logout footer at the bottom of the scroll view
              const SizedBox(height: 40),
              const AdminLogoutFooter(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
