
import 'package:accompaneo/utils/helpers/chords_helper.dart';
import 'package:accompaneo/widgets/facet_chip.dart';
import 'package:flutter/material.dart';

class ChordChip extends FacetChip {

  const ChordChip({
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
    return onDeleted != null ? null : CircleAvatar(backgroundColor: getChordColor(facetValueName), child: Text(''));
  }

  @override getLabel() {
    return onDeleted != null ? Container(decoration: BoxDecoration(color: getChordColor(facetValueName),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ), child: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(facetValueName, style: TextStyle(color: Colors.white)))) : Text('$facetValueName ($facetValueCount)');
  }

  Color? getChordColor(String chord) {
    ChordType chordType = ChordType.values.firstWhere((e) => e.toString() == 'ChordType.$chord', orElse: () => ChordType.UNKNOWN);
    AccompaneoChord? ac = ChordsHelper.accompaneoChords[chordType];
    if (ac == null) {
      return Colors.black;
    }

    return ac.color;
  }
}