import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/plant_tips_model.dart';
import '../../../core/services/firestore_service.dart';

class TipsTanamanScreen extends StatefulWidget {
  const TipsTanamanScreen({super.key});

  @override
  State<TipsTanamanScreen> createState() => _TipsTanamanScreenState();
}

class _TipsTanamanScreenState extends State<TipsTanamanScreen> {
  String? _selectedTanaman;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<PlantTipsModel>>(
        stream: _firestoreService.getPlantTips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tipsList = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(
                    top: 60,
                    left: 24,
                    right: 24,
                    bottom: 40,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF68A943),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.eco, color: Colors.white, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Tips Tanaman',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Panduan praktis untuk membantu\ntanaman tumbuh sehat dan subur.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (tipsList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Belum ada data tips tanaman.',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    ),
                  )
                else
                  _buildContent(tipsList),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(List<PlantTipsModel> tipsList) {
    // Select first tip by default if null
    if (_selectedTanaman == null ||
        !tipsList.any((t) => t.jenisTanaman == _selectedTanaman)) {
      _selectedTanaman = tipsList.first.jenisTanaman;
    }

    final currentTip = tipsList.firstWhere(
      (t) => t.jenisTanaman == _selectedTanaman,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tanaman Selector
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: tipsList.length,
            itemBuilder: (context, index) {
              final tip = tipsList[index];
              final isSelected = tip.jenisTanaman == _selectedTanaman;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(tip.jenisTanaman),
                  showCheckmark: false,
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textBlack,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTanaman = tip.jenisTanaman;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Column(
            key: ValueKey<String>(_selectedTanaman ?? ''),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // 3 Columns Tips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 240,
                        child: _buildTipColumn(
                          'Tips Penanaman',
                          Icons.eco,
                          currentTip.tipsPenanaman,
                          AppColors.primaryGreen.withValues(alpha: 0.1),
                          AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 240,
                        child: _buildTipColumn(
                          'Tips Penyiraman',
                          Icons.water_drop,
                          currentTip.tipsPenyiraman,
                          Colors.blue.withValues(alpha: 0.1),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 240,
                        child: _buildTipColumn(
                          'Tips Perawatan',
                          Icons.spa,
                          currentTip.tipsPerawatan,
                          AppColors.primaryGreen.withValues(alpha: 0.1),
                          AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Masalah dan Solusi
              if (currentTip.masalahSolusi.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.construction,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Masalah dan Solusi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 360,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: currentTip.masalahSolusi.length,
                    itemBuilder: (context, index) {
                      final ms = currentTip.masalahSolusi[index];
                      return _buildMasalahCard(ms);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Tips Hari Ini
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.tips_and_updates,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Tips Hari Ini',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Periksa kondisi daun setiap hari untuk mendeteksi hama dan penyakit sejak dini.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.search,
                        color: AppColors.primaryGreen,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipColumn(
    String title,
    IconData icon,
    List<String> tips,
    Color iconBgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          if (tips.isEmpty)
            const Text('-', style: TextStyle(color: AppColors.textGrey))
          else
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primaryGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tip.replaceAll('-', '').trim(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> getMasalahStyle(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('kuning') ||
        lower.contains('menguning') ||
        lower.contains('pucat')) {
      return {'icon': Icons.wb_sunny, 'color': Colors.amber};
    }
    if (lower.contains('layu') ||
        lower.contains('kering') ||
        lower.contains('mati')) {
      return {'icon': Icons.dry, 'color': Colors.brown};
    }
    if (lower.contains('busuk') || lower.contains('akar')) {
      return {'icon': Icons.water_damage, 'color': Colors.red};
    }
    if (lower.contains('hama') ||
        lower.contains('kutu') ||
        lower.contains('ulat') ||
        lower.contains('serangga') ||
        lower.contains('belalang') ||
        lower.contains('semut')) {
      return {'icon': Icons.bug_report, 'color': Colors.redAccent};
    }
    if (lower.contains('bercak') ||
        lower.contains('hitam') ||
        lower.contains('jamur') ||
        lower.contains('putih') ||
        lower.contains('coklat')) {
      return {'icon': Icons.blur_on, 'color': Colors.teal};
    }
    if (lower.contains('lambat') ||
        lower.contains('kerdil') ||
        lower.contains('kecil')) {
      return {'icon': Icons.trending_down, 'color': Colors.orange};
    }
    if (lower.contains('rontok') ||
        lower.contains('gugur') ||
        lower.contains('daun')) {
      return {'icon': Icons.nature, 'color': Colors.deepOrange};
    }
    if (lower.contains('basah') ||
        lower.contains('air') ||
        lower.contains('lembab')) {
      return {'icon': Icons.water_drop, 'color': Colors.blue};
    }

    return {'icon': Icons.eco, 'color': AppColors.primaryGreen};
  }

  Widget _buildMasalahCard(Map<String, String> ms) {
    String namaMasalah = ms['nama_masalah'] ?? '';
    if (namaMasalah.isEmpty) namaMasalah = 'Kendala Tanaman';
    String masalah = ms['masalah'] ?? '';
    String solusi = ms['solusi'] ?? '';
    String imageUrl = ms['imageUrl'] ?? '';

    List<String> masalahList = masalah
        .split('\n')
        .map((e) => e.replaceAll('-', '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    List<String> solusiList = solusi
        .split('\n')
        .map((e) => e.replaceAll('-', '').trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            const Center(
              child: Icon(Icons.eco, color: AppColors.primaryGreen, size: 60),
            ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              namaMasalah,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Masalah',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...masalahList.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Solusi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...solusiList.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
