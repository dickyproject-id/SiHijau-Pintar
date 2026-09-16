import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/plant_disease_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'api_key_manager.dart';

class GeminiService {

  static Future<String?> analyzeImageForDisease(File imageFile, String plantName, List<PlantDiseaseModel> diseases) async {
    int retryCount = 0;
    const int maxRetries = 10;

    while (retryCount < maxRetries) {
      final apiKey = await ApiKeyManager.getAvailableKey();
      
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      final model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: apiKey,
      );

      try {
        final imageBytes = await imageFile.readAsBytes();
        
        String diseaseOptions = diseases.map((e) => e.namaPenyakit).join(', ');
        String prompt = '''
Anda adalah pakar identifikasi dan penyakit tanaman.
Pengguna memilih tanaman: $plantName.

Langkah 1: Verifikasi Tanaman
Apakah gambar yang dilampirkan benar-benar tanaman $plantName? 
JIKA BUKAN (misalnya itu adalah bayam, kangkung, pakcoy, caisim, atau benda lain), balas HANYA dengan format persis seperti ini:
SALAH_TANAMAN: [Nama asli tanaman/benda di gambar]

Langkah 2: Identifikasi Penyakit
JIKA gambar TERBUKTI BENAR tanaman $plantName, periksa penyakitnya dari daftar berikut:
$diseaseOptions

Jika penyakit ada di daftar, balas HANYA dengan nama penyakit yang persis sama dengan daftar.
Jika tanaman tampak sehat atau penyakit tidak dikenali, balas HANYA dengan: TIDAK DIKENALI.

PENTING: Jangan tambahkan penjelasan lain. HANYA kembalikan nama penyakit, TIDAK DIKENALI, atau SALAH_TANAMAN: [nama].
''';

        final response = await model.generateContent([
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes),
          ])
        ]);
        
        return response.text?.trim();
      } catch (e) {
        String errorString = e.toString().toLowerCase();
        if (errorString.contains('429') || 
            errorString.contains('resourceexhausted') || 
            errorString.contains('quota') ||
            errorString.contains('too many requests') ||
            errorString.contains('high demand') ||
            errorString.contains('503')) {
          await ApiKeyManager.markKeyAsExhausted(apiKey);
          retryCount++;
          continue;
        } else {
          debugPrint('Error Gemini Vision: $e');
          return null;
        }
      }
    }
    return null;
  }

  static Stream<Map<String, dynamic>> askQuestionStream(String plantName, String question) async* {
    int retryCount = 0;
    const int maxRetries = 15; // Hindari infinite loop jika semua key limit

    while (retryCount < maxRetries) {
      final apiKey = await ApiKeyManager.getAvailableKey();
      
      if (apiKey == null || apiKey.isEmpty) {
        yield {
          'isOffTopic': false,
          'jawaban': '[ERROR] Maaf, tidak ada API Key yang tersedia.',
          'saran': <String>[],
          'isError': true,
        };
        return;
      }

      final model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: 1000,
        ),
        systemInstruction: Content.system(
          'Anda adalah pakar pertanian spesialis HANYA untuk tanaman $plantName. '
          'Tugas Anda HANYA mendiagnosis masalah atau menjawab pertanyaan seputar tanaman $plantName. '
          'JIKA pertanyaan BUKAN tentang tanaman $plantName, membandingkan dengan tanaman lain, atau di luar topik pertanian, balas HANYA dengan kata "[OFF-TOPIK]" lalu jelaskan penolakan Anda (contoh: [OFF-TOPIK] maaf, kamu berada dihalaman spesialis tanaman $plantName, saya tidak dapat menjawab tentang tanaman lain).\n\n'
          'Jika relevan dan sesuai topik, WAJIB membalas dengan format persis seperti ini:\n'
          'JAWABAN:\n'
          '(Penjelasan penyebab singkat 2-3 kalimat)\n'
          'SARAN:\n'
          '- (solusi 1)\n'
          '- (solusi 2)\n'
          '- (solusi 3)'
        ),
      );

      try {
        final stream = model.generateContentStream([Content.text(question)]);
        String fullText = '';

        await for (final chunk in stream) {
          fullText += chunk.text ?? '';
          yield _parseCustomFormat(fullText);
        }
        
        return; // Selesai dengan sukses
      } catch (e) {
        String errorString = e.toString().toLowerCase();
        if (errorString.contains('429') || 
            errorString.contains('resourceexhausted') || 
            errorString.contains('quota') ||
            errorString.contains('too many requests') ||
            errorString.contains('high demand') ||
            errorString.contains('503')) {
          
          debugPrint('API Key limit tercapai atau server sibuk. Beralih ke kunci berikutnya...');
          await ApiKeyManager.markKeyAsExhausted(apiKey);
          retryCount++;
          continue;
        } else {
          yield {
            'isOffTopic': false,
            'jawaban': '[ERROR] Gagal menghubungi server AI: $e',
            'saran': <String>[],
            'isError': true,
          };
          return;
        }
      }
    }

    // Jika keluar loop karena mencapai maxRetries
    yield {
      'isOffTopic': false,
      'jawaban': '[ERROR] Maaf, semua server AI sedang penuh atau mencapai batas harian (Quota Exhausted). Silakan coba lagi besok.',
      'saran': <String>[],
      'isError': true,
    };
  }

  static Map<String, dynamic> _parseCustomFormat(String text) {
    if (text.trim().startsWith('[OFF-TOPIK]')) {
      return {
        'isOffTopic': true,
        'jawaban': text.replaceAll('[OFF-TOPIK]', '').trim(),
        'saran': <String>[],
        'isError': false,
      };
    }

    String jawaban = '';
    List<String> saran = [];

    // Pisahkan JAWABAN dan SARAN
    if (text.contains('JAWABAN:') && text.contains('SARAN:')) {
      final parts = text.split('SARAN:');
      jawaban = parts[0].replaceAll('JAWABAN:', '').trim();
      
      final saranText = parts[1];
      saranText.split('\n').forEach((line) {
        line = line.trim();
        if (line.startsWith('-')) {
          saran.add(line.substring(1).trim());
        } else if (line.isNotEmpty) {
          // If bullet point text continues on new line
          if (saran.isNotEmpty) {
            saran[saran.length - 1] += ' $line';
          }
        }
      });
    } else if (text.contains('JAWABAN:')) {
      jawaban = text.replaceAll('JAWABAN:', '').trim();
    } else {
      jawaban = text;
    }

    return {
      'isOffTopic': false,
      'jawaban': jawaban,
      'saran': saran,
      'isError': false,
    };
  }
}
