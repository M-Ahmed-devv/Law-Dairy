import 'package:flutter/material.dart';
import '../models/case_model.dart';
import '../services/dbservice.dart';

class EditCaseScreen extends StatefulWidget {
  final CaseModel caseData;
  const EditCaseScreen({Key? key, required this.caseData}) : super(key: key);

  @override
  State<EditCaseScreen> createState() => _EditCaseScreenState();
}

class _EditCaseScreenState extends State<EditCaseScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _courtCtrl;
  late TextEditingController _stageCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.caseData.title);
    _courtCtrl = TextEditingController(text: widget.caseData.court);
    _stageCtrl = TextEditingController(text: widget.caseData.stage);
    _notesCtrl = TextEditingController(text: widget.caseData.notes);
  }

  Future<void> _save() async {
    widget.caseData.title = _titleCtrl.text.trim();
    widget.caseData.court = _courtCtrl.text.trim();
    widget.caseData.stage = _stageCtrl.text.trim();
    widget.caseData.notes = _notesCtrl.text;

    await DBService.instance.updateCase(widget.caseData);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Case?"),
        content: const Text("Kya aap yeh case delete karna chahte hain?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("NO"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("YES", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBService.instance.deleteCase(widget.caseData.id!);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A2E2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A201D),
        title: const Text("Case Notepad"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: "Delete Case",
            onPressed: _delete,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.greenAccent),
            tooltip: "Save",
            onPressed: _save,
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF6E3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF8B5E3C), width: 2),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF4A2E2B),
                    ),
                    decoration: const InputDecoration(
                      labelText: "Case Title",
                      labelStyle: TextStyle(color: Colors.brown),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _courtCtrl,
                          decoration: const InputDecoration(
                            labelText: "Court",
                            labelStyle: TextStyle(color: Colors.brown),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _stageCtrl,
                          decoration: const InputDecoration(
                            labelText: "Stage",
                            labelStyle: TextStyle(color: Colors.brown),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "NOTES (Notepad):",
                  style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(color: Colors.brown, thickness: 1.2, indent: 16, endIndent: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: null,
                  expands: true,
                  autofocus: true,
                  cursorColor: Colors.black,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 17, height: 1.5, color: Colors.black87),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Start typing case notes here...",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}