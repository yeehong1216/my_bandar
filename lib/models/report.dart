class Report {
  final String id;
  final String title;
  final String description;
  final String address;
  final String? photoPath;
  final String status; // 'Pending', 'In Progress', or 'Done'
  final String priority; // 'High', 'Medium', or 'Low'
  final DateTime date;
  final String aiReport;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.address,
    this.photoPath,
    required this.status,
    this.priority = 'Medium',
    required this.date,
    required this.aiReport,
  });

  Report copyWith({
    String? id,
    String? title,
    String? description,
    String? address,
    String? photoPath,
    String? status,
    String? priority,
    DateTime? date,
    String? aiReport,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      aiReport: aiReport ?? this.aiReport,
    );
  }
}
