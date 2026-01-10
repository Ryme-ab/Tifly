import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tifli/features/navigation/presentation/state/app_bar_config.dart';
import 'package:tifli/features/navigation/presentation/screens/drawer.dart';
import 'package:tifli/l10n/app_localizations.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';


import '../cubit/gallery_cubit.dart';
import '../../data/models/gallery_item.dart';
import 'add_memory_page.dart';
import '../widgets/memory_modal.dart';

class MemoriesPage extends StatefulWidget {
  final String childId;
  final String userId;

  const MemoriesPage({super.key, required this.childId, required this.userId});

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  late final GalleryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<GalleryCubit>();
    // Avoid calling Supabase with empty/invalid UUID which causes 22P02 errors
    if (widget.childId.isEmpty) {
      // Defer showing a prompt to next frame if needed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noChildSelected)),
        );
        Navigator.of(context).pop();
      });
    } else {
      _cubit.loadGallery(widget.childId);
    }
  }

  // Helper: extracts items list from GalleryState
  List<GalleryItem> _extractItems(GalleryState state) {
    return state.items;
  }

  bool _isLoading(GalleryState state) {
    return state.loading;
  }

  String? _extractError(GalleryState state) {
    return state.error;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppBarConfig>(
      create: (_) => AppBarConfig(title: AppLocalizations.of(context)!.memories),
      child: Scaffold(
        appBar: const CustomAppBar(),
        drawer: const Tiflidrawer(),
        body: BlocBuilder<GalleryCubit, GalleryState>(
          builder: (context, state) {
            final loading = _isLoading(state);
            final error = _extractError(state);
            final items = _extractItems(state);

            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (error != null && error.isNotEmpty) {
              return Center(child: Text(error));
            }

            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.noMemoriesYetPrompt,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: items.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _AddTile(
                      onTap: () async {
                        final res = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => AddMemoryPage(
                              childId: widget.childId,
                              userId: widget.userId,
                            ),
                          ),
                        );
                        if (res == true) _cubit.loadGallery(widget.childId);
                      },
                    );
                  }

                  final item = items[index - 1];
                  return _GalleryTile(
                    item: item,
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => MemoryModal(memory: item),
                      );
                    },
                    onEdit: () async {
                      final res = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => AddMemoryPage(
                            childId: widget.childId,
                            userId: widget.userId,
                            existing: item,
                          ),
                        ),
                      );
                      if (res == true) _cubit.loadGallery(widget.childId);
                    },
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!.deleteMemory),
                          content: Text(AppLocalizations.of(context)!.actionCannotBeUndone),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(AppLocalizations.of(context)!.delete),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await context.read<GalleryCubit>().deleteMemory(item);
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final res = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => AddMemoryPage(
                  childId: widget.childId,
                  userId: widget.userId,
                ),
              ),
            );
            if (res == true) _cubit.loadGallery(widget.childId);
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              Icon(Icons.add, size: 36, color: Colors.grey),
              SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.addMemory, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _GalleryTile({
    required this.item,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = item.pictureDate != null
        ? DateFormat.yMMMd().format(item.pictureDate!)
        : '';
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: item.filePath,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[200]),
                errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title ?? '',
                      style: AppFonts.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (dateText.isNotEmpty)
                      Text(
                        dateText,
                        style: AppFonts.small.copyWith(color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: Material(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) onEdit!();
                    if (value == 'delete' && onDelete != null) onDelete!();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(AppLocalizations.of(context)!.edit)),
                    PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context)!.delete)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
