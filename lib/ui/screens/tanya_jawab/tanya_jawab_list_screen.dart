import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'tanya_tanaman_screen.dart';

class TanyaJawabListScreen extends StatelessWidget {
  const TanyaJawabListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> plants = [
      {'name': 'Kangkung', 'latin': '(Ipomoea aquatica)', 'image': 'assets/kangkung.png'},
      {'name': 'Bayam', 'latin': '(Amaranthus spp.)', 'image': 'assets/bayam.png'},
      {'name': 'Pakcoy', 'latin': '(Brassica rapa)', 'image': 'assets/pakcoy.png'},
      {'name': 'Caisim', 'latin': '(Brassica rapa var. parachinensis)', 'image': 'assets/caisim.png'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tanya Jawab Tanaman'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Pilih tanaman yang ingin kamu tanyakan\nmasalahnya.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TanyaTanamanScreen(
                          plantName: plant['name']!,
                          plantLatin: plant['latin']!,
                          plantImage: plant['image']!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Plant image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              plant['image']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          plant['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plant['latin']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Info Box Bottom
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tanyakan masalah tanamanmu,\nAI akan membantu memberikan jawaban\ndan saran terbaik.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
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
