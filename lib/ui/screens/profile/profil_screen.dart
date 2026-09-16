import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  void _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout(context);
            },
            child: const Text('Keluar', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentPhone) {
    String initialPhone = currentPhone == '-' ? '' : currentPhone;
    if (initialPhone.startsWith('+62')) {
      initialPhone = initialPhone.substring(3);
    } else if (initialPhone.startsWith('62')) {
      initialPhone = initialPhone.substring(2);
    } else if (initialPhone.startsWith('0')) {
      initialPhone = initialPhone.substring(1);
    }

    final nameController = TextEditingController(text: currentName == 'Tanpa Nama' ? '' : currentName);
    final phoneController = TextEditingController(text: initialPhone);
    bool isLoading = false;
    String? phoneError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubah Profil',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nama Lengkap',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama lengkap',
                    filled: true,
                    fillColor: const Color(0xFFF9FBF9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nomor HP',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digitsOnly.length > 12) {
                      if (phoneError == null) {
                        setModalState(() => phoneError = 'Nomor telepon tidak boleh lebih dari 12 digit');
                      }
                    } else {
                      if (phoneError != null) {
                        setModalState(() => phoneError = null);
                      }
                    }
                  },
                  decoration: InputDecoration(
                    hintText: '812... (11-12 digit)',
                    prefixText: '+62 ',
                    prefixStyle: GoogleFonts.poppins(
                      fontSize: 14, 
                      color: const Color(0xFF212121), 
                      fontWeight: FontWeight.w500,
                    ),
                    errorText: phoneError,
                    filled: true,
                    fillColor: const Color(0xFFF9FBF9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            String phone = phoneController.text.trim();
                            
                            // Format phone number to start with +62
                            if (phone.startsWith('0')) {
                              phone = '+62${phone.substring(1)}';
                            } else if (phone.startsWith('62')) {
                              phone = '+$phone';
                            } else if (!phone.startsWith('+62') && phone.isNotEmpty) {
                              phone = '+62$phone';
                            }

                            String digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
                            if (digitsOnly.length < 11 || digitsOnly.length > 14) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nomor telepon harus 11-12 digit yang valid!')),
                              );
                              return;
                            }

                            setModalState(() => isLoading = true);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser!.uid)
                                  .update({
                                'namaLengkap': nameController.text.trim(),
                                'nomorHp': phone,
                              });
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Profil berhasil diperbarui')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal memperbarui profil: $e')),
                                );
                              }
                            } finally {
                              setModalState(() => isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Simpan Perubahan',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: currentUser == null
          ? const Center(child: Text('Pengguna tidak ditemukan'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Data profil tidak ditemukan.'));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final namaLengkap = userData['namaLengkap'] ?? 'Tanpa Nama';
                final email = userData['email'] ?? currentUser!.email ?? '-';
                final nomorHp = userData['nomorHp'] ?? '-';

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    children: [
                      // Avatar Profile
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.primaryGreen, width: 2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        namaLengkap,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Card Info
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.person_outline, 'Nama Lengkap', namaLengkap),
                            const Divider(height: 30, color: Color(0xFFF0F0F0)),
                            _buildInfoRow(Icons.email_outlined, 'Email', email),
                            const Divider(height: 30, color: Color(0xFFF0F0F0)),
                            _buildInfoRow(Icons.phone_android_outlined, 'Nomor HP', nomorHp),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Ubah Profil Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditProfileDialog(context, namaLengkap, nomorHp),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: Text(
                            'Ubah Profil',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () => _showLogoutDialog(context),
                          icon: const Icon(Icons.logout, color: AppColors.errorRed),
                          label: Text(
                            'Keluar Akun',
                            style: GoogleFonts.poppins(
                              color: AppColors.errorRed,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppColors.errorRed.withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F9F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
