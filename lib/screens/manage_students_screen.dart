import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String generateStudentId(int year) {
    final random =
        DateTime.now().millisecondsSinceEpoch.toString();
    final fiveDigit =
        random.substring(random.length - 5);
    return "MGK/$year/$fiveDigit";
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
                          DataColumn(label: Text("Phone")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Gender")),
                          DataColumn(label: Text("Fees")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rows: docs.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;

                          return DataRow(cells: [
                            DataCell(Text(
                                data['studentId'] ?? "")),
                            DataCell(Text(data['roll'] ?? "")),
                            DataCell(Text(data['name'] ?? "")),
                            DataCell(Text(data['class'] ?? "")),
                            DataCell(Text(
                                data['division'] ?? "")),
                            DataCell(Text(data['phone'] ?? "")),
                            DataCell(Text(data['email'] ?? "")),
                            DataCell(Text(
                                data['gender'] ?? "")),
                            DataCell(Text(
                                data['fees']?.toString() ??
                                    "0")),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _showEditDialog(
                                        doc.id, data);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore
                                        .instance
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
        final className =
            row[2]?.value.toString() ?? "";
        final division =
            row[3]?.value.toString() ?? "";
        final phone =
            row[4]?.value.toString() ?? "";
        final email =
            row[5]?.value.toString() ?? "";
        final gender =
            row[6]?.value.toString() ?? "";
        final birthYear =
            int.tryParse(row[7]?.value.toString() ?? "") ??
                DateTime.now().year;

        final isDuplicate =
            await isDuplicateStudent(
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

        final id =
            generateStudentId(birthYear);

        await FirebaseFirestore.instance
            .collection('students')
            .add({
          'studentId': id,
          'roll': roll,
          'name': name,
          'class': className,
          'division': division,
          'phone': phone,
          'email': email,
          'gender': gender,
          'fees': 0,
          'updatedAt':
              FieldValue.serverTimestamp(),
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