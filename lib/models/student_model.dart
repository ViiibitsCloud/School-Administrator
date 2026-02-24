class StudentModel {
  final String id;
  final String roll;
  final String name;
  final String className;
  final String division;
  final int age;
  final String phone;
  final String gender;

  StudentModel({
    required this.id,
    required this.roll,
    required this.name,
    required this.className,
    required this.division,
    required this.age,
    required this.phone,
    required this.gender,
  });

  factory StudentModel.fromMap(Map<String, dynamic> data, String id) {
    return StudentModel(
      id: id,
      roll: data['roll']?.toString() ?? '',
      name: data['name'] ?? '',
      className: data['class'] ?? '',
      division: data['division'] ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      phone: data['number']?.toString() ?? '',
      gender: data['gender'] ?? 'Unknown',
    );
  }
}