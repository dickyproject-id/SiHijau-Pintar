import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/quota_service.dart';

class JawabanScreen extends StatefulWidget {
  final String? plantName;
  final String? plantLatin;
  final String? plantImage;
  final String? question;

  const JawabanScreen({
    super.key,
    this.plantName,
    this.plantLatin,
    this.plantImage,
    this.question,
  });

  @override
  State<JawabanScreen> createState() => _JawabanScreenState();
}

class _JawabanScreenState extends State<JawabanScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _aiResponse;

  @override
  void initState() {
    super.initState();
    _fetchAnswer();
  }

  Future<void> _fetchAnswer() async {
    final pName = widget.plantName ?? 'Tanaman';
    final pQuestion = widget.question ?? '';

    if (pQuestion.isEmpty) {
      setState(() {
        _isLoading = false;
        _aiResponse = {
          'isError': true,
          'jawaban': 'Tidak ada pertanyaan.',
          'saran': <String>[],
          'isOffTopic': false,
        };
      });
      return;
    }

    final stream = GeminiService.askQuestionStream(pName, pQuestion);

    await for (final response in stream) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _aiResponse = response;
        });
      }
    }

    // Sesudah stream selesai, cek off topic
    if (_aiResponse != null && _aiResponse!['isOffTopic'] == true) {
      await QuotaService.recordStrike(pName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pName = widget.plantName ?? 'Kangkung';
    final pLatin = widget.plantLatin ?? '(Ipomoea aquatica)';
    final pImage = widget.plantImage ?? 'assets/kangkung.png';
    final pQuestion = widget.question ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Jawaban'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Plant Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(pImage, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textBlack,
                          ),
                        ),
                        Text(
                          pLatin,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: AppColors.textGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pertanyaanmu
            const Text(
              'Pertanyaanmu:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pQuestion,
                style: const TextStyle(color: AppColors.textBlack),
              ),
            ),
            const SizedBox(height: 24),

            // Jawaban AI
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderGrey.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color.fromARGB(255, 144, 170, 146),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Working',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const ThreeDotsLoading(),
                  ],
                ),
              )
            else if (_aiResponse?['isError'] == true) ...[
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _aiResponse?['jawaban'] ?? '',
                style: const TextStyle(color: Colors.red),
              ),
            ] else if (_aiResponse?['isOffTopic'] == true) ...[
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'Di Luar Topik',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _aiResponse?['jawaban'] ?? '',
                style: const TextStyle(color: Colors.red),
              ),
            ] else ...[
              // Jawaban Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.borderGrey.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Jawaban',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _aiResponse?['jawaban'] ?? '',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Saran Section
              if ((_aiResponse?['saran'] as List<String>? ?? [])
                  .isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.eco, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    const Text(
                      'Saran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...(_aiResponse?['saran'] as List<String>? ?? [])
                    .map((line) => _buildChecklistItem(line))
                    ,
              ],
            ],

            const SizedBox(height: 32),

            // Button
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Tanya Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primaryGreen,
            size: 22,
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

class ThreeDotsLoading extends StatefulWidget {
  const ThreeDotsLoading({super.key});

  @override
  State<ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<ThreeDotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double delay = index * 0.2;
            double value = (_controller.value - delay) % 1.0;
            if (value < 0) value += 1.0;

            double scale = 1.0;
            double opacity = 0.3;
            if (value < 0.5) {
              double pulse = (value / 0.5);
              double intensity = pulse < 0.5
                  ? (pulse * 2)
                  : (1 - (pulse - 0.5) * 2);
              scale = 1.0 + (0.3 * intensity);
              opacity = 0.3 + (0.7 * intensity);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
