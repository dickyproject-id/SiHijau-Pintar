import 'package:cloud_firestore/cloud_firestore.dart';

class PlantDiseaseModel {
  final String? id;
  final String jenisTanaman;
  final String namaPenyakit;
  final List<String> gejala;
  final String masalah;
  final List<String> solusi;
  final String imageUrl;
  final DateTime? createdAt;

  PlantDiseaseModel({
    this.id,
    required this.jenisTanaman,
    required this.namaPenyakit,
    required this.gejala,
    required this.masalah,
    required this.solusi,
    required this.imageUrl,
    this.createdAt,
  });

  factory PlantDiseaseModel.fromMap(Map<String, dynamic> data, String documentId) {
    return PlantDiseaseModel(
      id: documentId,
      jenisTanaman: data['jenisTanaman'] ?? '',
      namaPenyakit: data['namaPenyakit'] ?? '',
      gejala: List<String>.from(data['gejala'] ?? []),
      masalah: data['masalah'] ?? '',
      solusi: List<String>.from(data['solusi'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jenisTanaman': jenisTanaman,
      'namaPenyakit': namaPenyakit,
      'gejala': gejala,
      'masalah': masalah,
      'solusi': solusi,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
