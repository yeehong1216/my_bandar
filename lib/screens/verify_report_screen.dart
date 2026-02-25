import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class VerifyReportScreen extends StatefulWidget {
  const VerifyReportScreen({super.key});

  @override
  State<VerifyReportScreen> createState() => _VerifyReportScreenState();
}

class _VerifyReportScreenState extends State<VerifyReportScreen> {
  bool _isLoading = true;
  String _aiReport = '';
  late Map<String, dynamic> _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    if (_isLoading) {
      _generateReport();
    }
  }

  Future<void> _generateReport() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final provider = context.read<AppProvider>();
    final address = _args['address'] as String;
    final description = _args['description'] as String? ?? '';
    const title = 'Civic Report';

    setState(() {
      _aiReport = provider.generateAIReport(title, description, address);
      _isLoading = false;
    });
  }

  void _approveReport() {
    final provider = context.read<AppProvider>();
    final address = _args['address'] as String;
    final photoPath = _args['photoPath'] as String?;
    final description = _args['description'] as String? ?? '';

    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Civic Report',
      description: description,
      address: address,
      photoPath: photoPath,
      status: 'Pending',
      date: DateTime.now(),
      aiReport: _aiReport,
    );

    provider.addReport(report);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Report submitted successfully!'),
          ],
        ),
        backgroundColor: AppTheme.completeGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Pop back to home
    Navigator.of(context).popUntil((route) => route.settings.name == '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoading() : _buildReport(),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.primaryBlue,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI is generating report...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your submission',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildReport() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 16, color: AppTheme.primaryBlue),
                      SizedBox(width: 6),
                      Text(
                        'AI Generated Report',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Report Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    _aiReport,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      height: 1.6,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Buttons
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.cancelRed,
                    side: const BorderSide(color: AppTheme.cancelRed, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel Report'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _approveReport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Approve & Send'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
