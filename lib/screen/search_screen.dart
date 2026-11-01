import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/case_model.dart';
import '../services/dbservice.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<CaseModel> _allCases = [];
  List<CaseModel> _filteredCases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    try {
      final cases = await DBService.instance.getAllCases();
      setState(() {
        _allCases = cases;
        _filteredCases = cases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterCases(String query) {
    final lowerQuery = query.toLowerCase().trim();
    setState(() {
      if (lowerQuery.isEmpty) {
        _filteredCases = _allCases;
      } else {
        _filteredCases = _allCases.where((c) {
          return c.title.toLowerCase().contains(lowerQuery) ||
              c.court.toLowerCase().contains(lowerQuery) ||
              c.stage.toLowerCase().contains(lowerQuery) ||
              c.notes.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E9D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A2E2B),
        title: const Text("Search Cases"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF4A2E2B),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _filterCases,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: "Search Title, Court, Stage, Notes...",
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchCtrl.clear();
                          _filterCases('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.18),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
            child: Row(
              children: [
                Icon(Icons.folder_open, size: 18, color: Colors.brown.shade700),
                const SizedBox(width: 6),
                Text(
                  _isLoading ? "Loading..." : "${_filteredCases.length} cases found",
                  style: TextStyle(
                    color: Colors.brown.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A2E2B)))
                : _filteredCases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 70, color: Colors.brown.shade300),
                            const SizedBox(height: 12),
                            Text(
                              "No cases found",
                              style: TextStyle(fontSize: 17, color: Colors.brown.shade400),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _filteredCases.length,
                        itemBuilder: (context, index) {
                          final c = _filteredCases[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF4A2E2B),
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ),
                              title: Text(
                                c.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A2E2B),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${c.court}  •  ${c.stage}",
                                    style: TextStyle(fontSize: 13, color: Colors.brown.shade700),
                                  ),
                                  Text(
                                    "Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(c.hearingDate))}",
                                    style: TextStyle(fontSize: 12, color: Colors.brown.shade500),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              onTap: () {
                                try {
                                  DateTime caseDate = DateTime.parse(c.hearingDate);
                                  Navigator.pop(context, caseDate);
                                } catch (_) {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}