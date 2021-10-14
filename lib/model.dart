// To parse this JSON data, do
//
//     final soundListData = soundListDataFromJson(jsonString);

import 'dart:convert';

SoundListData soundListDataFromJson(String str) => SoundListData.fromJson(json.decode(str));

String soundListDataToJson(SoundListData data) => json.encode(data.toJson());

class SoundListData {
  SoundListData({
    this.songs,
  });

  List<Song> songs;

  factory SoundListData.fromJson(Map<String, dynamic> json) => SoundListData(
    songs: List<Song>.from(json["songs"].map((x) => Song.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "songs": List<dynamic>.from(songs.map((x) => x.toJson())),
  };
}

class Song {
  Song({
    this.id,
    this.updatedAt,
    this.createdAt,
    this.status,
    this.title,
    this.singer,
    this.playLyrics,
    this.singLyrics,
  });

  String id;
  DateTime updatedAt;
  DateTime createdAt;
  Status status;
  String title;
  String singer;
  String playLyrics;
  String singLyrics;

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json["id"],
    updatedAt: DateTime.parse(json["updatedAt"]),
    createdAt: DateTime.parse(json["createdAt"]),
    status: statusValues.map[json["status"]],
    title: json["title"],
    singer: json["singer"],
    playLyrics: json["play_lyrics"],
    singLyrics: json["sing_lyrics"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "updatedAt": updatedAt.toIso8601String(),
    "createdAt": createdAt.toIso8601String(),
    "status": statusValues.reverse[status],
    "title": title,
    "singer": singer,
    "play_lyrics": playLyrics,
    "sing_lyrics": singLyrics,
  };
}

enum Status { PENDING }

final statusValues = EnumValues({
  "pending": Status.PENDING
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
