import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_demo/music_player/providers/audio_player_provider.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioNotifier = ref.read(audioPlayerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          iconSize: 48.0,
          color: Colors.white,
          onPressed: audioNotifier.playPrevious,
        ),
        IconButton(
          icon: Icon(
            audioState.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
          ),
          iconSize: 72.0,
          color: Colors.white,
          onPressed: () {
            if (audioState.isPlaying) {
              audioNotifier.pause();
            } else {
              audioNotifier.play();
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: 48.0,
          color: Colors.white,
          onPressed: audioNotifier.playNext,
        ),
      ],
    );
  }
}
