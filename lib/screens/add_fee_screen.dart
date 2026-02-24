import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFeeScreen extends StatefulWidget {
  const AddFeeScreen({super.key});

  @override
  State<AddFeeScreen> createState() => _AddFeeScreenState();
}

class _AddFeeScreenState extends State<AddFeeScreen> {

  String? selectedStudentDocId;
  Map<String, dynamic>? selectedStudent;

  final totalCtrl = TextEditingController();
  final paidCtrl = TextEditingController();

  Future<void> addFee() async {

    if (selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a student")));
      return;
    }

    final total = double.tryParse(totalCtrl.text) ?? 0;
    final paid = double.tryParse(paidCtrl.text) ?? 0;
    final due = total - paid;

    await FirebaseFirestore.instance.collection('fees').add({
      'studentId': selectedStudent!['studentId'],
      'studentName': selectedStudent!['name'],
      'class': selectedStudent!['class'],
      'division': selectedStudent!['division'],
      'totalFees': total,
      'paidAmount': paid,
      'dueAmount': due,
      'status': due <= 0 ? 'paid' : 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fee Added Successfully")));

    totalCtrl.clear();
    paidCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Add Fee",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: "Select Student"),
                    items: students.map((doc) {

                      final data =
                          doc.data() as Map<String, dynamic>;

                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(
                            "${data['studentId']} - ${data['name']} (${data['class']}-${data['division']})"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStudentDocId = value;
                        selectedStudent = students
                            .firstWhere((e) => e.id == value)
                            .data() as Map<String, dynamic>;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: totalCtrl,
                    decoration:
                        const InputDecoration(labelText: "Total Fees"),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: paidCtrl,
                    decoration:
                        const InputDecoration(labelText: "Paid Amount"),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: addFee,
                    child: const Text("Add Fee"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}