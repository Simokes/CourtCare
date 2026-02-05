import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/terrain.dart';
import '../providers/database_provider.dart';
import '../providers/maintenance_provider.dart' as maintenanceProv;

class AddMaintenanceSheet extends ConsumerStatefulWidget {
  final int terrainNumero;
  final int terrainId;
  final TerrainType terrainType;

  const AddMaintenanceSheet({
    super.key,
    required this.terrainNumero,
    required this.terrainId,
    required this.terrainType,
  });

  @override
  ConsumerState<AddMaintenanceSheet> createState() =>
      _AddMaintenanceSheetState();
}

class _AddMaintenanceSheetState extends ConsumerState<AddMaintenanceSheet> {
  String? selectedType;

  late final TextEditingController commentController;
  late final TextEditingController sacsMantoController;
  late final TextEditingController sacsSottomantoController;
  late final TextEditingController sacsSiliceController;

  final List<String> maintenanceTypes = const [
    'Arrosage',
    'Rouleau',
    'Lignes',
    'Soufflage',
    'Nettoyage',
    'Décompactage',
    'Recharge',
    'Travaux',
  ];

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
    sacsMantoController = TextEditingController();
    sacsSottomantoController = TextEditingController();
    sacsSiliceController = TextEditingController();
  }

  @override
  void dispose() {
    commentController.dispose();
    sacsMantoController.dispose();
    sacsSottomantoController.dispose();
    sacsSiliceController.dispose();
    super.dispose();
  }

  bool get _showSacs =>
      selectedType == 'Recharge' || selectedType == 'Travaux';

  Future<void> _saveMaintenance() async {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir un type de maintenance')),
      );
      return;
    }

    final db = ref.read(databaseProvider);

    await db.addMaintenance(
      terrainId: widget.terrainId,
      type: selectedType!,
      commentaire: commentController.text,
      date: DateTime.now(),
      sacsTerreUtilises: widget.terrainType == TerrainType.terreBattue
          ? (int.tryParse(sacsMantoController.text) ?? 0) +
              (int.tryParse(sacsSottomantoController.text) ?? 0)
          : int.tryParse(sacsSiliceController.text) ?? 0,
      sacsSableUtilises: 0,
    );

    ref.invalidate(
      maintenanceProv.maintenancesByTerrainProvider(widget.terrainId),
    );
    ref.invalidate(
      maintenanceProv.maintenanceCountProvider(widget.terrainId),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nouvelle maintenance – Terrain ${widget.terrainNumero}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedType,
            items: maintenanceTypes
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => selectedType = v),
            decoration: const InputDecoration(labelText: 'Type'),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: commentController,
            decoration: const InputDecoration(labelText: 'Commentaire'),
          ),

          if (_showSacs) ...[
            const SizedBox(height: 12),
            if (widget.terrainType == TerrainType.terreBattue) ...[
              TextField(
                controller: sacsMantoController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Sacs Manto'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sacsSottomantoController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Sacs Sottomanto'),
              ),
            ] else ...[
              TextField(
                controller: sacsSiliceController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Sacs Silice'),
              ),
            ],
          ],

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _saveMaintenance,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
