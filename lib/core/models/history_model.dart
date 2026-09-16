import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final String? id;
  final String userId;
  final String plantName;
  final String diseaseName;
  final String? imageUrl;
  final String? masalah;
  final List<String>? solusi;
  final DateTime createdAt;

  HistoryModel({
    this.id,
    required this.userId,
    required this.plantName,
    required this.diseaseName,
    this.imageUrl,
    this.masalah,
    this.solusi,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'plantName': plantName,
      'diseaseName': diseaseName,
      'imageUrl': imageUrl,
      'masalah': masalah,
      'solusi': solusi,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return HistoryModel(
      id: documentId,
      userId: map['userId'] ?? '',
      plantName: map['plantName'] ?? '',
      diseaseName: map['diseaseName'] ?? '',
      imageUrl: map['imageUrl'],
      masalah: map['masalah'],
      solusi: map['solusi'] != null ? List<String>.from(map['solusi']) : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
