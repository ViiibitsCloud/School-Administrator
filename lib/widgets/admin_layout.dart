import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminLayout({
    super.key,
    required this.title,
    required this.child,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final List<Map<String, dynamic>> menuItems = [
    {"icon": Icons.dashboard, "title": "Overview"},
    {"icon": Icons.person_add, "title": "Teachers"},
    {"icon": Icons.school, "title": "Students"},
    {"icon": Icons.payments, "title": "Fees"},
    {"icon": Icons.assessment, "title": "Attendance"},
    {"icon": Icons.campaign, "title": "Announcements"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "School Admin",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          ...List.generate(menuItems.length, (index) {
            final item = menuItems[index];
            final isSelected = widget.selectedIndex == index;

            return ListTile(
              selected: isSelected,
              selectedTileColor: Colors.indigo.shade50,
              leading: Icon(
                item["icon"],
                color: isSelected ? Colors.indigo : Colors.grey,
              ),
              title: Text(
                item["title"],
                style: TextStyle(
                  color: isSelected ? Colors.indigo : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () => widget.onItemSelected(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          SizedBox(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}