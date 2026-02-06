class Maintenance {
  final int id;
  final int terrainId;
  final String type;
  final String? commentaire;
  final DateTime date;

  final int sacsMantoUtilises;
  final int sacsSottomantoUtilises;
  final int sacsSiliceUtilises;

  Maintenance({
    required this.id,
    required this.terrainId,
    required this.type,
    this.commentaire,
    required this.date,
    this.sacsMantoUtilises = 0,
    this.sacsSottomantoUtilises = 0,
    this.sacsSiliceUtilises = 0,
  });
}
