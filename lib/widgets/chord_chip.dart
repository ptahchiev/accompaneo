
import 'package:accompaneo/models/facet_value.dart';
import 'package:accompaneo/utils/helpers/chords_helper.dart';
import 'package:flutter/material.dart';

class ChordChip extends StatelessWidget {

  final bool selected;

  final FacetValueDto facetValue;

  final ValueChanged<bool>? onSelected;

  final VoidCallback? onDeleted;

  const ChordChip({
    super.key,
    required this.selected,
    required this.facetValue,
    this.onSelected,
    this.onDeleted
  });


  @override
  Widget build(BuildContext context) {
    return InputChip(
      isEnabled: true,
      selected: selected,
      avatar: onDeleted != null ? null : CircleAvatar(backgroundColor: getChordColor(facetValue.name), child: Text('')),
      label: onDeleted != null ? Container(decoration: BoxDecoration(color: getChordColor(facetValue.code),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ), child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(facetValue.code, style: TextStyle(color: Colors.white)))) : Text('${facetValue.name} (${facetValue.count})'),
      showCheckmark: onDeleted == null,
      checkmarkColor: Colors.white,
      side: BorderSide(color: selected ? Colors.grey : Colors.grey.shade400),
      onSelected: onSelected,
      onDeleted: onDeleted
    );
  }

  Color? getChordColor(String chord) {
    return ChordsHelper.chordTypeColors[ChordType.values.firstWhere((e) => e.toString() == 'ChordType.${chord}', orElse: () => ChordType.UNKNOWN)];
  }
}