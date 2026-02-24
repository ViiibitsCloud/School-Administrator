import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceReportsScreen extends StatelessWidget {
  const AttendanceReportsScreen({super.key});
@override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Title
            const Text(
              "Attendance Reports",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// Table Area (IMPORTANT FIX)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('attendance_reports')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No attendance records found."));
                  }

                  final docs = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 40,
                        headingRowColor:
                            MaterialStateProperty.all(
                                Colors.grey.shade100),
                        columns: const [
                          DataColumn(label: Text("Class")),
                          DataColumn(label: Text("Subject")),
                          DataColumn(label: Text("Total")),
                          DataColumn(label: Text("Present")),
                          DataColumn(label: Text("Absent")),
                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Time")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: docs.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;

                          final timestamp =
                              data['timestamp'] as Timestamp?;

                          final date = timestamp != null
                              ? timestamp
                                  .toDate()
                                  .toString()
                                  .split(' ')[0]
                              : "-";

                          final time = timestamp != null
                              ? timestamp
                                  .toDate()
                                  .toString()
                                  .split(' ')[1]
                                  .split('.')[0]
                              : "-";

                          return DataRow(cells: [
                            DataCell(Text(data['class'] ?? "")),
                            DataCell(Text(data['subject'] ?? "")),
                            DataCell(Text(
                                (data['total'] ?? 0).toString())),
                            DataCell(Text(
                                (data['present'] ?? 0).toString())),
                            DataCell(Text(
                                (data['absent'] ?? 0).toString())),
                            DataCell(Text(date)),
                            DataCell(Text(time)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.blue),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection(
                                            'attendance_reports')
                                        .doc(doc.id)
                                        .delete();
                                  },
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}