import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:school_admin/screens/add_fee_screen.dart';
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
                  fontWeight: FontWeight.bold,
                  color: color)),
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('fees').snapshots(),
      builder: (context, snapshot) {

        double totalCollected = 0;
        double totalPending = 0;
        double totalOverdue = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            final paid =
                (data['paidAmount'] ?? 0).toDouble();
            final due =
                (data['dueAmount'] ?? 0).toDouble();

            totalCollected += paid;
            totalPending += due;

            if ((data['status'] ?? "") == "overdue") {
              totalOverdue += due;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Fee Management",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                        ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddFeeScreen(),
                        ),
                      );
                    },
                    child: const Text("Add Fee"),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                      child: statCard(
                          "Total Collected",
                          "₹${totalCollected.toStringAsFixed(0)}",
                          Colors.green)),
                  const SizedBox(width: 20),
                  Expanded(
                      child: statCard(
                          "Pending",
                          "₹${totalPending.toStringAsFixed(0)}",
                          Colors.orange)),
                  const SizedBox(width: 20),
                  Expanded(
                      child: statCard(
                          "Overdue",
                          "₹${totalOverdue.toStringAsFixed(0)}",
                          Colors.red)),
                ],
              ),

              const SizedBox(height: 30),

              /// Fees Table
              Card(
                color: Colors.white,
                elevation: totalOverdue > 0 ? 4 : 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: snapshot.hasData &&
                          snapshot.data!.docs.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text("Student ID")),
                              DataColumn(label: Text("Name")),
                              DataColumn(label: Text("Class")),
                              DataColumn(label: Text("Division")),
                              DataColumn(label: Text("Total")),
                              DataColumn(label: Text("Paid")),
                              DataColumn(label: Text("Due")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Actions")),

                            ],
                            rows: snapshot.data!.docs.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>;

                              return DataRow(cells: [
                                DataCell(
                                    Text(data['studentId'] ?? "")),
                                DataCell(
                                    Text(data['studentName'] ?? "")),
                                DataCell(
                                    Text(data['studentClass'] ?? "")),
                                DataCell(
                                    Text(data['studentDivision'] ?? "")),
                                DataCell(Text(
                                    "₹${data['totalFees'] ?? 0}")),
                                DataCell(Text(
                                    "₹${data['paidAmount'] ?? 0}")),
                                DataCell(Text(
                                    "₹${data['dueAmount'] ?? 0}")),
                                DataCell(
                                    Text(data['status'] ?? "")),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        // Implement edit functionality here
                                      },  
                                      ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.share,
                                          color: Colors.green),
                                      onPressed: () {
                                       _shareFeesReport(data); // Implement delete functionality here
                                      },  
                                      ),  
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        )
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text(
                              "No Fees Records Found.\nAdd Fees to See Data Here.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              /// Pie Chart (safe even if 0)
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
                          value:
                              totalPending == 0 ? 1 : totalPending,
                          color: Colors.orange,
                          title: "Pending"),
                      PieChartSectionData(
                          value:
                              totalOverdue == 0 ? 1 : totalOverdue,
                          color: Colors.red,
                          title: "Overdue"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _shareFeesReport(Map<String, dynamic> student) {
    Share.share("""
Dear Parent,

Fees Status Update:

Student: ${student['name']}
Class: ${student['class']} - ${student['division']}
Roll No: ${student['roll']}

Total Fees: ₹${student['total']}
Paid: ₹${student['paid']}
Pending: ₹${student['pending']}

Please clear the pending fees at the earliest to avoid any inconvenience.
Contact the school office for payment options or queries.

Thank you,
MG Public School Administration
""");
  }
}
