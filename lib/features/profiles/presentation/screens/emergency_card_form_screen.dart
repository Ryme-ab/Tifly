import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/features/profiles/domain/entities/emergency_card_entity.dart';
import 'package:tifli/features/profiles/presentation/cubit/emergency_card_cubit.dart';

class EmergencyCardFormScreen extends StatefulWidget {
  final EmergencyCard? existingCard;

  const EmergencyCardFormScreen({super.key, this.existingCard});

  @override
  State<EmergencyCardFormScreen> createState() => _EmergencyCardFormScreenState();
}

class _EmergencyCardFormScreenState extends State<EmergencyCardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _chronicConditionsController;
  late TextEditingController _doctorNameController;
  late TextEditingController _doctorPhoneController;
  late TextEditingController _hospitalController;
  late TextEditingController _emergencyNumberController;
  late TextEditingController _primaryNameController;
  late TextEditingController _primaryPhoneController;
  late TextEditingController _secondaryNameController;
  late TextEditingController _secondaryPhoneController;
  late TextEditingController _vaccinationController;
  late TextEditingController _notesController;
  late TextEditingController _nationalIdController;
  late TextEditingController _insuranceController;

  final List<String> _allergies = [];
  final List<MedicationInfo> _medications = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final card = widget.existingCard;
    
    _fullNameController = TextEditingController(text: card?.fullName ?? "");
    _dobController = TextEditingController(text: card != null ? DateFormat('yyyy-MM-dd').format(card.dateOfBirth) : "");
    _bloodTypeController = TextEditingController(text: card?.bloodType ?? "");
    _chronicConditionsController = TextEditingController(text: card?.chronicConditions ?? "");
    _doctorNameController = TextEditingController(text: card?.medicalContacts.doctorName ?? "");
    _doctorPhoneController = TextEditingController(text: card?.medicalContacts.doctorPhone ?? "");
    _hospitalController = TextEditingController(text: card?.medicalContacts.hospitalName ?? "");
    _emergencyNumberController = TextEditingController(text: card?.medicalContacts.emergencyNumber ?? "");
    _primaryNameController = TextEditingController(text: card?.emergencyContacts.primaryName ?? "");
    _primaryPhoneController = TextEditingController(text: card?.emergencyContacts.primaryPhone ?? "");
    _secondaryNameController = TextEditingController(text: card?.emergencyContacts.secondaryName ?? "");
    _secondaryPhoneController = TextEditingController(text: card?.emergencyContacts.secondaryPhone ?? "");
    _vaccinationController = TextEditingController(text: card?.vaccinationSummary ?? "");
    _notesController = TextEditingController(text: card?.medicalNotes ?? "");
    _nationalIdController = TextEditingController(text: card?.healthIdentifiers.nationalId ?? "");
    _insuranceController = TextEditingController(text: card?.healthIdentifiers.insuranceNumber ?? "");

    if (card != null) {
      _selectedDate = card.dateOfBirth;
      _allergies.addAll(card.allergies);
      _medications.addAll(card.medications);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _bloodTypeController.dispose();
    _chronicConditionsController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _hospitalController.dispose();
    _emergencyNumberController.dispose();
    _primaryNameController.dispose();
    _primaryPhoneController.dispose();
    _secondaryNameController.dispose();
    _secondaryPhoneController.dispose();
    _vaccinationController.dispose();
    _notesController.dispose();
    _nationalIdController.dispose();
    _insuranceController.dispose();
    super.dispose();
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
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final childId = context.read<ChildSelectionCubit>().selectedChildId;
    if (childId == null) return;

    final card = EmergencyCard(
      id: widget.existingCard?.id ?? const Uuid().v4(),
      childId: childId,
      fullName: _fullNameController.text.trim(),
      dateOfBirth: _selectedDate!,
      bloodType: _bloodTypeController.text.trim(),
      allergies: List.from(_allergies),
      chronicConditions: _chronicConditionsController.text.trim(),
      medications: List.from(_medications),
      medicalContacts: MedicalContacts(
        doctorName: _doctorNameController.text.trim(),
        doctorPhone: _doctorPhoneController.text.trim(),
        hospitalName: _hospitalController.text.trim(),
        emergencyNumber: _emergencyNumberController.text.trim(),
      ),
      emergencyContacts: EmergencyContacts(
        primaryName: _primaryNameController.text.trim(),
        primaryPhone: _primaryPhoneController.text.trim(),
        secondaryName: _secondaryNameController.text.trim(),
        secondaryPhone: _secondaryPhoneController.text.trim(),
      ),
      vaccinationSummary: _vaccinationController.text.trim(),
      medicalNotes: _notesController.text.trim(),
      healthIdentifiers: HealthIdentifiers(
        nationalId: _nationalIdController.text.trim(),
        insuranceNumber: _insuranceController.text.trim(),
      ),
      updatedAt: DateTime.now(),
      syncStatus: 'pending',
    );

    context.read<EmergencyCardCubit>().saveEmergencyCard(card);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCard == null ? "Create Emergency Card" : "Edit Emergency Card"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle("General Information"),
              _buildTextField(_fullNameController, "Full Name", Icons.person, validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(_dobController, "Date of Birth", Icons.cake, validator: (v) => v!.isEmpty ? "Required" : null),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(_bloodTypeController, "Blood Type", Icons.bloodtype, validator: (v) => v!.isEmpty ? "Required" : null),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Allergies & Conditions"),
              _buildChronicConditionsSection(),
              const SizedBox(height: 12),
              _buildAllergiesSection(),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Medications"),
              _buildMedicationsSection(),

              const SizedBox(height: 24),
              _buildSectionTitle("Emergency Contacts"),
              _buildTextField(_primaryNameController, "Primary Contact Name", Icons.person, validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              _buildTextField(_primaryPhoneController, "Primary Contact Phone", Icons.phone, validator: (v) => v!.isEmpty ? "Required" : null, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(_secondaryNameController, "Secondary Contact Name", Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(_secondaryPhoneController, "Secondary Contact Phone", Icons.phone_android, keyboardType: TextInputType.phone),

              const SizedBox(height: 24),
              _buildSectionTitle("Medical Contacts"),
              _buildTextField(_doctorNameController, "Doctor Name", Icons.local_hospital),
              const SizedBox(height: 12),
              _buildTextField(_doctorPhoneController, "Doctor Phone", Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(_hospitalController, "Preferred Hospital", Icons.business),
              
              const SizedBox(height: 24),
              _buildSectionTitle("Identifiers & Notes"),
              _buildTextField(_nationalIdController, "National ID / ID Number", Icons.badge),
              const SizedBox(height: 12),
              _buildTextField(_insuranceController, "Insurance Number", Icons.security),
              const SizedBox(height: 12),
              _buildTextField(_vaccinationController, "Vaccination Summary", Icons.vaccines),
              const SizedBox(height: 12),
              _buildTextField(_notesController, "Additional Medical Notes", Icons.notes, maxLines: 4),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save Emergency Card", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildChronicConditionsSection() {
     return _buildTextField(_chronicConditionsController, "Chronic Conditions", Icons.health_and_safety, maxLines: 2);
  }

  Widget _buildAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Allergies", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ..._allergies.map((a) => InputChip(
              label: Text(a),
              onDeleted: () => setState(() => _allergies.remove(a)),
            )),
            ActionChip(
              label: const Icon(Icons.add, size: 20),
              onPressed: _showAddAllergyDialog,
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddAllergyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Allergy"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Enter allergy name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() => _allergies.add(controller.text.trim()));
              Navigator.pop(context);
            }
          }, child: const Text("Add")),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return Column(
      children: [
        ..._medications.asMap().entries.map((entry) => ListTile(
          title: Text(entry.value.name),
          subtitle: Text(entry.value.dosage),
          trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => _medications.removeAt(entry.key))),
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )).toList(),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _showAddMedicationDialog,
          icon: const Icon(Icons.add),
          label: const Text("Add Medication"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
        ),
      ],
    );
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Medication"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: "Medication Name")),
            TextField(controller: dosageController, decoration: const InputDecoration(hintText: "Dosage (e.g. 5ml twice daily)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () {
            if (nameController.text.isNotEmpty) {
              setState(() => _medications.add(MedicationInfo(name: nameController.text.trim(), dosage: dosageController.text.trim())));
              Navigator.pop(context);
            }
          }, child: const Text("Add")),
        ],
      ),
    );
  }
}
