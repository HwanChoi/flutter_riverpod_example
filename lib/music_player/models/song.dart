import 'package:flutter/foundation.dart';

@immutable
class Song {
  const Song({
    required this.title,
    required this.artist,
    required this.albumArtPath,
    required this.audioPath,
  });

  final String title;
  final String artist;
  final String albumArtPath;
  final String audioPath;
}
