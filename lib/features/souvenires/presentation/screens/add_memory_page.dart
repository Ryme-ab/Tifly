import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';
import 'package:tifli/l10n/app_localizations.dart';

import '../../data/models/gallery_item.dart';
import '../cubit/gallery_cubit.dart';

class AddMemoryPage extends StatefulWidget {
  final String childId;
  final String userId;
  final GalleryItem? existing; // when provided, acts as edit

  const AddMemoryPage({
    super.key,
    required this.childId,
    required this.userId,
    this.existing,
  });

  @override
  State<AddMemoryPage> createState() => _AddMemoryPageState();
}

class _AddMemoryPageState extends State<AddMemoryPage> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  File? _pickedImage;
  bool _submitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title ?? '';
      _selectedDate = widget.existing!.pictureDate ?? DateTime.now();
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? p = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (p != null) setState(() => _pickedImage = File(p.path));
  }

  Future<void> _takePhoto() async {
    final XFile? p = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (p != null) setState(() => _pickedImage = File(p.path));
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _submit() async {
    final isEdit = widget.existing != null;
    if (!isEdit &&
        (_pickedImage == null || _titleController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleasePickImageAndEnterTitle,
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      print('=== ADD MEMORY PAGE: SUBMIT START ===');
      final cubit = context.read<GalleryCubit>();
      if (isEdit) {
        await cubit.updateMemory(
          id: widget.existing!.id,
          title: _titleController.text.trim(),
          pictureDate: _selectedDate,
          newPicture: _pickedImage,
        );
      } else {
        // Call addMemory and wait for it to complete
        await cubit.addMemory(
          childId: widget.childId,
          uploadedBy: widget.userId,
          title: _titleController.text.trim(),
          pictureDate: _selectedDate,
          picture: _pickedImage!,
        );
      }

      // Check if there was an error in the cubit state
      final currentState = cubit.state;
      if (currentState.error != null && currentState.error!.isNotEmpty) {
        print('=== ADD MEMORY PAGE: ERROR IN STATE ===');
        print('Error: ${currentState.error}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.uploadFailedWithError(currentState.error!),
              ),
            ),
          );
        }
      } else {
        print('=== ADD MEMORY PAGE: SUCCESS ===');
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('=== ADD MEMORY PAGE: EXCEPTION ===');
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.uploadFailedWithError(e.toString()),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMd().format(_selectedDate);
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isEdit
              ? AppLocalizations.of(context)!.editMemory
              : AppLocalizations.of(context)!.addMemory,
          style: AppFonts.heading2.copyWith(color: AppColors.textPrimaryLight),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: Text(
                            AppLocalizations.of(context)!.chooseFromGallery,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _pickFromGallery();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: Text(AppLocalizations.of(context)!.takePhoto),
                          onTap: () {
                            Navigator.pop(context);
                            _takePhoto();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: _pickedImage == null
                  ? (isEdit && widget.existing?.filePath != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.existing!.filePath,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 32),
                                  SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.tapToAddPhoto,
                                  ),
                                ],
                              ),
                            ),
                          )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _pickedImage!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.title,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.dateLabel(dateText),
                  style: AppFonts.body.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(AppLocalizations.of(context)!.change),
                ),
              ],
            ),
            const Spacer(),
            if (isEdit)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: Text(
                      AppLocalizations.of(context)!.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onPressed: _submitting
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(context)!.deleteMemory,
                                ),
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.actionCannotBeUndone,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancel,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      AppLocalizations.of(context)!.delete,
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              setState(() => _submitting = true);
                              try {
                                await context.read<GalleryCubit>().deleteMemory(
                                  widget.existing!,
                                );
                                if (mounted) Navigator.of(context).pop(true);
                              } finally {
                                if (mounted) {
                                  setState(() => _submitting = false);
                                }
                              }
                            }
                          },
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit
                            ? AppLocalizations.of(context)!.saveChanges
                            : AppLocalizations.of(context)!.save,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
