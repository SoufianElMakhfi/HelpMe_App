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

  // State
  bool _isViewMode = false; 
  bool _isEditing = false;
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _companyController = TextEditingController(); // Only for Craftsman

  bool _isLoading = true; // Start loading immediately to prevent flash of wrong content
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



  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        final fullName = (data['full_name'] as String?) ?? '';
        final parts = fullName.split(' ');
        if (parts.isNotEmpty) {
           _firstNameController.text = parts.first;
           if (parts.length > 1) {
             _lastNameController.text = parts.sublist(1).join(' ');
           }
        }
        
        _phoneController.text = (data['phone'] as String?) ?? '';
        _streetController.text = (data['street'] as String?) ?? '';
        _houseNumberController.text = (data['house_number'] as String?) ?? '';
        _zipCodeController.text = (data['zip_code'] as String?) ?? '';
        _cityController.text = (data['city'] as String?) ?? '';
        _companyController.text = (data['company_name'] as String?) ?? '';
        
        setState(() {
          _avatarUrl = data['avatar_url'] as String?;
          // Logic: If we have data (Full Name or Street), we are in "View Mode" (Profile exists).
          // Otherwise, we remain in "Edit Mode" (Setup).
          if (fullName.isNotEmpty || _streetController.text.isNotEmpty) {
            _isEditing = true; // Still needed for "Update" API call logic
            _isViewMode = true; // Show Read-Only View first
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... _submitProfile stays mostly the same, but we might want to stay on screen after save or go back to ViewMode? 
  // For now, let's keep the redirect logic but maybe update it if the user just wants to save edits.
  // Actually, let's update _submitProfile to switch back to View Mode instead of redirecting if it was just an edit.
  // BUT: The user flow typically goes Setup -> Dashboard. 
  // If accessing from Dashboard -> Profile -> Edit -> Save -> View Mode.
  
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
          const SnackBar(content: Text('Profil aktualisiert! ✅')),
        );
        
        // If we were already in "Editing Mode" (meaning profile existed), just switch back to View Mode.
        // If it was initial setup (_isViewMode was never true), redirect to dashboard.
        if (_isEditing) {
             setState(() {
               _isViewMode = true; 
               _isLoading = false;
             });
        } else {
            // Initial Setup -> Redirect
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Determine Colors & Assets based on Role
    final isCustomer = widget.role == 'customer';
    final accentColor = isCustomer ? AppColors.accentPrimary : AppColors.accentSecondary; 
    final backgroundColor = accentColor; // Use the resolved accentColor 
    final imagePath = isCustomer 
        ? 'assets/images/customer_character.png' 
        : 'assets/images/craftsman_character.png';

    final screenHeight = MediaQuery.of(context).size.height;

    // Show Loading Screen to prevent flickering of Form-Mode before View-Mode is decided
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0E121A),
        body: Center(
          child: CircularProgressIndicator(color: accentColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor, 
      body: Stack(
        children: [
          // A. 3D Character Image
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            height: screenHeight * 0.30,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter, 
            ),
          ),


          // B. Back Button (Always visible)
          Positioned(
            top: 40,
            left: 20,
            child: SafeArea(
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Icon(Icons.arrow_back_ios_new, size: 20, color: accentColor), 
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          
          // C. Edit Toggle Button (Only in View Mode)
          if (_isViewMode)
            Positioned(
              top: 40,
              right: 20,
              child: SafeArea(
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Icon(Icons.edit, size: 20, color: accentColor), 
                  ),
                  onPressed: () => setState(() => _isViewMode = false),
                ),
              ),
            ),

          // D. Glass Card Content
          Positioned(
            top: screenHeight * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF151515).withValues(alpha: 0.95), 
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 40, 
                    spreadRadius: 0,
                    offset: const Offset(0, -10)
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                    child: _isViewMode 
                        ? _buildViewMode(accentColor) // SHOW READ-ONLY view
                        : _buildEditForm(accentColor, isCustomer), // SHOW EDIT FORM
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- VIEW MODE WIDGETS ---
  Widget _buildViewMode(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center alignment for profile view
      children: [
         // Avatar (View Only, larger)
         Container(
           width: 120,
           height: 120,
           decoration: BoxDecoration(
             shape: BoxShape.circle,
             color: const Color(0xFF2A2A2A),
             border: Border.all(color: accentColor, width: 3),
             boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))],
             image: _avatarUrl != null 
                 ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover)
                 : null,
           ),
           child: _avatarUrl == null 
               ? const Icon(Icons.person, size: 60, color: Colors.white)
               : null,
         ),
         const SizedBox(height: 24),
         
         // Name
         Text(
           '${_firstNameController.text} ${_lastNameController.text}',
           style: const TextStyle(
             fontFamily: 'Outfit',
             fontSize: 28, 
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         if (_companyController.text.isNotEmpty)
           Padding(
             padding: const EdgeInsets.only(top: 4.0),
             child: Text(
               _companyController.text,
               style: TextStyle(fontSize: 18, color: accentColor, fontWeight: FontWeight.w500),
             ),
           ),
           
         const SizedBox(height: 40),
         
         // Info Tiles
         Container(
           padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(
             color: const Color(0xFF252525),
             borderRadius: BorderRadius.circular(20),
           ),
           child: Column(
             children: [
               _buildInfoRow(Icons.phone_outlined, 'Telefon', _phoneController.text),
               const Divider(color: Colors.white12, height: 30),
               _buildInfoRow(Icons.location_on_outlined, 'Adresse', '${_streetController.text} ${_houseNumberController.text}\n${_zipCodeController.text} ${_cityController.text}'),
             ],
           ),
         ),
         
         const SizedBox(height: 40),
         // Optional: Action Button (e.g. Logout or to Dashboard if accessed via deep link)
      ],
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value.isNotEmpty ? value : '-', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  // --- EDIT MODE WIDGETS ---
  Widget _buildEditForm(Color accentColor, bool isCustomer) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
           Text(
            _isEditing ? 'Profil bearbeiten' : 'Profil vervollständigen',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white, 
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isEditing 
                ? 'Ändere deine Daten hier.' 
                : 'Erzähl uns ein bisschen über dich.',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Avatar Picker (Editable)
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2A2A2A), 
                      border: Border.all(color: accentColor, width: 2), 
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                      image: _webImage != null
                          ? DecorationImage(image: MemoryImage(_webImage!), fit: BoxFit.cover)
                          : _avatarFile != null
                              ? DecorationImage(image: FileImage(_avatarFile!), fit: BoxFit.cover)
                              : (_avatarUrl != null ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover) : null),
                    ),
                    child: (_webImage == null && _avatarFile == null && _avatarUrl == null)
                        ? const Opacity(
                            opacity: 0.5,
                            child: Icon(Icons.person, size: 50, color: Colors.white),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor, 
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Form Fields
          Row(
            children: [
              Expanded(child: _buildTextField('Vorname', _firstNameController, icon: Icons.person_outline, accentColor: accentColor, isReadOnly: _isEditing)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Nachname', _lastNameController, icon: Icons.person_outline, accentColor: accentColor, isReadOnly: _isEditing)),
            ],
          ),
          if (_isEditing)
             Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8), 
              child: Text('Hinweis: Namensänderung nur über Support.', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
             ),
          const SizedBox(height: 16),

          _buildTextField('Telefonnummer', _phoneController, icon: Icons.phone_outlined, isNumber: true, accentColor: accentColor),
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 12, color: Colors.white.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Text(
                  'Nur für die interne Abwicklung sichtbar.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ],
            ),
          ),

          if (!isCustomer) ...[
            _buildTextField('Firmenname (Optional)', _companyController, icon: Icons.business, required: false, accentColor: accentColor),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(flex: 2, child: _buildTextField('Straße', _streetController, icon: Icons.home_outlined, accentColor: accentColor)),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: _buildTextField('Nr.', _houseNumberController, icon: null, accentColor: accentColor)),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(flex: 1, child: _buildTextField('PLZ', _zipCodeController, icon: null, isNumber: true, accentColor: accentColor)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildTextField('Stadt', _cityController, icon: Icons.location_city, accentColor: accentColor)),
            ],
          ),
          
          const SizedBox(height: 40),

          // Action Buttons
          Row(
            children: [
               if (_isEditing) // Show "Cancel" only if we are editing an existing profile
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isViewMode = true),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Abbrechen'),
                    ),
                  ),
                ),
              
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor, 
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: accentColor.withValues(alpha: 0.4),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('Speichern'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool required = true, bool isNumber = false, required Color accentColor, bool isReadOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly, // Integrity feature
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      // White Text for Dark Background (Grey if locked)
      style: TextStyle(fontWeight: FontWeight.w600, color: isReadOnly ? Colors.white54 : Colors.white), 
      validator: required ? (value) => (value == null || value.isEmpty) ? 'Pflichtfeld' : null : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 20) : null,
        suffixIcon: isReadOnly ? Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.3), size: 16) : null, // Lock Icon
        filled: true,
        fillColor: isReadOnly ? const Color(0xFF1A1A1A) : const Color(0xFF252525), // Darker Grey if locked
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          // Accent Color Border on Focus (unless locked)
          borderSide: isReadOnly ? BorderSide.none : BorderSide(color: accentColor, width: 1.5), 
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }
}
