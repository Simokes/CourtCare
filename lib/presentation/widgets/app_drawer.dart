import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/maintenance_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/all_maintenances_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, Widget screen) {
    Navigator.pop(context); // ferme le drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => _go(context, const HomeScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Maintenance'),
            onTap: () => _go(context, const MaintenanceScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Toutes les maintenances'),
            onTap: () => _go(context, const AllMaintenancesScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Stats'),
            onTap: () => _go(context, const StatsScreen()),
          ),

          const Divider(),
          // Placeholders (si tu veux les activer plus tard)
          const ListTile(
              leading: Icon(Icons.sports_tennis), title: Text('Terrains')),
          const ListTile(
              leading: Icon(Icons.calendar_month), title: Text('Calendrier')),
          const ListTile(leading: Icon(Icons.cloud), title: Text('Météo')),
          const ListTile(
              leading: Icon(Icons.local_shipping), title: Text('Livraisons')),
          const ListTile(
              leading: Icon(Icons.settings), title: Text('Paramètres')),
        ],
      ),
    );
  }
}
