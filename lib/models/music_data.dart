class MusicData {
  MusicData({
    required this.strum,
    required this.clock,
    required this.bars,
  });

  factory MusicData.fromJson(Map<String, dynamic> json) {
    return MusicData(
      strum: json['strum'],
      clock: List<num>.from(json['clock']),
      bars: (json['bars'] as List).map((e) => Bar.fromJson(e)).toList(),
    );
  }

  final String strum;
  final List<num> clock;
  final List<Bar> bars;
}

extension ListBarExtension<T> on List<T> {
  T? safeIndex(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }

    return null;
  }
}

class Bar {
  Bar({required this.events});

  factory Bar.fromJson(Map<String, dynamic> json) {
    return Bar(
      events: (json['events'] as List).map((e) => Event.fromJson(e)).toList(),
    );
  }

  final List<Event> events;
}

class Event {
  Event({
    required this.type,
    required this.position,
    this.content,
    this.name,
    this.text,
    this.wordId,
    required this.start,
    required this.duration,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      type: EventType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => EventType.unknown,
      ),
      content: json['content'] != null
          ? EventContent.fromJson(json['content'])
          : null,
      name: json['name'],
      position: (json['position'] as num?)?.toDouble() ?? 0,
      text: json['text'],
      wordId: json['wordId'],
      start: (json['start'] as num?)?.toDouble() ?? 0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
    );
  }

  final EventType type;
  final EventContent? content;
  final String? name;
  final double position;
  final String? text;
  final int? wordId;

  final double start;
  final double duration;
}

class EventContent {
  EventContent({
    required this.type,
    this.meter,
    this.partName,
  });

  factory EventContent.fromJson(Map<String, dynamic> json) {
    return EventContent(
      type: json['type'],
      meter: json['meter'],
      partName: json['partName'],
    );
  }

  final String type;
  final String? meter;
  final String? partName;
}

enum EventType {
  countIn,
  meta,
  chord,
  lyric,
  unknown,
}
