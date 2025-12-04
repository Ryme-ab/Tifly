import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/baby_model.dart';
import '../cubit/baby_cubit.dart';

class AddBabyProfilePictureScreen extends StatefulWidget {
  final Baby baby;

  const AddBabyProfilePictureScreen({super.key, required this.baby});

  @override
  State<AddBabyProfilePictureScreen> createState() =>
      _AddBabyProfilePictureScreenState();
}

class _AddBabyProfilePictureScreenState
    extends State<AddBabyProfilePictureScreen> {
  Uint8List? imageBytes; // Works for all platforms
  bool loading = false;
  String? uploadedImageUrl;

  Future<void> _pickAndUpload() async {
    try {
      setState(() => loading = true);

      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      // Always read bytes — works on all platforms including web
      final bytes = await picked.readAsBytes();
      imageBytes = bytes;

      final bucket = 'baby_profiles';
      final fileName = "baby_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Upload using uploadBinary (correct type)
      await Supabase.instance.client.storage
          .from(bucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      String publicUrl = Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(fileName);

      if (publicUrl.isEmpty) {
        publicUrl = await Supabase.instance.client.storage
            .from(bucket)
            .createSignedUrl(fileName, 3600);
      }

      // Save URL in database
      await Supabase.instance.client
          .from("children")
          .update({'profile_image': publicUrl})
          .eq("id", widget.baby.id!);

      setState(() => uploadedImageUrl = publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  ImageProvider? _getImageProvider() {
    if (imageBytes != null) return MemoryImage(imageBytes!);
    if (uploadedImageUrl != null) return NetworkImage(uploadedImageUrl!);
    if (widget.baby.profileImage != null) {
      return NetworkImage(widget.baby.profileImage!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<BabyCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Upload Profile Picture")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: _getImageProvider(),
                child: _getImageProvider() == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : null,
              ),
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _pickAndUpload,
                      child: const Text("Choose & Upload Image"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
