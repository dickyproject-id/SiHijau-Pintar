import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/history_model.dart';

import '../../../core/services/firestore_service.dart';
import '../../../core/models/plant_disease_model.dart';

class DetailHistoryScreen extends StatelessWidget {
  final HistoryModel history;

  const DetailHistoryScreen({super.key, required this.history});

  Future<PlantDiseaseModel?> _fetchDiseaseDetail() async {
    try {
      final diseases = await FirestoreService().getPlantDiseases().first;
      return diseases.firstWhere((d) => 
        d.namaPenyakit.toLowerCase().trim() == history.diseaseName.toLowerCase().trim() &&
        d.jenisTanaman.toLowerCase().trim() == history.plantName.toLowerCase().trim()
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Analisis',
          style: GoogleFonts.poppins(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<PlantDiseaseModel?>(
        future: _fetchDiseaseDetail(),
        builder: (context, snapshot) {
          final diseaseDetail = snapshot.data;
          final List<String> gejala = diseaseDetail?.gejala ?? [];
          final List<String> solusi = diseaseDetail?.solusi ?? history.solusi ?? [];
          final String masalah = diseaseDetail?.masalah ?? history.masalah ?? '';
          
          final String displayImageUrl = (diseaseDetail?.imageUrl != null && diseaseDetail!.imageUrl.isNotEmpty)
              ? diseaseDetail.imageUrl
              : (history.imageUrl ?? '');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The image captured
                if (displayImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      displayImageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
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
                            history.plantName,
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
                      history.diseaseName,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                
                if (masalah.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  // Masalah
                  _buildBorderedSection(
                    icon: Icons.warning_amber_rounded,
                    title: 'Masalah pada Tanaman',
                    children: [
                      Text(
                        masalah,
                        style: const TextStyle(color: AppColors.textGrey, height: 1.5),
                      ),
                    ],
                  ),
                ],
                
                if (gejala.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  // Gejala
                  _buildBorderedSection(
                    icon: Icons.coronavirus,
                    title: 'Gejala pada Tanaman',
                    children: gejala.map((g) => _buildChecklistItem(g)).toList(),
                  ),
                ],
                
                if (solusi.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  // Penanganan / Solusi
                  _buildBorderedSection(
                    icon: Icons.eco,
                    title: 'Solusi / Saran',
                    children: solusi.map((s) => _buildChecklistItem(s, isSolution: true)).toList(),
                  ),
                ],
              ],
            ),
          );
        },
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
          Padding(
            padding: EdgeInsets.only(top: isSolution ? 2.0 : 4.0),
            child: Icon(
              isSolution ? Icons.check_circle : Icons.fiber_manual_record,
              color: isSolution ? AppColors.primaryGreen : Colors.orange,
              size: isSolution ? 20 : 12,
            ),
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
