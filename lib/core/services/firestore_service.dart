import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant_disease_model.dart';
import '../models/plant_tips_model.dart';
import '../models/compost_guide_model.dart';
import '../models/history_model.dart';
import '../models/my_plant_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==============================
  // --- USERS ---
  // ==============================
  Future<String?> getEmailByUsername(String username) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['email'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==============================
  // --- PLANT DISEASE (PENYAKIT) ---
  // ==============================
  
  Future<void> addPlantDisease(PlantDiseaseModel disease) async {
    try {
      await _db.collection('plant_diseases').add(disease.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan data penyakit tanaman: $e');
    }
  }

  Stream<List<PlantDiseaseModel>> getPlantDiseases() {
    return _db.collection('plant_diseases').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PlantDiseaseModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updatePlantDisease(PlantDiseaseModel disease) async {
    if (disease.id == null) return;
    try {
      await _db.collection('plant_diseases').doc(disease.id).update(disease.toMap());
    } catch (e) {
      throw Exception('Gagal mengupdate data penyakit tanaman: $e');
    }
  }

  Future<void> deletePlantDisease(String id) async {
    try {
      await _db.collection('plant_diseases').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus data penyakit tanaman: $e');
    }
  }

  // ==============================
  // --- PLANT TIPS (TIPS TANAMAN) ---
  // ==============================

  Future<void> addPlantTip(PlantTipsModel tip) async {
    try {
      await _db.collection('plant_tips').add(tip.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan tips tanaman: $e');
    }
  }

  Stream<List<PlantTipsModel>> getPlantTips() {
    return _db.collection('plant_tips').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PlantTipsModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updatePlantTip(PlantTipsModel tip) async {
    if (tip.id == null) return;
    try {
      await _db.collection('plant_tips').doc(tip.id).update(tip.toMap());
    } catch (e) {
      throw Exception('Gagal mengupdate tips tanaman: $e');
    }
  }

  Future<void> deletePlantTip(String id) async {
    try {
      await _db.collection('plant_tips').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus tips tanaman: $e');
    }
  }

  // ==============================
  // --- COMPOST GUIDE (KOMPOS) ---
  // ==============================

  Future<void> addCompostGuide(CompostGuideModel guide) async {
    try {
      await _db.collection('compost_guides').add(guide.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan panduan kompos: $e');
    }
  }

  Stream<List<CompostGuideModel>> getCompostGuides() {
    return _db.collection('compost_guides').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CompostGuideModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateCompostGuide(CompostGuideModel guide) async {
    if (guide.id == null) return;
    try {
      await _db.collection('compost_guides').doc(guide.id).update(guide.toMap());
    } catch (e) {
      throw Exception('Gagal mengupdate panduan kompos: $e');
    }
  }

  Future<void> deleteCompostGuide(String id) async {
    try {
      await _db.collection('compost_guides').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus panduan kompos: $e');
    }
  }

  // ==============================
  // --- USER HISTORY (RIWAYAT) ---
  // ==============================

  Future<void> addHistory(HistoryModel history) async {
    try {
      await _db.collection('user_histories').add(history.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan riwayat: $e');
    }
  }

  Stream<List<HistoryModel>> getUserHistory(String userId) {
    return _db
        .collection('user_histories')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => HistoryModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort locally descending (terbaru ke terlama)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ==============================
  // --- MY PLANTS (TANAMAN SAYA) ---
  // ==============================

  Future<void> addMyPlant(MyPlantModel plant) async {
    try {
      await _db.collection('my_plants').add(plant.toMap());
    } catch (e) {
      throw Exception('Gagal menyimpan tanaman: $e');
    }
  }

  Future<void> updateMyPlant(MyPlantModel plant) async {
    if (plant.id == null) throw Exception('Plant ID is null');
    try {
      await _db.collection('my_plants').doc(plant.id).update(plant.toMap());
    } catch (e) {
      throw Exception('Gagal mengubah tanaman: $e');
    }
  }

  Stream<List<MyPlantModel>> getUserPlants(String userId) {
    return _db
        .collection('my_plants')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => MyPlantModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort locally descending (terbaru ke terlama)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> deleteMyPlant(String id) async {
    try {
      await _db.collection('my_plants').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus tanaman: $e');
    }
  }
}
