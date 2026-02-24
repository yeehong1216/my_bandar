import 'package:flutter/material.dart';
import '../models/report.dart';

class AppProvider extends ChangeNotifier {
  String _userName = '';
  bool _isLoggedIn = false;
  final List<Report> _reports = [];

  String get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;
  List<Report> get reports => List.unmodifiable(_reports);

  // ─── Status counts for dashboard ───
  int get pendingCount => _reports.where((r) => r.status == 'Pending').length;
  int get inProgressCount =>
      _reports.where((r) => r.status == 'In Progress').length;
  int get doneCount => _reports.where((r) => r.status == 'Done').length;

  void login(String name) {
    _userName = name;
    _isLoggedIn = true;
    // Seed with sample mock data using 3-stage statuses
    _reports.addAll([
      Report(
        id: '1',
        title: 'Pothole on Jalan Ampang',
        description: 'Large pothole near the intersection.',
        address: 'Jalan Ampang, 50450 Kuala Lumpur',
        status: 'Pending',
        priority: 'High',
        date: DateTime.now().subtract(const Duration(days: 1)),
        aiReport: _generateMockAIReport(
          'Pothole on Jalan Ampang',
          'Large pothole near the intersection.',
          'Jalan Ampang, 50450 Kuala Lumpur',
        ),
      ),
      Report(
        id: '2',
        title: 'Broken Street Light',
        description: 'Street light flickering for a week.',
        address: 'Jalan Bukit Bintang, 55100 Kuala Lumpur',
        status: 'In Progress',
        priority: 'Medium',
        date: DateTime.now().subtract(const Duration(days: 3)),
        aiReport: _generateMockAIReport(
          'Broken Street Light',
          'Street light flickering for a week.',
          'Jalan Bukit Bintang, 55100 Kuala Lumpur',
        ),
      ),
      Report(
        id: '3',
        title: 'Clogged Drain',
        description: 'Storm drain blocked causing flooding.',
        address: 'Jalan Imbi, 55100 Kuala Lumpur',
        status: 'Pending',
        priority: 'High',
        date: DateTime.now().subtract(const Duration(days: 2)),
        aiReport: _generateMockAIReport(
          'Clogged Drain',
          'Storm drain blocked causing flooding.',
          'Jalan Imbi, 55100 Kuala Lumpur',
        ),
      ),
      Report(
        id: '4',
        title: 'Illegal Dumping',
        description: 'Waste dumped near residential area.',
        address: 'Taman Desa, 58100 Kuala Lumpur',
        status: 'Done',
        priority: 'Low',
        date: DateTime.now().subtract(const Duration(days: 7)),
        aiReport: _generateMockAIReport(
          'Illegal Dumping',
          'Waste dumped near residential area.',
          'Taman Desa, 58100 Kuala Lumpur',
        ),
      ),
      Report(
        id: '5',
        title: 'Water Pipe Leak',
        description: 'Water leaking from main pipe.',
        address: 'Jalan Pudu, 55100 Kuala Lumpur',
        status: 'Done',
        priority: 'Medium',
        date: DateTime.now().subtract(const Duration(days: 10)),
        aiReport: _generateMockAIReport(
          'Water Pipe Leak',
          'Water leaking from main pipe.',
          'Jalan Pudu, 55100 Kuala Lumpur',
        ),
      ),
      Report(
        id: '6',
        title: 'Fallen Tree Branch',
        description: 'Large branch blocking pedestrian path.',
        address: 'KLCC Park, 50088 Kuala Lumpur',
        status: 'Done',
        priority: 'High',
        date: DateTime.now().subtract(const Duration(days: 5)),
        aiReport: _generateMockAIReport(
          'Fallen Tree Branch',
          'Large branch blocking pedestrian path.',
          'KLCC Park, 50088 Kuala Lumpur',
        ),
      ),
      Report(
        id: '7',
        title: 'Graffiti on Public Wall',
        description: 'Vandalism on heritage building.',
        address: 'Jalan Sultan, 50000 Kuala Lumpur',
        status: 'Done',
        priority: 'Low',
        date: DateTime.now().subtract(const Duration(days: 14)),
        aiReport: _generateMockAIReport(
          'Graffiti on Public Wall',
          'Vandalism on heritage building.',
          'Jalan Sultan, 50000 Kuala Lumpur',
        ),
      ),
      Report(
        id: '8',
        title: 'Broken Sidewalk',
        description: 'Cracked sidewalk near school zone.',
        address: 'Jalan Tun Razak, 50400 Kuala Lumpur',
        status: 'Done',
        priority: 'Medium',
        date: DateTime.now().subtract(const Duration(days: 12)),
        aiReport: _generateMockAIReport(
          'Broken Sidewalk',
          'Cracked sidewalk near school zone.',
          'Jalan Tun Razak, 50400 Kuala Lumpur',
        ),
      ),
    ]);
    notifyListeners();
  }

  void logout() {
    _userName = '';
    _isLoggedIn = false;
    _reports.clear();
    notifyListeners();
  }

  void addReport(Report report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  String _generateMockAIReport(
      String title, String description, String address) {
    return '''
═══════════════════════════════════════
       CIVIC ISSUE ANALYSIS REPORT
═══════════════════════════════════════

REPORT TITLE: $title

LOCATION: $address

DESCRIPTION: $description

───────────────────────────────────────
              AI ASSESSMENT
───────────────────────────────────────

CATEGORY: Infrastructure & Public Safety
SEVERITY: Medium-High
PRIORITY LEVEL: P2

IMPACT ANALYSIS:
This issue poses a moderate-to-significant risk to public safety and daily commuter convenience. Based on pattern analysis of similar reports in the area, this type of issue typically affects approximately 200–500 residents daily.

RECOMMENDED ACTIONS:
1. Dispatch field inspection team within 48 hours
2. Issue temporary safety measures (signage/barriers)
3. Schedule permanent repair within 5 business days
4. Notify affected residents via municipal alert system

ESTIMATED RESOLUTION: 5–7 business days

───────────────────────────────────────
This report was auto-generated by MyBandar AI.
Verification confidence: 94.7%
═══════════════════════════════════════
''';
  }

  String generateAIReport(String title, String description, String address) {
    return _generateMockAIReport(title, description, address);
  }
}
