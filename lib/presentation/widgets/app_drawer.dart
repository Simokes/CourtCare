import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          DrawerHeader(
            child: Text(
              'CourtCare',
              style: TextStyle(fontSize: 24),
            ),
          ),
          ListTile(leading: Icon(Icons.home), title: Text('Accueil')),
          ListTile(leading: Icon(Icons.sports_tennis), title: Text('Terrains')),
          ListTile(leading: Icon(Icons.build), title: Text('Maintenance')),
          ListTile(leading: Icon(Icons.calendar_month), title: Text('Calendrier')),
          ListTile(leading: Icon(Icons.cloud), title: Text('Météo')),
          ListTile(leading: Icon(Icons.local_shipping), title: Text('Livraisons')),
          ListTile(leading: Icon(Icons.bar_chart), title: Text('Résumés')),
          Divider(),
          ListTile(leading: Icon(Icons.settings), title: Text('Paramètres')),
        ],
      ),
    );
  }
}
