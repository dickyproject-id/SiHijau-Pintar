import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/services/cloudinary_service.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/plant_tips_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class InputTipsScreen extends StatefulWidget {
  final PlantTipsModel? tipToEdit;

  const InputTipsScreen({super.key, this.tipToEdit});

  @override
  State<InputTipsScreen> createState() => _InputTipsScreenState();
}

class _InputTipsScreenState extends State<InputTipsScreen> {
  final _tipsPenanamanController = TextEditingController();
  final _tipsPenyiramanController = TextEditingController();
  final _tipsPerawatanController = TextEditingController();

  String? _selectedTanaman;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();
  final List<String> _listTanaman = ['Kangkung', 'Bayam', 'Pakcoy', 'Caisim'];

  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Using dynamic to store TextEditingController and image data
  final List<Map<String, dynamic>> _masalahSolusiControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.tipToEdit != null) {
      final tip = widget.tipToEdit!;
      _selectedTanaman = tip.jenisTanaman;
      _tipsPenanamanController.text = tip.tipsPenanaman.join('\n');
      _tipsPenyiramanController.text = tip.tipsPenyiraman.join('\n');
      _tipsPerawatanController.text = tip.tipsPerawatan.join('\n');

      for (var ms in tip.masalahSolusi) {
        _masalahSolusiControllers.add(<String, dynamic>{
          'nama_masalah': TextEditingController(text: ms['nama_masalah']),
          'masalah': TextEditingController(text: ms['masalah']),
          'solusi': TextEditingController(text: ms['solusi']),
          'imageFile': null,
          'imageUrl': ms['imageUrl'],
        });
      }
    }

    if (_masalahSolusiControllers.isEmpty) {
      _addMasalahSolusiField();
    }
  }

  void _addMasalahSolusiField() {
    setState(() {
      _masalahSolusiControllers.add(<String, dynamic>{
        'nama_masalah': TextEditingController(),
        'masalah': TextEditingController(),
        'solusi': TextEditingController(),
        'imageFile': null,
        'imageUrl': null,
      });
    });
  }

  void _removeMasalahSolusiField(int index) {
    if (_masalahSolusiControllers.length > 1) {
      setState(() {
        _masalahSolusiControllers[index]['nama_masalah']?.dispose();
        _masalahSolusiControllers[index]['masalah']?.dispose();
        _masalahSolusiControllers[index]['solusi']?.dispose();
        _masalahSolusiControllers.removeAt(index);
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
          _masalahSolusiControllers[index]['imageFile'] = File(
            croppedFile.path,
          );
        });
      }
    }
  }

  Future<void> _saveData() async {
    if (_selectedTanaman == null ||
        _tipsPenanamanController.text.isEmpty ||
        _tipsPenyiramanController.text.isEmpty ||
        _tipsPerawatanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi jenis tanaman dan semua tips!'),
        ),
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

      List<Map<String, String>> masalahSolusiList = [];
      for (var e in _masalahSolusiControllers) {
        String namaMasalah = e['nama_masalah']?.text.trim() ?? '';
        String masalah = e['masalah']?.text.trim() ?? '';
        String solusi = e['solusi']?.text.trim() ?? '';
        File? imageFile = e['imageFile'];
        String imageUrl = e['imageUrl'] ?? '';

        if (namaMasalah.isEmpty || masalah.isEmpty || solusi.isEmpty) continue;

        if (imageFile != null) {
          final uploadedUrl = await _cloudinaryService.uploadImage(
            imageFile,
            folderName: 'tips_tanaman',
          );
          if (uploadedUrl != null) imageUrl = uploadedUrl;
        }

        masalahSolusiList.add({
          'nama_masalah': namaMasalah,
          'masalah': masalah,
          'solusi': solusi,
          'imageUrl': imageUrl,
        });
      }

      final tip = PlantTipsModel(
        id: widget.tipToEdit?.id,
        jenisTanaman: _selectedTanaman!,
        tipsPenanaman: parseList(_tipsPenanamanController.text),
        tipsPenyiraman: parseList(_tipsPenyiramanController.text),
        tipsPerawatan: parseList(_tipsPerawatanController.text),
        masalahSolusi: masalahSolusiList,
      );

      if (widget.tipToEdit != null) {
        await _firestoreService.updatePlantTip(tip);
      } else {
        await _firestoreService.addPlantTip(tip);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.tipToEdit != null
                  ? 'Data Tips berhasil diubah!'
                  : 'Data Tips berhasil disimpan!',
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
    _tipsPenanamanController.dispose();
    _tipsPenyiramanController.dispose();
    _tipsPerawatanController.dispose();
    for (var controllers in _masalahSolusiControllers) {
      controllers['nama_masalah']?.dispose();
      controllers['masalah']?.dispose();
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
          widget.tipToEdit != null
              ? 'Edit Tips Tanaman'
              : 'Tambah Tips Tanaman',
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
                const Text(
                  'Jenis Tanaman',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Pilih Tanaman'),
                      value: _selectedTanaman,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primaryGreen,
                      ),
                      items: _listTanaman
                          .map(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.eco,
                                    color: AppColors.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(value),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedTanaman = value),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  controller: _tipsPenanamanController,
                  labelText: 'Tips Penanaman',
                  hintText:
                      '- Pilih benih berkualitas\n- Gunakan media tanam gembur',
                  prefixIcon: Icons.grass,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _tipsPenyiramanController,
                  labelText: 'Tips Penyiraman',
                  hintText:
                      '- Siram pagi hari\n- Hindari penyiraman berlebihan',
                  prefixIcon: Icons.water_drop,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _tipsPerawatanController,
                  labelText: 'Tips Perawatan',
                  hintText: '- Berikan pupuk organik\n- Bersihkan gulma',
                  prefixIcon: Icons.spa,
                  maxLines: 4,
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
                  itemCount: _masalahSolusiControllers.length,
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
                              if (_masalahSolusiControllers.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: AppColors.errorRed,
                                  ),
                                  onPressed: () =>
                                      _removeMasalahSolusiField(index),
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
                                    _masalahSolusiControllers[index]['imageFile'] !=
                                        null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _masalahSolusiControllers[index]['imageFile'],
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (_masalahSolusiControllers[index]['imageUrl'] !=
                                              null &&
                                          _masalahSolusiControllers[index]['imageUrl']
                                              .isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          _masalahSolusiControllers[index]['imageUrl'],
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
                                _masalahSolusiControllers[index]['nama_masalah'],
                            labelText: 'Nama Masalah / Kendala',
                            hintText: 'Daun Menguning',
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller:
                                _masalahSolusiControllers[index]['masalah'],
                            labelText: 'Penyebab / Masalah',
                            hintText:
                                '- Kekurangan nutrisi\n- Penyiraman berlebihan',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller:
                                _masalahSolusiControllers[index]['solusi'],
                            labelText: 'Solusi',
                            hintText:
                                '- Tambahkan pupuk organik\n- Kurangi frekuensi penyiraman',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                TextButton.icon(
                  onPressed: _addMasalahSolusiField,
                  icon: const Icon(Icons.add, color: AppColors.primaryGreen),
                  label: const Text(
                    'Tambah Masalah & Solusi',
                    style: TextStyle(color: AppColors.primaryGreen),
                  ),
                ),

                const SizedBox(height: 32),
                CustomButton(
                  text: widget.tipToEdit != null
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
