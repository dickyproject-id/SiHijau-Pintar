import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/compost_guide_model.dart';
import '../../../core/services/firestore_service.dart';

class KomposScreen extends StatefulWidget {
  const KomposScreen({super.key});

  @override
  State<KomposScreen> createState() => _KomposScreenState();
}

class _KomposScreenState extends State<KomposScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedGuideId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<CompostGuideModel>>(
        stream: _firestoreService.getCompostGuides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final guides = snapshot.data ?? [];

          if (_selectedGuideId == null && guides.isNotEmpty) {
            // Kita bungkus dalam Future.microtask untuk menghindari setState selama build phase,
            // tapi karena ini tidak memanggil setState (hanya set variable), it's fine.
            _selectedGuideId = guides.first.id;
          } else if (guides.isNotEmpty &&
              !guides.any((g) => g.id == _selectedGuideId)) {
            _selectedGuideId = guides.first.id;
          }

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
                          const Icon(
                            Icons.recycling,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Kompos Sampah Dapur',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Ubah Sampah Dapur Menjadi\nPupuk Organik Berkualitas',
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

                if (guides.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'Belum ada data panduan kompos.',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    ),
                  )
                else ...[
                  // Pilihan Panduan (Choice Chips)
                  if (guides.length > 1) ...[
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: guides.length,
                        itemBuilder: (context, index) {
                          final guide = guides[index];
                          final isSelected = guide.id == _selectedGuideId;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text('Panduan ${guides.length - index}'),
                              showCheckmark: false,
                              selected: isSelected,
                              selectedColor: AppColors.primaryGreen,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textBlack,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedGuideId = guide.id;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: _buildContent(
                      guides.firstWhere(
                        (g) => g.id == _selectedGuideId,
                        orElse: () => guides.first,
                      ),
                      key: ValueKey<String>(_selectedGuideId ?? ''),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String getBahanEmoji(String text) {
    if (text.toLowerCase().contains('sayur')) return '🥬';
    if (text.toLowerCase().contains('buah')) return '🍌';
    if (text.toLowerCase().contains('kopi') ||
        text.toLowerCase().contains('teh')) {
      return '☕';
    }
    if (text.toLowerCase().contains('daun')) return '🍂';
    if (text.toLowerCase().contains('cangkang')) return '🥚';
    return '🌱';
  }

  Map<String, dynamic> getPerawatanStyle(String text) {
    final lower = text.toLowerCase();
    
    if (lower.contains('aduk') || lower.contains('bolak') || lower.contains('balik') || lower.contains('campur') || lower.contains('rutin') || lower.contains('putar')) {
      return {'icon': Icons.autorenew, 'color': AppColors.primaryGreen, 'bg': AppColors.primaryGreen.withValues(alpha: 0.1)};
    }
    if (lower.contains('lembap') || lower.contains('lembab') || lower.contains('air') || lower.contains('basah') || lower.contains('siram')) {
      return {'icon': Icons.water_drop, 'color': Colors.blue, 'bg': Colors.blue.withValues(alpha: 0.1)};
    }
    if (lower.contains('udara') || lower.contains('sirkulasi') || lower.contains('ventilasi') || lower.contains('angin') || lower.contains('oksigen')) {
      return {'icon': Icons.air, 'color': AppColors.primaryGreen, 'bg': AppColors.primaryGreen.withValues(alpha: 0.1)};
    }
    if (lower.contains('pisah') || lower.contains('sampah') || lower.contains('non-organik') || lower.contains('non organik') || lower.contains('buang') || lower.contains('plastik')) {
      return {'icon': Icons.delete_outline, 'color': AppColors.primaryGreen, 'bg': AppColors.primaryGreen.withValues(alpha: 0.1)};
    }
    if (lower.contains('wadah') || lower.contains('tempat') || lower.contains('kotak') || lower.contains('tong') || lower.contains('pot')) {
      return {'icon': Icons.compost, 'color': Colors.orange, 'bg': Colors.orange.withValues(alpha: 0.1)};
    }
    if (lower.contains('pupuk') || lower.contains('nutrisi') || lower.contains('zat')) {
      return {'icon': Icons.local_florist, 'color': Colors.purple, 'bg': Colors.purple.withValues(alpha: 0.1)};
    }
    if (lower.contains('suhu') || lower.contains('panas') || lower.contains('hangat')) {
      return {'icon': Icons.thermostat, 'color': Colors.red, 'bg': Colors.red.withValues(alpha: 0.1)};
    }
    if (lower.contains('sinar') || lower.contains('matahari') || lower.contains('cahaya') || lower.contains('terang')) {
      return {'icon': Icons.wb_sunny, 'color': Colors.amber, 'bg': Colors.amber.withValues(alpha: 0.1)};
    }
    
    return {'icon': Icons.eco, 'color': AppColors.primaryGreen, 'bg': AppColors.primaryGreen.withValues(alpha: 0.1)};
  }


  Map<String, dynamic> getMasalahStyle(String text) {
    final lower = text.toLowerCase();
    
    if (lower.contains('bau') || lower.contains('busuk') || lower.contains('menyengat')) {
      return {'icon': Icons.waves, 'color': Colors.brown};
    }
    if (lower.contains('basah') || lower.contains('air') || lower.contains('becek')) {
      return {'icon': Icons.water_drop, 'color': Colors.blue};
    }
    if (lower.contains('kering')) {
      return {'icon': Icons.format_color_reset, 'color': Colors.brown};
    }
    if (lower.contains('lambat') || lower.contains('lama')) {
      return {'icon': Icons.hourglass_empty, 'color': Colors.amber};
    }
    if (lower.contains('belatung') || lower.contains('hama') || lower.contains('lalat') || lower.contains('serangga') || lower.contains('semut')) {
      return {'icon': Icons.bug_report, 'color': Colors.red};
    }
    if (lower.contains('panas') || lower.contains('suhu')) {
      return {'icon': Icons.whatshot, 'color': Colors.deepOrange};
    }
    if (lower.contains('dingin')) {
      return {'icon': Icons.ac_unit, 'color': Colors.lightBlue};
    }
    if (lower.contains('jamur') || lower.contains('putih')) {
      return {'icon': Icons.blur_on, 'color': Colors.teal};
    }
    
    return {'icon': Icons.warning_amber_rounded, 'color': Colors.orange};
  }

  Widget _buildContent(CompostGuideModel guide, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.settings,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pembuatan Kompos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 240,
                          child: _buildBahanColumn(guide.bahanDigunakan),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 260,
                          child: _buildLangkahColumn(guide.langkahPembuatan),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 200,
                          child: _buildWaktuColumn(guide.waktuPengomposan),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Perawatan Kompos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.eco, color: AppColors.primaryGreen, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Perawatan Kompos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: guide.perawatan.map((p) {
                        List<String> parts = p.split('\n');
                        String title = parts[0].replaceAll('-', '').trim();
                        String subtitle = parts.length > 1
                            ? parts.sublist(1).join(' ').trim()
                            : '';
                        if (subtitle.isEmpty && title.contains(':')) {
                          final splitColon = title.split(':');
                          title = splitColon[0].trim();
                          subtitle = splitColon.sublist(1).join(':').trim();
                        }
                        final style = getPerawatanStyle(title);
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                            
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: style['bg'] as Color,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  style['icon'] as IconData,
                                  color: style['color'] as Color,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: style['color'] as Color,
                                ),
                              ),
                              if (subtitle.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),



        if (guide.masalahSolusi.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          fontSize: 16,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 380,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: guide.masalahSolusi.length,
                      itemBuilder: (context, index) {
                        final ms = guide.masalahSolusi[index];
                        return _buildMasalahCard(ms);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        // Tips Cepat
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
                const Icon(
                  Icons.lightbulb,
                  color: AppColors.primaryGreen,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tips Cepat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Campuran bahan hijau (sayuran, buah) dan bahan coklat (daun kering, kertas) akan menghasilkan kompos yang lebih cepat matang.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBahanColumn(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12),

      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(Icons.eco, color: AppColors.primaryGreen, size: 16),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Bahan yang Dapat Digunakan',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            String text = item.replaceAll('-', '').trim();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    getBahanEmoji(text),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLangkahColumn(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12),

      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(Icons.list, color: AppColors.primaryGreen, size: 16),
              SizedBox(width: 4),
              Text(
                'Langkah Pembuatan',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            int idx = entry.key;
            String text = entry.value.replaceAll('-', '').trim();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWaktuColumn(String waktu) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12),

      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(Icons.schedule, color: AppColors.primaryGreen, size: 16),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Waktu Pengomposan',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.calendar_month,
            color: AppColors.primaryGreen,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            waktu,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textBlack),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMasalahCard(Map<String, String> ms) {
    String namaKendala = ms['nama_kendala'] ?? '';
    if (namaKendala.isEmpty) namaKendala = ms['kendala'] ?? 'Masalah Kompos';
    String kendala = ms['kendala'] ?? '';
    String penyebab = ms['penyebab'] ?? '';
    String solusi = ms['solusi'] ?? '';
    String imageUrl = ms['imageUrl'] ?? '';

    List<String> kendalaList = kendala
        .split('\n')
        .map((e) => e.replaceAll('-', '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    List<String> penyebabList = penyebab
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
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        
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
          else ...[
            Builder(
              builder: (context) {
                final style = getMasalahStyle(namaKendala);
                return Center(
                  child: Icon(
                    style['icon'] as IconData,
                    color: style['color'] as Color,
                    size: 60,
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 12),
          Center(
            child: Text(
              namaKendala,
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

                  ...kendalaList.map(
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
                  const SizedBox(height: 8),

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
                  ...penyebabList.map(
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
                  const SizedBox(height: 8),

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
