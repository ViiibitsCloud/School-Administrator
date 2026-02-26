import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

class ManageFeesScreen extends StatelessWidget {
  const ManageFeesScreen({super.key});

  Widget statCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  void _editFees(BuildContext context,
      String studentId,
      double currentPaid) {
    final controller =
        TextEditingController(text: currentPaid.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Paid Amount"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: "Paid Amount"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              double newPaid =
                  double.tryParse(controller.text) ?? 0;

              await FirebaseFirestore.instance
                  .collection('fees')
                  .doc(studentId)
                  .set({
                'paidAmount': newPaid,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _shareFeesReport(
      Map<String, dynamic> student,
      double total,
      double paid,
      double due) {

    Share.share("""
Dear Parent,

Fees Status Update

Student: ${student['name']}
Class: ${student['class']} - ${student['division']}
Roll No: ${student['roll'] ?? ""}

Total Fees: ₹$total
Paid: ₹$paid
${due == 0 ? "Thanks for paying fees!" : "Pending: ₹$due\n\nPlease clear pending fees at earliest."}

MG Public School Administration
""");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('students').snapshots(),
      builder: (context, studentSnapshot) {

        if (!studentSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = studentSnapshot.data!.docs;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('fees')
              .snapshots(),
          builder: (context, feeSnapshot) {

            Map<String, Map<String, dynamic>> feeMap = {};

            if (feeSnapshot.hasData) {
              for (var doc in feeSnapshot.data!.docs) {
                feeMap[doc.id] =
                    doc.data() as Map<String, dynamic>;
              }
            }

           double totalCollected = 0;
double totalPending = 0;

for (var studentDoc in students) {
  final student =
      studentDoc.data() as Map<String, dynamic>;

  final feeData = feeMap[studentDoc.id] ?? {};

  double total =
      (student['defaultFees'] ?? 9000).toDouble();

  double paid =
      (feeData['paidAmount'] ?? 0).toDouble();

  double due = total - paid;

  totalCollected += paid;
  totalPending += due;
}
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text("Fee Management",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                          child: statCard(
                              "Collected",
                              "₹${totalCollected.toStringAsFixed(0)}",
                              Colors.green)),
                      const SizedBox(width: 20),
                      Expanded(
                          child: statCard(
                              "Pending",
                              "₹${totalPending.toStringAsFixed(0)}",
                              Colors.orange)),
                      const SizedBox(width: 20),
                              // Expanded(
                              //   child: statCard(
                              //     "Total",
                              //     "₹${(totalCollected + totalPending).toStringAsFixed(0)}",
                              //     Colors.blue,
                              //   ),
                              // ),
                              // const SizedBox(width: 20),
                              Expanded(child: statCard("Due", "₹${totalPending.toStringAsFixed(0)}", Colors.red),)
                    ],
                  ),

                  const SizedBox(height: 30),


                  /// TABLE
                  Card(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text(" Student ID")),
                          DataColumn(label: Text("Name")),
                          DataColumn(label: Text("Class")),
                          DataColumn(label: Text("Division")),
                          DataColumn(label: Text("Total")),
                          DataColumn(label: Text("Paid")),
                          DataColumn(label: Text("Due")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: students.map((studentDoc) {

                          final student =
                              studentDoc.data()
                                  as Map<String, dynamic>;

                          final feeData =
                              feeMap[studentDoc.id] ?? {};

                          double total =
                              (student['defaultFees'] ?? 9000)
                                  .toDouble();

                          double paid =
                              (feeData['paidAmount'] ?? 0)
                                  .toDouble();

                          double due = total - paid;

                          String status =
                              due <= 0 ? "Paid" : "Pending";


                          return DataRow(cells: [

                            DataCell(Text(
                                student['studentId'] ?? "Generating...")),

                            DataCell(Text(
                                student['name'] ?? "")),

                            DataCell(Text(
                                student['class'] ?? "")),

                            DataCell(Text(
                                student['division'] ?? "")),

                            DataCell(Text("₹$total")),

                            DataCell(Text("₹$paid")),

                            DataCell(Text("₹$due")),

                            DataCell(Text(status)),

                            DataCell(Row(
                              children: [

                                /// EDIT
                                IconButton(
                                  icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _editFees(
                                      context,
                                      studentDoc.id,
                                      paid,
                                    );
                                  },
                                ),

                                /// SHARE
                                IconButton(
                                  icon: const Icon(
                                      Icons.share,
                                      color: Colors.green),
                                  onPressed: () {
                                    _shareFeesReport(
                                      student,
                                      total,
                                      paid,
                                      due,
                                    );
                                  },
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                 
                  /// PIE CHART
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                              value: totalCollected == 0
                                  ? 1
                                  : totalCollected,
                              color: Colors.green,
                              title: "Collected"),
                          PieChartSectionData(
                              value: totalPending == 0
                                  ? 1
                                  : totalPending,
                              color: Colors.orange,
                              title: "Pending"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}