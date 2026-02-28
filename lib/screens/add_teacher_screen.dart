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
  final _formKey = GlobalKey<FormState>();
bool _obscurePassword = true;

  List<String> selectedClasses = [];
  List<String> selectedSubjects = [];

  final List<String> allClasses = ['8', '9', '10', '11', '12'];
  final List<String> allSubjects = ['Hindi', 'English', 'Maths', 'Science', 'Social Science', 'Computer', 'Physical Education'];

  bool _loading = false;


void _showTeacherDetails(String uid, Map<String, dynamic> data) {
  final classes = List<String>.from(data['assignedClasses'] ?? []);
  final subjects = List<String>.from(data['assignedSubjects'] ?? []);
  final newPassCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Teacher Details"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${data['name']}"),
            const SizedBox(height: 8),
            Text("Email: ${data['email']}"),
            const SizedBox(height: 8),
            Text("Class: ${classes.join(', ')}"),
            const SizedBox(height: 8),
            Text("Subjects: ${subjects.join(', ')}"),
            const Divider(height: 30),

            const Text("Change Password"),
            const SizedBox(height: 10),

            TextField(
              controller: newPassCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "New Password",
              ),
              obscureText: true,
            ),

            const SizedBox(height: 10),

          ElevatedButton(
  onPressed: () async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: data['email']);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent successfully"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  },
  child: const Text("Send Reset Email"),
)
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"))
      ],
    ),
  );
}

  Future<void> _addTeacher() async {
  if (!_formKey.currentState!.validate()) return;

  if (selectedClasses.length != 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select exactly ONE class")),
    );
    return;
  }

  if (selectedSubjects.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select at least ONE subject")),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'role': 'teacher',
      'assignedClasses': selectedClasses,
      'assignedSubjects': selectedSubjects,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Teacher added successfully!")),
    );

    _formKey.currentState!.reset();
    _nameCtrl.clear();
    _emailCtrl.clear();
    _passwordCtrl.clear();
    selectedClasses.clear();
    selectedSubjects.clear();
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error: $e")));
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
                child: Form(
                  key: _formKey,
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
    labelText: "Full Name",
    prefixIcon: Icon(Icons.person),
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }
    if (value.length < 3) {
      return "Name must be at least 3 characters";
    }
    return null;
  },
),
                      const SizedBox(height: 16),
                  
                     TextFormField(
  controller: _emailCtrl,
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
    labelText: "Email",
    prefixIcon: Icon(Icons.email),
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    final emailRegex =
        RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$");
    if (!emailRegex.hasMatch(value)) {
      return "Enter valid email";
    }
    return null;
  },
),
                      const SizedBox(height: 16),
                  
                      TextFormField(
  controller: _passwordCtrl,
  obscureText: _obscurePassword,
  decoration: InputDecoration(
    border: const OutlineInputBorder(),
    labelText: "Password",
    prefixIcon: const Icon(Icons.lock),
    suffixIcon: IconButton(
      icon: Icon(
        _obscurePassword
            ? Icons.visibility_off
            : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  },
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
    selectedClasses.clear();
    if (val) {
      selectedClasses.add(cls);
    }
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

                return GestureDetector(
                  onTap: () {
                    // Implement edit functionality if needed
                     _showTeacherDetails(doc.id, data);
                  },
                  child: Container(
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