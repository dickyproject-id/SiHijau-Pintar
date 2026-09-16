import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import 'hasil_foto_screen.dart';

class FotoTanamanScreen extends StatefulWidget {
  const FotoTanamanScreen({super.key});

  @override
  State<FotoTanamanScreen> createState() => _FotoTanamanScreenState();
}

class _FotoTanamanScreenState extends State<FotoTanamanScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFile != null) {
        if (mounted) {
          _showVerificationSheet(pickedFile);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  void _showVerificationSheet(XFile pickedFile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'Verifikasi Deteksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'AI menemukan beberapa kecocokan pola daun. Untuk akurasi diagnosis penyakit yang maksimal, mohon konfirmasi jenis tanamanmu:',
                style: TextStyle(color: AppColors.textGrey, height: 1.5),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ['Kangkung', 'Bayam', 'Pakcoy', 'Caisim'].map((plant) {
                  return ActionChip(
                    label: Text(plant),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    backgroundColor: AppColors.lightGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    onPressed: () {
                      Navigator.pop(context); // close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HasilFotoScreen(
                            imageFile: pickedFile,
                            plantName: plant,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Foto Tanaman'),
      ),
      body: Stack(
        children: [
          Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Ambil foto tanamanmu\nagar AI dapat menganalisis kesehatannya.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            // Plant Illustration
            Image.asset(
              'assets/plant.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            // Ambil Foto Option
            _buildOptionCard(
              context,
              icon: Icons.camera_alt,
              title: 'Ambil Foto',
              subtitle: 'Gunakan kamera untuk memotret tanaman',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 16),
            // Upload dari Galeri Option
            _buildOptionCard(
              context,
              icon: Icons.image,
              title: 'Upload dari Galeri',
              subtitle: 'Pilih foto tanaman dari galeri perangkat',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const Spacer(),
            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 32),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Foto tanamanmu hanya digunakan\nuntuk analisis dan tidak disimpan.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
