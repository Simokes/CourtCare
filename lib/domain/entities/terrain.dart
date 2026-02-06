enum TerrainType {
  terreBattue,
  synthetique,
}

enum TerrainStatut {
  ouvert,
  ferme,
  maintenance,
  pluie, // ajouté
  gel, // si tu veux gérer le gel
  travaux, // si tu veux gérer travaux
}

class Terrain {
  final int id;
  final int numero;
  final TerrainType type;
  final TerrainStatut statut;

  Terrain({
    required this.id,
    required this.numero,
    required this.type,
    required this.statut,
  });
}
