import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class MedicationLogsScreen extends StatefulWidget {
  const MedicationLogsScreen({super.key});

  @override
  State<MedicationLogsScreen> createState() => _MedicationLogsScreenState();
}

class _MedicationLogsScreenState extends State<MedicationLogsScreen> {
  List<Map<String, dynamic>> logs = [
    {
      "type": "Vitamin D",
      "icon": Icons.medication_liquid,
      "time": "09:00 AM",
      "dose": "1 drop",
      "color": const Color(0xffe8f3ff),
    },
    {
      "type": "Paracetamol",
      "icon": Icons.vaccines,
      "time": "02:30 PM",
      "dose": "2.5ml",
      "color": const Color(0xfffff0f0),
    },
    {
      "type": "Nasal Spray",
      "icon": Icons.healing,
      "time": "07:00 PM",
      "dose": "1 spray",
      "color": const Color(0xfffff9e5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f4f8),
      appBar: const CustomAppBar(title: "Medication Tracker"),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Medication Logs",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundImage: const AssetImage("assets/profile.jpg"),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Logs
            ...logs.map((log) => _logCard(log)),

            const SizedBox(height: 20),

            // Summary chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Medication Summary",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _miniBarChart(),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffb03a57),
        onPressed: _addDummy,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _logCard(Map<String, dynamic> log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(log["type"] + log.hashCode.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xffb03a57),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => setState(() => logs.remove(log)),
        child: Container(
          decoration: BoxDecoration(
            color: log["color"],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(log["icon"], color: const Color(0xffb03a57)),
              ),
              const SizedBox(width: 12),

              // Text section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log["type"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      log["time"],
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              // Dose
              Text(
                log["dose"],
                style: const TextStyle(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),

              // Completed tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffb03a57),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Taken",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  // YOU CAN CONNECT TO YOUR MEDICATION EDIT PAGE LATER
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniBarChart() {
    final barData = [
      {"label": "Vit D", "value": 1.0, "color": const Color(0xffe3f2fd)},
      {"label": "Para", "value": 2.0, "color": const Color(0xffffcdd2)},
      {"label": "Spray", "value": 1.0, "color": const Color(0xfffff9c4)},
    ];

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= barData.length)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      barData[index]["label"] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(barData.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: barData[i]["value"] as double,
                  color: barData[i]["color"] as Color,
                  width: 30,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _addDummy() {
    setState(() {
      logs.insert(0, {
        "type": "New Medication",
        "icon": Icons.medication,
        "time": DateFormat('hh:mm a').format(DateTime.now()),
        "dose": "1 ml",
        "color": const Color(0xfff0eaff),
      });
    });
  }
}
