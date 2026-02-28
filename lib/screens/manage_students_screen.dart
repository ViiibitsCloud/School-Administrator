import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() =>
      _ManageStudentsScreenState();
}

class _ManageStudentsScreenState
    extends State<ManageStudentsScreen> {

  bool _uploading = false;

  //student ID generator
  String generateStudentId(int admissionYear) {
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final fiveDigit = timestamp.substring(timestamp.length - 5);
  return "MGK/$admissionYear/$fiveDigit";
}
 //Duplicate Check
  Future<bool> isDuplicateStudent({
    required String email,
    required String phone,
    required String roll,
    required String name,
    required String className,
    required String division,
  }) async {
    final emailQuery = await FirebaseFirestore.instance
        .collection('students')
        .where('email', isEqualTo: email)
        .get();

    if (emailQuery.docs.isNotEmpty) return true;

    final phoneQuery = await FirebaseFirestore.instance
        .collection('students')
        .where('phone', isEqualTo: phone)
        .get();

    if (phoneQuery.docs.isNotEmpty) return true;

    final comboQuery = await FirebaseFirestore.instance
        .collection('students')
        .where('roll', isEqualTo: roll)
        .where('class', isEqualTo: className)
        .where('division', isEqualTo: division)
        .where('name', isEqualTo: name)
        .get();

    if (comboQuery.docs.isNotEmpty) return true;

    return false;
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
              style:
                  TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton.icon(
  icon: const Icon(Icons.download),
  label: const Text("Download Template"),
  onPressed: _downloadTemplate,
),
const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue),
              icon: const Icon(Icons.upload_file,
                  color: Colors.white),
              label: const Text("Upload Excel",
                  style: TextStyle(color: Colors.white)),
              onPressed: _uploadExcel,
            ),
          ],
        ),
        const SizedBox(height: 20),

     //Scrolling DataTable
        Expanded(
          child: Card(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("Student ID")),
                          DataColumn(label: Text("Roll")),
                          DataColumn(label: Text("Name")),
                          DataColumn(label: Text("Class")),
                          DataColumn(label: Text("Division")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Gender")),
                          DataColumn(label: Text("Phone")),
                          DataColumn(label: Text("Birth Year")),
                          DataColumn(label: Text("Age")),
                          DataColumn(label: Text("Admission Year")),
                          DataColumn(label: Text("Address")),
                          DataColumn(label: Text("Last Updated")),
                          DataColumn(label: Text("Fees")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: docs.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;

                          return DataRow(cells: [
  DataCell(Text(data['studentId'] ?? "")),
  DataCell(Text(data['roll'] ?? "")),
  DataCell(Text(data['name'] ?? "")),
  DataCell(Text(data['class'] ?? "")),
  DataCell(Text(data['division'] ?? "")),
  DataCell(Text(data['email'] ?? "")),
  DataCell(Text(data['gender'] ?? "")),
  DataCell(Text(data['phone'] ?? "")),
  DataCell(Text(data['birthYear']?.toString() ?? "")),
  DataCell(Text(data['age']?.toString() ?? "")),
  DataCell(Text(data['admissionYear']?.toString() ?? "")),
  DataCell(Text(data['address'] ?? "")),
  DataCell(Text(
    data['updatedAt'] != null
        ? (data['updatedAt'] as Timestamp)
            .toDate()
            .toString()
        : "",
  )),
  DataCell(Text(data['fees']?.toString() ?? "0")),
  DataCell(Row(
    children: [
      IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () {
          _showEditDialog(doc.id, data);
        },
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
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

//Excel Upload Handler
  Future<void> _uploadExcel() async {
    setState(() => _uploading = true);

    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
        withData: true,
      );

      if (result == null) return;

      final bytes = result.files.single.bytes!;
      final excel = Excel.decodeBytes(bytes);
      final sheet =
          excel.tables[excel.tables.keys.first]!;

      int success = 0;
      int duplicate = 0;

     for (var row in sheet.rows.skip(1)) {

  final roll = row[0]?.value.toString() ?? "";
  final name = row[1]?.value.toString() ?? "";
  final className = row[2]?.value.toString() ?? "";
  final division = row[3]?.value.toString() ?? "";
  final phone = row[4]?.value.toString() ?? "";
  final email = row[5]?.value.toString() ?? "";
  final gender = row[6]?.value.toString() ?? "";
  final birthYear =
      int.tryParse(row[7]?.value.toString() ?? "") ?? 0;
  final admissionYear =
      int.tryParse(row[8]?.value.toString() ?? "") ??
          DateTime.now().year;
  final address = row[9]?.value.toString() ?? "";

  final age = DateTime.now().year - birthYear;

  final isDuplicate = await isDuplicateStudent(
    email: email,
    phone: phone,
    roll: roll,
    name: name,
    className: className,
    division: division,
  );

  if (isDuplicate) {
    duplicate++;
    continue;
  }

  final studentId =
      generateStudentId(admissionYear);

  await FirebaseFirestore.instance
      .collection('students')
      .add({
    'studentId': studentId,
    'roll': roll,
    'name': name,
    'class': className,
    'division': division,
    'phone': phone,
    'email': email,
    'gender': gender,
    'birthYear': birthYear,
    'admissionYear': admissionYear,
    'age': age,
    'address': address,
    'fees': 0,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  success++;
}
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Upload Summary"),
          content: Text(
              "Added: $success\nSkipped Duplicates: $duplicate"),
          actions: [
            TextButton(
                onPressed: () =>
                    Navigator.pop(context),
                child: const Text("OK"))
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
              SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _uploading = false);
    }
  }
//downloaad template
Future<void> _downloadTemplate() async {
  final excel = Excel.createExcel();
  final sheet = excel['Students'];

  sheet.appendRow([
    TextCellValue("Roll"),
    TextCellValue("Name"),
    TextCellValue("Class"),
    TextCellValue("Division"),
    TextCellValue("Phone"),
    TextCellValue("Email"),
    TextCellValue("Gender"),
    TextCellValue("BirthYear"),
    TextCellValue("AdmissionYear"),
    TextCellValue("Address"),
  ]);

  final List<int>? fileBytes = excel.encode();

  if (fileBytes == null) return;

  final Uint8List uint8List = Uint8List.fromList(fileBytes);

  await FilePicker.platform.saveFile(
    dialogTitle: "Save Template",
    fileName: "students_template.xlsx",
    bytes: uint8List,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Template Downloaded")),
  );
}

  
  //Edit Dialog
  void _showEditDialog(
      String docId,
      Map<String, dynamic> data) {
    final nameCtrl =
        TextEditingController(text: data['name']);
    final phoneCtrl =
        TextEditingController(text: data['phone']);
    final emailCtrl =
        TextEditingController(text: data['email']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration:
                    const InputDecoration(
                        labelText: "Name")),
            TextField(
                controller: phoneCtrl,
                decoration:
                    const InputDecoration(
                        labelText: "Phone")),
            TextField(
                controller: emailCtrl,
                decoration:
                    const InputDecoration(
                        labelText: "Email")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore
                  .instance
                  .collection('students')
                  .doc(docId)
                  .update({
                'name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'updatedAt':
                    FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
  
}
