import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _phoneError;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || username.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua bidang teks!')),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email tidak valid!')),
      );
      return;
    }

    // Format phone number to start with +62
    if (phone.startsWith('0')) {
      phone = '+62${phone.substring(1)}';
    } else if (phone.startsWith('62')) {
      phone = '+$phone';
    } else if (!phone.startsWith('+62')) {
      phone = '+62$phone';
    }

    // Remove any non-numeric characters for length validation (excluding +)
    String digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // A standard Indonesian mobile number is 10-13 digits total (including 62)
    // So 08xx xxxx xxx (11 digits) becomes 628xx xxxx xxx (12 digits)
    // And 08xx xxxx xxxx (12 digits) becomes 628xx xxxx xxxx (13 digits)
    if (digitsOnly.length < 11 || digitsOnly.length > 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon harus 11-12 digit yang valid!')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi dan konfirmasi tidak cocok!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUp(
        name: name,
        username: username,
        email: email,
        phone: phone,
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil! Silakan masuk.')),
        );
        Navigator.pop(context); // Kembali ke Login Screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Background Vector (Fixed at top)
          Positioned(
            top: -160, 
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/vector/Vector login-register.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fitWidth,
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // 1. Back Button (Fixed at top)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF2E7D32), 
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),
                
                // Content (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Title
                  Text(
                    'Selamat Datang!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF212121),
                      ),
                      children: const [
                        TextSpan(text: 'Daftar untuk mulai menggunakan\n'),
                        TextSpan(
                          text: 'SiHijau Pintar',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Illustration with circle and sparkles
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F8E9), 
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Positioned(
                            top: 20,
                            right: 15,
                            child: Text('✦', style: TextStyle(color: Color(0xFFC8E6C9), fontSize: 24)),
                          ),
                          const Positioned(
                            bottom: 50,
                            left: -10,
                            child: Text('✦', style: TextStyle(color: Color(0xFFC8E6C9), fontSize: 20)),
                          ),
                          const Positioned(
                            top: 80,
                            right: -10,
                            child: Text('✦', style: TextStyle(color: Color(0xFFC8E6C9), fontSize: 28)),
                          ),
                          Positioned(
                            bottom: -30, 
                            child: Image.asset(
                              'assets/plant_pot.png',
                              width: 210,
                              height: 210,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Form Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'Nama Lengkap',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _usernameController,
                          hintText: 'Username',
                          icon: Icons.alternate_email,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: '812... (11-12 digit)',
                          prefixText: '+62 ',
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          errorText: _phoneError,
                          onChanged: (value) {
                            String digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                            if (digitsOnly.length > 12) {
                              if (_phoneError == null) {
                                setState(() {
                                  _phoneError = 'Nomor telepon tidak boleh lebih dari 12 digit';
                                });
                              }
                            } else {
                              if (_phoneError != null) {
                                setState(() {
                                  _phoneError = null;
                                });
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Kata sandi',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onTogglePassword: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Konfirmasi Kata sandi',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          onTogglePassword: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Daftar Sekarang',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Divider
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFEEEEEE),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'atau',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF757575),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFEEEEEE),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Login Text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah punya akun? ',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF757575),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Masuk disini',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF2E7D32),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? prefixText,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF212121)),
        decoration: InputDecoration(
          hintText: hintText,
          errorText: errorText,
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF9E9E9E)),
          prefixIcon: prefixText != null 
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: const Color(0xFF2E7D32), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        prefixText,
                        style: GoogleFonts.poppins(
                          fontSize: 14, 
                          color: const Color(0xFF212121), 
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF9E9E9E),
                    size: 22,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
          ),
        ),
      ),
    );
  }
}
