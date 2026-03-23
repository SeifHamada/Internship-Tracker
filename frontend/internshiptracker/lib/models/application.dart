class Application {
  // Fields matching the database columns
  int id;
  String company;
  String role;
  DateTime applicationDate;
  DateTime? deadlineDate; // Optional - application may have no deadline
  String status;
  String? notes; // Optional - user may not add notes

  // Constructor - required fields must be provided, optional fields have defaults
  Application({
    required this.id,
    required this.company,
    required this.role,
    required this.applicationDate,
    this.deadlineDate,
    required this.status,
    this.notes,
  });

  // Converts JSON response from FastAPI into a Dart Application object
  // JSON keys use snake_case (from Python) mapped to camelCase (Dart convention)
  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      company: json['company'],
      role: json['role'],
      applicationDate: DateTime.parse(json['application_date']),
      deadlineDate: json['deadline_date'] != null
          ? DateTime.parse(json['deadline_date'])
          : null,
      status: json['status'],
      notes: json['notes'],
    );
  }

  // Converts a Dart Application object back into JSON to send to FastAPI
  // Note: id is excluded because it is sent in the URL, not the request body
  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'role': role,
      'application_date': applicationDate.toIso8601String().split('T')[0],
      'deadline_date': deadlineDate?.toIso8601String().split('T')[0],
      'status': status,
      'notes': notes,
    };
  }
}