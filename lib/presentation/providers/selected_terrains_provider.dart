import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedTerrainsNotifier extends StateNotifier<Set<int>> {
  SelectedTerrainsNotifier() : super(<int>{}); // vide => tous terrains

  void toggle(int terrainId) {
    final s = Set<int>.from(state);
    if (s.contains(terrainId)) {
      s.remove(terrainId);
    } else {
      s.add(terrainId);
    }
    state = s;
  }

  void clear() => state = <int>{}; // vide => tous
  void setAll(Iterable<int> ids) => state = ids.toSet();
}

final selectedTerrainsProvider = StateNotifierProvider<SelectedTerrainsNotifier, Set<int>>(
  (ref) => SelectedTerrainsNotifier(),
);