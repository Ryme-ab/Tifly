import 'package:flutter/material.dart';
import 'package:tifli/core/config/supabaseClient.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class EditBabyScreen extends StatefulWidget {
  final Map<String, dynamic> babyData;

  const EditBabyScreen({super.key, required this.babyData});

  @override
  State<EditBabyScreen> createState() => _EditBabyScreenState();
}

class _EditBabyScreenState extends State<EditBabyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _circController;
  late TextEditingController _bloodTypeController;

  bool _isBoy = true;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.babyData['first_name'],
    );
    _dateController = TextEditingController(
      text: _formatDate(widget.babyData['birth_date']),
    );
    _weightController = TextEditingController(
      text: widget.babyData['born_weight']?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.babyData['born_height']?.toString() ?? '',
    );
    _circController = TextEditingController(
      text: widget.babyData['circum']?.toString() ?? '',
    );
    _bloodTypeController = TextEditingController(
      text: widget.babyData['blood_type'] ?? '',
    );

    _isBoy = widget.babyData['gender'] == 'male';
    if (widget.babyData['birth_date'] != null) {
      _selectedDate = DateTime.parse(widget.babyData['birth_date']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _circController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateBaby() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updateData = <String, dynamic>{
        'first_name': _nameController.text.trim(),
        'gender': _isBoy ? 'male' : 'female',
      };

      if (_uploadedImageUrl != null) {
        updateData['profile_image'] = _uploadedImageUrl;
      }

      if (_selectedDate != null) {
        updateData['birth_date'] = _selectedDate!.toIso8601String();
      }

      if (_weightController.text.isNotEmpty) {
        updateData['born_weight'] = int.parse(_weightController.text);
      }

      if (_heightController.text.isNotEmpty) {
        updateData['born_height'] = int.parse(_heightController.text);
      }

      if (_circController.text.isNotEmpty) {
        updateData['circum'] = int.parse(_circController.text);
      }

      if (_bloodTypeController.text.isNotEmpty) {
        updateData['blood_type'] = _bloodTypeController.text.trim();
      }

      await SupabaseClientManager().client
          .from('children')
          .update(updateData)
          .eq('id', widget.babyData['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Baby information updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // NEW: Image Upload Variables
  Uint8List? _imageBytes;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  // NEW: Image Picker Logic
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final bytes = await picked.readAsBytes();
      final bucket = 'baby_profiles';
      final fileName = "baby_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Upload
      await Supabase.instance.client.storage
          .from(bucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get URL
      String publicUrl = Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(fileName);

      if (publicUrl.isEmpty) {
        publicUrl = await Supabase.instance.client.storage
            .from(bucket)
            .createSignedUrl(fileName, 3600);
      }

      setState(() {
        _imageBytes = bytes;
        _uploadedImageUrl = publicUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image upload failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFBE185D);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Baby Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // NEW: Profile Picture Upload Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (_uploadedImageUrl != null
                                    ? NetworkImage(_uploadedImageUrl!)
                                    : (widget.babyData['profile_image'] != null
                                          ? NetworkImage(
                                              widget.babyData['profile_image'],
                                            )
                                          : null))
                                as ImageProvider?,
                      child:
                          (_imageBytes == null &&
                              _uploadedImageUrl == null &&
                              widget.babyData['profile_image'] == null)
                          ? Icon(
                              Icons.child_care,
                              size: 50,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: _isUploadingImage
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _nameController,
                label: 'Baby Name',
                icon: Icons.child_care,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dateController,
                    label: 'Birth Date',
                    icon: Icons.calendar_today,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Gender',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _isBoy = true),
                      icon: const Icon(Icons.child_care, size: 18),
                      label: const Text('Boy'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: _isBoy
                            ? Colors.cyan[700]
                            : Colors.cyan[300],
                        backgroundColor: _isBoy
                            ? Colors.cyan[100]
                            : Colors.grey[100],
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _isBoy = false),
                      icon: const Icon(Icons.face_3, size: 18),
                      label: const Text('Girl'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: !_isBoy
                            ? primaryColor
                            : Colors.pink[300],
                        backgroundColor: !_isBoy
                            ? const Color(0xFFFFE4E9)
                            : Colors.grey[100],
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _weightController,
                label: 'Birth Weight (kg)',
                icon: Icons.monitor_weight,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _heightController,
                label: 'Birth Height (cm)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _circController,
                label: 'Head Circumference (cm)',
                icon: Icons.radio_button_unchecked,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _bloodTypeController,
                label: 'Blood Type',
                icon: Icons.bloodtype,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _updateBaby,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
