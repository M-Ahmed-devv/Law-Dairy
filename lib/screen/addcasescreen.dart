import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/case_model.dart';
import '../services/dbservice.dart';
import '../services/notificationservice.dart';

class AddCaseScreen extends StatefulWidget {
  final DateTime? preselectedDate;
  const AddCaseScreen({Key? key, this.preselectedDate}) : super(key: key);

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _titleCtrl = TextEditingController();
  final _courtCtrl = TextEditingController();
  final _stageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.preselectedDate;
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Case Title aur Date lazmi hain!")),
      );
      return;
    }

    String timeStr =
        "${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}";

    CaseModel c = CaseModel(
      title: _titleCtrl.text.trim(),
      court: _courtCtrl.text.trim(),
      stage: _stageCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      hearingDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      reminderTime: timeStr,
    );

    int id = await DBService.instance.insertCase(c);
    await NotificationService.scheduleAlert(
      id: id,
      title: c.title,
      court: c.court,
      hearingDate: _selectedDate!,
      reminderTime: timeStr,
    );

    if (mounted) Navigator.pop(context, _selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E9D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A2E2B),
        title: const Text("Add New Case"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: "Case Title (e.g. State VS Ali)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courtCtrl,
              decoration: const InputDecoration(
                labelText: "Court Name",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _stageCtrl,
              decoration: const InputDecoration(
                labelText: "Stage (Evidence/Arguments)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Case Notes / Details",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF4A2E2B)),
                title: Text(
                  _selectedDate == null
                      ? "Select Hearing Date"
                      : DateFormat('EEE, dd MMM yyyy').format(_selectedDate!),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.redAccent),
                title: Text("Reminder: 1 day before at ${_reminderTime.format(context)}"),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime,
                  );
                  if (picked != null) setState(() => _reminderTime = picked);
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("SAVE CASE", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A2E2B),
                  foregroundColor: Colors.white,
                ),
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}