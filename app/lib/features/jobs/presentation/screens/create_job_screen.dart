import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  
  // State
  String _selectedCategory = 'Sonstiges';
  DateTime? _selectedDate;
  bool _isLoading = false;
  
  // Image Upload
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.water_drop_outlined, 'label': 'Sanitär'},
    {'icon': Icons.lightbulb_outline, 'label': 'Elektro'},
    {'icon': Icons.chair_outlined, 'label': 'Möbel'},
    {'icon': Icons.grass_outlined, 'label': 'Garten'},
    {'icon': Icons.format_paint_outlined, 'label': 'Maler'},
    {'icon': Icons.cleaning_services_outlined, 'label': 'Reinigung'},
    {'icon': Icons.local_shipping_outlined, 'label': 'Umzug'},
    {'icon': Icons.build_outlined, 'label': 'Sonstiges'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImages.add(photo);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentPrimary,
              onPrimary: Colors.black,
              surface: Color(0xFF1E2430),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle ein Datum aus.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      // 1. Upload Images (if any)
      List<String> imageUrls = [];
      for (var image in _selectedImages) {
        final fileExt = image.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final filePath = '$userId/$fileName';
        
        final bytes = await image.readAsBytes();
        await Supabase.instance.client.storage.from('job_images').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
        final url = Supabase.instance.client.storage.from('job_images').getPublicUrl(filePath);
        imageUrls.add(url);
      }

      // 2. Create Job
      await Supabase.instance.client.from('jobs').insert({
        'customer_id': userId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'budget': _budgetController.text.trim().isEmpty ? 'VB' : _budgetController.text.trim(),
        'location': _locationController.text.trim(),
        'scheduled_date': _selectedDate!.toIso8601String(),
        'status': 'open',
        'images': imageUrls, // Array of URLs
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auftrag erfolgreich erstellt! 🎉')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Erstellen: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Neuen Auftrag',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Selector (Horizontal)
                      const Text('Kategorie wählen', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected = _selectedCategory == cat['label'];
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCategory = cat['label']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 80,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.accentPrimary : AppColors.bgElevated,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.accentPrimary : Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      cat['icon'], 
                                      color: isSelected ? Colors.black : Colors.white70,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      cat['label'],
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Title & Description
                      _buildTextField('Titel (z.B. Wasserhahn tropft)', _titleController, icon: Icons.title),
                      const SizedBox(height: 16),
                      _buildTextField('Beschreibung', _descriptionController, maxLines: 5, icon: Icons.description_outlined),
                      
                      const SizedBox(height: 32),
                      
                      // Images
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fotos hinzufügen', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _takePhoto,
                                icon: const Icon(Icons.camera_alt_outlined, color: AppColors.accentPrimary),
                                tooltip: 'Kamera',
                              ),
                              TextButton.icon(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.photo_library_outlined, size: 16, color: AppColors.accentPrimary),
                                label: const Text('Galerie', style: TextStyle(color: AppColors.accentPrimary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_selectedImages.isNotEmpty)
                        Container(
                          height: 100,
                          margin: const EdgeInsets.only(top: 8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white12),
                                      image: DecorationImage(
                                        image: kIsWeb 
                                            ? NetworkImage(_selectedImages[index].path) 
                                            : FileImage(File(_selectedImages[index].path)) as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      else 
                        Container(
                          height: 80,
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: AppColors.bgElevated.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12, style: BorderStyle.solid),
                          ),
                          child: Center(
                            child: Icon(Icons.camera_alt_outlined, color: Colors.white.withValues(alpha: 0.2), size: 32),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Location & Date
                      _buildTextField('Ort / Adresse', _locationController, icon: Icons.location_on_outlined),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF252525),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, color: Colors.white.withValues(alpha: 0.5), size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate == null 
                                  ? 'Wunschtermin wählen' 
                                  : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down, color: Colors.white54),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      _buildTextField('Budget (Optional)', _budgetController, icon: Icons.euro, required: false),

                      const SizedBox(height: 48),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitJob,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPrimary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            shadowColor: AppColors.accentPrimary.withValues(alpha: 0.4),
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : const Text('Auftrag veröffentlichen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, IconData? icon, bool required = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      validator: required ? (value) {
        if (value == null || value.isEmpty) return 'Pflichtfeld';
        return null;
      } : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 20) : null,
        filled: true,
        fillColor: const Color(0xFF252525),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentPrimary, width: 1.5),
        ),
      ),
    );
  }
}
