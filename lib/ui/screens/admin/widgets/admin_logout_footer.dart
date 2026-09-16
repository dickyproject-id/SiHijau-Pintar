import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../auth/login_screen.dart';
import 'dart:math' as math;

class AdminLogoutFooter extends StatefulWidget {
  const AdminLogoutFooter({super.key});

  @override
  State<AdminLogoutFooter> createState() => _AdminLogoutFooterState();
}

class _AdminLogoutFooterState extends State<AdminLogoutFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _doorAnimation;
  late Animation<Offset> _arrowAnimation;
  late Animation<double> _arrowOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Door rotates from 0 to -pi/2.5 (opens outwards to the left)
    _doorAnimation = Tween<double>(begin: 0, end: -math.pi / 2.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Arrow slides from inside (left) to the right
    _arrowAnimation =
        Tween<Offset>(
          begin: const Offset(-0.8, 0),
          end: const Offset(0.8, 0),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.9, curve: Curves.easeOutBack),
          ),
        );

    // Arrow fades in
    _arrowOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    // Prevent double tap
    if (_controller.isAnimating || _controller.isCompleted) return;

    // Run animation
    await _controller.forward();

    // Wait a little bit for user to see the full animation before navigating
    await Future.delayed(const Duration(milliseconds: 200));

    final authService = AuthService();
    await authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 40),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Ingin keluar dari panel admin?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Klik tombol di bawah untuk keluar.',
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _handleLogout,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E20), // Dark almost black background
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Outer Door Frame
                    Container(
                      width: 48,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2D),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF3A3A3D),
                          width: 2,
                        ),
                      ),
                    ),

                    // Inside Darkness (The hole when door is open)
                    Container(
                      width: 44,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    // Red Arrow
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _arrowAnimation,
                          child: FadeTransition(
                            opacity: _arrowOpacity,
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFFE53935), // Red
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),

                    // The Door (rotates to open from the left edge)
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.003) // Perspective effect
                            ..rotateY(_doorAnimation.value),
                          child: Container(
                            width: 44,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF333336), // Door color
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF4A4A4D),
                                width: 1.5,
                              ),
                            ),
                            // Door handle
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              width: 4,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E20),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
