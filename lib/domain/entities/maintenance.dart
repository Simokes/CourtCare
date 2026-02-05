class Maintenance {
  final int id;
  final int terrainId;
  final String type;
  final String? commentaire;
  final DateTime date;

  final int sacsTerreUtilises; // manto + sottomanto OU silice
  final int sacsSableUtilises;

  Maintenance({
    required this.id,
    required this.terrainId,
    required this.type,
    this.commentaire,
    required this.date,
    required this.sacsTerreUtilises,
    required this.sacsSableUtilises,
  });
}
