import 'package:cloud_firestore/cloud_firestore.dart';

class PlantTipsModel {
  final String? id;
  final String jenisTanaman;
  final List<String> tipsPenanaman;
  final List<String> tipsPenyiraman;
  final List<String> tipsPerawatan;
  final List<Map<String, String>> masalahSolusi;
  final DateTime? createdAt;

  PlantTipsModel({
    this.id,
    required this.jenisTanaman,
    required this.tipsPenanaman,
    required this.tipsPenyiraman,
    required this.tipsPerawatan,
    required this.masalahSolusi,
    this.createdAt,
  });

  factory PlantTipsModel.fromMap(Map<String, dynamic> data, String documentId) {
    var masalahSolusiList = data['masalahSolusi'] as List? ?? [];
    List<Map<String, String>> parsedMasalahSolusi = masalahSolusiList.map((e) {
      return {
        'nama_masalah': e['nama_masalah']?.toString() ?? '',
        'masalah': e['masalah']?.toString() ?? '',
        'solusi': e['solusi']?.toString() ?? '',
        'imageUrl': e['imageUrl']?.toString() ?? '',
      };
    }).toList();

    return PlantTipsModel(
      id: documentId,
      jenisTanaman: data['jenisTanaman'] ?? '',
      tipsPenanaman: List<String>.from(data['tipsPenanaman'] ?? []),
      tipsPenyiraman: List<String>.from(data['tipsPenyiraman'] ?? []),
      tipsPerawatan: List<String>.from(data['tipsPerawatan'] ?? []),
      masalahSolusi: parsedMasalahSolusi,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jenisTanaman': jenisTanaman,
      'tipsPenanaman': tipsPenanaman,
      'tipsPenyiraman': tipsPenyiraman,
      'tipsPerawatan': tipsPerawatan,
      'masalahSolusi': masalahSolusi,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
