import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/plant_disease_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/models/history_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class HasilFotoScreen extends StatefulWidget {
  final XFile imageFile;
  final String plantName;
  
  const HasilFotoScreen({super.key, required this.imageFile, required this.plantName});

  @override
  State<HasilFotoScreen> createState() => _HasilFotoScreenState();
}

class _HasilFotoScreenState extends State<HasilFotoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  PlantDiseaseModel? _result;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      // Simulate network/AI delay
      await Future.delayed(const Duration(seconds: 2));

      // Fetch the diseases from Firestore
      final stream = _firestoreService.getPlantDiseases();
      final allDiseases = await stream.first;
      
      // Filter by selected plant
      final diseases = allDiseases.where(
        (d) => d.jenisTanaman.toLowerCase() == widget.plantName.toLowerCase()
      ).toList();

      if (diseases.isNotEmpty) {
        // Use AI to verify plant and determine which disease it is
        final resultName = await GeminiService.analyzeImageForDisease(
          File(widget.imageFile.path), 
          widget.plantName, 
          diseases
        );
        
        if (resultName != null && resultName.toUpperCase().startsWith('SALAH_TANAMAN:')) {
          String actualPlant = resultName.substring('SALAH_TANAMAN:'.length).trim();
          setState(() {
            _error = 'Gambar yang Anda unggah terdeteksi sebagai $actualPlant, BUKAN tanaman ${widget.plantName}. Silakan pilih tanaman yang sesuai saat verifikasi.';
            _isLoading = false;
          });
          return;
        }
        
        PlantDiseaseModel? matchedDisease;
        if (resultName != null && resultName.isNotEmpty) {
          try {
             matchedDisease = diseases.firstWhere(
               (d) => d.namaPenyakit.toLowerCase().trim() == resultName.toLowerCase().trim()
             );
          } catch(e) {
             // Not found exactly, fallback to checking contains
             try {
               matchedDisease = diseases.firstWhere(
                 (d) => d.namaPenyakit.toLowerCase().contains(resultName.toLowerCase().trim()) ||
                        resultName.toLowerCase().contains(d.namaPenyakit.toLowerCase().trim())
               );
             } catch(e) {
               // Ignore fallback error
             }
          }
        }
        
        if (matchedDisease == null) {
          setState(() {
            _error = 'Maaf, penyakit tidak dikenali, bukan tanaman, atau tanaman tampak sehat.';
            _isLoading = false;
          });
        } else {
          setState(() {
            _result = matchedDisease;
            _isLoading = false;
          });
          
          // Save to history in background to not block UI
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            Future.microtask(() async {
              try {
                // Upload image first
                final cloudinary = CloudinaryService();
                final imageUrl = await cloudinary.uploadImage(File(widget.imageFile.path));
                
                final history = HistoryModel(
                  userId: user.uid,
                  plantName: widget.plantName,
                  diseaseName: matchedDisease!.namaPenyakit,
                  imageUrl: imageUrl,
                  masalah: matchedDisease.masalah,
                  solusi: matchedDisease.solusi,
                  createdAt: DateTime.now(),
                );
                await _firestoreService.addHistory(history);
              } catch (e) {
                debugPrint('Failed to save history: $e');
              }
            });
          }
        }
      } else {
        setState(() {
          _error = 'Maaf, sistem AI kami belum dapat mengidentifikasi penyakit pada tanaman ${widget.plantName} Anda saat ini.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal menganalisis gambar: $e';
        _isLoading = false;
      });
    }
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
        title: const Text('Hasil Analisis'),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error.isNotEmpty
              ? _buildErrorState()
              : _buildResultState(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          SizedBox(height: 16),
          Text('AI sedang menganalisis foto tanamanmu...', style: TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultState() {
    final result = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The image captured
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(widget.imageFile.path),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),

          // Plant Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: AppColors.primaryGreen, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jenis Tanaman',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                    Text(
                      result.jenisTanaman,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Penyakit
          _buildBorderedSection(
            icon: Icons.bug_report,
            title: 'Penyakit Terdeteksi',
            children: [
              Text(
                result.namaPenyakit,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Masalah
          _buildBorderedSection(
            icon: Icons.warning_amber_rounded,
            title: 'Masalah pada Tanaman',
            children: [
              Text(
                result.masalah,
                style: const TextStyle(color: AppColors.textGrey, height: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gejala
          _buildBorderedSection(
            icon: Icons.coronavirus,
            title: 'Gejala pada Tanaman',
            children: result.gejala.map((g) => _buildChecklistItem(g)).toList(),
          ),
          const SizedBox(height: 16),

          // Solusi
          _buildBorderedSection(
            icon: Icons.eco,
            title: 'Solusi / Saran',
            children: result.solusi.map((s) => _buildChecklistItem(s, isSolution: true)).toList(),
          ),
          const SizedBox(height: 32),

          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.image_search),
            label: const Text('Periksa Gambar Lainnya'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBorderedSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, {bool isSolution = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isSolution ? Icons.check_circle : Icons.fiber_manual_record,
            color: isSolution ? AppColors.primaryGreen : Colors.orange,
            size: isSolution ? 20 : 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textGrey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
