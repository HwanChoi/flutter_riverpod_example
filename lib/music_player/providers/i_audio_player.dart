import 'package:audioplayers/audioplayers.dart';

abstract class IAudioPlayer {
  Future<void> setSource(Source source);
  Future<void> resume();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> dispose();

  Stream<PlayerState> get onPlayerStateChanged;
  Stream<Duration> get onDurationChanged;
  Stream<Duration> get onPositionChanged;
  Stream<void> get onPlayerComplete;
}
