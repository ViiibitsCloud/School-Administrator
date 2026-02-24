import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  bool _uploading = false;
  Future<void> fixOldStudents() async {
  final students =
      await FirebaseFirestore.instance.collection('students').get();

  for (var doc in students.docs) {
    final data = doc.data();

    if (data['studentId'] == null) {
      final newId =
          "STU${DateTime.now().year}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

      await doc.reference.update({
        'studentId': newId,
      });
    }
  }
}

@override
void initState() {
  super.initState();
  // fixOldStudents(); // Uncomment this line to fix old students without IDs
}
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Students List",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text("Upload Excel", style: TextStyle(color: Colors.white)),
              onPressed: () {
                _uploadExcel();
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Card(
            color: Colors.white,
            elevation: 3,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Student ID")),
                      DataColumn(label: Text("Roll")),
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Class")),
                      DataColumn(label: Text("Division")),
                      DataColumn(label: Text("Age")),
                      DataColumn(label: Text("Phone")),
                      DataColumn(label: Text("Gender")),
                      DataColumn(label: Text("Updated At")),
                      DataColumn(label: Text("Fees")),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DataRow(cells: [
                        DataCell(Text(data['studentId'] ?? "Generating...")),
                        DataCell(Text(data['roll'] ?? "")),
                        DataCell(Text(data['name'] ?? "")),
                        DataCell(Text(data['class'] ?? "")),
                        DataCell(Text(data['division'] ?? "")),
                        DataCell(Text(data['age'].toString())),
                        DataCell(Text(data['phone'] ?? "")),
                        DataCell(Text(data['gender'] ?? "")),
                        DataCell(Text(data['updatedAt'] != null
                            ? (data['updatedAt'] as Timestamp)
                                .toDate()
                                .toString()
                            : "Never")),
                        DataCell(Text(data['fees'].toString())),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () { }
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
            await FirebaseFirestore.instance
                .collection('students')
                .doc(doc.id)
                .delete();
          },  
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadExcel() async {
  setState(() => _uploading = true);

  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
      withData: true, // IMPORTANT FOR WEB
    );

    if (result == null) return;

    final bytes = result.files.single.bytes!;
    final excel = Excel.decodeBytes(bytes);

    final sheet = excel.tables[excel.tables.keys.first]!;

    final batch = FirebaseFirestore.instance.batch();

    for (var row in sheet.rows.skip(1)) {

  final docRef =
      FirebaseFirestore.instance.collection('students').doc();

  final generatedId =
      "STU${DateTime.now().year}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";

  batch.set(docRef, {
    'studentId': generatedId,
    'roll': row[0]?.value.toString(),
    'name': row[1]?.value.toString(),
    'class': row[2]?.value.toString(),
    'division': row[3]?.value.toString(),
    'age': int.tryParse(row[4]?.value.toString() ?? '0') ?? 0,
    'phone': row[5]?.value.toString(),
    'gender': row[6]?.value.toString(),
    'updatedAt': FieldValue.serverTimestamp(),
    'fees': 0,
    'attendance': 0,
  });
}
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Students uploaded successfully")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
        print("Upload failed: $e");
  } finally {
    setState(() => _uploading = false);
  }
}
}