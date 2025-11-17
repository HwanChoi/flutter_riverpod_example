import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_demo/music_player/data/songs.dart';
import 'package:flutter_application_demo/music_player/models/song.dart';
import 'package:flutter_application_demo/music_player/providers/i_audio_player.dart'; // Import IAudioPlayer

// Adapter to make AudioPlayer conform to IAudioPlayer
class AudioPlayerAdapter implements IAudioPlayer {
  final AudioPlayer _audioPlayer;

  AudioPlayerAdapter(this._audioPlayer);

  @override
  Future<void> setSource(Source source) => _audioPlayer.setSource(source);

  @override
  Future<void> resume() => _audioPlayer.resume();

  @override
  Future<void> pause() => _audioPlayer.pause();

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> dispose() => _audioPlayer.dispose();

  @override
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;

  @override
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  @override
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;

  @override
  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;
}

@immutable
class AudioPlayerState {
  const AudioPlayerState({
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.currentSong,
    this.playlist = const [],
    this.currentIndex = 0,
  });

  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final Song? currentSong;
  final List<Song> playlist;
  final int currentIndex;

  AudioPlayerState copyWith({
    bool? isPlaying,
    Duration? duration,
    Duration? position,
    Song? currentSong,
    List<Song>? playlist,
    int? currentIndex,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      currentSong: currentSong ?? this.currentSong,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  AudioPlayerNotifier(this._audioPlayer) : super(const AudioPlayerState()) {
    _init();
  }

  AudioPlayerNotifier.test(this._audioPlayer) : super(const AudioPlayerState()) {
    _init();
  }

  final IAudioPlayer _audioPlayer;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _playerCompleteSubscription;

  void _init() {
    state = state.copyWith(
      playlist: songPlaylist,
      currentSong: songPlaylist.isNotEmpty ? songPlaylist[0] : null,
      currentIndex: 0,
    );

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((playerState) {
      state = state.copyWith(isPlaying: playerState == PlayerState.playing);
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      state = state.copyWith(position: position);
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      playNext();
    });

    if (state.currentSong != null) {
      _setSong(state.currentSong!);
    }
  }

  Future<void> _setSong(Song song) async {
    try {
      await _audioPlayer.setSource(AssetSource(song.audioPath));
    } catch (e) {
      debugPrint('Error setting audio source: $e');
    }
  }

  Future<void> play() async {
    if (state.currentSong != null) {
      await _audioPlayer.resume();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playSong(int index) async {
    if (index < 0 || index >= state.playlist.length) return;
    
    state = state.copyWith(currentIndex: index, currentSong: state.playlist[index]);
    await _setSong(state.currentSong!);
    await play();
  }

  Future<void> playNext() async {
    final nextIndex = (state.currentIndex + 1) % state.playlist.length;
    await playSong(nextIndex);
  }

  Future<void> playPrevious() async {
    final prevIndex = (state.currentIndex - 1 + state.playlist.length) % state.playlist.length;
    await playSong(prevIndex);
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final audioPlayerProvider = StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  final audioPlayer = AudioPlayerAdapter(AudioPlayer()); // Use the adapter
  ref.onDispose(audioPlayer.dispose);
  return AudioPlayerNotifier(audioPlayer);
});
