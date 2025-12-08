import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/features/schedules/presentation/cubit/schedules_cubit.dart';
import 'package:tifli/features/schedules/data/models/schedules_model.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final Color primary = const Color(0xFFBA224D);
  final TextEditingController newItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load checklists when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChecklistCubit>().loadChecklist();
    });
  }

  void addItem() async {
    if (newItemController.text.trim().isEmpty) return;
    context.read<ChecklistCubit>().addItem(newItemController.text.trim());
    newItemController.clear();
  }

  void toggleItem(ChecklistItem item) {
    context.read<ChecklistCubit>().toggleItem(item);
  }

  void deleteItem(ChecklistItem item) {
    context.read<ChecklistCubit>().deleteItem(item.id);
  }

  @override
  void dispose() {
    newItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Checklist'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<ChecklistCubit, ChecklistState>(
          builder: (context, state) {
            List<ChecklistItem> items = [];
            if (state is ChecklistLoaded) {
              items = state.items;
            }

            int completed = items.where((item) => item.done).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daily Checklist",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$completed of ${items.length} completed",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundImage: const AssetImage("assets/profile.jpg"),
                      backgroundColor: Colors.grey[200],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ADD NEW ITEM
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newItemController,
                        decoration: InputDecoration(
                          hintText: "Add new task...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => addItem(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.add, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // CHECKLIST ITEMS
                Expanded(
                  child: state is ChecklistLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state is ChecklistError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Error: ${state.message}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        )
                      : items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No tasks yet",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Add your first task above",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return checklistItem(
                              item: item,
                              onToggle: () => toggleItem(item),
                              onDelete: () => deleteItem(item),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------- Checklist Item Widget ----------
  Widget checklistItem({
    required ChecklistItem item,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: item.done ? primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.done ? primary : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  item.done ? Icons.check_circle : Icons.circle_outlined,
                  color: item.done ? primary : Colors.grey,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: onToggle,
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    decoration: item.done ? TextDecoration.lineThrough : null,
                    color: item.done ? Colors.black54 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red.shade400,
              iconSize: 22,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
