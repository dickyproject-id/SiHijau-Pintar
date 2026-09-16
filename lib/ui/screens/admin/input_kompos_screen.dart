import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/services/cloudinary_service.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/compost_guide_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class InputKomposScreen extends StatefulWidget {
  final CompostGuideModel? guideToEdit;

  const InputKomposScreen({super.key, this.guideToEdit});

  @override
  State<InputKomposScreen> createState() => _InputKomposScreenState();
}

class _InputKomposScreenState extends State<InputKomposScreen> {
  final _bahanController = TextEditingController();
  final _langkahController = TextEditingController();
  final _waktuController = TextEditingController();
  final List<Map<String, TextEditingController>> _perawatanControllers = [];

  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Using dynamic to store TextEditingController and image data
  final List<Map<String, dynamic>> _kendalaControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.guideToEdit != null) {
      final guide = widget.guideToEdit!;
      _bahanController.text = guide.bahanDigunakan.join('\n');
      _langkahController.text = guide.langkahPembuatan.join('\n');
      _waktuController.text = guide.waktuPengomposan;
      if (guide.perawatan.isNotEmpty) {
        for (var p in guide.perawatan) {
          final parts = p.split(':');
          final judul = parts[0].trim();
          final deskripsi = parts.length > 1
              ? parts.sublist(1).join(':').trim()
              : '';
          _perawatanControllers.add({
            'judul': TextEditingController(text: judul),
            'deskripsi': TextEditingController(text: deskripsi),
          });
        }
      } else {
        _addPerawatanField();
      }

      for (var ms in guide.masalahSolusi) {
        _kendalaControllers.add({
          'nama_kendala': TextEditingController(text: ms['nama_kendala']),
          'kendala': TextEditingController(text: ms['kendala']),
          'penyebab': TextEditingController(text: ms['penyebab']),
          'solusi': TextEditingController(text: ms['solusi']),
          'imageFile': null,
          'imageUrl': ms['imageUrl'],
        });
      }
    }

    if (_kendalaControllers.isEmpty) {
      _addKendalaField();
    }
  }

  void _addPerawatanField() {
    setState(() {
      _perawatanControllers.add({
        'judul': TextEditingController(),
        'deskripsi': TextEditingController(),
      });
    });
  }

  void _removePerawatanField(int index) {
    if (_perawatanControllers.length > 1) {
      setState(() {
        _perawatanControllers[index]['judul']?.dispose();
        _perawatanControllers[index]['deskripsi']?.dispose();
        _perawatanControllers.removeAt(index);
      });
    }
  }

  void _addKendalaField() {
    setState(() {
      _kendalaControllers.add({
        'nama_kendala': TextEditingController(),
        'kendala': TextEditingController(),
        'penyebab': TextEditingController(),
        'solusi': TextEditingController(),
        'imageFile': null,
        'imageUrl': null,
      });
    });
  }

  void _removeKendalaField(int index) {
    if (_kendalaControllers.length > 1) {
      setState(() {
        _kendalaControllers[index]['nama_kendala']?.dispose();
        _kendalaControllers[index]['kendala']?.dispose();
        _kendalaControllers[index]['penyebab']?.dispose();
        _kendalaControllers[index]['solusi']?.dispose();
        _kendalaControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickAndCropImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Gambar',
            toolbarColor: const Color(0xFF68A943),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Potong Gambar', aspectRatioLockEnabled: true),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _kendalaControllers[index]['imageFile'] = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> _saveData() async {
    if (_bahanController.text.isEmpty ||
        _langkahController.text.isEmpty ||
        _waktuController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua bidang teks!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> parseList(String text) {
        return text
            .split('\n')
            .map((e) => e.replaceAll('-', '').trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      List<Map<String, String>> kendalaList = [];
      for (var e in _kendalaControllers) {
        String namaKendala = e['nama_kendala']?.text.trim() ?? '';
        String kendala = e['kendala']?.text.trim() ?? '';
        String penyebab = e['penyebab']?.text.trim() ?? '';
        String solusi = e['solusi']?.text.trim() ?? '';
        File? imageFile = e['imageFile'];
        String imageUrl = e['imageUrl'] ?? '';

        if (namaKendala.isEmpty || penyebab.isEmpty || solusi.isEmpty) continue;

        if (imageFile != null) {
          final uploadedUrl = await _cloudinaryService.uploadImage(
            imageFile,
            folderName: 'kompos_sampah_dapur',
          );
          if (uploadedUrl != null) imageUrl = uploadedUrl;
        }

        kendalaList.add({
          'nama_kendala': namaKendala,
          'kendala': kendala,
          'penyebab': penyebab,
          'solusi': solusi,
          'imageUrl': imageUrl,
        });
      }

      List<String> perawatanList = [];
      for (var p in _perawatanControllers) {
        String judul = p['judul']?.text.trim() ?? '';
        String deskripsi = p['deskripsi']?.text.trim() ?? '';
        if (judul.isNotEmpty) {
          if (deskripsi.isNotEmpty) {
            perawatanList.add('$judul: $deskripsi');
          } else {
            perawatanList.add(judul);
          }
        }
      }

      final guide = CompostGuideModel(
        id: widget.guideToEdit?.id,
        bahanDigunakan: parseList(_bahanController.text),
        langkahPembuatan: parseList(_langkahController.text),
        waktuPengomposan: _waktuController.text.trim(),
        perawatan: perawatanList,
        masalahSolusi: kendalaList,
      );

      if (widget.guideToEdit != null) {
        await _firestoreService.updateCompostGuide(guide);
      } else {
        await _firestoreService.addCompostGuide(guide);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.guideToEdit != null
                  ? 'Data Kompos berhasil diubah!'
                  : 'Data Kompos berhasil disimpan!',
            ),
          ),
        );
        Navigator.pop(context); // Go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bahanController.dispose();
    _langkahController.dispose();
    _waktuController.dispose();
    for (var p in _perawatanControllers) {
      p['judul']?.dispose();
      p['deskripsi']?.dispose();
    }
    for (var controllers in _kendalaControllers) {
      controllers['nama_kendala']?.dispose();
      controllers['kendala']?.dispose();
      controllers['penyebab']?.dispose();
      controllers['solusi']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF68A943),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.guideToEdit != null
              ? 'Edit Panduan Kompos'
              : 'Tambah Panduan Kompos',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _bahanController,
                  labelText: 'Bahan yang Digunakan',
                  hintText: '- Sisa sayuran\n- Kulit buah',
                  prefixIcon: Icons.eco,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _langkahController,
                  labelText: 'Langkah Pembuatan',
                  hintText: '- Siapkan wadah\n- Masukkan sampah organik',
                  prefixIcon: Icons.format_list_numbered,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _waktuController,
                  labelText: 'Waktu Pengomposan',
                  hintText: '± 1-3 bulan tergantung bahan',
                  prefixIcon: Icons.access_time,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Daftar Perawatan Kompos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _perawatanControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGreen),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Data Perawatan ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_perawatanControllers.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: AppColors.errorRed,
                                  ),
                                  onPressed: () => _removePerawatanField(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _perawatanControllers[index]['judul']!,
                            labelText: 'Judul Perawatan',
                            hintText: 'Misal: Aduk Secara Rutin',
                            prefixIcon: Icons.title,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller:
                                _perawatanControllers[index]['deskripsi']!,
                            labelText: 'Deskripsi',
                            hintText: 'Misal: 1-2 kali setiap minggu',
                            prefixIcon: Icons.description,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addPerawatanField,
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppColors.primaryGreen,
                    ),
                    label: const Text(
                      'Tambah Perawatan',
                      style: TextStyle(color: AppColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Daftar Masalah dan Solusi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _kendalaControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGreen),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Data Masalah & Solusi ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_kendalaControllers.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: AppColors.errorRed,
                                  ),
                                  onPressed: () => _removeKendalaField(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Image Picker
                          Center(
                            child: GestureDetector(
                              onTap: () => _pickAndCropImage(index),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderGrey,
                                  ),
                                ),
                                child:
                                    _kendalaControllers[index]['imageFile'] !=
                                        null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _kendalaControllers[index]['imageFile'],
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (_kendalaControllers[index]['imageUrl'] !=
                                              null &&
                                          _kendalaControllers[index]['imageUrl']
                                              .isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _kendalaControllers[index]['imageUrl'],
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            color: AppColors.textGrey,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Foto (Opsional)',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller:
                                _kendalaControllers[index]['nama_kendala'],
                            labelText: 'Nama Masalah / Kendala',
                            hintText: 'Kompos Berbau Busuk',
                          ),
                          const SizedBox(height: 8),

                          CustomTextField(
                            controller: _kendalaControllers[index]['penyebab'],
                            labelText: 'Masalah',
                            hintText: '- Terlalu basah\n- Kurang oksigen',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _kendalaControllers[index]['solusi'],
                            labelText: 'Solusi',
                            hintText:
                                '- Tambahkan bahan kering (daun kering)\n- Aduk kompos',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                TextButton.icon(
                  onPressed: _addKendalaField,
                  icon: const Icon(Icons.add, color: AppColors.primaryGreen),
                  label: const Text(
                    'Tambah Masalah & Solusi',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                ),

                const SizedBox(height: 32),
                CustomButton(
                  text: widget.guideToEdit != null
                      ? 'Simpan Perubahan'
                      : 'Simpan Data',
                  icon: Icons.save,
                  onPressed: _saveData,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            ),
        ],
      ),
    );
  }
}
