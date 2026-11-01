class CaseModel {
  int? id;
  String title;
  String court;
  String stage;
  String notes;
  String hearingDate;
  String reminderTime;

  CaseModel({
    this.id,
    required this.title,
    required this.court,
    required this.stage,
    required this.notes,
    required this.hearingDate,
    this.reminderTime = "20:00",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'court': court,
      'stage': stage,
      'notes': notes,
      'hearingDate': hearingDate,
      'reminderTime': reminderTime,
    };
  }

  factory CaseModel.fromMap(Map<String, dynamic> map) {
    return CaseModel(
      id: map['id'],
      title: map['title'] ?? '',
      court: map['court'] ?? '',
      stage: map['stage'] ?? '',
      notes: map['notes'] ?? '',
      hearingDate: map['hearingDate'] ?? '',
      reminderTime: map['reminderTime'] ?? '20:00',
    );
  }
}