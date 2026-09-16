import 'package:cloud_firestore/cloud_firestore.dart';

class MyPlantModel {
  final String? id;
  final String userId;
  final String plantName;
  final String notes;
  final String status;
  final String? imageUrl;
  final DateTime createdAt;
  
  // New Advanced Fields
  final DateTime? tanggalTanam;
  final String? frekuensiSiram;
  final String? jenisPupuk;
  final String? frekuensiPupuk;
  final String? gejala;
  final DateTime? lastWateredAt;
  final DateTime? lastFertilizedAt;

  MyPlantModel({
    this.id,
    required this.userId,
    required this.plantName,
    required this.notes,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    this.tanggalTanam,
    this.frekuensiSiram,
    this.jenisPupuk,
    this.frekuensiPupuk,
    this.gejala,
    this.lastWateredAt,
    this.lastFertilizedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'plantName': plantName,
      'notes': notes,
      'status': status,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'tanggalTanam': tanggalTanam != null ? Timestamp.fromDate(tanggalTanam!) : null,
      'frekuensiSiram': frekuensiSiram,
      'jenisPupuk': jenisPupuk,
      'frekuensiPupuk': frekuensiPupuk,
      'gejala': gejala,
      'lastWateredAt': lastWateredAt != null ? Timestamp.fromDate(lastWateredAt!) : null,
      'lastFertilizedAt': lastFertilizedAt != null ? Timestamp.fromDate(lastFertilizedAt!) : null,
    };
  }

  factory MyPlantModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MyPlantModel(
      id: documentId,
      userId: map['userId'] ?? '',
      plantName: map['plantName'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'Sehat',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      tanggalTanam: map['tanggalTanam'] != null ? (map['tanggalTanam'] as Timestamp).toDate() : null,
      frekuensiSiram: map['frekuensiSiram'],
      jenisPupuk: map['jenisPupuk'],
      frekuensiPupuk: map['frekuensiPupuk'],
      gejala: map['gejala'],
      lastWateredAt: map['lastWateredAt'] != null ? (map['lastWateredAt'] as Timestamp).toDate() : null,
      lastFertilizedAt: map['lastFertilizedAt'] != null ? (map['lastFertilizedAt'] as Timestamp).toDate() : null,
    );
  }
}
