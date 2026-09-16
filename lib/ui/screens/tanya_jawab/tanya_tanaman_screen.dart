import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'jawaban_screen.dart';
import '../../../core/services/quota_service.dart';

class TanyaTanamanScreen extends StatefulWidget {
  final String plantName;
  final String plantLatin;
  final String plantImage;

  const TanyaTanamanScreen({
    super.key,
    required this.plantName,
    required this.plantLatin,
    required this.plantImage,
  });

  @override
  State<TanyaTanamanScreen> createState() => _TanyaTanamanScreenState();
}

class _TanyaTanamanScreenState extends State<TanyaTanamanScreen> {
  final TextEditingController _questionController = TextEditingController();
  bool _isSuspended = false;
  Duration _cooldownRemaining = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkSuspension();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWarning();
    });
  }

  void _checkSuspension() async {
    Duration remaining = await QuotaService.getCooldownRemaining(widget.plantName);
    if (remaining.inSeconds > 0) {
      if (mounted) {
        setState(() {
          _isSuspended = true;
          _cooldownRemaining = remaining;
        });
      }
      _startTimer();
    } else {
      if (mounted) {
        setState(() {
          _isSuspended = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      Duration remaining = await QuotaService.getCooldownRemaining(widget.plantName);
      if (remaining.inSeconds <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isSuspended = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _cooldownRemaining = remaining;
          });
        }
      }
    });
  }

  Future<void> _checkWarning() async {
    bool shouldShow = await QuotaService.shouldShowWarning(widget.plantName);
    if (shouldShow && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            '⚠️ Peringatan',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            'Halo! Mohon pastikan pertanyaan Anda hanya seputar tanaman ${widget.plantName} ya 🌱.\\n\\nJika terdeteksi pertanyaan di luar topik lagi, fitur tanya jawab ${widget.plantName} ini akan dinonaktifkan sementara selama 6 jam.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Saya Mengerti',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      await QuotaService.markWarningShown(widget.plantName);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionController.dispose();
    super.dispose();
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
        title: Text('Tanya ${widget.plantName}'),
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
                      child: Image.asset(widget.plantImage, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textBlack,
                          ),
                        ),
                        Text(
                          widget.plantLatin,
                          style: TextStyle(
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
            const SizedBox(height: 32),

            if (_isSuspended)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.timer_off_outlined, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Fitur Ditangguhkan',
                      style: TextStyle(
                        color: Colors.red, 
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Anda telah mengajukan pertanyaan di luar topik terlalu sering.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Buka kembali dalam: ${_cooldownRemaining.inHours > 0 ? '${_cooldownRemaining.inHours} jam' : '${_cooldownRemaining.inMinutes > 0 ? '${_cooldownRemaining.inMinutes} menit ' : ''}${_cooldownRemaining.inSeconds % 60} detik'}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                'Ketik pertanyaanmu tentang ${widget.plantName.toLowerCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _questionController,
                maxLines: 5,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText:
                      'Contoh: Daun ${widget.plantName.toLowerCase()} saya menguning,\nkenapa ya?',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tip Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tips: Jelaskan masalah dengan detail\nagar jawaban lebih akurat.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Kirim',
                icon: Icons.send,
                onPressed: () async {
                  if (_questionController.text.trim().isEmpty) return;

                  Duration cooldown = await QuotaService.getCooldownRemaining(
                    widget.plantName,
                  );
                  if (cooldown.inSeconds > 0) {
                    _checkSuspension();
                    return;
                  }

                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JawabanScreen(
                        plantName: widget.plantName,
                        plantLatin: widget.plantLatin,
                        plantImage: widget.plantImage,
                        question: _questionController.text.trim(),
                      ),
                    ),
                  ).then((_) {
                    _questionController.clear();
                    _checkSuspension();
                    _checkWarning();
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
