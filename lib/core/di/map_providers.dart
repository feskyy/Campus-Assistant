import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_assistant/features/map/domain/entities/building.dart';
import 'package:campus_assistant/features/map/presentation/campus_map_view.dart';

typedef CampusMapBuilder = CampusMapView Function(
  List<Building> buildings,
  String? selectedId,
  ValueChanged<String> onSelected,
);
final campusMapViewProvider = Provider<CampusMapBuilder>(
  (ref) =>
      (buildings, selectedId, onSelected) => CampusPlanView(
        buildings: buildings,
        selectedId: selectedId,
        onSelected: onSelected,
      ),
);

final campusMapPreviewProvider = Provider<CampusMapBuilder>(
  (ref) =>
      (buildings, selectedId, onSelected) => CampusPlanView(
        buildings: buildings,
        selectedId: selectedId,
        onSelected: onSelected,
        interactive: false,
        compact: true,
      ),
);
