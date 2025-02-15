
import 'package:accompaneo/widgets/facet_chip.dart';
import 'package:flutter/material.dart';

class PracticeTypesChip extends FacetChip {

  const PracticeTypesChip({
    super.key,
    required super.selected,
    required super.facetValueCode,
    required super.facetValueName,
    super.showCheckmark,
    super.facetValueCount,
    super.onSelected,
    super.onDeleted
  });

  @override
  Widget? getAvatar() {
    return selected ? Icon(getIcon()) : Container();
  }

  @override
  Widget getLabel() {
    return facetValueCount != null ? Text('$facetValueName ($facetValueCount)') : Text(facetValueName);
  }

  IconData getIcon() {
    if (facetValueName == 'Band And Vocals') {
      return Icons.mic_external_on;
    }
    if (facetValueName == "Band No Vocals") {
      return Icons.piano;
    }

    return Icons.do_not_disturb;
  }

}