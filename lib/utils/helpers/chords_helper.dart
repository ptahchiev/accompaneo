import 'package:accompaneo/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guitar_chord/flutter_guitar_chord.dart';

enum ChordType {
  A,
  B,
  C,
  D,
  E,
  F,
  G,
  Am,
  Bm,
  Cm,
  Dm,
  Em,
  Fm,
  Gm,
  Ab,
  Bb,
  Cb,
  Db,
  Eb,
  Fb,
  Gb,
  A5,
  B5,
  C5,
  D5,
  E5,
  F5,
  G5,
  A7,
  B7,
  C7,
  D7,
  E7,
  F7,
  G7,
  Asus2,
  UNKNOWN
}

class AccompaneoChord {
  final String prefix;

  final String suffix;

  final Color color;

  const AccompaneoChord(this.prefix, this.suffix, this.color);
}


class ChordsHelper {
  const ChordsHelper._();

  static ChordType stringToChord(String chordName) {
    try {
      return ChordType.values
          .firstWhere((e) => e.toString() == 'ChordType.$chordName');
    } catch (e) {
      return ChordType.UNKNOWN;
    }
  }

  static const Map<ChordType, AccompaneoChord> accompaneoChords = {
    ChordType.A: AccompaneoChord("A", "major", Colors.blueGrey),
    ChordType.B: AccompaneoChord("B", "major", Colors.purple),
    ChordType.C: AccompaneoChord("C", "major", Colors.red),
    ChordType.D: AccompaneoChord("D", "major",Colors.orange),
    ChordType.E: AccompaneoChord("E", "major",Colors.brown),
    ChordType.F:AccompaneoChord("F", "major", Colors.blue),
    ChordType.G:AccompaneoChord("G", "major", Colors.green),
    ChordType.Am: AccompaneoChord("A", "minor",Colors.blueGrey),
    ChordType.Bm: AccompaneoChord("B", "minor", Colors.purple),
    ChordType.Cm:AccompaneoChord("C", "minor", Colors.red),
    ChordType.Dm:AccompaneoChord("D", "minor", Colors.orange),
    ChordType.Em:AccompaneoChord("E", "minor", Colors.brown),
    ChordType.Fm:AccompaneoChord("F", "minor", Colors.blue),
    ChordType.Gm:AccompaneoChord("G", "minor", Colors.green),
    ChordType.Ab: AccompaneoChord("Ab", "major",Colors.blueGrey),
    ChordType.Bb:AccompaneoChord("Bb", "major", Colors.purple),
    ChordType.Cb:AccompaneoChord("Cb", "major", Colors.red),
    ChordType.Db:AccompaneoChord("Db", "major", Colors.orange),
    ChordType.Eb:AccompaneoChord("Eb", "major", Colors.brown),
    ChordType.Fb:AccompaneoChord("Fb", "major", Colors.blue),
    ChordType.Gb:AccompaneoChord("Gb", "major", Colors.green),
    ChordType.A7: AccompaneoChord("A", "7",Colors.blueGrey),
    ChordType.B7:AccompaneoChord("A", "7", Colors.purple),
    ChordType.C7:AccompaneoChord("B", "7", Colors.red),
    ChordType.D7:AccompaneoChord("C", "7", Colors.orange),
    ChordType.E7:AccompaneoChord("D", "7", Colors.brown),
    ChordType.F7:AccompaneoChord("E", "7", Colors.blue),
    ChordType.G7:AccompaneoChord("F", "7", Colors.green),
    ChordType.Asus2:AccompaneoChord("A", "sus2", Colors.blueGrey),
    ChordType.UNKNOWN: AccompaneoChord("A", "7",Colors.grey)
  };
}
