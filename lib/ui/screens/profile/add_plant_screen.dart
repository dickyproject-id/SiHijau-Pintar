import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/models/my_plant_model.dart';

class AddPlantScreen extends StatefulWidget {
  final MyPlantModel? plantToEdit;
  const AddPlantScreen({super.key, this.plantToEdit});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plantNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _jenisPupukController = TextEditingController();
  final _gejalaController = TextEditingController();
  
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  bool _isLoading = false;
  File? _imageFile;
  String _status = 'Sehat';
  String? _existingImageUrl;
  
  DateTime _tanggalTanam = DateTime.now();
  String? _frekuensiSiram;
  String? _frekuensiPupuk;

  final List<String> _statusOptions = ['Sehat', 'Perlu Perawatan', 'Sakit'];
  final List<String> _freqSiramOptions = ['Setiap hari', '2 Hari Sekali', 'Seminggu Sekali', 'Sesuai Kebutuhan'];
  final List<String> _freqPupukOptions = ['Seminggu Sekali', '2 Minggu Sekali', 'Sebulan Sekali', 'Jarang'];

  @override
  void initState() {
    super.initState();
    if (widget.plantToEdit != null) {
      _plantNameController.text = widget.plantToEdit!.plantName;
      _notesController.text = widget.plantToEdit!.notes;
      _status = widget.plantToEdit!.status;
      _existingImageUrl = widget.plantToEdit!.imageUrl;
      
      _tanggalTanam = widget.plantToEdit!.tanggalTanam ?? widget.plantToEdit!.createdAt;
      _frekuensiSiram = widget.plantToEdit!.frekuensiSiram;
      _frekuensiPupuk = widget.plantToEdit!.frekuensiPupuk;
      _jenisPupukController.text = widget.plantToEdit!.jenisPupuk ?? '';
      _gejalaController.text = widget.plantToEdit!.gejala ?? '';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryGreen),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalTanam,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggalTanam) {
      setState(() {
        _tanggalTanam = picked;
      });
    }
  }

  void _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap login terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        imageUrl = await _cloudinaryService.uploadImage(_imageFile!);
      }

      if (widget.plantToEdit == null) {
        final newPlant = MyPlantModel(
          userId: user.uid,
          plantName: _plantNameController.text.trim(),
          notes: _notesController.text.trim(),
          status: _status,
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
          tanggalTanam: _tanggalTanam,
          frekuensiSiram: _frekuensiSiram,
          jenisPupuk: _jenisPupukController.text.trim(),
          frekuensiPupuk: _frekuensiPupuk,
          gejala: _status != 'Sehat' ? _gejalaController.text.trim() : null,
        );
        await _firestoreService.addMyPlant(newPlant);
      } else {
        final updatedPlant = MyPlantModel(
          id: widget.plantToEdit!.id,
          userId: user.uid,
          plantName: _plantNameController.text.trim(),
          notes: _notesController.text.trim(),
          status: _status,
          imageUrl: imageUrl,
          createdAt: widget.plantToEdit!.createdAt,
          tanggalTanam: _tanggalTanam,
          frekuensiSiram: _frekuensiSiram,
          jenisPupuk: _jenisPupukController.text.trim(),
          frekuensiPupuk: _frekuensiPupuk,
          gejala: _status != 'Sehat' ? _gejalaController.text.trim() : null,
          lastWateredAt: widget.plantToEdit!.lastWateredAt,
          lastFertilizedAt: widget.plantToEdit!.lastFertilizedAt,
        );
        await _firestoreService.updateMyPlant(updatedPlant);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.plantToEdit == null ? 'Tanaman berhasil ditambahkan!' : 'Tanaman berhasil diubah!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _notesController.dispose();
    _jenisPupukController.dispose();
    _gejalaController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textBlack,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9FBF9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
      ),
      validator: isRequired ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Kolom ini tidak boleh kosong';
        }
        return null;
      } : null,
    );
  }

  Widget _buildDropdown(String? value, List<String> items, Function(String?) onChanged, String hint) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FBF9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.plantToEdit == null ? 'Tambah Tanaman' : 'Ubah Tanaman',
          style: GoogleFonts.poppins(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Upload Section
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FBF9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 2),
                    ),
                    child: _imageFile == null && _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _existingImageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  _imageFile!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40, color: AppColors.primaryGreen.withValues(alpha: 0.5)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tambah Foto',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Nama Tanaman'),
              _buildTextField(_plantNameController, 'Contoh: Tomat, Cabai, dll', isRequired: true),
              
              _buildLabel('Tanggal Tanam (Umur: ${DateTime.now().difference(_tanggalTanam).inDays < 1 ? 'Baru ditanam' : '${DateTime.now().difference(_tanggalTanam).inDays} Hari'})'),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FBF9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMMM yyyy').format(_tanggalTanam),
                        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textBlack),
                      ),
                    ],
                  ),
                ),
              ),

              _buildLabel('Status Kondisi'),
              Wrap(
                spacing: 8.0,
                children: _statusOptions.map((status) {
                  final isSelected = _status == status;
                  Color chipColor;
                  if (status == 'Sehat') chipColor = AppColors.primaryGreen;
                  else if (status == 'Sakit') chipColor = Colors.red;
                  else chipColor = Colors.orange;

                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _status = status;
                        });
                      }
                    },
                    selectedColor: chipColor.withValues(alpha: 0.2),
                    backgroundColor: const Color(0xFFF9FBF9),
                    labelStyle: TextStyle(
                      color: isSelected ? chipColor : AppColors.textGrey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSelected ? chipColor : Colors.grey.shade300),
                  );
                }).toList(),
              ),

              if (_status == 'Sakit') ...[
                _buildLabel('Gejala pada Tanaman'),
                _buildTextField(_gejalaController, 'Contoh: Daun menguning, bercak hitam, layu terserang hama...', maxLines: 2),
              ] else if (_status == 'Perlu Perawatan') ...[
                _buildLabel('Kondisi / Penyebab (Opsional)'),
                _buildTextField(_gejalaController, 'Contoh: Kurang air, butuh pemupukan, media tanam kering...', maxLines: 2),
              ],

              const SizedBox(height: 24),
              // Expandable Advanced Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      '⚙️ Pengaturan Perawatan (Opsional)',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
                    children: [
                      _buildLabel('Target Frekuensi Siram'),
                      _buildDropdown(_frekuensiSiram, _freqSiramOptions, (val) => setState(() => _frekuensiSiram = val), 'Pilih Frekuensi'),
                      
                      _buildLabel('Jenis Pupuk'),
                      _buildTextField(_jenisPupukController, 'Contoh: NPK, Kompos'),
                      
                      _buildLabel('Target Frekuensi Pupuk'),
                      _buildDropdown(_frekuensiPupuk, _freqPupukOptions, (val) => setState(() => _frekuensiPupuk = val), 'Pilih Frekuensi'),
                    ],
                  ),
                ),
              ),

              _buildLabel('Catatan Tambahan (Opsional)'),
              _buildTextField(_notesController, 'Tulis catatan lainnya...', maxLines: 3),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePlant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Simpan Tanaman',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
