import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_demo/music_player/providers/audio_player_provider.dart';
import 'package:flutter_application_demo/music_player/data/songs.dart';
import 'package:flutter_application_demo/music_player/models/song.dart';
import 'package:flutter_application_demo/music_player/providers/i_audio_player.dart'; // Import IAudioPlayer

// Manual Mock for IAudioPlayer
class MockAudioPlayer implements IAudioPlayer {
  bool _isActuallyPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _currentDuration = Duration.zero;
  AssetSource? _currentSource;

  // Stream controllers to simulate events
  final StreamController<PlayerState> _playerStateController = StreamController<PlayerState>.broadcast();
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<void> _playerCompleteController = StreamController<void>.broadcast();

  @override
  Future<void> setSource(Source source) async {
    _currentSource = source as AssetSource;
    // Simulate loading time or success
    _currentDuration = const Duration(minutes: 3, seconds: 30); // Default duration for testing
    _durationController.add(_currentDuration); // Use controller to add event
  }

  @override
  Future<void> resume() async {
    _isActuallyPlaying = true;
    _playerStateController.add(PlayerState.playing); // Use controller to add event
  }

  @override
  Future<void> pause() async {
    _isActuallyPlaying = false;
    _playerStateController.add(PlayerState.paused); // Use controller to add event
  }

  @override
  Future<void> seek(Duration position) async {
    _currentPosition = position;
    _positionController.add(_currentPosition); // Use controller to add event
  }

  @override
  Future<void> dispose() async {
    await _playerStateController.close();
    await _durationController.close();
    await _positionController.close();
    await _playerCompleteController.close();
  }

  @override
  Stream<PlayerState> get onPlayerStateChanged => _playerStateController.stream;

  @override
  Stream<Duration> get onDurationChanged => _durationController.stream;

  @override
  Stream<Duration> get onPositionChanged => _positionController.stream;

  @override
  Stream<void> get onPlayerComplete => _playerCompleteController.stream;

  // Helper to simulate completion
  void simulateCompletion() {
    _playerCompleteController.add(null);
  }

  // Helper to simulate position updates
  void simulatePosition(Duration position) {
    _currentPosition = position;
    _positionController.add(position);
  }

