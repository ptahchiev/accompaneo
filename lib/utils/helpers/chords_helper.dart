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
  Amaj7,
  Bmaj7,
  Cmaj7,
  Dmaj7,
  Emaj7,
  Fmaj7,
  Gmaj7,
  UNKNOWN
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

  static const Map<ChordType, Color> chordTypeColors = {
    ChordType.A: Colors.blueGrey,
    ChordType.B: Colors.purple,
    ChordType.C: Colors.red,
    ChordType.D: Colors.orange,
    ChordType.E: Colors.brown,
    ChordType.F: Colors.blue,
    ChordType.G: Colors.green,
    ChordType.Am: Colors.blueGrey,
    ChordType.Bm: Colors.purple,
    ChordType.Cm: Colors.red,
    ChordType.Dm: Colors.orange,
    ChordType.Em: Colors.brown,
    ChordType.Fm: Colors.blue,
    ChordType.Gm: Colors.green,
    ChordType.Ab: Colors.blueGrey,
    ChordType.Bb: Colors.purple,
    ChordType.Cb: Colors.red,
    ChordType.Db: Colors.orange,
    ChordType.Eb: Colors.brown,
    ChordType.Fb: Colors.blue,
    ChordType.Gb: Colors.green,
    ChordType.A7: Colors.blueGrey,
    ChordType.B7: Colors.purple,
    ChordType.C7: Colors.red,
    ChordType.D7: Colors.orange,
    ChordType.E7: Colors.brown,
    ChordType.F7: Colors.blue,
    ChordType.G7: Colors.green,
    ChordType.UNKNOWN: Colors.grey
  };

  static const Map<ChordType, FlutterGuitarChord> chordTypeOptions = {
    ChordType.A: A,
    ChordType.B: B,
    ChordType.C: C,
    ChordType.D: D,
    ChordType.E: E,
    ChordType.F: F,
    ChordType.G: G,
    ChordType.Am: Am,
    ChordType.Bm: Bm,
    ChordType.Cm: Cm,
    ChordType.Dm: Dm,
    ChordType.Em: Em,
    ChordType.Fm: Fm,
    ChordType.Gm: Gm,
    ChordType.Ab: Ab,
    ChordType.Bb: Bb,
    //ChordType.Cb: Cb,
    ChordType.Db: Db,
    //ChordType.Eb: Eb,
    //ChordType.Fb: Fb,
    //ChordType.Gb: Gb,
    //ChordType.A7: A7,
    ChordType.B7: B7,
    ChordType.C7: C7,
    ChordType.D7: D7,
    ChordType.E7: E7,
    ChordType.F7: F7,
    //ChordType.G7: G7,

    ChordType.UNKNOWN: UNKNOWN,
  };

  static const FlutterGuitarChord MISSING = FlutterGuitarChord(
    baseFret: 1,
    chordName: '?',
    fingers: '0 0 0 0 0 0',
    frets: '0 0 0 0 0 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.black,
  );

  static const FlutterGuitarChord A = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'A',
    fingers: '0 0 2 1 3 0',
    frets: '-1 0 2 2 2 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.blueGrey,
  );

  static const FlutterGuitarChord B = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'B',
    fingers: '0 1 2 3 4 1',
    frets: '-1 2 4 4 4 2',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.purple,
  );

  static const FlutterGuitarChord C = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'C',
    fingers: '0 3 2 0 1 0',
    frets: '-1 3 2 0 1 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.red,
  );

  static const FlutterGuitarChord D = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'D',
    fingers: '0 0 0 1 3 2',
    frets: '-1 -1 0 2 3 2',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.orange,
  );

  static const FlutterGuitarChord E = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'E',
    fingers: '0 2 3 1 0 0',
    frets: '0 2 2 1 0 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.brown,
  );

  static const FlutterGuitarChord F = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'F',
    fingers: '1 3 4 2 1 1',
    frets: '1 3 3 2 1 1',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.blue,
  );

  static const FlutterGuitarChord G = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'G',
    fingers: '2 1 0 0 0 3',
    frets: '3 2 0 0 0 3',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.green,
  );

  static const FlutterGuitarChord Am = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Am',
    fingers: '0 0 2 3 1 0',
    frets: '-1 0 2 2 1 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.blueGrey,
  );

  static const FlutterGuitarChord Bm = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Bm',
    fingers: '0 1 3 4 2 1',
    frets: '-1 2 4 4 3 2',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.purple,
  );

  static const FlutterGuitarChord Cm = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Cm',
    fingers: '0 3 2 0 1 0',
    frets: '-1 3 2 0 1 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.red,
  );

  static const FlutterGuitarChord Dm = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Dm',
    fingers: '0 0 0 2 4 1',
    frets: '-1 -1 0 2 3 1',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.orange,
  );

  static const FlutterGuitarChord Em = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Em',
    fingers: '0 2 3 0 0 0',
    frets: '0 2 2 0 0 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.brown,
  );

  static const FlutterGuitarChord Fm = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Fm',
    fingers: '0 3 2 0 1 0',
    frets: '-1 3 2 0 1 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.blue,
  );

  static const FlutterGuitarChord Gm = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Gm',
    fingers: '0 3 2 0 1 0',
    frets: '-1 3 2 0 1 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.green,
  );

  static const FlutterGuitarChord Ab = FlutterGuitarChord(
    baseFret: 4,
    chordName: 'Ab',
    fingers: '1 3 4 2 1 1',
    frets: '1 3 3 2 1 1',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.blueGrey,
  );

  static const FlutterGuitarChord Bb = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Bb',
    fingers: '0 1 2 3 4 1',
    frets: '-1 1 3 3 3 1',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.purple,
  );

  static const FlutterGuitarChord Db = FlutterGuitarChord(
    baseFret: 4,
    chordName: 'Db',
    fingers: '0 1 2 3 4 1',
    frets: '-1 1 3 3 3 1',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.orange,
  );

  static const FlutterGuitarChord B7 = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'B7',
    fingers: '0 2 1 3 0 4',
    frets: '-1 2 1 2 0 2',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.purple,
  );

  static const FlutterGuitarChord C7 = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'C7',
    fingers: '0 3 2 4 1 0',
    frets: '-1 3 2 3 1 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.red,
  );

  static const FlutterGuitarChord D7 = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'D7',
    fingers: '0 0 0 2 1 3',
    frets: '-1 -1 0 2 1 2',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.orange,
  );

  static const FlutterGuitarChord E7 = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'E7',
    fingers: '0 2 0 1 0 0',
    frets: '0 2 0 1 0 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.brown,
  );

  static const FlutterGuitarChord Em7 = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Em7',
    fingers: '0 1 2 0 3 0',
    frets: '0 2 2 0 3 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.brown,
  );

  static const FlutterGuitarChord F7 = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'F7',
    fingers: '0 0 3 2 1 0',
    frets: '-1 -1 3 2 1 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.blue,
  );

  static const FlutterGuitarChord Bbm = FlutterGuitarChord(
    baseFret: 1,
    chordName: 'Bbm',
    fingers: '0 1 3 4 2 1',
    frets: '-1 1 3 3 2 1',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.purple,
  );

  static const FlutterGuitarChord CSharpm = FlutterGuitarChord(
    baseFret: 4,
    chordName: 'C#m',
    fingers: '0 1 3 4 2 1',
    frets: '-1 1 3 3 2 1',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.red,
  );

  static const FlutterGuitarChord UNKNOWN = FlutterGuitarChord(
    baseFret: 4,
    chordName: '',
    fingers: '0 0 0 0 0 0',
    frets: '0 0 0 0 0 0',
    totalString: 6,
    labelColor: AppColors.primaryColor,
    showLabel: false,
    tabForegroundColor: Colors.white,
    tabBackgroundColor: Colors.red,
  );
}
