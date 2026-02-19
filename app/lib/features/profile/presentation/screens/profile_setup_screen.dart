import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../dashboard/presentation/screens/customer_home_screen.dart';
import '../../../dashboard/presentation/screens/craftsman_home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String role; // 'customer' or 'craftsman' to show relevant fields

  const ProfileSetupScreen({super.key, required this.role});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _companyController = TextEditingController(); // Only for Craftsman

  bool _isLoading = false;
  File? _avatarFile;
  Uint8List? _webImage;
  String? _avatarUrl;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _avatarFile = File('a_path'); 
        });
      } else {
        setState(() {
          _avatarFile = File(pickedFile.path);
        });
      }
      _uploadAvatar(pickedFile);
    }
  }

  Future<void> _uploadAvatar(XFile file) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final fileExt = file.name.split('.').last;
    final fileName = '$userId.${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = fileName; 
    
    setState(() => _isLoading = true);
    try {
      final bytes = await file.readAsBytes();
      await Supabase.instance.client.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      final imageUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(filePath);
      
      // Update local and remote
      setState(() => _avatarUrl = imageUrl);

      await Supabase.instance.client.from('profiles').update({
        'avatar_url': imageUrl,
      }).eq('id', userId);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Fehler: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      final Map<String, dynamic> updates = {
        'full_name': fullName,
        'phone': _phoneController.text.trim(),
        'street': _streetController.text.trim(),
        'house_number': _houseNumberController.text.trim(),
        'zip_code': _zipCodeController.text.trim(),
        'city': _cityController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (_avatarUrl != null) {
        updates['avatar_url'] = _avatarUrl;
      }

      updates['company_name'] = _companyController.text.trim();

      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil erfolgreich erstellt! ✨')),
        );
        
        // Redirect to Dashboard
        if (widget.role == 'customer') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const CustomerHomeScreen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const CraftsmanHomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
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
      appBar: AppBar(
        title: const Text('Profil vervollständigen'),
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wir brauchen noch ein paar Details von dir, um deinen Account einzurichten.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Avatar Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.bgElevated,
                        backgroundImage: _webImage != null
                            ? MemoryImage(_webImage!)
                            : _avatarFile != null
                                ? FileImage(_avatarFile!)
                                : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null) as ImageProvider?,
                        child: (_webImage == null && _avatarFile == null && _avatarUrl == null)
                            ? const Icon(Icons.person, size: 50, color: AppColors.textSecondary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accentPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Name
              Row(
                children: [
                  Expanded(child: _buildTextField('Vorname', _firstNameController)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildTextField('Nachname', _lastNameController)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              _buildTextField('Firmenname (Optional)', _companyController, required: false),
              const SizedBox(height: AppSpacing.lg),

              // Address
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextField('Straße', _streetController)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(flex: 1, child: _buildTextField('Nr.', _houseNumberController)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(flex: 1, child: _buildTextField('PLZ', _zipCodeController, isNumber: true)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(flex: 2, child: _buildTextField('Stadt', _cityController)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Phone
              _buildTextField('Telefonnummer', _phoneController, isNumber: true),

              const SizedBox(height: AppSpacing.xxl),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                    foregroundColor: AppColors.textInverse, // Black text on yellow button
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: AppColors.textInverse)
                    : const Text('Speichern & Loslegen 🚀'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = true, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: required ? (value) {
        if (value == null || value.isEmpty) {
          return 'Pflichtfeld';
        }
        return null;
      } : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.textSecondary),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.accentPrimary),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: AppColors.bgSurface,
      ),
    );
  }
}
