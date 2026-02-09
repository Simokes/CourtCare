import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/terrain.dart';
import '../../domain/entities/maintenance.dart';
import '../providers/maintenance_provider.dart' as maintenance_prov;

class AddMaintenanceSheet extends ConsumerStatefulWidget {
  final int terrainNumero;
  final int terrainId;
  final TerrainType terrainType;

  /// Mode édition : maintenance existante
  final Maintenance? existing;

  const AddMaintenanceSheet({
    super.key,
    required this.terrainNumero,
    required this.terrainId,
    required this.terrainType,
    this.existing,
  });

  @override
  ConsumerState<AddMaintenanceSheet> createState() =>
      _AddMaintenanceSheetState();
}

class _AddMaintenanceSheetState extends ConsumerState<AddMaintenanceSheet> {
  // UI State
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

    // MODE ÉDITION : pré-remplissage
    if (widget.existing != null) {
      final m = widget.existing!;
      selectedType = m.type;
      commentController.text = m.commentaire ?? '';
      sacsMantoController.text = m.sacsMantoUtilises.toString();
      sacsSottomantoController.text = m.sacsSottomantoUtilises.toString();
      sacsSiliceController.text = m.sacsSiliceUtilises.toString();
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    sacsMantoController.dispose();
    sacsSottomantoController.dispose();
    sacsSiliceController.dispose();
    super.dispose();
  }

  bool get _showSacs => selectedType == 'Recharge' || selectedType == 'Travaux';

  Future<void> _saveMaintenance() async {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez choisir un type de maintenance')),
      );
      return;
    }

    final manto = int.tryParse(sacsMantoController.text) ?? 0;
    final sotto = int.tryParse(sacsSottomantoController.text) ?? 0;
    final silice = int.tryParse(sacsSiliceController.text) ?? 0;

    try {
      final notifier = ref.read(maintenance_prov.maintenanceProvider.notifier);

      if (widget.existing == null) {
        /// MODE CRÉATION
        await notifier.addMaintenance(
          terrainId: widget.terrainId,
          terrainType: widget.terrainType,
          type: selectedType!,
          commentaire:
              commentController.text.isEmpty ? null : commentController.text,
          sacsMantoUtilises: manto,
          sacsSottomantoUtilises: sotto,
          sacsSiliceUtilises: silice,
        );
      } else {
        /// MODE ÉDITION
        await notifier.updateMaintenance(
          existing: widget.existing!,
          type: selectedType!,
          commentaire:
              commentController.text.isEmpty ? null : commentController.text,
          sacsMantoUtilises: manto,
          sacsSottomantoUtilises: sotto,
          sacsSiliceUtilises: silice,
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('❌ Erreur enregistrement : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l’enregistrement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

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
            isEditing
                ? 'Modifier maintenance – Terrain ${widget.terrainNumero}'
                : 'Nouvelle maintenance – Terrain ${widget.terrainNumero}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          /// TYPE
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

          /// COMMENTAIRE
          TextField(
            controller: commentController,
            decoration: const InputDecoration(labelText: 'Commentaire'),
          ),

          /// MATÉRIAUX (si type = recharge / travaux)
          if (_showSacs) ...[
            const SizedBox(height: 12),
            if (widget.terrainType == TerrainType.terreBattue) ...[
              TextField(
                controller: sacsMantoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sacs Manto'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sacsSottomantoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sacs Sottomanto'),
              ),
            ] else ...[
              TextField(
                controller: sacsSiliceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sacs Silice'),
              ),
            ],
          ],

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _saveMaintenance,
            child: Text(isEditing ? 'Mettre à jour' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }
}
