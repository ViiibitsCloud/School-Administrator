class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final List<String>? assignedClasses;
  final List<String>? assignedSubjects;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.assignedClasses,
    this.assignedSubjects,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'teacher',
      assignedClasses: List<String>.from(data['assignedClasses'] ?? []),
      assignedSubjects: List<String>.from(data['assignedSubjects'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'assignedClasses': assignedClasses,
      'assignedSubjects': assignedSubjects,
    };
  }
}