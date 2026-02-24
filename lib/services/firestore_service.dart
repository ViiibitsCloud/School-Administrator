import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all teachers
  Stream<List<Map<String, dynamic>>> getTeachers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }).toList());
  }

  // Add new teacher
  Future<void> addTeacher({
    required String name,
    required String email,
    required List<String> classes,
    required List<String> subjects,
  }) async {
    // This is called after auth user is created
    // uid comes from FirebaseAuth
  }

  // Get students by class
  Stream<List<Map<String, dynamic>>> getStudentsByClass(String className) {
    return _firestore
        .collection('students')
        .where('class', isEqualTo: className)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }).toList());
  }

  // Add more methods as needed (fees, announcements, etc.)
}