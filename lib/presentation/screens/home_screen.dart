import 'package:flutter/material.dart';
import 'maintenance_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CourtCare')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'CourtCare',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Maintenance'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MaintenanceScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Bienvenue dans CourtCare',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
