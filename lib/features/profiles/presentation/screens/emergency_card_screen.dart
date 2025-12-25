import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';

import 'package:tifli/features/profiles/domain/entities/emergency_card_entity.dart';
import 'package:tifli/features/profiles/presentation/cubit/emergency_card_cubit.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/features/navigation/presentation/screens/drawer.dart';
import 'emergency_card_form_screen.dart';

class EmergencyCardScreen extends StatelessWidget {
  const EmergencyCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      drawer: const Tiflidrawer(),
      appBar: const CustomAppBar(title: "Emergency Medical Card"),
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<EmergencyCardCubit, EmergencyCardState>(
        builder: (context, state) {
          if (state is EmergencyCardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EmergencyCardError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is EmergencyCardLoaded) {
            final card = state.card;
            if (card == null) {
              return _buildEmptyState(context);
            }
            return _buildEmergencyCard(context, card);
          }

          return const Center(child: Text('Select a child to view emergency card.'));
        },
      ),
      bottomNavigationBar: BlocBuilder<EmergencyCardCubit, EmergencyCardState>(
        builder: (context, state) {
          if (state is EmergencyCardLoaded && state.card != null) {
            return _buildBottomAppBar(context, state.card!);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              "No emergency card found for this child.",
              textAlign: TextAlign.center,
              style: AppFonts.heading2,
            ),
            const SizedBox(height: 16),
            const Text(
              "Create an emergency card to store critical medical information and contacts.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmergencyCardFormScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Create Emergency Card", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, EmergencyCard card) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadOnlyHeader(),
          const SizedBox(height: 20),
          _buildInfoSection("Child Information", [
            _buildDetailRow(Icons.person, "Full Name", card.fullName),
            _buildDetailRow(Icons.cake, "Date of Birth", DateFormat('MMMM dd, yyyy').format(card.dateOfBirth)),
          ]),
          const SizedBox(height: 16),
          _buildInfoSection("Medical Information", [
            _buildBloodTypeChip(card.bloodType),
            if (card.allergies.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text("Allergies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: card.allergies.map((a) => Chip(
                  label: Text(a),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  side: BorderSide.none,
                )).toList(),
              ),
            ],
            if (card.chronicConditions != null && card.chronicConditions!.isNotEmpty)
              _buildDetailRow(Icons.health_and_safety, "Chronic Conditions", card.chronicConditions!),
            if (card.medications.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text("Medications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ...card.medications.map((m) => _buildDetailRow(Icons.medication, m.name, m.dosage)),
            ],
          ]),
          const SizedBox(height: 16),
          _buildInfoSection("Contacts", [
            _buildDetailRow(Icons.person, "Primary Contact", "${card.emergencyContacts.primaryName} (${card.emergencyContacts.primaryPhone})"),
            if (card.emergencyContacts.secondaryName != null)
              _buildDetailRow(Icons.person_outline, "Secondary Contact", "${card.emergencyContacts.secondaryName} (${card.emergencyContacts.secondaryPhone})"),
            _buildDetailRow(Icons.local_hospital, "Doctor", "${card.medicalContacts.doctorName ?? 'N/A'} (${card.medicalContacts.doctorPhone ?? 'N/A'})"),
          ]),
          const SizedBox(height: 16),
          _buildInfoSection("Other Info", [
            if (card.vaccinationSummary != null)
              _buildDetailRow(Icons.vaccines, "Vaccinations", card.vaccinationSummary!),
            if (card.healthIdentifiers.nationalId != null)
              _buildDetailRow(Icons.badge, "National ID", card.healthIdentifiers.nationalId!),
            if (card.medicalNotes != null)
              _buildDetailRow(Icons.notes, "Notes", card.medicalNotes!),
          ]),
          const SizedBox(height: 80), // Space for fab/navbar
        ],
      ),
    );
  }

  Widget _buildReadOnlyHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: Colors.red, size: 20),
          SizedBox(width: 12),
          Text(
            "Emergency View – Read Only",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeChip(String bloodType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bloodtype, color: AppColors.primary, size: 18),
          const SizedBox(width: 4),
          Text("Blood Type: $bloodType", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context, EmergencyCard card) {
    return BottomAppBar(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHighContrastButton(
            Icons.call,
            "Call Parent",
            Colors.green,
            () => _launchCaller(card.emergencyContacts.primaryPhone),
          ),
          _buildHighContrastButton(
            Icons.medical_information,
            "Call Doctor",
            Colors.blue,
            () => _launchCaller(card.medicalContacts.doctorPhone ?? ""),
          ),
           _buildHighContrastButton(
            Icons.share,
            "Share",
            Colors.orange,
            () => _shareCard(card),
          ),
        ],
      ),
    );
  }

  Widget _buildHighContrastButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _launchCaller(String phone) async {
    if (phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _shareCard(EmergencyCard card) {
    final text = "EMERGENCY MEDICAL CARD\n"
        "Child: ${card.fullName}\n"
        "Blood Type: ${card.bloodType}\n"
        "Allergies: ${card.allergies.join(', ')}\n"
        "Primary Contact: ${card.emergencyContacts.primaryName} (${card.emergencyContacts.primaryPhone})";
    Share.share(text);
  }
}
