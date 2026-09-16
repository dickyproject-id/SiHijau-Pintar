import 'package:cloud_firestore/cloud_firestore.dart';

class CompostGuideModel {
  final String? id;
  final List<String> bahanDigunakan;
  final List<String> langkahPembuatan;
  final String waktuPengomposan;
  final List<String> perawatan;
  final List<Map<String, String>> masalahSolusi;
  final DateTime? createdAt;

  CompostGuideModel({
    this.id,
    required this.bahanDigunakan,
    required this.langkahPembuatan,
    required this.waktuPengomposan,
    required this.perawatan,
    required this.masalahSolusi,
    this.createdAt,
  });

  factory CompostGuideModel.fromMap(Map<String, dynamic> data, String documentId) {
    var masalahSolusiList = data['masalahSolusi'] as List? ?? [];
    List<Map<String, String>> parsedMasalahSolusi = masalahSolusiList.map((e) {
      return {
        'nama_kendala': e['nama_kendala']?.toString() ?? '',
        'kendala': e['kendala']?.toString() ?? '',
        'penyebab': e['penyebab']?.toString() ?? '',
        'solusi': e['solusi']?.toString() ?? '',
        'imageUrl': e['imageUrl']?.toString() ?? '',
      };
    }).toList();

    return CompostGuideModel(
      id: documentId,
      bahanDigunakan: List<String>.from(data['bahanDigunakan'] ?? []),
      langkahPembuatan: List<String>.from(data['langkahPembuatan'] ?? []),
      waktuPengomposan: data['waktuPengomposan'] ?? '',
      perawatan: List<String>.from(data['perawatan'] ?? []),
      masalahSolusi: parsedMasalahSolusi,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bahanDigunakan': bahanDigunakan,
      'langkahPembuatan': langkahPembuatan,
      'waktuPengomposan': waktuPengomposan,
      'perawatan': perawatan,
      'masalahSolusi': masalahSolusi,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
