import 'package:flutter/material.dart';
import '../widgets/admin_layout.dart';
import 'add_teacher_screen.dart';
import 'manage_students_screen.dart';
import 'manage_fees_screen.dart';
import 'attendance_reports_screen.dart';
import 'announcements_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Overview',
    'Teachers',
    'Students',
    'Fees',
    'Attendance Reports',
    'Announcements',
  ];

  final List<Widget> _screens = [
    const OverviewTab(),
    const AddTeacherScreen(),
    const ManageStudentsScreen(),
    const ManageFeesScreen(),
    const AttendanceReportsScreen(),
    const AnnouncementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: _titles[_selectedIndex],
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        setState(() => _selectedIndex = index);
      },
      child: _screens[_selectedIndex],
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required String percent,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  percent,
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          Text(value,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _scheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Today's Schedule",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Staff Meeting"),
            subtitle: Text("10:00 AM - Conference Hall"),
            trailing: Chip(
              label: Text("Upcoming"),
              backgroundColor: Colors.orangeAccent,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Parent-Teacher Meeting"),
            subtitle: Text("11:30 AM - Room 101"),
            trailing: Chip(
              label: Text("Upcoming"),
              backgroundColor: Colors.orangeAccent,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Fee Review"),
            subtitle: Text("12:30 PM - Admin Office"),
            trailing: Chip(
              label: Text("Upcoming"),
              backgroundColor: Colors.orangeAccent,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Student Council Meeting"),
            subtitle: Text("2:00 PM - Auditorium"),
            trailing: Chip(
              label: Text("Upcoming"),
              backgroundColor: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Weekly Attendance Chart Placeholder",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const Spacer(),
          const Icon(Icons.bar_chart, size: 80, color: Colors.grey),
          const Spacer(),
          const Text(
            "Attendance trends will be displayed here.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Greeting Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Good Morning, Principal 👋",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("Here's what's happening in your school today.",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {},
                    child: const Text("Export Report", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      // Navigate to Add Student Screen
                     
                    },
                    child: const Text("Add Student +", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 30),

          /// Stats Row
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: "TOTAL STUDENTS",
                  value: "1,240",
                  subtitle: "Enrolled",
                  color: Colors.blue,
                  percent: "+12%",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _statCard(
                  title: "TOTAL TEACHERS",
                  value: "42",
                  subtitle: "Active Staff",
                  color: Colors.purple,
                  percent: "+5%",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _statCard(
                  title: "PENDING FEES",
                  value: "₹2,40,000",
                  subtitle: "Outstanding",
                  color: Colors.orange,
                  percent: "-2%",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _statCard(
                  title: "ATTENDANCE RATE",
                  value: "94.5%",
                  subtitle: "This Week",
                  color: Colors.green,
                  percent: "+1.2%",
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _overviewChart()),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _scheduleCard()),
            ],
          ),
        ],
      ),
    );
  }
}