import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/case_model.dart';
import '../services/dbservice.dart';
import 'addcasescreen.dart';
import 'editcasescreen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 365);
  final DateTime _baseDate = DateTime.now();
  List<CaseModel> _allCases = [];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    final cases = await DBService.instance.getAllCases();
    if (mounted) {
      setState(() => _allCases = cases);
    }
  }

  DateTime _getDateByIndex(int index) {
    return _baseDate.add(Duration(days: index - 365));
  }

  int _getIndexByDate(DateTime date) {
    DateTime onlyDate = DateTime(date.year, date.month, date.day);
    DateTime onlyBase =
        DateTime(_baseDate.year, _baseDate.month, _baseDate.day);
    return onlyDate.difference(onlyBase).inDays + 365;
  }

  void _jumpToDate(DateTime date) {
    _pageController.animateToPage(
      _getIndexByDate(date),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  List<CaseModel> _getCasesForDate(DateTime date) {
    String formatted = DateFormat('yyyy-MM-dd').format(date);
    return _allCases.where((c) => c.hearingDate == formatted).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit Lawyer Diary?"),
            content: const Text("Kya aap app band karna chahte hain?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("NO", style: TextStyle(color: Colors.brown)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("YES", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF4A2E2B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A201D),
          elevation: 0,
          title: const Text(
            "Lawyer's Diary 2026",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: "Search Cases",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
                if (result != null && result is DateTime) {
                  _loadCases();
                  _jumpToDate(result);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.today),
              tooltip: "Go to Today",
              onPressed: () => _pageController.animateToPage(
                365,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
            ),
          ],
        ),
        body: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, index) {
            DateTime date = _getDateByIndex(index);
            List<CaseModel> cases = _getCasesForDate(date);
            return _buildPage(date, cases, index);
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF3A201D),
          icon: const Icon(Icons.add),
          label: const Text("Add Case"),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCaseScreen()),
            );
            _loadCases();
            if (result != null && result is DateTime) {
              _jumpToDate(result);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPage(DateTime date, List<CaseModel> cases, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = (_pageController.page ?? 0) - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        return Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((_pageController.position.haveDimensions
                    ? ((_pageController.page ?? 0) - index)
                    : 0) *
                0.8),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _pageContent(date, cases),
    );
  }

  Widget _pageContent(DateTime date, List<CaseModel> cases) {
    String day = DateFormat('EEEE').format(date).toUpperCase();
    String dateStr = DateFormat('dd').format(date);
    String monthYear = DateFormat('MMMM yyyy').format(date);

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6E3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(2, 4))
        ],
        border: Border.all(color: const Color(0xFF8B5E3C), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF4A2E2B), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2E2B),
                      ),
                    ),
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A2E2B),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      monthYear,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2E2B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: 15,
              itemBuilder: (ctx, i) {
                if (i < cases.length) {
                  return _caseTile(cases[i], i + 1);
                } else {
                  return _blankLine(date, i + 1);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _caseTile(CaseModel c, int number) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditCaseScreen(caseData: c),
          ),
        );
        if (result == true) _loadCases();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.brown.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF4A2E2B),
              child: Text(
                "$number",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF4A2E2B),
                    ),
                  ),
                  Text(
                    "${c.court}  •  ${c.stage}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_note, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _blankLine(DateTime date, int number) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddCaseScreen(preselectedDate: date),
          ),
        );
        _loadCases();
        if (result != null && result is DateTime) {
          _jumpToDate(result);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.brown.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(
              number.toString().padLeft(2, '0'),
              style: TextStyle(
                color: Colors.brown.shade400,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                "Tap to write note / case...",
                style: TextStyle(
                  color: Colors.brown.shade300,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Icon(Icons.edit, size: 16, color: Colors.brown.shade300),
          ],
        ),
      ),
    );
  }
}
