import 'package:flutter/material.dart';
import 'services/report_service.dart';
import 'user_profile.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayIncome = ReportService.incomeForDay(today);
    final monthIncome = ReportService.incomeForMonth(today.year, today.month);
    final top = ReportService.topCostumes(limit: 10);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${UserProfile.name.isEmpty ? 'Admin' : UserProfile.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Summary cards
            Row(
              children: [
                _SummaryCard(title: 'Today Income', value: ReportService.formatCurrency(todayIncome)),
                const SizedBox(width: 12),
                _SummaryCard(title: 'This Month', value: ReportService.formatCurrency(monthIncome)),
              ],
            ),

            const SizedBox(height: 18),
            const Text('Top Rented Costumes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: top.keys.length,
                itemBuilder: (context, index) {
                  final key = top.keys.elementAt(index);
                  final count = top[key]!;
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(key),
                    trailing: Text('$count times'),
                    subtitle: Text('$count sewa'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
