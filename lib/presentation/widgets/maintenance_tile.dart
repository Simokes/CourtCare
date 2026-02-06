import 'package:flutter/material.dart';
import '../../domain/entities/maintenance.dart';

class MaintenanceTile extends StatelessWidget {
  final Maintenance maintenance;

  const MaintenanceTile({super.key, required this.maintenance});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = '${maintenance.date.day.toString().padLeft(2, '0')}/'
        '${maintenance.date.month.toString().padLeft(2, '0')}/'
        '${maintenance.date.year} '
        '${maintenance.date.hour.toString().padLeft(2, '0')}:'
        '${maintenance.date.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(
          maintenance.type,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (maintenance.commentaire != null &&
                maintenance.commentaire!.isNotEmpty)
              Text('Commentaire: ${maintenance.commentaire}'),
            Text('Sacs Manto : ${maintenance.sacsMantoUtilises}'),
            Text('Sacs SottoM : ${maintenance.sacsSottomantoUtilises}'),
            Text('Sacs sable : ${maintenance.sacsSiliceUtilises}'),
            Text('Date: $dateFormatted'),
          ],
        ),
        leading: const Icon(Icons.build_circle_rounded, color: Colors.orange),
      ),
    );
  }
}
