import 'package:flutter/material.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final Color primary = const Color(0xFFBA224D);

  List<Map<String, dynamic>> checklist = [
    {"title": "Feed the baby", "done": false},
    {"title": "Change diaper", "done": false},
    {"title": "Check temperature", "done": false},
    {"title": "Prepare sleep area", "done": false},
  ];

  final TextEditingController newItemController = TextEditingController();

  void addItem() {
    if (newItemController.text.trim().isEmpty) return;

    setState(() {
      checklist.add({"title": newItemController.text.trim(), "done": false});
      newItemController.clear();
    });
  }

  void toggleItem(int index) {
    setState(() {
      checklist[index]["done"] = !checklist[index]["done"];
    });
  }

  void deleteItem(int index) {
    setState(() {
      checklist.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    int completed = checklist.where((item) => item["done"] == true).length;

    return Scaffold(
      appBar: AppBar(title: const Text("Checklist"), backgroundColor: primary),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER ----------------
            Text(
              "Daily Checklist",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$completed of ${checklist.length} completed",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),

            const SizedBox(height: 18),

            // ---------------- ADD NEW ITEM ----------------
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: newItemController,
                    decoration: InputDecoration(
                      hintText: "Add new task...",
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 24),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ---------------- CHECKLIST ITEMS ----------------
            Expanded(
              child: ListView.builder(
                itemCount: checklist.length,
                itemBuilder: (context, index) {
                  return checklistItem(
                    title: checklist[index]["title"],
                    done: checklist[index]["done"],
                    onToggle: () => toggleItem(index),
                    onDelete: () => deleteItem(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Checklist Item Widget ----------
  Widget checklistItem({
    required String title,
    required bool done,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: done ? primary.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done ? primary : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              done ? Icons.check_circle : Icons.circle_outlined,
              color: done ? primary : Colors.grey,
              size: 26,
            ),
          ),

          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                decoration: done ? TextDecoration.lineThrough : null,
                color: done ? Colors.black54 : Colors.black87,
                fontWeight: done ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.shade400,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
