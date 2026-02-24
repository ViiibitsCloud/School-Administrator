import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  List<String> selectedClasses = [];
  List<String> selectedSubjects = [];

  final List<String> allClasses = ['8', '9', '10', '11', '12'];
  final List<String> allSubjects = ['Hindi', 'English', 'Maths', 'Science', 'Social Science', 'Computer', 'Physical Education'];

  bool _loading = false;

  Future<void> _addTeacher() async {
    setState(() => _loading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': 'teacher',
        'assignedClasses': selectedClasses.isEmpty ? [] : selectedClasses,
        'assignedSubjects': selectedSubjects.isEmpty ? [] : selectedSubjects,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teacher added successfully!")),
      );

      _nameCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
      selectedClasses.clear();
      selectedSubjects.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }


@override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

       
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
               color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add Teacher",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Full Name"),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Email"),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Password"),
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: allClasses.map((cls) {
                        final isSelected = selectedClasses.contains(cls);
                        return FilterChip(
                          label: Text("Class $cls"),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              val
                                  ? selectedClasses.add(cls)
                                  : selectedClasses.remove(cls);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: allSubjects.map((sub) {
                        final isSelected = selectedSubjects.contains(sub);
                        return FilterChip(
                          label: Text(sub),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              val
                                  ? selectedSubjects.add(sub)
                                  : selectedSubjects.remove(sub);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _addTeacher,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Add Teacher",
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
             
            ),
          ),
        ),

        const SizedBox(height: 40),

       
        const Text("Teachers List",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

        const SizedBox(height: 20),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'teacher')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
print("Docs count: ${snapshot.data?.docs.length}");
print("User UID: ${FirebaseAuth.instance.currentUser?.uid}");
print("Docs count: ${snapshot.data?.docs.length}");

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No teachers added yet."));
            }

            final teachers = snapshot.data!.docs;

            return Column(
              children: teachers.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final classes = List<String>.from(data['assignedClasses'] ?? []);
final subjects = List<String>.from(data['assignedSubjects'] ?? []);

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 8,
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    children: [

                     
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['name'] ?? '',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(data['email'] ?? '',
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),

                     
                      Expanded(
                        flex: 2,
                        child: Wrap(
                          spacing: 6,
                          children: classes
                              .map((cls) => Chip(
                                    label: Text("Class $cls"),
                                    backgroundColor:
                                        Colors.blue.withOpacity(0.1),
                                  ))
                              .toList(),
                        ),
                      ),

                     
                      Expanded(
                        flex: 3,
                        child: Wrap(
                          spacing: 6,
                          children: subjects
                                  .map((sub) => Chip(
                                        label: Text(sub),
                                        backgroundColor:
                                            Colors.green.withOpacity(0.1),
                                      ))
                                  .toList(),
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(doc.id)
                              .delete();
                        },
                      )
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  );
}
}   