import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/plant_disease_model.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class InputPenyakitScreen extends StatefulWidget {
  final PlantDiseaseModel? diseaseToEdit;

  const InputPenyakitScreen({super.key, this.diseaseToEdit});

  @override
  State<InputPenyakitScreen> createState() => _InputPenyakitScreenState();
}

class _InputPenyakitScreenState extends State<InputPenyakitScreen> {
  final _namaPenyakitController = TextEditingController();
  final _gejalaController = TextEditingController();
  final _masalahController = TextEditingController();
  final _solusiController = TextEditingController();

  String? _selectedTanaman;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirestoreService _firestoreService = FirestoreService();

  final List<String> _listTanaman = ['Kangkung', 'Bayam', 'Pakcoy', 'Caisim'];

  @override
  void initState() {
    super.initState();
    if (widget.diseaseToEdit != null) {
      final disease = widget.diseaseToEdit!;
      _namaPenyakitController.text = disease.namaPenyakit;
      _gejalaController.text = disease.gejala.join('\n');
      _masalahController.text = disease.masalah;
      _solusiController.text = disease.solusi.join('\n');
      _selectedTanaman = disease.jenisTanaman;
      _existingImageUrl = disease.imageUrl;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveData() async {
    if ((_selectedImage == null && _existingImageUrl == null) ||
        _selectedTanaman == null ||
        _namaPenyakitController.text.isEmpty ||
        _gejalaController.text.isEmpty ||
        _masalahController.text.isEmpty ||
        _solusiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data dan foto!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = _existingImageUrl ?? '';

      if (_selectedImage != null) {
        final newUrl = await _cloudinaryService.uploadImage(
          _selectedImage!,
          folderName: 'penyakit_tanaman',
        );
        if (newUrl == null) {
          throw Exception('Gagal mengupload gambar ke Cloudinary.');
        }
        imageUrl = newUrl;
      }

      List<String> gejalaList = _gejalaController.text
          .split('\n')
          .map((e) => e.replaceAll('-', '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      List<String> solusiList = _solusiController.text
          .split('\n')
          .map((e) => e.replaceAll('-', '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final disease = PlantDiseaseModel(
        id: widget.diseaseToEdit?.id,
        jenisTanaman: _selectedTanaman!,
        namaPenyakit: _namaPenyakitController.text.trim(),
        gejala: gejalaList,
        masalah: _masalahController.text.trim(),
        solusi: solusiList,
        imageUrl: imageUrl,
      );

      if (widget.diseaseToEdit != null) {
        await _firestoreService.updatePlantDisease(disease);
      } else {
        await _firestoreService.addPlantDisease(disease);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.diseaseToEdit != null
                  ? 'Data Penyakit berhasil diubah!'
                  : 'Data Penyakit berhasil disimpan!',
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
    _namaPenyakitController.dispose();
    _gejalaController.dispose();
    _masalahController.dispose();
    _solusiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF68A943),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.diseaseToEdit != null
              ? 'Edit Data Penyakit'
              : 'Tambah Data Penyakit',
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
                  'Upload Gambar Penyakit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : _existingImageUrl != null
                        ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt,
                                color: AppColors.primaryGreen,
                                size: 64,
                              ),
                              Positioned(
                                bottom: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    'Area Preview Gambar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(
                          Icons.camera_alt,
                          color: AppColors.primaryGreen,
                        ),
                        label: const Text(
                          'Ambil Foto',
                          style: TextStyle(color: AppColors.primaryGreen),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(
                          Icons.image,
                          color: AppColors.textGrey,
                        ),
                        label: const Text(
                          'Galeri',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderGrey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                CustomTextField(
                  controller: _namaPenyakitController,
                  labelText: 'Nama Penyakit',
                  hintText: 'Busuk Daun',
                  prefixIcon: Icons.bug_report,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _gejalaController,
                  labelText: 'Gejala pada Tanaman',
                  hintText: '- Daun menguning\n- Terdapat bercak coklat',
                  prefixIcon: Icons.coronavirus,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _masalahController,
                  labelText: 'Masalah',
                  hintText: 'Disebabkan oleh jamur...',
                  prefixIcon: Icons.warning_amber_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _solusiController,
                  labelText: 'Solusi',
                  hintText: '- Pangkas daun yang terinfeksi',
                  prefixIcon: Icons.eco,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

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
                      onChanged: (value) {
                        setState(() {
                          _selectedTanaman = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                CustomButton(
                  text: widget.diseaseToEdit != null
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