  // Helper to simulate duration updates
  void simulateDuration(Duration duration) {
    _currentDuration = duration;
    _durationController.add(duration);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter binding for tests

  group('AudioPlayerNotifier', () {
    late MockAudioPlayer mockAudioPlayer;
    late ProviderContainer container;
    late AudioPlayerNotifier notifier;

    setUp(() {
      mockAudioPlayer = MockAudioPlayer();
      container = ProviderContainer(
        overrides: [
          audioPlayerProvider.overrideWith((ref) => AudioPlayerNotifier.test(mockAudioPlayer)),
        ],
      );
      notifier = container.read(audioPlayerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(audioPlayerProvider);
      expect(state.isPlaying, false);
      expect(state.playlist, songPlaylist);
      expect(state.currentSong, songPlaylist[0]);
      expect(state.currentIndex, 0);
      // Duration should be updated by mock after setSource in _init
      expect(state.duration, const Duration(minutes: 3, seconds: 30));
      expect(state.position, Duration.zero);
    });

    test('play() resumes the audio player and updates state', () async {
      await notifier.play();
      expect(container.read(audioPlayerProvider).isPlaying, true);
    });

    test('pause() pauses the audio player and updates state', () async {
      await notifier.play(); // First play
      await notifier.pause();
      expect(container.read(audioPlayerProvider).isPlaying, false);
    });

    test('seek() seeks the audio player and updates state', () async {
      const position = Duration(seconds: 30);
      await notifier.seek(position);
      expect(container.read(audioPlayerProvider).position, position);
    });

    test('playSong() sets the current song, plays, and updates state', () async {
      // Ensure there's more than one song for playNext/Previous to work meaningfully
      // For this test, we'll just test setting the first song
      await notifier.playSong(0);

      final state = container.read(audioPlayerProvider);
      expect(state.currentIndex, 0);
      expect(state.currentSong, songPlaylist[0]);
      expect(state.isPlaying, true);
      // Duration should be updated by mock after setSource
      expect(state.duration, const Duration(minutes: 3, seconds: 30));
    });

    test('playNext() plays the next song in the playlist and updates state', () async {
      // Add a second song to the playlist for this test
      final originalPlaylist = List<Song>.from(songPlaylist);
      final testPlaylist = <Song>[
        originalPlaylist[0],
        const Song(
          title: 'Test Song 2',
          artist: 'Test Artist 2',
          albumArtPath: 'assets/images/album_art.jpg',
          audioPath: 'audio/test_sample_2.mp3',
        ),
      ];

      // Override the playlist for this specific test
      container = ProviderContainer(
        overrides: [
          audioPlayerProvider.overrideWith((ref) => AudioPlayerNotifier.test(mockAudioPlayer)),
        ],
      );
      notifier = container.read(audioPlayerProvider.notifier);
      // Manually set the playlist in the notifier's state for this test
      notifier.state = notifier.state.copyWith(playlist: testPlaylist, currentSong: testPlaylist[0], currentIndex: 0);

      await notifier.playNext();

      final state = container.read(audioPlayerProvider);
      expect(state.currentIndex, 1);
      expect(state.currentSong, testPlaylist[1]);
      expect(state.isPlaying, true);
    });

    test('playPrevious() plays the previous song in the playlist and updates state', () async {
      // Add a second song to the playlist for this test
      final originalPlaylist = List<Song>.from(songPlaylist);
      final testPlaylist = <Song>[
        originalPlaylist[0],
        const Song(
          title: 'Test Song 2',
          artist: 'Test Artist 2',
          albumArtPath: 'assets/images/album_art.jpg',
          audioPath: 'audio/test_sample_2.mp3',
        ),
      ];

      // Override the playlist for this specific test
      container = ProviderContainer(
        overrides: [
          audioPlayerProvider.overrideWith((ref) => AudioPlayerNotifier.test(mockAudioPlayer)),
        ],
      );
      notifier = container.read(audioPlayerProvider.notifier);
      // Manually set the playlist in the notifier's state for this test, starting at index 1
      notifier.state = notifier.state.copyWith(playlist: testPlaylist, currentSong: testPlaylist[1], currentIndex: 1);

      await notifier.playPrevious();

      final state = container.read(audioPlayerProvider);
      expect(state.currentIndex, 0);
      expect(state.currentSong, testPlaylist[0]);
      expect(state.isPlaying, true);
    });

    test('onPlayerComplete plays next song', () async {
      // Add a second song to the playlist for this test
      final originalPlaylist = List<Song>.from(songPlaylist);
      final testPlaylist = <Song>[
        originalPlaylist[0],
        const Song(
          title: 'Test Song 2',
          artist: 'Test Artist 2',
          albumArtPath: 'assets/images/album_art.jpg',
          audioPath: 'audio/test_sample_2.mp3',
        ),
      ];

      // Override the playlist for this specific test
      container = ProviderContainer(
        overrides: [
          audioPlayerProvider.overrideWith((ref) => AudioPlayerNotifier.test(mockAudioPlayer)),
        ],
      );
      notifier = container.read(audioPlayerProvider.notifier);
      notifier.state = notifier.state.copyWith(playlist: testPlaylist, currentSong: testPlaylist[0], currentIndex: 0);

      // Simulate completion
      mockAudioPlayer.simulateCompletion();
      await Future.delayed(Duration.zero); // Allow event to propagate

      final state = container.read(audioPlayerProvider);
      expect(state.currentIndex, 1);
      expect(state.currentSong, testPlaylist[1]);
      expect(state.isPlaying, true);
    });
  });
}